```
  ╔═╗┌─┐┌─┐┌┬┐┌─┐┬ ┬┌┐┌┌─┐
  ╚═╗│  ├─┤│││└─┐│ │││││ ┬
  ╚═╝└─┘┴ ┴┴ ┴└─┘└─┘┘└┘└─┘
      ··· d e b l o a t ···
```

# scamsung-debloat

[![Release do GitHub](https://img.shields.io/github/v/release/AurelioMo/scamsung-debloat)](https://github.com/AurelioMo/scamsung-debloat/releases)
[![Licença do GitHub](https://img.shields.io/github/license/AurelioMo/scamsung-debloat)](LICENSE)
[![Plataforma](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](#requisitos)
[![Shell: bash 3.2+](https://img.shields.io/badge/shell-bash%203.2%2B-green)](scamsung-debloat)

**Remova o bloatware da Samsung sem root** no One UI 8/9 — prévia primeiro,
confirmação digitada, undo com um comando. Interface em Português, English e Español.

🌐 [Site do projeto](https://aureliomo.github.io/scamsung-debloat/) ·
📄 [English version](README.md)

## Começo rápido de 60 segundos

```bash
# 1. adb, uma vez por computador:
brew install --cask android-platform-tools     # macOS
winget install --id Google.PlatformTools -e    # Windows
sudo apt install android-tools-adb             # Debian/Ubuntu

# 2. celular, uma vez: Configurações → Sobre o telefone → toque 7× em
#    "Número de compilação" → Opções do desenvolvedor → Depuração USB
#    → conecte o cabo → Permitir

# 3. baixe a ferramenta e dê dois cliques nela (scamsung-debloat.cmd no Windows)
git clone https://github.com/AurelioMo/scamsung-debloat.git

# 4. no menu: 1 → diagnóstico, 2 → aplicar, "basic",
#    leia a prévia, digite: sim
```

**Nada muda no celular antes de você digitar `sim`.** Sem root, sem Knox,
sem desbloqueio de bootloader — e a opção 4 do menu restaura tudo.

## Por que este projeto existe

O [UAD](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation)
e o [Canta](https://github.com/samolego/Canta) são excelentes — este projeto
reaproveita a pesquisa de risco deles. O scamsung-debloat cobre o que sobra:
gente que não quer instalar outro app nem manter o Shizuku rodando para remover
apps, que quer um menu no próprio idioma, presets testados especificamente no
One UI 8/9 (baseados nas [listas da comunidade do itxjobe](https://github.com/itxjobe/samsungdebloat))
e um caminho de restore que é uma opção de menu, não um reset de fábrica. É um
script bash único — o modelo de segurança inteiro cabe na sua cabeça.

## ⚠️ Letras miúdas honestas (leia)

> - Tudo roda via `adb shell pm … --user 0`: os apps saem do seu perfil de
>   usuário, não de `/system`. Knox, garantia e Play Integrity ficam intactos.
> - **Você sempre vê a lista completa de remoção primeiro** e precisa digitar `sim`.
> - **Atualizações OTA** da Samsung podem reinstalar apps — rode o preset de
>   novo, nada quebra.
> - Apps que **dependem de serviços Samsung** (watch faces, plugins do Pay,
>   conteúdo da Galaxy Store) quebram sem a dependência. Cada linha do preset avisa.
> - **Validado contra um adb falso** que simula One UI 9 (veja `tests/`), não no
>   seu firmware específico. A prévia é a conferência final — leia.
> - Nenhum espaço de armazenamento é liberado: os APKs ficam na partição de
>   sistema, somente leitura. O ganho é RAM, bateria, privacidade e gaveta limpa.
>   Não são gigabytes.

## Conteúdo

- [Começo rápido de 60 segundos](#começo-rápido-de-60-segundos)
- [Por que este projeto existe](#por-que-este-projeto-existe)
- [Requisitos](#requisitos)
- [Uso: o menu](#uso-o-menu)
- [Presets](#presets)
- [Como é uma execução](#como-é-uma-execução)
- [Tweaks](#tweaks-opção-5-do-menu)
- [Restaurando](#restaurando)
- [FAQ](#faq)
- [Desinstalando](#desinstalando)
- [Testes](#testes)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Contribuindo](#contribuindo)
- [Créditos](#créditos)
- [Licença](#licença)

## Requisitos

| | O que você precisa |
|---|---|
| Celular | Qualquer Samsung Galaxy no One UI 8/9 (Android 16/17). Versões antigas funcionam; mais novas disparam aviso e rodam |
| Computador | `adb` (platform-tools) + macOS, Linux, ou Windows com [Git for Windows](https://git-scm.com/download/win) |
| Cabo | USB — ou pareamento Wi-Fi, opção 7 do menu (Android 11+) |

## Uso: o menu

Dois cliques no arquivo (`scamsung-debloat.cmd` no Windows; no macOS, na primeira
vez: clique com o botão direito → Abrir). Um menu numerado aparece, no idioma do
seu sistema:

```
  ╔═╗┌─┐┌─┐┌┬┐┌─┐┬ ┬┌┐┌┌─┐
  ╚═╗│  ├─┤│││└─┐│ │││││ ┬
  ╚═╝└─┘┴ ┴┴ ┴└─┘└─┘┘└┘└─┘
      ··· d e b l o a t ···
no root · fully reversible · One UI 8/9
  1) Diagnóstico do aparelho   ← confere adb + celular + versão do One UI (comece aqui)
  2) Aplicar preset            ← escolha basic / light / heavy, veja a prévia, confirme
  3) Ver o que você removeu    ← tudo o que esta ferramenta já removeu
  4) Restaurar tudo            ← desfaz tudo o que esta ferramenta fez
  5) Tweaks (GOS, RAM Plus…)   ← opções de desempenho, cada uma explicada no lugar
  6) Ver pacotes instalados    ← pesquise o que está no celular
  7) Parear por Wi-Fi          ← largue o cabo
  8) Sair
Escolha:
```

Primeira execução recomendada: **1** → **2** → `basic` → leia cada linha → digite `sim`.

## Presets

Arquivos de texto puro em `lists/` — um pacote por linha, cada um com explicação
em linguagem clara do que é e do que você perde. Os presets se aninham:
`heavy` ⊃ `light` ⊃ `basic`. Os números abaixo são de um Galaxy zerinho no
simulador de testes.

| Preset | Pacotes | O que sai | Risco |
|--------|--------:|-----------|-------|
| `basic` | 51 | Lixo pré-instalado: Facebook/Netflix/Booking/Amazon, apps Samsung duplicados (Notas, Calendário, Relógio, Calculadora, Internet, Health, Free, Members), Game Launcher, AR Emoji/Zone | **Baixo.** Nenhum componente de sistema; conta Samsung, Wallet e Galaxy AI ficam |
| `light` | 98 | `basic` + Chrome, Gmail, "Ok Google", Android Auto, Galaxy Themes, Samsung Pass, Wallet, Smart Switch, Bixby wakeup/Vision, Buscar meu telefone | **Médio.** Sem pagamentos Samsung nem Buscar meu telefone — substitua antes |
| `heavy` | 126 | `light` + YouTube, Maps, Gemini, Docs/Sheets/Slides, pilha de impressão, SmartThings, Interpreter, Samsung Email | **Médio-alto.** Máximo que ainda é reversível |

Nunca removidos, em nenhum preset nem pedido manual: **Play Store/Services,
SystemUI, Configurações, launcher One UI, telefone/discador, IMS/VoLTE/chamadas
Wi-Fi, teclado Samsung, assistente de configuração** — a deny-list embutida não
pode ser contornada digitando. Pacotes que não existem no seu aparelho são
ignorados, nunca inventados.

## Como é uma execução

Saída real contra o fake-adb da suíte de testes (seu celular mostra os próprios
números — aqui, 20 dos 51 pacotes do `basic` estavam de fato instalados):

```
==> Galaxy SM-S931B (e1q) · Android 17 · One UI 9.0
==> 55 pacotes no aparelho · preset "basic" marca 51

  ~ com.facebook.katana          — Facebook
  ~ com.netflix.mediaclient      — Netflix
  ~ com.samsung.android.aremoji  — AR Emoji
  ~ com.sec.android.app.sbrowser — Samsung Internet
    … mais 46, cada um explicado …

Digite sim para continuar: sim
==> Aplicando (desinstalar)…
==> removidos: 20 · ignorados (ausentes): 31
==> desfaça quando quiser: ./scamsung-debloat restore
```

Falhas de desinstalação caem automaticamente para *desativar* o app (dados
preservados).

## Tweaks (opção 5 do menu)

Todo tweak grava o valor original e é exatamente reversível com `r`:

| Opção | O que faz | O ônus honesto |
|-------|-----------|----------------|
| `p` **desempenho** (padrão) | Desativa o GOS (throttling de jogos da Samsung), RAM Plus + zram off, animações em 0.35x, controle térmico em jogos off | Mais calor sob carga; multitarefa pode recarregar apps; estatísticas de jogo do GOS são apagadas (`pm clear`) |
| `a` **leve** | Animações em 0.5x, congelador de apps em segundo plano, bateria adaptativa ON, menos varredura Wi-Fi/Bluetooth em segundo plano | Precisão um pouco pior de localização por rede |
| `s` **status** | Mostra cada tweak alterado por esta ferramenta, com valores originais | — |
| `r` **reset** | Restaura exatamente o que **esta ferramenta** mudou, reativa o GOS | — |

Configurações que não existem no seu firmware são ignoradas com aviso.

## Restaurando

- **Tudo:** opção **4** do menu.
- **Um app, na mão:** `adb shell cmd package install-existing <pacote>` (removido)
  ou `adb shell pm enable <pacote>` (desativado).
- **Tweaks:** `./scamsung-debloat tweaks --reset`.
- **Registros:** `~/.local/share/scamsung-debloat/` — `state.tsv`, `tweaks.tsv`,
  `logs/session-*.tsv`. Apagar essa pasta perde o restore automático; os apps
  ainda voltam manualmente.

<details>
<summary><b>Avançado: flags de CLI</b> (o menu cobre o uso normal)</summary>

```bash
./scamsung-debloat doctor            # diagnóstico
./scamsung-debloat list              # mostra os presets
./scamsung-debloat apply basic       # prévia → digite "sim" → aplica
./scamsung-debloat apply --only com.facebook.katana
./scamsung-debloat explain <pacote>  # o que é este pacote, em quais presets está
./scamsung-debloat scan [termo]      # pacotes instalados contendo <termo>
./scamsung-debloat status            # o que a ferramenta já removeu
./scamsung-debloat restore           # desfaz tudo
./scamsung-debloat tweaks [--performance|--status|--reset|--ram-plus off|on]
./scamsung-debloat wireless          # parear por Wi-Fi
./scamsung-debloat self-test         # valida os presets (sem celular)

# opções:
#   -y, --yes        pula a digitação (a prévia continua sempre visível)
#       --disable    desativa em vez de desinstalar (mantém dados)
#       --skip a,b   pula estes pacotes
#       --serial S   escolhe o aparelho quando há vários
#   -v / -q          verboso / silencioso
```

Ambiente: `SCAMSUNG_LANG=pt|en|es` (força o idioma), `ANDROID_SERIAL`,
`SCAMSUNG_DEBLOAT_DATA_DIR`, `NO_COLOR=1`.

</details>

## FAQ

**Precisa de root? Dispara Knox ou quebra Play Integrity?**
Não, em todos os casos. Remoção `--user 0` é recurso nativo do Android — nada
toca o bootloader, `/system`, Knox ou atestação. Apps de banco e Google Pay
continuam funcionando.

**Como recupero um app removido?**
Opção 4 do menu restaura tudo. Um app só, na mão:
`adb shell cmd package install-existing <pacote>`.

**Uma atualização OTA traz o bloatware de volta?**
Às vezes. Rode o preset de novo depois da atualização; nada quebra nesse meio-tempo.

**Libera espaço de armazenamento?**
Não — os APKs ficam na partição de sistema, somente leitura. Os ganhos são RAM,
dreno de bateria em segundo plano, privacidade e gaveta de apps limpa.

**E se um app que eu uso depender de um removido?**
O recurso dependente para de funcionar até o restore. Cada linha do preset
explica a consequência e a prévia mostra a lista completa antes.

**Posso remover um app só?**
`./scamsung-debloat apply --only com.facebook.katana`. A deny-list continua
valendo; `explain <pacote>` diz o que qualquer coisa é antes de você tocar nela.

## Desinstalando

A ferramenta não instala nada no seu computador — é um script só:

1. Opção **4** do menu para voltar o celular ao estado de fábrica.
2. Apague a pasta clonada.
3. Apague a pasta de estado: `rm -rf ~/.local/share/scamsung-debloat` (Linux/macOS).

Desative a depuração USB no celular se ativou só para isso.

## Testes

A suíte roda contra um **adb falso** que simula um Galaxy no One UI 9 — sem
celular, sem tocar em nenhum aparelho real:

```bash
bash tests/run.sh
```

73 verificações: self-test, doctor, scan, prévia obrigatória, apply, deny-list,
pacotes inexistentes, restore, modo disable, `--skip`, presets e todos os caminhos
de tweak (idempotência, status, reset exato, `--performance`, `--ram-plus`).

## Estrutura do projeto

```
scamsung-debloat           # a ferramenta
scamsung-debloat.cmd       # entrada de dois cliques no Windows (cmd.exe)
scamsung-debloat.ps1       # entrada de dois cliques no Windows (PowerShell)
lists/basic.txt            # 51 pacotes, cada um explicado
lists/light.txt            # 98
lists/heavy.txt            # 126
lists/README.md            # formato dos arquivos de preset
lang/pt-BR.sh              # strings da interface, base completa
lang/en.sh                 # overlay em inglês
lang/es.sh                 # overlay em espanhol
tests/adb                  # adb falso (simulador Galaxy One UI 9)
tests/run.sh               # suíte de testes
docs/                      # site do projeto (GitHub Pages) + notas de compat
README.md                  # este arquivo, in English
```

## Contribuindo

Issues e PRs são bem-vindos. O mais útil: **relatos de pacotes** (o que um pacote
faz no seu firmware — abra issue com a saída do `explain`), novos **idiomas de
interface** (um arquivo em `lang/`, o `self-test` valida a paridade) e melhorias
nas linhas dos presets. Rode `bash tests/run.sh` antes de enviar qualquer coisa —
a régua é 73/73.

## Créditos

- [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat) — **base dos presets**,
  testada no aparelho do próprio autor (One UI 8/8.5/9)
- [invinciblevenom/debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android) — ideia original e `Tweaks.bat`
- [Universal Android Debloater NG](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) — níveis de risco e descrições de pacotes
- [TheOneAndOnlyAtlas/Samsung-Debloater](https://github.com/TheOneAndOnlyAtlas/Samsung-Debloater) — referência One UI 7/8

## Licença

MIT — veja [LICENSE](LICENSE). Use por sua conta e risco; há uma prévia antes de
cada remoção por um motivo.
