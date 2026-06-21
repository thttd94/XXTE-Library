from pathlib import Path
import hashlib, json, urllib.parse

ROOT = Path(__file__).resolve().parent
REPO = 'thttd94/XXTE-Library'
BRANCH = 'main'
BASE_RAW = f'https://raw.githubusercontent.com/{REPO}/{BRANCH}'
DIRS = ['lib', 'lua/examples', 'lua/scripts', 'archives', 'ipa']
EXCLUDE = {
    'lua/scripts/sync_library.lua',
    'lua/scripts/sync_library.xxt',
    'lib/sync_library.lua',
    'lib/sync_library.xxt',
}
EXCLUDE_PARTS = (
    '_xxt_plain_backup_',
    'backup_before',
    'backup_before_stage2',
    'scripts_backup_before_encrypt_',
    'lua_backup_before_encrypt_',
)
items = []
for d in DIRS:
    base = ROOT / d
    if not base.exists():
        continue
    for p in sorted(base.rglob('*')):
        if not p.is_file():
            continue
        rel = p.relative_to(ROOT).as_posix()
        rel_lower = rel.lower()
        if rel.endswith('/.gitkeep') or rel.endswith('.gitkeep'):
            continue
        if rel_lower in EXCLUDE:
            continue
        if any(part in rel_lower for part in EXCLUDE_PARTS):
            continue
        if p.suffix.lower() == '.lua':
            continue
        if rel.startswith('lua/scripts/') and any(ch.isspace() for ch in rel):
            # Giữ đúng rule workflow cũ: bỏ script có dấu cách trong tên
            continue
        data = p.read_bytes()
        if len(data) <= 0:
            continue
        items.append({
            'rel': rel,
            'dest': '/var/mobile/Media/1ferver/' + rel,
            'url': BASE_RAW + '/' + urllib.parse.quote(rel, safe='/'),
            'size': len(data),
            'sha1': hashlib.sha1(data).hexdigest(),
        })

out = {
    'repo': REPO,
    'branch': BRANCH,
    'base_raw': BASE_RAW,
    'files': items,
}
(ROOT / 'manifest.json').write_text(json.dumps(out, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('manifest files:', len(items))
