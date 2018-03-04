#!/usr/bin/env python
# -*- coding:utf-8 -*-

from gevent import monkey
from gevent import queue
monkey.patch_all()  # NOQA
from streql import equals
import gevent
import falcon
import ujson
import os
import logging
import re
import zipfile
import requests
from datetime import datetime, timedelta
import shutil

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s %(name)s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)
build_fetch_queue = queue.Queue()


APK_SIGN_KEY_PASS = os.environ['APK_SIGN_KEY_PASS']
APK_SIGN_STORE_PASS = os.environ['APK_SIGN_STORE_PASS']
GITLAB_TOKEN = os.environ['GITLAB_WEBHOOK_TOKEN']
GITLAB_TRIGGER_TOKEN = os.environ['GITLAB_TRIGGER_TOKEN']
TMP_DATA_DIR = os.environ.get('TMP_DATA_DIR', '/data')
APK_SIGN_KEY_STORE_PATH = os.environ['APK_SIGN_KEY_STORE_PATH']
OTA_DIR = '/data/ota/'
BUILD_DIR = '/data/release_download/'
ARTIFACT_URL = ('https://gitlab.com/koreader/nightly-builds'
                '/-/jobs/%s/artifacts/download')
NIGHTLY_BUILD_DIR = BUILD_DIR + 'nightly'
STABLE_BUILD_DIR = BUILD_DIR + 'stable'
# Matching:
# koreader-ubuntu-touch-arm-linux-gnueabihf-v2015.11-640-g17e9a8e.targz
# koreader-android-arm-linux-androideabi-v2015.11-654-gb7392f7.apk
artifact_re = re.compile(
    ('.*/koreader-([a-z\-]+)-(?:arm|i686)-.*-'
     'v[0-9]{4}.[0-9]{2}-[0-9]+-g[0-9a-z]{7}\.([a-z]+).*'))
version_re = re.compile(
    'koreader-.*-(v[0-9]{4}.[0-9]{2}-[0-9]+-g[0-9a-z]{7})\.[a-z]+')


def trigger_build():
    repo = 'koreader%2Fnightly-builds'
    trigger_url = 'https://gitlab.com/api/v4/projects/%s/trigger/pipeline' % repo
    while True:
        now = datetime.now()
        next_build_time = now.replace(hour=6, minute=0, second=0)
        if now > next_build_time:
            next_build_time = next_build_time + timedelta(days=1)
        wait_time = (next_build_time - now).seconds
        logger.info('Will trigger next nightly build in %s minutes.',
                    wait_time/60)
        gevent.sleep(wait_time)
        re = requests.post(trigger_url,
                           data={'token': GITLAB_TRIGGER_TOKEN,
                                 'ref': 'master'})
        logger.info('New nightly build triggered: %s', re.status_code)
        gevent.sleep(1)


def run_cmd(cmd):
    logger.info('Running command: %s', ' '.join(cmd))
    return gevent.subprocess.call(cmd)


def sign_apk(apk_path):
    # TODO: move to apk signature scheme v2 for faster install on
    # android N
    logger.info('Removing existing debug signature from %s...', apk_path)
    run_cmd(['zip', '-d', apk_path, 'META-INF/*'])

    logger.info('Signing %s...', apk_path)
    re = gevent.subprocess.check_output(
        ['jarsigner', '-verbose', '-sigalg', 'SHA1withRSA',
         '-digestalg', 'SHA1', '-tsa', 'http://timestamp.digicert.com',
         '-keystore', APK_SIGN_KEY_STORE_PATH,
         '-keypass', APK_SIGN_KEY_PASS,
         '-storepass', APK_SIGN_STORE_PASS,
         apk_path, 'koreader_release'])
    logger.info('Output from jarsigner:\n%s', re)

    aligned_apk_path = apk_path + '_apligned'
    run_cmd(['zipalign', '-v', '4', apk_path, aligned_apk_path])

    run_cmd(['mv', '-f', aligned_apk_path, apk_path])


def get_artifact_metadata(artifact_zip):
    try:
        zf = zipfile.ZipFile(artifact_zip)
    except zipfile.BadZipfile:
        logger.exception('Got invalid zip file: %s', artifact_zip)
        return None, None

    platform = None
    artifact = {}
    for f in zf.namelist():
        m = artifact_re.match(f)
        if not m:
            continue
        platform, ftype = m.groups()
        artifact[ftype] = os.path.basename(f.strip())

    zf.close()
    return platform, artifact


download_artifact_ext_map = {
    'build_android': 'apk',
    'build_android_x86': 'apk',
    'build_ubuntutouch': 'click',
}

ota_models = frozenset(['build_kindle', 'build_legacy_kindle',
                        'build_kobo', 'build_pocketbook'])


