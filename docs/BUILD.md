# ManyMoons — Build Pipeline

## Prerequisites

Before cloning, ensure the following are installed:

| Tool | Version | Notes |
|------|---------|-------|
| Unreal Engine 5 | 5.7 | Must match `.uproject` `EngineAssociation` |
| Git | Any recent | |
| Git LFS | 3.x+ | **Required** — UE5 binary assets are LFS-tracked |
| Visual Studio 2022 | Community or higher | Workload: **Desktop development with C++** |

> Git LFS install: https://git-lfs.com — run `git lfs install` once after installing.

---

## Clone

```bash
git clone https://github.com/SwervoJake/CLAAAUDE-STUDIO.git
cd CLAAAUDE-STUDIO
git lfs pull
```

`git lfs pull` downloads all binary UE5 assets (`.uasset`, `.umap`, etc.) that are tracked via LFS. **Do not skip this step** — the project will fail to open without the binary assets.

---

## Open the Project

1. Navigate to `ManyMoons/`
2. Double-click `ManyMoons.uproject`
3. If prompted to rebuild modules, click **Yes**
4. First open will compile shaders — allow **5–15 minutes** on initial load

The editor will open to `Lvl_FirstPerson` (the M0 test level) by default.

---

## Play In Editor (PIE) — Smoke Test

1. Open `Content/FirstPerson/Lvl_FirstPerson` in the Content Browser
2. Press **Play** (or `Alt+P`)
3. Verify:
   - [ ] Player spawns and can move (WASD + mouse look)
   - [ ] No fall-through or physics bugs
   - [ ] `BP_DoorFrame` or `BP_JumpPad` responds to player interaction
   - [ ] No error dialogs or Blueprint compile errors in the Output Log

---

## Package Windows Build

1. In the editor: **Platforms → Windows → Package Project**
2. Choose an output directory outside the repo (e.g., `~/Builds/ManyMoons_Windows/`)
3. Wait for cook + package (~5–20 min first build, faster on subsequent builds)
4. Output: `WindowsNoEditor/ManyMoons.exe`

### Command-line package (optional)

```bash
"C:\Program Files\Epic Games\UE_5.7\Engine\Build\BatchFiles\RunUAT.bat" ^
  BuildCookRun ^
  -project="C:\path\to\CLAAAUDE-STUDIO\ManyMoons\ManyMoons.uproject" ^
  -noP4 -platform=Win64 -clientconfig=Shipping ^
  -cook -allmaps -build -stage -pak -archive ^
  -archivedirectory="C:\Builds\ManyMoons"
```

---

## Smoke Test Checklist (M0 Gate)

Run this after every packaging:

```
- [ ] ManyMoons.exe launches without crash
- [ ] Player can move and look around in Lvl_FirstPerson
- [ ] Interaction event fires on BP_DoorFrame or BP_JumpPad
- [ ] No error popups on launch
- [ ] Alt+F4 exits cleanly (no hang)
```

---

## Troubleshooting

**Shaders recompiling every launch**
- Normal on first launch after engine update or new asset import. Subsequent launches skip this.

**"Missing modules" on open**
- Click Yes to rebuild. If it fails, ensure Visual Studio 2022 with C++ Desktop workload is installed.

**LFS assets show as text pointers (small files)**
- Run `git lfs pull` from the repo root. If LFS is not installed, run `git lfs install` first.

**Packaging fails with cook errors**
- Check Output Log for red errors. Common cause: missing redirectors after asset rename. Run **Fix Up Redirectors** from Content Browser right-click menu.

---

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable, gate-passed builds only |
| `claude/weekly-planning-review-BtESU` | Active development |
| Feature branches | Per-agent work, merged to dev after review |

> Human gate approval required before merging to `main` at each milestone.
