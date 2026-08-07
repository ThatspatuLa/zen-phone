# Zen Phone

Phase 2 of the Zen Phone project. Flutter iOS app for the operator (Tyson) — agent OS on iPhone 15.

## Status (2026-08-07)

- Flutter SDK installed at `C:\Users\Tyson\Downloads\flutter_windows_3.44.9-stable\flutter`
- Project created with bundle `spatula.zen_phone`
- Backend Phase 1 complete (8 endpoints in `agent_os_server.py` + `mobile_endpoints.py`)
- Tailscale mesh: desktop `100.126.122.39:8765`, iPhone `100.122.91.91`
- All screens drafted: Home, Kanban, Chat, Skills, Memory, Settings
- NOT YET BUILT — `flutter build ipa` requires macOS (use Codemagic)

## Build path

1. **Push to GitHub** (you need to create a repo first):
   ```bash
   cd "C:\Users\...\..."> cd "C:\Users\Tyson\Projects\zen_phone"
   git init
   git add .
   git commit -m "Initial Zen Phone scaffold"
   git remote add origin <github-url>
   git push -u origin main
   ```

2. **Codemagic** (sign up at https://codemagic.io)
   - Connect GitHub repo
   - Auto-detects `pubspec.yaml` as Flutter
   - macOS VM runs `flutter build ipa --release`
   - Produces `.ipa` file

3. **Install on iPhone**
   - Free: TestFlight (need Apple ID, free)
   - Sideload: download `.ipa` via Diawi or AppCircle

## Backend

Running Python server at `100.126.122.39:8765` (Tailscale only). Endpoints:
- `GET /api/projects/summary`
- `GET /api/projects/<id>/kanban`
- `GET /api/kanban/task/<id>`
- `POST /api/kanban/task/<id>/move`
- `GET /api/chat/<project>/history`
- `POST /api/chat/<project>/send`
- `GET /api/skills`
- `GET /api/memory/vault`
- `GET /api/memory/file?path=...`
- `GET /api/memory/activity`
- `GET /api/agents/status`

## What got built

| Screen | File |
|---|---|
| Home (Pulse) | `lib/screens/home_screen.dart` |
| Kanban | `lib/screens/kanban_screen.dart` |
| Chat (text + voice) | `lib/screens/chat_screen.dart` |
| Skills (read-only) | `lib/screens/skills_screen.dart` |
| Memory (vault + activity) | `lib/screens/memory_screen.dart` |
| Settings | `lib/screens/settings_screen.dart` |
| Side drawer | `lib/widgets/side_drawer.dart` |

## Known gaps / not done

- Live Activity (requires Apple Developer account, parked)
- Push notifications (Phase 9)
- Skill detail content (currently only metadata + description)
- Voice listening visual feedback (mic active but no waveform)
- Error retry on most screens
- Empty state art for some screens
- App icon (still default Flutter icon)

## Open follow-ups

1. Test on iPhone once built via Codemagic
2. Add Live Activity when you have a dev account
3. Polish for App Store (when/if you ever publish)