def extract_build(artifact_zip, build):
    # caller is responsible for removing artifact_zip
    platform, artifact = get_artifact_metadata(artifact_zip)
    if not platform or not artifact_zip:
        logger.error(
            'Invalid build artifact, failed to extract metadata from zipfile.')
        return

    # validate artifact_zip
    if 'targz' not in artifact:
        logger.error('Invalid build artifact, missing targz file.')
        return
    download_artifact_ext = download_artifact_ext_map.get(build['name'], 'zip')
    if download_artifact_ext not in artifact:
        logger.error('Invalid build artifact, missing %s file.',
                     download_artifact_ext)
        return

    # check to see if we already have the build
    version = version_re.match(artifact['targz']).group(1)
    version_dir = '%s/%s/' % (NIGHTLY_BUILD_DIR, version)

    download_artifact = artifact[download_artifact_ext]
    download_artifact_path = version_dir + download_artifact
    if os.path.exists(download_artifact_path):
        logger.info('Skipping because %s already exists.',
                    download_artifact_path)
        return

    if not os.path.exists(version_dir):
        os.mkdir(version_dir)

    # unzip to tmp directory
    tmp_version_dir = '%s/tmp-%s-%s/' % (TMP_DATA_DIR, platform, version)
    # -n for no overwrite, -j for junk path
    unzip_cmd = ['unzip', '-n', '-j', '-d', tmp_version_dir, artifact_zip]
    run_cmd(unzip_cmd)

    tmp_artifact_path = tmp_version_dir + download_artifact
    tmp_targz_path = tmp_version_dir + artifact['targz']
    if build['name'].startswith('build_android'):
        sign_apk(tmp_artifact_path)
    shutil.move(tmp_artifact_path, download_artifact_path)
    # also make a copy of targz for rebuilding zsync index if needed
    shutil.copy2(tmp_targz_path, version_dir)

    # build zsync metadata for kindle, kobo and pocketbook OTA
    if build['name'] in ota_models:
        # FIXME: check verion in latest-nightly and skip old versions
        zsync_file = OTA_DIR + ('koreader-%s-latest-nightly.zsync' % platform)
        shutil.move(tmp_targz_path, OTA_DIR)
        run_cmd(['zsyncmake', OTA_DIR + artifact['targz'],
                 '-u', artifact['targz'], '-o', zsync_file])
        # TODO: find the new targz file by reading the second line of zsync
        # file, then purge the old targzs

    shutil.rmtree(tmp_version_dir)


def fetch_build(build):
    logger.info('Fetching artifacts for build %s(%s): %s',
                build['name'], build['id'], build['artifacts_file'])
    artifact_zip = '%s/%s_artifacts.zip' % (TMP_DATA_DIR, build['id'])
    # `-C -` for continue download from dropped off
    # `-L` to follow redirects
    retcode = run_cmd(['curl', '--retry', '3', '-C', '-', '-L',
                       ARTIFACT_URL % build['id'], '-o', artifact_zip])
    if retcode != 0:
        logger.error('Failed to download build %s(%s)',
                     build['name'], build['id'])
    else:
        extract_build(artifact_zip, build)
    os.remove(artifact_zip)


def fetch_build_worker():
    if not os.path.exists(NIGHTLY_BUILD_DIR):
        os.mkdir(NIGHTLY_BUILD_DIR)
    if not os.path.exists(STABLE_BUILD_DIR):
        os.mkdir(STABLE_BUILD_DIR)
    while True:
        logger.info('Fetch build worker waiting for new builds....')
        gevent.spawn(fetch_build, build_fetch_queue.get()).join(timeout=60)


class PipeLine():
    def on_post(self, req, resp):
        token = req.headers.get('X-GITLAB-TOKEN')
        if not token or not equals(token, GITLAB_TOKEN):
            raise falcon.HTTPBadRequest('Yoyo', '')

        try:
            data = ujson.load(req.stream)
        except:
            raise falcon.HTTPBadRequest('Bad body', '')
        logger.debug('Got webhook request: %s', data)

        if data['object_kind'] != 'pipeline':
            resp.body = '["meh"]'
            return

        commit = data['commit']
        attributes = data['object_attributes']
        status = attributes['status']
        logger.info('Processing pipeline event %s, status: %s, commit: %s, '
                    'commit message:\n%s',
                    attributes['id'], status, commit['id'], commit['message'])

        if status == 'success' or status == 'failed':
            # build finished, download as many artifacts as possible
            for build in data['builds']:
                if not build['name'].startswith('build_'):
                    logger.debug('Skipping non-build job %s(%s), status: %s...',
                                 build['name'], build['id'], build['status'])
                    continue
                logger.info('Processing build %s(%s), status: %s...',
                            build['name'], build['id'], build['status'])
                if build['status'] != 'success':
                    continue
                build_fetch_queue.put(build)
        resp.body = '["ok"]'


def init():
    gevent.spawn(fetch_build_worker)
    gevent.spawn(trigger_build)
    # TODO: purge old nightly targz


api = falcon.API()
api.add_route('/webhooks/gitlab-pipeline', PipeLine())
init()
