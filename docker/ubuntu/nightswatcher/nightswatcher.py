#!/usr/bin/env python
# -*- coding:utf-8 -*-

from gevent import monkey
from gevent import queue
monkey.patch_all()  # NOQA

# pylint: disable=wrong-import-position,wrong-import-order
# ruff: noqa: E402
from collections import defaultdict
from pathlib import Path
from requests import Session
from requests.adapters import HTTPAdapter
from tempfile import NamedTemporaryFile
from types import SimpleNamespace
from urllib3.util import Retry
import binascii
import falcon
import gevent
import hashlib
import hmac
import json
import logging
import os
import re
import shutil


logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s %(name)s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
update_queue = queue.Queue()


NIGHTWATCHER_TESTING = bool(os.environ.get('NIGHTWATCHER_TESTING'))
GITHUB_WEBHOOK_SECRET = os.environ['GITHUB_WEBHOOK_SECRET'].encode('utf-8')
OTA_DIR = Path('/data/ota')
BUILD_DIR = Path('/data/release_download')
NIGHTLY_BUILD_DIR = BUILD_DIR / 'nightly'
STABLE_BUILD_DIR = BUILD_DIR / 'stable'

# Free space budget (GiB) that old version directories are purged to maintain.
KEEP_FREE_GB = int(os.environ.get('KEEP_FREE_GB', 10))
# Minimum number of versions of each kind to keep around when purging.
KEEP_NIGHTLY_AMOUNT = int(os.environ.get('KEEP_NIGHTLY_AMOUNT', 7))
KEEP_STABLE_AMOUNT = int(os.environ.get('KEEP_STABLE_AMOUNT', 2))


logger.setLevel(logging.DEBUG if NIGHTWATCHER_TESTING else logging.INFO)


# Setup requests session.
session = Session()
# Enable automatic retries.
session.mount('https://', HTTPAdapter(max_retries=Retry(
    total=3,
    backoff_factor=0.1,
    status_forcelist=[502, 503, 504],
    allowed_methods={'GET'},
)))
# Enable support for `file://` URLs.
if NIGHTWATCHER_TESTING:
    from requests_file import FileAdapter
    session.mount('file://', FileAdapter())


def sha256path(path):
    path = Path(path)
    return path.with_name(path.name + '.sha256')

def sha256sum(path):
    path = Path(path)
    try:
        sha256 = sha256path(path).read_text(encoding='utf-8').split(None, 1)[0]
    except FileNotFoundError:
        sha256 = hashlib.sha256(path.read_bytes()).hexdigest()
        sha256path(path).write_text(f'{sha256} {path.name}\n', encoding='utf-8')
        sha256path(path).chmod(0o444)
    return sha256

def fetch(url, expected_sha256):
    logger.debug('fetch %s', url)
    resp = session.get(url)
    if resp.status_code != 200:
        logger.error('Failed to fetch %s: %u %s', url, resp.status_code, resp.reason)
        return None
    with NamedTemporaryFile(delete=False) as tmpf:
        tmpf.write(resp.content)
        tmpf.close()
        actual_sha256 = sha256sum(tmpf.name)
        if expected_sha256 != actual_sha256:
            logger.error(f'Failed to fetch {url}: SHA-256 do not match, expected {expected_sha256}, calculated {actual_sha256}')
            rm(sha256path(tmpf.name))
            rm(tmpf.name)
            return None
        return Path(tmpf.name)


PLATFORM_RX = r'(?P<platform>.+)'
VERSION_RX = r'(?P<version>(?P<base_version>[0-9]+(\.[0-9]+)*)(?:-(?P<commit_number>[0-9]+)-g(?P<commit_hash>[a-f0-9]+))?(?:_(?P<commit_date>[0-9]{4}-[0-9]{2}-[0-9]{2}))?)'
EXTENSION_RX = r'\.(?P<extension>7z|apk|AppImage|deb|kotasync|targz|tar\.xz|zip|zsync)'

ASSET_RX_LIST = (
    # koreader-linux-x86_64-v2023.06.1.tar.xz
    # koreader-android-arm-v2015.11-654-gb7392f7_2018-03-09.apk
    re.compile('koreader-' + PLATFORM_RX + '-v' + VERSION_RX + EXTENSION_RX),
    # koreader-v2023.06.1-x86_64.AppImage
    # koreader-v2025.10-197-g7c5ee9c1a2_2026-03-13-x86_64.AppImage
    re.compile('koreader-v' + VERSION_RX + '-' + PLATFORM_RX + EXTENSION_RX),
    # koreader_2026.09-8-g84cf973-1_amd64.deb
    re.compile('koreader_' + VERSION_RX + '-1_' + PLATFORM_RX + EXTENSION_RX),
    # koreader-android-arm-latest-nightly
    # koreader-kindlepw2-latest-nightly.kotasync
    # koreader-kindlepw2-latest-stable.zsync
    re.compile('koreader-' + PLATFORM_RX + '-latest-(?P<version>nightly|stable)(?:' + EXTENSION_RX + '|)'),
    # koreader-android-fdroid-latest
    re.compile('koreader-(?P<platform>android)-(?P<version>fdroid)-latest'),
)


