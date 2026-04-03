# SnapNote

Mac app that pops a tiny note window right after taking a screenshot, so the screenshot keeps its context.

## Current PoC

- Watches `~/Desktop` for newly created screenshot files
- Opens a floating note panel when a fresh screenshot appears
- Lets you type context immediately
- Saves a sidecar note next to the image as `*.note.md`
- Runs as a menu bar utility (`LSUIElement`)

## Structure

- `project.yml` — XcodeGen project spec
- `SnapNote/App` — app entry + AppDelegate
- `SnapNote/Core` — state + screenshot watcher
- `SnapNote/UI` — dashboard + note panel UI

## Next step

Generate the Xcode project and run it:

```bash
cd projects/snapnote
xcodegen generate
open SnapNote.xcodeproj
```

## Known limitations

- Screenshot detection is simple Desktop polling for now
- No ScreenCaptureKit / event tap yet
- No persistence beyond sidecar markdown notes yet
