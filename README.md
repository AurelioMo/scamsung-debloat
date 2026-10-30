```
  ╔═╗┌─┐┌─┐┌┬┐┌─┐┬ ┬┌┐┌┌─┐
  ╚═╗│  ├─┤│││└─┐│ │││││ ┬
  ╚═╝└─┘┴ ┴┴ ┴└─┘└─┘┘└┘└─┘
      ··· d e b l o a t ···
```

# scamsung-debloat

[![GitHub release](https://img.shields.io/github/v/release/AurelioMo/scamsung-debloat)](https://github.com/AurelioMo/scamsung-debloat/releases)
[![GitHub license](https://img.shields.io/github/license/AurelioMo/scamsung-debloat)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](#requirements)
[![Shell: bash 3.2+](https://img.shields.io/badge/shell-bash%203.2%2B-green)](scamsung-debloat)

**Remove Samsung bloatware without root** on One UI 8/9 — preview first,
typed confirmation, one-command undo. Interface in Português, English and Español.

📄 [Versão em Português](README_PT-BR.md)

## 60-second quickstart

```bash
# 1. adb, once per computer:
brew install --cask android-platform-tools     # macOS
winget install --id Google.PlatformTools -e    # Windows
sudo apt install android-tools-adb             # Debian/Ubuntu

# 2. phone, once: Settings → About phone → tap "Build number" 7×
#    → Developer options → USB debugging ON → plug cable → Allow

# 3. get the tool and double-click it (scamsung-debloat.cmd on Windows)
git clone https://github.com/AurelioMo/scamsung-debloat.git

# 4. in the menu: 1 → diagnostics, 2 → apply, "basic",
#    read the preview, type: sim
```

**Nothing changes on the phone before you type `sim`.** No root, no Knox,
no bootloader — and menu option 4 restores everything.

## Why this exists

[UAD](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
and [Canta](https://github.com/samolego/Canta) are excellent — this project reuses
their risk research. scamsung-debloat covers what's left: people who don't want to
install another app or keep Shizuku running to remove apps, who want a menu in their
own language, presets tested specifically on One UI 8/9 (based on
[itxjobe's community lists](https://github.com/itxjobe/samsungdebloat)), and a
restore path that is one menu option instead of a factory reset. It's a single
bash script — the entire safety model fits in your head.

## ⚠️ Honest fine print (read this)

> - Everything runs through `adb shell pm … --user 0`: apps leave your user
>   profile, not `/system`. Knox, warranty and Play Integrity stay intact.
> - **You always see the full removal list first** and must type `sim`.
> - Samsung **OTA updates** can reinstall apps — run the preset again, nothing breaks.
> - Apps that **depend on Samsung services** (watch faces, pay plugins, Galaxy
>   Store content) break when their dependency goes. Every preset line says so.
> - **Validated against a fake adb** simulating One UI 9 (see `tests/`), not on
>   your specific firmware. The preview is the final check — read it.
> - No storage is freed: APKs stay in the read-only system partition. You gain
>   RAM, battery, privacy and a clean app drawer. Not gigabytes.

## Contents

- [60-second quickstart](#60-second-quickstart)
- [Why this exists](#why-this-exists)
- [Requirements](#requirements)
- [Usage: the menu](#usage-the-menu)
- [Presets](#presets)
- [What a run looks like](#what-a-run-looks-like)
- [Tweaks](#tweaks-menu-option-5)
- [Restoring](#restoring)
- [FAQ](#faq)
- [Uninstalling](#uninstalling)
- [Tests](#tests)
- [Project structure](#project-structure)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

## Requirements

| | What you need |
|---|---|
| Phone | Any Samsung Galaxy on One UI 8/9 (Android 16/17). Older versions work too; newer ones trigger a warning, then run |
| Computer | `adb` (platform-tools) + macOS, Linux, or Windows with [Git for Windows](https://git-scm.com/download/win) |
| Cable | USB — or Wi-Fi pairing, menu option 7 (Android 11+) |

## Usage: the menu

Double-click the file (`scamsung-debloat.cmd` on Windows; on macOS the first time
it's right-click → Open). A numbered menu appears, in your OS language:

```
  ╔═╗┌─┐┌─┐┌┬┐┌─┐┬ ┬┌┐┌┌─┐
  ╚═╗│  ├─┤│││└─┐│ │││││ ┬
  ╚═╝└─┘┴ ┴┴ ┴└─┘└─┘┘└┘└─┘
      ··· d e b l o a t ···
no root · fully reversible · One UI 8/9
  1) Device diagnostics        ← check adb + phone + One UI version (start here)
  2) Apply preset              ← pick basic / light / heavy, see preview, confirm
  3) See what you removed      ← everything this tool ever removed
  4) Restore everything        ← undo everything this tool did
  5) Tweaks (GOS, RAM Plus…)   ← performance options, each explained in place
  6) See installed packages    ← search what's on the phone
  7) Pair over Wi-Fi           ← drop the cable
  8) Quit
Choose:
```

Recommended first run: **1** → **2** → `basic` → read every line → type `sim`.

## Presets

Plain text files in `lists/` — one package per line, each with a plain-language
explanation of what it is and what you lose. Presets nest: `heavy` ⊃ `light` ⊃ `basic`.
Numbers below are from a fresh-out-of-box Galaxy on the test rig.

| Preset | Packages | What goes away | Risk |
|--------|---------:|----------------|------|
| `basic` | 51 | Preinstalled junk: Facebook/Netflix/Booking/Amazon, duplicate Samsung user apps (Notes, Calendar, Clock, Calculator, Internet, Health, Free, Members), Game Launcher, AR Emoji/Zone | **Low.** No system component touched; Samsung account, Wallet and Galaxy AI stay |
| `light` | 98 | `basic` + Chrome, Gmail, "Ok Google", Android Auto, Galaxy Themes, Samsung Pass, Wallet, Smart Switch, Bixby wakeup/Vision, Find My Mobile | **Medium.** No Samsung payments or Find My Mobile — replace those first |
| `heavy` | 126 | `light` + YouTube, Maps, Gemini, Docs/Sheets/Slides, printing stack, SmartThings, Interpreter, Samsung Email | **Medium-high.** Maximum that is still reversible |

Never removed, in any preset or manual request: **Play Store/Services, SystemUI,
Settings, One UI launcher, dialer, IMS/VoLTE/Wi-Fi calling, Samsung keyboard, setup
wizard** — the built-in deny-list can't be typed around. Packages that don't exist
on your phone are skipped, never invented.

## What a run looks like

Real output against the project's fake-adb test rig (your phone shows its own
numbers — here, 20 of the 51 `basic` packages were actually installed):

```
==> Galaxy SM-S931B (e1q) · Android 17 · One UI 9.0
==> 55 packages on device · preset "basic" flags 51

  ~ com.facebook.katana          — Facebook
  ~ com.netflix.mediaclient      — Netflix
  ~ com.samsung.android.aremoji  — AR Emoji
  ~ com.sec.android.app.sbrowser — Samsung Internet
    … 46 more, each explained …

Type sim to continue: sim
==> Applying (uninstall)…
==> removed: 20 · skipped (not on this device): 31
==> undo anytime: ./scamsung-debloat restore
```

Uninstall failures fall back to *disabling* the app (data preserved).

## Tweaks (menu option 5)

Every tweak records its original value and is exactly reversible with `r`:

| Option | What it does | The honest trade-off |
|--------|--------------|----------------------|
| `p` **performance** (default) | Disables GOS (Samsung's game throttling), RAM Plus + zram off, animations at 0.35x, in-game thermal control off | More heat under load; multitasking may reload apps; GOS play statistics are wiped (`pm clear`) |
| `a` **light** | Animations 0.5x, background app freezer, adaptive battery ON, less background Wi-Fi/Bluetooth scanning | Slightly worse network-based location accuracy |
| `s` **status** | Shows every tweak this tool changed, with original values | — |
| `r` **reset** | Restores exactly what **this tool** changed, re-enables GOS | — |

Settings that don't exist on your firmware are skipped with a warning.

## Restoring

- **Everything:** menu option **4**.
- **One app, by hand:** `adb shell cmd package install-existing <package>` (removed)
  or `adb shell pm enable <package>` (disabled).
- **Tweaks:** `./scamsung-debloat tweaks --reset`.
- **Records:** `~/.local/share/scamsung-debloat/` — `state.tsv`, `tweaks.tsv`,
  `logs/session-*.tsv`. Deleting that folder forfeits automated restore; apps are
  still recoverable by hand.

<details>
<summary><b>Advanced: CLI flags</b> (the menu covers normal use)</summary>

```bash
./scamsung-debloat doctor            # diagnostics
./scamsung-debloat list              # show presets
./scamsung-debloat apply basic       # preview → type "sim" → apply
./scamsung-debloat apply --only com.facebook.katana
./scamsung-debloat explain <package> # what is this package, which presets have it
./scamsung-debloat scan [term]       # installed packages containing <term>
./scamsung-debloat status            # what this tool already removed
./scamsung-debloat restore           # undo everything
./scamsung-debloat tweaks [--performance|--status|--reset|--ram-plus off|on]
./scamsung-debloat wireless          # pair over Wi-Fi
./scamsung-debloat self-test         # validate presets (no phone needed)

# options:
#   -y, --yes        skip the typing (the preview is still always shown)
#       --disable    disable instead of uninstall (keeps app data)
#       --skip a,b   skip these packages
#       --serial S   pick device when several are connected
#   -v / -q          verbose / quiet
```

Environment: `SCAMSUNG_LANG=pt|en|es` (force the UI language), `ANDROID_SERIAL`,
`SCAMSUNG_DEBLOAT_DATA_DIR`, `NO_COLOR=1`.

</details>

## FAQ

**Does it need root? Does it trip Knox or break Play Integrity?**
No, on all counts. `--user 0` package removal is a stock Android feature — nothing
touches the bootloader, `/system`, Knox or attestation. Banking apps and Google
Pay keep working.

**How do I get a removed app back?**
Menu option 4 restores everything. Single app by hand:
`adb shell cmd package install-existing <package>`.

**Will an OTA update bring the bloatware back?**
Sometimes. Re-run the preset after the update; nothing breaks meanwhile.

**Does it free up storage?**
No — APKs stay in the read-only system partition. The gains are RAM, background
battery drain, privacy and a clean app drawer.

**What if an app I keep depends on a removed one?**
The dependent feature stops working until restore. Every preset line explains its
consequence and the preview shows the full list first.

**Can I remove just one app?**
`./scamsung-debloat apply --only com.facebook.katana`. The deny-list still
applies; `explain <package>` tells you what anything is before you touch it.

## Uninstalling

The tool installs nothing on your computer — it is one script:

1. Menu option **4** to restore the phone to stock.
2. Delete the cloned folder.
3. Delete the state folder: `rm -rf ~/.local/share/scamsung-debloat` (Linux/macOS).

Disable USB debugging on the phone if you enabled it only for this.

## Tests

The suite runs against a **fake adb** simulating a Galaxy on One UI 9 — no phone
required, no real device ever touched:

```bash
bash tests/run.sh
```

73 checks: self-test, doctor, scan, mandatory preview, apply, deny-list,
nonexistent packages, restore, disable mode, `--skip`, presets, and every tweak
path (idempotence, status, exact reset, `--performance`, `--ram-plus`).

## Project structure

```
scamsung-debloat           # the tool
scamsung-debloat.cmd       # Windows double-click entry (cmd.exe)
scamsung-debloat.ps1       # Windows double-click entry (PowerShell)
lists/basic.txt            # 51 packages, each explained
lists/light.txt            # 98
lists/heavy.txt            # 126
lists/README.md            # preset file format
lang/pt-BR.sh              # interface strings, complete baseline
lang/en.sh                 # English overlay
lang/es.sh                 # Spanish overlay
tests/adb                  # fake adb (Galaxy One UI 9 simulator)
tests/run.sh               # test suite
README_PT-BR.md            # this file, em português
```

## Contributing

Issues and PRs are welcome. Most wanted: **package reports** (what a package does
on your specific firmware — open an issue with `explain` output), new **interface
languages** (one file in `lang/`, `self-test` validates parity), and preset line
improvements. Run `bash tests/run.sh` before sending anything — 73/73 is the bar.

## Credits

- [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat) — **preset base**,
  tested on the author's own device (One UI 8/8.5/9)
- [invinciblevenom/debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android) — original idea and `Tweaks.bat`
- [Universal Android Debloater NG](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) — risk levels and package descriptions
- [TheOneAndOnlyAtlas/Samsung-Debloater](https://github.com/TheOneAndOnlyAtlas/Samsung-Debloater) — One UI 7/8 reference

## License

MIT — see [LICENSE](LICENSE). Use at your own risk; there's a preview before
every removal for a reason.
