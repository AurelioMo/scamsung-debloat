# scamsung

Limpar o Galaxy sem root, sem dor de cabeça e sem quebrar o básico.

Isto é uma reescrita do
[debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android),
que era um `.bat` de Windows, ficou parado na One UI 6.1 e foi arquivado com aviso
para não usar depois de janeiro de 2025. Mantive a ideia, atualizei as listas para a
One UI 8/9 e adicionei as proteções que faltavam: antes de remover o que quer que
seja, o script mostra tudo e espera um `sim`.

Nada de root. Tudo é `adb shell pm ... --user 0`, ou seja, esconde o app do seu
perfil — dá para voltar atrás com `./scamsung restore`.

## O que ele faz, em resumo

- três presets com explicação em cada pacote: **basic** (113), **light** (193) e **heavy** (264);
- antes de aplicar, você vê linha por linha o que sai e o que é cada pacote;
- uma deny-list protege o que não pode sair (Play Store, telefone, teclado, IMS/VoLTE...);
- se o firmware novo renomeou um pacote, ele simplesmente é ignorado — não tem erro
  bobo de `Failure [not installed for 0]`;
- se a desinstalação falhar, ele tenta desativar o app no lugar;
- guarda tudo que fez e volta atrás quando você pedir;
- e o famoso `Tweaks.bat` virou `./scamsung tweaks`, agora com verificação e reset exato.

## Requisitos

- `adb` (platform-tools) — o script procura sozinho em PATH, Homebrew, `/usr/bin`,
  snap e Android SDK;
- Bash 3.2+ (o que já vem no macOS; no Linux e no Git Bash idem);
- Depuração USB ligada no Galaxy.

| Sistema | Como rodar | Instalando o adb |
|---------|-----------|------------------|
| macOS | `./scamsung ...` | `brew install --cask android-platform-tools` |
| Linux | `./scamsung ...` | `sudo apt install android-tools-adb` (Debian/Ubuntu), `sudo dnf install android-tools` (Fedora), `sudo pacman -S android-tools` (Arch) |
| Windows | `scamsung.cmd ...` ou `scamsung.ps1 ...` | `winget install --id Google.PlatformTools -e` e `winget install --id Git.Git -e` |

No Windows o arquivo principal é o mesmo script; os `.cmd`/`.ps1` só acham o
`bash.exe` do Git for Windows e repassam os argumentos. WSL também funciona —
rode `./scamsung` de dentro dele. Não precisa de Admin.

## Começando

No celular:

1. Configurações → Sobre o telefone → Informações do software
2. Toque 7× em **Número da versão**
3. Opções do desenvolvedor → **Depuração USB**
4. Conecte o cabo e aceite **Permitir depuração USB?**

Depois:

```bash
chmod +x scamsung
./scamsung doctor     # confere host, adb, aparelho e versão do Android/One UI
./scamsung list       # os presets
./scamsung explain com.facebook.katana
./scamsung apply basic
```

Sem cabo, `./scamsung wireless` guia o pareamento pela depuração sem fio.

## Presets

Três arquivos em `lists/`, cada um autocontido. Cada linha é um pacote seguido da
explicação do que ele é e do que você perde:

| Preset | Pacotes | O que remove | Para quem |
|--------|--------:|--------------|-----------|
| `basic` | 113 | pré-instalados, Facebook/Microsoft, apps Google opcionais, AR, Edge | todo mundo; mantém conta Samsung, Galaxy AI e Health |
| `light` | 193 | tudo do basic + Bixby, conta/cloud/pagamentos Samsung, apps Samsung | quem não usa conta Samsung |
| `heavy` | 264 | tudo do light + Device Care, Notes, Calculadora, Quick Share, TTS | máximo que ainda é reversível |

O `apply` começa pela prévia — sempre, com `-n` ou sem:

```
  ~ com.facebook.katana  — Facebook
  ~ com.android.printspooler  — impressão do Android: só remova se você nunca imprime

  remover:              97
  já removidos antes:   3
  ausentes no aparelho: 13 (ignorados)

Digite sim para continuar:
```

Sem o `sim`, nada sai do aparelho. `-y` pula a pergunta, mas a prévia continua no ar.

Também dá para apontar direto:

```bash
./scamsung apply --only com.facebook.katana
./scamsung --skip com.samsung.android.app.watchmanager apply light
```

## Tweaks (o antigo `Tweaks.bat`)

```bash
./scamsung tweaks                 # conjunto leve
./scamsung tweaks --performance   # o modo agressivo do .bat original
./scamsung tweaks --status        # o que mudou e qual era o valor original
./scamsung tweaks --reset         # desfaz exatamente o que ESTE script mudou
./scamsung tweaks --ram-plus off|on
```

O conjunto leve: animações a `0.5x`, freezer de apps em background, bateria
adaptativa ligada, menos varredura de Wi-Fi/Bluetooth.

O `--performance` é o miolo do `.bat`:

| Ação | Efeito |
|------|--------|
| animações a `0.35` | valor do .bat original |
| `com.samsung.android.game.gos` desativado + `pm clear` | jogos param de ser limitados; estatísticas de jogo são apagadas |
| `ram_expand_size 0` | RAM Plus desligada |
| `zram_enabled 0` | sem compressão de memória, se a chave existir |
| `game_auto_temperature_control 0` | sem controle térmico em jogos |