# Create a tuple of int for sorting version strings:
# 2025.10                           → (2025, 10, 0,    0)
# 2025.10-156-g7fdba6a99_2026-03-01 → (2025, 10, 0,  156)
# 2026.03.1                         → (2026,  3, 1,    0)
def version_key(version):
    m = re.fullmatch(VERSION_RX, version)
    if m is None:
        raise ValueError(f'bad version string: {version}')
    key = list(map(int, m.group('base_version').split('.')))
    # NOTE: pad to 3 elements to keep the tuple size stable.
    while len(key) < 3:
        key.append(0)
    key.append(int(m.group('commit_number') or 0))
    return tuple(key)


# pylint: disable=too-few-public-methods
class AssetName(SimpleNamespace):

    def __init__(self, name):
        super().__init__()
        for rx in ASSET_RX_LIST:
            m = rx.fullmatch(name)
            if m is not None:
                self.__dict__.update(m.groupdict())
                break
        else:
            raise ValueError(f"invalid asset name: {name}")
        for f in ('base_version', 'commit_number', 'commit_hash', 'commit_date', 'extension'):
            self.__dict__[f] = self.__dict__.get(f)
        self.name = name
        self.latest = '-latest' in name
        self.ota = self.latest or self.extension in {'kotasync', 'zsync'}
        self.stable = self.version == 'stable' or (self.version != 'nightly' and self.commit_number is None)

    def __str__(self):
        return self.name


def cp(src, dst):
    logger.debug('cp %s %s', src, dst)
    shutil.copy(src, dst)
    Path(dst).chmod(0o644)

def rm(path):
    logger.debug('rm %s', path)
    Path(path).unlink(missing_ok=True)

def symlink(target, link):
    logger.debug('ln -sf %s %s', target, link)
    link = Path(link)
    link.unlink(missing_ok=True)
    link.symlink_to(target)


