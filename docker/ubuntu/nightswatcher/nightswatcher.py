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

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s %(name)s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)
build_fetch_queue = queue.Queue()


GITLAB_TOKEN = os.environ['GITLAB_WEBHOOK_TOKEN']
GITLAB_TRIGGER_TOKEN = os.environ['GITLAB_TRIGGER_TOKEN']
TMP_DIR_DIR = os.environ.get('TMP_DATA_DIR', '/data')
BUILD_DIR = '/data/release_download'
ARTIFACT_URL = ('https://gitlab.com/koreader/nightly-builds'
                '/builds/%s/artifacts/download')
nightly_build_dir = '%s/nightly' % BUILD_DIR
# matching:
# koreader-ubuntu-touch-arm-linux-gnueabihf-v2015.11-640-g17e9a8e.targz
artifact_match = re.compile(
    '.*/koreader-.*-(v[0-9]{4}.[0-9]{2}-[0-9]+-g[0-9a-z]{7})\.[a-z]+.*')


def trigger_build():
    repo = 'koreader%2Fnightly-builds'
    trigger_url = 'https://gitlab.com/api/v3/projects/%s/trigger/builds' % repo
    while True:
        now = datetime.now()
        next_build_time = now.replace(hour=8, minute=0, second=0)
        if now > next_build_time:
            next_build_time = next_build_time + timedelta(days=1)
        wait_time = (next_build_time - now).seconds
        logger.info('Will trigger next nightly build in %s minutes.',
                    wait_time/60)
        gevent.sleep(wait_time)
        requests.post(trigger_url,
                      data={'token': GITLAB_TRIGGER_TOKEN,
                            'ref': 'master'})
        gevent.sleep(1)


def run_cmd(cmd):
    logger.info('Running command: %s', ' '.join(cmd))
    return gevent.subprocess.call(cmd)


def fetch_build(build):
    logger.info('Fetching artifacts for build %s(%s): %s',
                build['name'], build['id'], build['artifacts_file'])
    zip_name = '%s/%s_artifacts.zip' % (TMP_DIR_DIR, build['id'])
    # -C - for continue download from dropped off
    retcode = run_cmd(['curl', '--retry', '3', '-C', '-',
                       ARTIFACT_URL % build['id'], '-o', zip_name])
    if retcode != 0:
        logger.error('Failed to download build %s(%s)',
                     build['name'], build['id'])
        os.remove(zip_name)
        return

    version = None
    zf = zipfile.ZipFile(zip_name)
    for f in zf.namelist():
        match = artifact_match(f)
        if match:
            version = match.group(1)
            break
    zf.close()
    if version:
        version_dir = '%s/%s/' % (nightly_build_dir, version)
        # -n for no overwrite, -j for junk path
        unzip_cmd = ['unzip', '-n', '-j', '-d', version_dir, zip_name]
        run_cmd(unzip_cmd)
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
