# Daydream Visual QA

Use the private [app-visual-qa-tool](https://github.com/rckim77/app-visual-qa-tool) checkout beside the main app checkout, or set `APP_VISUAL_QA_TOOL_ROOT`. Worktree wrappers resolve sibling placement from Git's common directory.

Validated with tool revision `fdcd1f7`.

```bash
export DEVELOPER_DIR=/Applications/Xcode_27RC.app/Contents/Developer
export VISUAL_QA_OUTPUT_ROOT="$HOME/Desktop/Screenshots/DaydreamVisualQA"
bash scripts/capture_visual_qa_snapshots.sh --suite base
bash scripts/capture_visual_qa_snapshots.sh --suite additional
```

Omitting `--suite` selects base. Open `$VISUAL_QA_OUTPUT_ROOT/base/index.html` and `$VISUAL_QA_OUTPUT_ROOT/additional/index.html`. The reports stay separate, so additional capture preserves the base screenshots. Add `--dry-run` to either command to inspect coverage without capture; `--ios 27` narrows the selected suite to that generation.

The shared base devices are iPhone SE (3rd generation), iPhone 17 Pro Max, iPad Pro 11-inch (M5) portrait, and iPad Pro 13-inch (M5) landscape. Only the SE is dark; all other devices are light. Additional coverage adds an iPad mini (A17 Pro) in landscape on both OS versions, without repeating base cases.

Base captures the main screen in English on iOS 27: **4 screenshots**. Additional captures English on all five devices on iOS 26 and the landscape mini on iOS 27: **6 additional screenshots**, 10 combined.

Both configurations are required in `config.json`. Base device definitions live in the shared tool. Additional OS generations, languages by OS, and extra devices are customized here.

Capture runs serially. For a focused check, set `VISUAL_QA_DEVICE_PROFILES='configured-device-id:Dedicated Simulator Name'`. Capture reinstalls the app by default; use dedicated simulators to preserve personal app state. `--suite base --clean` deletes only base artifacts; `--suite additional --refresh-dashboard` rebuilds the additional report without capturing.

The dedicated `VisualQA` scheme and `visualqa.xctestplan` keep captures separate from regular unit tests. The capture test supplies a fixed city order through an opt-in Debug launch environment. Tips are not reset. Images use the real Places/cache path, and the test waits for all five photos. Provide the existing ignored `Daydream/Shared/apiKeys.plist` locally. City detail and map screens are outside this suite.