class Manifest:

    def __init__(self, ota_dir, nightlies_dir, stables_dir):
        self.ota_dir = Path(ota_dir)
        self.nightlies_dir = Path(nightlies_dir)
        self.stables_dir = Path(stables_dir)
        self.ota = {}
        self.by_sha256 = defaultdict(set)

    def ensure_dirs(self):
        for d in (self.ota_dir, self.nightlies_dir, self.stables_dir):
            d.mkdir(parents=True, exist_ok=True)

    def initial_update(self):
        stable = {}
        nightly = {}
        for manifest, directory in (
            (self.ota, self.ota_dir),
            (nightly, self.nightlies_dir),
            (stable, self.stables_dir),
        ):
            for dirpath, _dirnames, filenames in directory.walk():
                for name in filenames:
                    path = dirpath / name
                    if path.suffix == '.sha256':
                        continue
                    assert path.name not in manifest
                    realpath = path.resolve()
                    sha256 = sha256sum(realpath)
                    manifest[path.name] = sha256
                    self.by_sha256[sha256].add(realpath)
        logger.info('ota: %u files', len(self.ota))
        logger.info('stable: %u files', len(stable))
        logger.info('nightly: %u files', len(nightly))

    def update_asset(self, asset):
        logger.info('Updating asset: %s', asset.name)
        local_copies = self.by_sha256[asset.sha256]
        if local_copies:
            path, path_is_temp = next(iter(local_copies)), False
        else:
            path, path_is_temp = fetch(asset.browser_download_url, asset.sha256), True
            if path is None:
                return None
        if asset.name.ota:
            dest_dir = self.ota_dir
        elif asset.name.stable:
            dest_dir = self.stables_dir / asset.name.version
        else:
            dest_dir = self.nightlies_dir / asset.name.version.split('_', 1)[0]
        dest_path = dest_dir / str(asset.name)
        if path != dest_path:
            dest_path.parent.mkdir(exist_ok=True)
            cp(path, dest_path)
            cp(sha256path(path), sha256path(dest_path))
        if path_is_temp:
            rm(sha256path(path))
            rm(path)
        return dest_path

    def on_ota_update(self, release):
        logger.info('OTA update: %s', release.target_commitish)
        updated = []
        removed = set(self.ota)
        for asset in release.assets:
            removed.discard(str(asset.name))
            if self.ota.get(str(asset.name)) != asset.sha256:
                updated.append(asset)
        for asset in sorted(updated, key=lambda a: (a.name.latest, a.name.ota, str(a.name))):
            dest_path = self.update_asset(asset)
            if not dest_path:
                return
            if dest_path.parent != self.ota_dir:
                symlink(dest_path, self.ota_dir / dest_path.name)
            self.ota[dest_path.name] = asset.sha256
        for name in sorted(removed):
            logger.info('Removing asset: %s', name)
            sha256 = self.ota.pop(name)
            path = self.ota_dir / name
            rm(path)
            rm(sha256path(path))
            if not path.is_symlink():
                self.by_sha256[sha256].discard(path)
        self.purge_old_versions()

    def on_new_release(self, release):
        logger.info('new release: %s', release.tag_name)
        for asset in sorted(release.assets, key=lambda a: str(a.name)):
            dest_path = self.update_asset(asset)
            if not dest_path:
                return
        self.purge_old_versions()

    def purge_old_versions(self):
        # Purge version directories oldest-first (across both kinds) to free up
        # KEEP_FREE_GB, never touching the KEEP_*_AMOUNT newest of each kind.
        purgable = []
        for directory, keep in (
            (self.nightlies_dir, KEEP_NIGHTLY_AMOUNT),
            (self.stables_dir, KEEP_STABLE_AMOUNT),
        ):
            dirs = sorted((d.name for d in directory.iterdir() if d.is_dir() and re.fullmatch(VERSION_RX, d.name)), key=version_key)
            purgable.extend(directory / d for d in dirs[:max(0, len(dirs) - keep)])
        for d in sorted(purgable, key=lambda x: version_key(x.name)):
            if shutil.disk_usage(BUILD_DIR).free >= (KEEP_FREE_GB << 30):
                break
            logger.info('Purging old version directory: %s', d)
            for path in d.iterdir():
                if path.is_symlink():
                    continue
                self.by_sha256[sha256sum(path)].discard(path.resolve())
            shutil.rmtree(d)
        # Purge dangling OTA symlinks (e.g., to purged versions).
        for path in self.ota_dir.iterdir():
            if path.is_symlink() and not path.exists():
                self.ota.pop(path.name, None)
                rm(path)

    def on_update(self, release):
        release = SimpleNamespace(**release)
        assetlist = []
        for asset in release.assets:
            asset = SimpleNamespace(**asset)
            if asset.state != 'uploaded':
                continue
            asset.name = AssetName(asset.name)
            sha256 = asset.digest
            assert sha256.startswith('sha256:')
            asset.sha256 = sha256.removeprefix('sha256:')
            assetlist.append(asset)
        release.assets = assetlist
        if release.tag_name == 'ota':
            self.on_ota_update(release)
        else:
            self.on_new_release(release)


def update_worker():
    manifest = Manifest(OTA_DIR, NIGHTLY_BUILD_DIR, STABLE_BUILD_DIR)
    manifest.ensure_dirs()
    manifest.initial_update()
    while True:
        logger.info('Update worker waiting for updates…')
        timeout = (10 if NIGHTWATCHER_TESTING else 3) * 60
        gevent.spawn(manifest.on_update, update_queue.get()).join(timeout=timeout)


# pylint: disable=too-few-public-methods
class GitHubWebHook():

    OTA_UPDATE_DEBOUNCE_DELAY = 4 if NIGHTWATCHER_TESTING else 40

    def __init__(self):
        self._ota_update_debounce = None

    def on_post(self, req, _resp):
        signature_header = req.headers.get('X-HUB-SIGNATURE-256')
        if not signature_header:
            raise falcon.errors.HTTPForbidden(description='x-hub-signature-256 header is missing!')
        body = req.stream.read()
        expected_digest = hmac.digest(GITHUB_WEBHOOK_SECRET, body, 'SHA256')
        expected_signature = 'sha256=' + binascii.hexlify(expected_digest).decode()
        if not hmac.compare_digest(expected_signature, signature_header):
            raise falcon.errors.HTTPForbidden(description='Request signatures do not match!')
        data = json.loads(body)
        logger.info('Webhook: “%s” %s, %u assets',
                    data.get('release', {}).get('tag_name'),
                    data.get('action'),
                    len(data.get('release', {}).get('assets', ())))
        assert 'action' in data
        assert 'release' in data
        release = data['release']
        if release['draft']:
            return
        if release['tag_name'] == 'ota' and data['action'] == 'edited':
            if self._ota_update_debounce is not None:
                self._ota_update_debounce.kill()
                self._ota_update_debounce = None
            self._ota_update_debounce = gevent.spawn_later(self.OTA_UPDATE_DEBOUNCE_DELAY, lambda: update_queue.put(release))
        elif release['tag_name'] != 'ota' and data['action'] == 'published':
            update_queue.put(release)


api = falcon.App()
api.add_route('/webhooks/github', GitHubWebHook())
gevent.spawn(update_worker)
