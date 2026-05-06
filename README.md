# XXTE Library

Thư viện public cho XXTE Manager Sync library.

## Cách thêm file mới

1. Copy file vào đúng thư mục:
   - `lib/`
   - `lua/examples/`
   - `lua/scripts/`
   - `archives/`
   - `ipa/`
2. Mở GitHub Desktop.
3. Commit + Push.
4. GitHub Actions sẽ tự rebuild `manifest.json` sau mỗi lần push.
5. Đợi workflow **Build sync manifest** chạy xong, rồi bấm **Sync library** trong app.

Không cần sửa `manifest.json` thủ công.

## Lưu ý

- Repo phải để **Public** để iPhone tải raw GitHub không cần token.
- `sync_library.lua/xxt` là loader nội bộ của app, không đưa vào manifest public.
- Script release nên dùng `.xxt`; `.lua` chỉ để test/dev.
