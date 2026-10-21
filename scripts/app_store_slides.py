#!/usr/bin/env python3
"""Render/edit one repository-owned Daydream screenshot version without capture."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

from PIL import Image


def read(path):
    return json.loads(path.read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def resolve(value, base):
    path = Path(value).expanduser()
    return path if path.is_absolute() else (base / path).resolve()


def input_entries(version, configs):
    entries = {}
    for path, config in configs:
        for device, settings in config['devices'].items():
            for slide in config['slides']:
                source = resolve(settings['screenshotRoot'], path.parent) / slide['screenshot']
                # A version's source images must live with that version.
                relative = source.resolve().relative_to(version / 'inputs')
                with Image.open(source) as image:
                    size = list(image.size)
                    image.verify()
                key = f"{device}/{config['defaultLocale']}/{slide['screenshot']}"
                entries[key] = {'path': str(Path('inputs') / relative), 'sha256': digest(source), 'dimensions': size}
    return entries


def normalize(path, config, device, output, slides):
    folder = resolve(output or config['outputRoot'], path.parent) / config['version'] / device / config['defaultLocale']
    size = config['devices'][device]['canvas']
    for slide in config['slides']:
        if slides and slide['id'] not in slides:
            continue
        png = folder / (slide['id'] + '.png')
        with Image.open(png) as image:
            if image.size != (size['width'], size['height']):
                raise ValueError(f'Unexpected output dimensions: {png}')
            if 'A' in image.getbands():
                if image.getchannel('A').getextrema() != (255, 255):
                    raise ValueError(f'Transparent pixels in final slide: {png}')
                image.convert('RGB').save(png, icc_profile=image.info.get('icc_profile'))
            elif image.mode != 'RGB':
                raise ValueError(f'Unexpected output mode {image.mode}: {png}')


def latest_version(root):
    versions = []
    for folder in root.iterdir():
        match = re.fullmatch(r'v(\d+)\.(\d+)\.(\d+)', folder.name)
        if match and (folder / 'configs').is_dir():
            versions.append((tuple(map(int, match.groups())), folder.name))
    if not versions:
        raise ValueError('No screenshot version folders found')
    return max(versions)[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['render', 'validate', 'editor', 'sources', 'normalize'])
    parser.add_argument('--version', help='Source version folder; defaults to the highest numbered vX.Y.Z folder')
    parser.add_argument('--device', default='all', choices=['all', 'iphone', 'ipad'])
    parser.add_argument('--locale', action='append', default=[])
    parser.add_argument('--slide', action='append', default=[])
    parser.add_argument('--output')
    parser.add_argument('--validate-only', action='store_true')
    parser.add_argument('--port', type=int, default=4325)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1] / 'app-store-slides'
    selected = args.version or latest_version(root)
    if not selected.startswith('v') or Path(selected).name != selected:
        raise ValueError('Version must name a folder such as v5.2.0')
    version = (root / selected).resolve()
    if version.parent != root or not (version / 'configs').is_dir():
        raise ValueError(f'Missing screenshot version: {selected}')
    tool = Path(os.environ.get('APP_STORE_SLIDES_TOOL_ROOT', '~/Desktop/Development/app-store-slides-tool')).expanduser()
    configs = [(path, read(path)) for path in sorted((version / 'configs').glob('*.json'))]
    if not configs or any(config['version'] != selected for _, config in configs):
        raise ValueError('Every config must match its containing version folder')
    sources_path = version / 'sources.json'
    manifest = read(sources_path)
    inputs = input_entries(version, configs)
    if args.action == 'sources':
        manifest['screenshotSet'] = selected
        manifest['inputs'] = inputs
        sources_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')
        print(f'{selected}: recorded {len(inputs)} input hashes')
        return
    if manifest['screenshotSet'] != selected or inputs != manifest['inputs']:
        raise ValueError('Inputs or source selection changed; review them, then run sources --version ' + selected)
    locales = set(args.locale)
    configs = [(path, config) for path, config in configs
               if (not locales or config['defaultLocale'] in locales)
               and (args.device == 'all' or args.device in config['devices'])]
    if not configs or locales - {config['defaultLocale'] for _, config in configs}:
        raise ValueError('No configs matched the requested device/locales')
    if args.action == 'editor':
        first = configs[0][1]
        command = [str(tool / 'Scripts/editor.sh'), '--config-dir', str(version / 'configs'),
                   '--slides-root', str(resolve(first['outputRoot'], configs[0][0].parent)),
                   '--version', selected, '--device', 'iphone' if args.device == 'all' else args.device,
                   '--locale', first['defaultLocale'], '--no-render', '--port', str(args.port)]
        os.execv(command[0], command)
    output = str(Path(args.output).expanduser().resolve()) if args.output else None
    for path, config in configs:
        if set(args.slide) - {slide['id'] for slide in config['slides']}:
            raise ValueError(f'Unknown slide in {path.name}')
        for device in list(config['devices']) if args.device == 'all' else [args.device]:
            if args.action != 'normalize':
                command = [str(tool / 'Scripts/render.sh'), '--config', str(path), '--device', device, '--locale', config['defaultLocale']]
                if output:
                    command += ['--output', output]
                if args.action == 'validate' or args.validate_only:
                    subprocess.run(command + ['--validate-only'], check=True)
                    continue
                for slide in args.slide or [None]:
                    subprocess.run(command + (['--slide', slide] if slide else []), check=True)
            normalize(path, config, device, output, args.slide)
    print(f'Daydream {selected}: {args.action} succeeded')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
