#!/usr/bin/env python
# -*- coding:utf-8 -*-

from gevent import monkey
from gevent import queue
monkey.patch_all()
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
BUILD_DIR = '/data/release_download'
ARTIFACT_URL = ('https://gitlab.com/koreader/nightly-builds'
                '/builds/%s/artifacts/download')
nightly_build_dir = '%s/nightly' % BUILD_DIR
# Matching:
# koreader-ubuntu-touch-arm-linux-gnueabihf-v2015.11-640-g17e9a8e.targz
# koreader-android-arm-linux-androideabi-v2015.11-654-gb7392f7.apk
artifact_re = re.compile(
    '.*/koreader-.*-v[0-9]{4}.[0-9]{2}-[0-9]+-g[0-9a-z]{7}\.[a-z]+.*')
version_re = re.compile(
    'koreader-.*-(v[0-9]{4}.[0-9]{2}-[0-9]+-g[0-9a-z]{7})\.[a-z]+')


def trigger_build():
    repo = 'koreader%2Fnightly-builds'
    trigger_url = 'https://gitlab.com/api/v3/projects/%s/trigger/builds' % repo
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
    # TODO: move to apk signature scheme v2 for faster install in
    # android N
    logger.info('Signing %s...', apk_path)
    re = gevent.subprocess.check_output(
        ['jarsigner', '-verbose', '-sigalg', 'SHA1withRSA',
            '-digestalg', 'SHA1', '-tsa', 'http://timestamp.digicert.com',
            '-keystore', APK_SIGN_KEY_STORE_PATH,
            '-keypass', APK_SIGN_KEY_PASS,
            '-storepass', APK_SIGN_STORE_PASS,
            apk_path, 'koreader_release'])
    logger.info('Output from jarsigner:\n%s', re)


def extract_build(zip_name, build):
    try:
        zf = zipfile.ZipFile(zip_name)
    except zipfile.BadZipfile:
        # caller is responsible for removing the zipfile
        logger.error('Got invalid zip file: %s', zip_name)
        return

    artifacts = [os.path.basename(f.strip())
                 for f in zf.namelist()
                 if artifact_re.match(f)]
    zf.close()
    if not artifacts:
        return

    version = version_re.match(artifacts[0]).group(1)
    version_dir = '%s/%s/' % (nightly_build_dir, version)
    if all([os.path.exists(version_dir+fname) for fname in artifacts]):
        logger.info('Skipping because build already extracted.')
        return

    if build['name'] == 'build_android':
        tmp_version_dir = '%s/tmp-%s' % (TMP_DATA_DIR, version)
        # -n for no overwrite, -j for junk path
        unzip_cmd = ['unzip', '-n', '-j', '-d', tmp_version_dir, zip_name]
        run_cmd(unzip_cmd)
        # android build needs extra signing
        sign_apk(os.path.join(
            tmp_version_dir,
            'koreader-android-arm-linux-androideabi-%s.apk' % version
        ))
        if not os.path.exists(version_dir):
            os.mkdir(version_dir)
        for artifact in artifacts:
            shutil.copy2(os.path.join(tmp_version_dir, artifact), version_dir)
        shutil.rmtree(tmp_version_dir)
    else:
        # -n for no overwrite, -j for junk path
        unzip_cmd = ['unzip', '-n', '-j', '-d', version_dir, zip_name]
        run_cmd(unzip_cmd)


def fetch_build(build):
    logger.info('Fetching artifacts for build %s(%s): %s',
                build['name'], build['id'], build['artifacts_file'])
    zip_name = '%s/%s_artifacts.zip' % (TMP_DATA_DIR, build['id'])
    # -C - for continue download from dropped off
    retcode = run_cmd(['curl', '--retry', '3', '-C', '-',
                       ARTIFACT_URL % build['id'], '-o', zip_name])
    if retcode != 0:
        logger.error('Failed to download build %s(%s)',
                     build['name'], build['id'])
    else:
        extract_build(zip_name, build)
    os.remove(zip_name)


def fetch_build_worker():
    if not os.path.exists(nightly_build_dir):
        os.mkdir(nightly_build_dir)
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
                logger.info('Processing build %s(%s), status: %s...',
                            build['name'], build['id'], build['status'])
                if build['status'] != 'success':
                    continue
                build_fetch_queue.put(build)
        resp.body = '["ok"]'


def init():
    gevent.spawn(fetch_build_worker)
    gevent.spawn(trigger_build)


api = falcon.API()
api.add_route('/webhooks/gitlab-pipeline', PipeLine())
init()
