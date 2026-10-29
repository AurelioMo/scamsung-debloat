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

**Remove Samsung bloatware without root** on One UI 8/9 — macOS, Linux and Windows.

🌐 [Site](https://aureliomo.github.io/scamsung-debloat/) · 📄 [Versão em Português](README_PT-BR.md)
A modern rewrite of the archived
[debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android),
with presets based on
[itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat).

**No terminal skills needed: double-click the file, pick numbers from a menu.**
The whole interface — menus, warnings, errors — follows your OS language
(Português, English, Español; override with `SCAMSUNG_LANG=pt|en|es`).

## 60-second quickstart

1. Install `adb` once: `brew install --cask android-platform-tools` (macOS) ·
   `winget install --id Google.PlatformTools -e` (Windows) ·
   `sudo apt install android-tools-adb` (Debian/Ubuntu).
2. On the phone: tap **Build number** 7× → **Developer options → USB debugging** ON.
3. [Download the ZIP](https://github.com/AurelioMo/scamsung-debloat/archive/refs/heads/main.zip)
   or `git clone`, then double-click `scamsung-debloat` (`.cmd` on Windows).
4. Menu: **1** diagnostics → **2** apply → `basic` → read the preview → type `sim`.

Nothing changes on the phone before you type `sim`. Details below.

## Why another debloat tool?

[UAD](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
and [Canta](https://github.com/samolego/Canta) are excellent apps, and this
project reuses their risk knowledge. scamsung-debloat exists for what's left
over: people who don't want to install another app or keep Shizuku running, who
want a menu in their own language, presets built for One UI 8/9 specifically
(from [itxjobe's community-tested lists](https://github.com/itxjobe/samsungdebloat)),
and a restore path that's one menu option instead of a factory reset. It's one
auditable bash script — the whole safety model fits in your head.

## Contents

- [⚠️ Read this first](#-read-this-first--always)
- [Requirements](#requirements)
- [Getting started — two clicks, no typing](#getting-started--two-clicks-no-typing)
- [Presets](#presets)
- [What applying a preset looks like](#what-applying-a-preset-looks-like)
- [Tweaks](#tweaks-menu-option-5)
- [Restoring](#restoring)
- [What this tool does NOT do](#what-this-tool-does-not-do)
- [Safety design](#safety-design)
- [FAQ](#faq)
- [Uninstalling](#uninstalling-the-tool)
- [Tests](#tests)
- [Project structure](#project-structure)
- [Credits](#credits)
- [License](#license)

---

## ⚠️ Read this first — always

> **Debloating is reversible here, but it is never risk-free.**
>
> - Everything this tool does runs through `adb shell pm ... --user 0`: apps are
>   removed from your user profile, not from `/system`. Root is never touched,
>   Knox does not trip, warranty and Play Integrity stay intact.
> - **Before anything is removed, you always see the full list** and must type
>   `sim` to continue. No surprises.
> - Removed apps can come back after a **Samsung OTA update**. That's normal —
>   just run it again.
> - Third-party apps that depend on Samsung services (Samsung pay plugins, watch
>   faces, Galaxy Store content) **can break** when their dependency is removed.
>   Read the preset lines; each one explains what stops working.
> - Nothing here was tested on **your** device. It was validated against a fake
>   adb simulating a Galaxy (see `tests/`). You are the final preview.
> - You are responsible for what you confirm. When in doubt, remove less.

---

## Requirements

| | What you need |
|---|---|
| Phone | Any Samsung Galaxy on One UI 8/9 (Android 16/17). Older versions work, newer ones trigger a warning first |
| Computer | `adb` (platform-tools) installed and either macOS, Linux, or Windows with [Git for Windows](https://git-scm.com/download/win) |
| Cable | USB, or Wi-Fi for wireless pairing (menu option 7) |

Install adb once:

- **macOS:** `brew install --cask android-platform-tools`
- **Windows:** `winget install --id Google.PlatformTools -e`
- **Linux:** `sudo apt install android-tools-adb` (Debian/Ubuntu), `sudo dnf install android-tools` (Fedora), `sudo pacman -S android-tools` (Arch)

Prepare the phone once:

1. **Settings → About phone → Software information**
2. Tap **Build number** 7 times → Developer options unlocked
3. **Settings → Developer options → USB debugging** → ON
4. Plug the cable and tap **Allow** on the phone's prompt

## Getting started — two clicks, no typing

1. Download/clone this repo.
2. Double-click:
   - **Windows:** `scamsung-debloat.cmd`
   - **macOS:** `scamsung-debloat` (first time only: right-click → Open, then Open again)
   - **Linux:** `scamsung-debloat` → choose *Run in Terminal* when asked
     (if nothing happens, the file needs its executable bit: right-click → Properties → "Allow executing file as program")
3. A numbered menu appears. **Type a number, press Enter.** That's the whole interface:

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

> The menu follows your OS language automatically (Português, English, Español —
> example above in English). Every destructive path shows a preview first and
> asks for a typed confirmation — invalid input never applies anything.

Recommended first run: **1** (diagnostics) → **2** → `basic` → read the preview →
type `sim`. You can stop at any point before the `sim` and nothing happens.

## Presets

Each preset is a plain text file in `lists/` — one package per line, each with a
plain-language explanation of what it is and what you lose. Presets nest:
`heavy` ⊃ `light` ⊃ `basic`.

| Preset | Packages | What goes away | Risk |
|--------|---------:|----------------|------|
| `basic` | 51 | Preinstalled junk only: Facebook/Netflix/Booking/Amazon, duplicate Samsung user apps (Notes, Calendar, Clock, Calculator, Messages, Internet, Health, Free, Members), Game Launcher, AR Emoji/Zone | **Low.** No system component is touched; Samsung account, Wallet and Galaxy AI stay. Worst case: an app you liked is gone — restore brings it back |
| `light` | 98 | Everything in `basic`, plus: Chrome, Gmail, "Ok Google", Android Auto, Galaxy Themes, Samsung Pass, Wallet, Smart Switch, Bixby wakeup/Vision, Find My Mobile | **Medium.** You lose Samsung payments and Find My Mobile. Only pick this if you already replaced those with Google/third-party apps |
| `heavy` | 126 | Everything in `light`, plus: YouTube, Maps, Gemini, Docs/Sheets/Slides, printing stack, SmartThings, Interpreter, Samsung Email | **Medium-high.** Maximum that is still reversible. Have replacements installed first |

What never gets removed, in any preset: Play Store/Services, SystemUI, Settings,
One UI launcher, phone/dialer, IMS/VoLTE/Wi-Fi calling, Samsung keyboard, setup
wizard, and anything else on the built-in **deny-list**. The tool also *skips*
any package that isn't actually installed on your device instead of erroring out.

## What applying a preset looks like

Option **2** always starts with the preview — there is no way to skip it:

```
  ~ com.facebook.katana  — Facebook
  ~ com.sec.android.app.sbrowser  — Samsung Internet (navegador)
  ...

  remover:              47
  já removidos antes:   2
  ausentes no aparelho: 2 (ignorados)

Digite sim para continuar:
```

Each package prints with its explanation. Only after you type `sim` does anything
leave the phone. Uninstall failures automatically fall back to *disabling* the
app instead (data preserved).

## Tweaks (menu option 5)

All tweaks record their original value and are exactly reversible with `r`:

| Option | What it does | The honest trade-off |
|--------|--------------|----------------------|
| `p` **performance** (default) | Disables GOS (Samsung's game throttling), turns off RAM Plus + zram, animations at 0.35x, disables in-game thermal control | More heat under load; multitasking may reload apps more; GOS play statistics are wiped (`pm clear`) |
| `a` **light** | Animations at 0.5x, background app freezer, adaptive battery ON, less background Wi-Fi/Bluetooth scanning | Slightly worse network-based location accuracy |
| `s` **status** | Shows every tweak this tool changed and the original value | — |
| `r` **reset** | Restores exactly what **this tool** changed, re-enables GOS | — |

Settings that don't exist on your firmware are skipped with a warning, never invented.

## Restoring

- **Everything:** menu option **4** (`restaurar tudo`).
- **One app, by hand:** `adb shell cmd package install-existing <package>` or
  `adb shell pm enable <package>` if it was disabled.
- Full log of every action: `~/.local/share/scamsung-debloat/`
  (`state.tsv`, `tweaks.tsv`, `logs/session-*.tsv`).

## What this tool does NOT do

- ❌ No root, no bootloader, no custom recovery — ever.
- ❌ Doesn't flash, wipe, or modify `/system`; storage space isn't freed (APKs
  stay in the system partition — the win is RAM, battery, privacy, and an empty
  app drawer).
- ❌ Doesn't block OTA updates or guarantee a reinstalled app stays gone.
- ❌ Doesn't promise better benchmark scores. It removes apps you don't want;
  performance gains are a side effect, not the contract.

## Safety design

1. **Deny-list first:** critical packages can't even be typed in by hand.
2. **Device-filtered:** only what exists on *your* phone is touched — new firmware
   with renamed packages degrades to "left some bloat behind", never to breakage.
3. **Preview is mandatory:** the removal list is always shown; confirmation is
   always required.
4. **Fallback:** uninstall fails ⇒ app is disabled instead.
5. **Undo:** every action is logged and `Restaurar tudo` reverts it.

---

<details>
<summary><b>Advanced: non-interactive CLI flags</b> (optional — the numbered menu above covers normal use)</summary>

For scripting or repeat runs, the same operations exist as flags:

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

Environment: `ANDROID_SERIAL` (same as `--serial`), `SCAMSUNG_LANG=pt|en|es`
(force the UI language), `SCAMSUNG_DEBLOAT_DATA_DIR` (state/logs location),
`NO_COLOR=1`.

</details>

## FAQ

**Does scamsung-debloat require root?**
No. It only runs `adb shell pm … --user 0`, the same ADB commands a power user
would type by hand. Apps are removed from your user profile, not from the
system partition.

**Will it trip Knox, void my warranty or break Play Integrity?**
No. `--user 0` package removal is a stock Android feature exposed through ADB —
nothing touches the bootloader, `/system`, Knox or device attestation. Banking
apps and Google Pay keep working.

**Which devices are supported?**
Built and validated for Samsung Galaxy devices running One UI 8/9 (Android
16/17). Older One UI versions work the same way; newer, unseen versions trigger
a warning but still run, because the tool only touches packages that actually
exist on the phone.

**How do I get a removed app back?**
Menu option **4** (*Restore everything*) brings back everything this tool
removed. Single app, by hand: `adb shell cmd package install-existing <package>`.

**Will a Samsung OTA update bring the bloatware back?**
Sometimes. OTAs can reinstall Samsung apps — just run the same preset again.
Nothing breaks in the meantime.

**Does debloating free up storage space?**
No. The APKs stay in the read-only system partition. The gains are RAM,
background battery drain, privacy and a clean app drawer — not gigabytes.

**What if an app I keep depends on something a preset removes?**
The dependent feature stops working (e.g. Samsung watch faces need Samsung
apps). Every preset line explains what breaks, the preview shows the full list
before anything happens, and restore always brings the dependency back.

**Can I remove just one specific app?**
Yes: `./scamsung-debloat apply --only com.facebook.katana`. The deny-list still
applies — `explain <package>` tells you what anything is before you touch it.

**Where is the log of what the tool did?**
`~/.local/share/scamsung-debloat/` — `state.tsv` (pending restores),
`tweaks.tsv` (original tweak values) and `logs/session-*.tsv` (every action).

## Uninstalling the tool

The tool installs nothing on your computer — it is one script. To remove it
completely:

1. Run menu option **4** (*Restore everything*) so the phone goes back to stock.
2. Delete the cloned/downloaded folder.
3. Delete the state folder: `rm -rf ~/.local/share/scamsung-debloat`.

Disable USB debugging on the phone if you enabled it only for this.

## Tests

The suite runs against a **fake adb** that simulates a Galaxy on One UI 9 — no
phone required, and no real device is ever touched by the tests:

```bash
bash tests/run.sh
```

73 checks: self-test, doctor, scan, mandatory preview, apply, deny-list,
nonexistent packages, restore, disable mode, `--skip`, presets, and every tweak
path (idempotence, status, exact reset, `--performance`, `--ram-plus`).

## Project structure

```
scamsung-debloat          # the tool
scamsung-debloat.cmd      # Windows double-click entry (cmd.exe)
scamsung-debloat.ps1      # Windows double-click entry (PowerShell)
lists/basic.txt           # 51 packages, each explained
lists/light.txt           # 98
lists/heavy.txt           # 126
lists/README.md           # preset file format
lang/pt-BR.sh             # interface strings, complete baseline
lang/en.sh                # English overlay
lang/es.sh                # Spanish overlay
tests/adb                 # fake adb (Galaxy One UI 9 simulator)
tests/run.sh              # test suite
docs/oneui-compat.md      # One UI 8/9 compatibility notes (pt-BR)
docs/auditoria-pacotes.md # package risk audit (pt-BR, historical)
docs/index.html           # project website (GitHub Pages)
README_PT-BR.md           # this file, em português
```

## Contributing

Issues and PRs are welcome. Most wanted: **package reports** (what a package
does on your specific firmware — open an issue with `explain` output), new
**interface languages** (one file in `lang/`, `self-test` validates parity), and
preset line improvements. Run `bash tests/run.sh` before sending anything —
73/73 is the bar.

## Credits

- [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat) — **preset base**,
  tested on the author's own device (One UI 8/8.5/9)
- [invinciblevenom/debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android) — original idea and `Tweaks.bat`
- [Universal Android Debloater NG](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) — risk levels and package descriptions
- [TheOneAndOnlyAtlas/Samsung-Debloater](https://github.com/TheOneAndOnlyAtlas/Samsung-Debloater) — One UI 7/8 reference

## License

MIT — see [LICENSE](LICENSE). Use at your own risk; there's a preview before
every removal for a reason.
