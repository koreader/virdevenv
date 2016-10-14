#!/usr/bin/env python
# -*- coding:utf-8 -*-

from gevent import monkey
monkey.patch_all()
from streql import equals
import gevent
import falcon
import ujson
import os
import logging

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.DEBUG)


gitlab_token = os.environ['GITLAB_WEBHOOK_TOKEN']
BUILD_DIR = '/data/release_download'
ARTIFACT_URL = ('https://gitlab.com/koreader/nightly-builds'
                '/builds/%s/artifacts/download')


def fetch_build(build):
    logger.info('Fetching artifacts for build %s(%s): %s',
                build['name'], build['id'], build['artifacts_file'])
    zip_name = '/data/%s_artifacts.zip' % build['id']
    # -C for continue download from dropped off
    retcode = gevent.subprocess.call(
        ['curl', '--retry', '3', '-C',
         ARTIFACT_URL % build['id'], '-o', zip_name])
    if retcode == 0:
        retcode = gevent.subprocess.call(
            ['unzip', '-j', '-d', BUILD_DIR, zip_name])
        if retcode != 0:
            logger.error('Failed to unzip file: %s', zip_name)
    else:
        logger.error('Failed to download build %s(%s)',
                     build['name'], build['id'])
    os.remove(zip_name)


class PipeLine():
    def on_post(self, req, resp):
        token = req.headers.get('X-GITLAB-TOKEN')
        if not token or not equals(token, gitlab_token):
            raise falcon.HTTPBadRequest('Yoyo', '')

        try:
            data = ujson.load(req.stream)
        except:
            raise falcon.HTTPBadRequest('Bad body', '')
        logger.debug('Got webhook request: %s', data)

        if data['object_kind'] != 'pipeline':
            resp.body = '["meh"]'
            return

        attributes = data['object_attributes']
        commit = data['commit']
        status = attributes['status']
        logger.info('Processing pipeline event %s, status: %s, commit: %s, '
                    'commit message:\n%s',
                    attributes['id'], status, commit['id'], commit['message'])

        if status == 'success' or status == 'failed':
            # build finished, download as many artifacts as possible
            for build in data['builds']:
                print build
                logger.info('Processing build %s(%s), status: %s...',
                            build['name'], build['id'], build['status'])
                if build['status'] != 'success':
                    continue
                gevent.spawn(fetch_build, build)
        resp.body = '["ok"]'


api = falcon.API()
api.add_route('/webhooks/gitlab-pipeline', PipeLine())