O preço de letra miúda: mais calor em sessões longas e, em aparelhos com pouca
RAM, apps sendo reabertos com mais frequência. Chave que não existe no seu
firmware é pulada com aviso, não inventada. O `--reset` devolve os settings e ainda
reativa o GOS.

## Segurança

O que o script garante:

- só age no que está instalado no **seu** aparelho — lista desatualizada não quebra nada;
- deny-list embutida cobre Play Services/Store, WebView, SystemUI, Configurações,
  One UI Home, telefone/dialer, IMS/VoLTE/Wi-Fi calling, teclado Samsung, Wi-Fi,
  timezone, `com.samsung.android.kgclient` (trava o aparelho com overlay),
  AOD, MTP e afins;
- desinstalação falhou? cai para `pm disable-user`;
- cada ação fica em `~/.local/share/scamsung/state.tsv` e em `logs/session-*.tsv`;
- `./scamsung restore` reinstala (`cmd package install-existing`) e reativa (`pm enable`).

O que ele **não** faz:

- não toca em `/system`, não precisa de root, não mexe em Knox nem Play Integrity;
- não apaga dados de usuário além do app que saiu;
- não libera espaço de verdade: `pm uninstall --user 0` esconde o app, o APK segue
  em `/system`. O ganho é RAM, bateria, privacidade e gaveta de apps vazia.

Avisos que importam:

- `light` e `heavy` tiram a conta Samsung (`com.osp.app.signin`): você perde Galaxy
  Store, Find My, backup, Wallet e recursos Galaxy AI. Não usa nada disso? Ok, mas
  era bom avisar antes.
- `heavy` tira TTS, Android System Intelligence, Device Care, Notes, Calculadora
  e Quick Share. Tenha substitutos instalados.
- OTA da Samsung pode reinstalar apps. Depois de atualizar, rode `status` e `apply`
  de novo.
- Reverter tudo: `./scamsung restore`. À mão, um pacote específico:
  `adb shell cmd package install-existing <pacote>` ou `adb shell pm enable <pacote>`.

## O que mudou em relação ao original

O `.bat` rodava `pm uninstall --user 0` em ~100–330 pacotes fixos, sem checar nada.
Em firmware novo isso produz desde erro inofensivo até coisa quebrada (o próprio
projeto removeu `com.android.cellbroadcastreceiver`, `kgclient`, `soundpicker`...).

1. Multiplataforma de verdade: bash 3.2, detecção de adb em Homebrew/apt/snap/
   Android SDK/winget, wrappers `.cmd`/`.ps1`, pareamento por Wi-Fi, tratamento de
   `unauthorized`/`offline`, sem `pause` nem `kill-server`.
2. One UI 8/9: lê `ro.build.version.oneui` e avisa em versões futuras; lista
   filtrada pelo que está instalado; fallback para disable; deny-list com o que o
   original removia e hoje dá problema.
3. Listas atualizadas: Galaxy AI, Smart Suggestions, Modes and Routines, Quick
   Share, Device Care, além dos preloads atuais (TikTok, LinkedIn etc.).
4. Presets auto-explicativos: cada pacote com comentário em pt-BR; `explain` mostra
   o que é, em quais presets está e o estado atual.
5. Prévia obrigatória, confirmação, log de sessão e restore exato.
6. Tweaks com verificação de cada setting e reset exato.
7. Auditoria cruzada com UAD-ng, Atlas, itxjobe, Willie169, Tom4tot e
   OutrageousStorm: 16 pacotes de risco fora, 19 seguros dentro. Detalhes em
   [`docs/auditoria-pacotes.md`](docs/auditoria-pacotes.md).

As listas vêm do projeto original, do
[UAD-ng](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
e de listas públicas de One UI 7–9. Validadas com um Galaxy simulado (Android 17 /
One UI 9); em aparelho real, use a prévia obrigatória como rede de segurança.

## Testes

Sem aparelho, com um `adb` falso que finge um Galaxy One UI 9:

```bash
bash tests/run.sh
```

Cobre self-test, doctor, scan, prévia, apply, deny-list, pacote inexistente,
restore, modo disable, `--skip`, presets e tweaks (idempotência, status, reset,
`--performance`, `--ram-plus`).

## Estrutura

```
scamsung            # a CLI
scamsung.cmd        # atalho Windows (cmd.exe)
scamsung.ps1        # atalho Windows (PowerShell)
lists/basic.txt     # preset básico (113 pacotes, cada um com explicação)
lists/light.txt     # preset recomendado (193)
lists/heavy.txt     # preset agressivo (264)
lists/README.md     # formato dos presets
tests/adb           # adb falso
tests/run.sh        # suíte de fumaça
docs/oneui-compat.md        # notas de compatibilidade One UI 8/9
docs/auditoria-pacotes.md   # o que é seguro remover e por quê
```

Estado e logs: `~/.local/share/scamsung/` (`state.tsv`, `tweaks.tsv`,
`logs/session-*.tsv`). Muda com `SCSUNG_DATA_DIR`.

## Créditos

- [invinciblevenom/debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android) — ideia e listas base, `Tweaks.bat`
- [Universal Android Debloater NG](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) — descrições e nível de risco
- [TheOneAndOnlyAtlas/Samsung-Debloater](https://github.com/TheOneAndOnlyAtlas/Samsung-Debloater) — referência One UI 7/8
- [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat) — nomes verificados na One UI 8/8.5/9
- XDA e Technastic pelas listas públicas de bloatware Samsung
