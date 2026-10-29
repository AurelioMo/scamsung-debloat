```
  ╔═╗┌─┐┌─┐┌┬┐┌─┐┬ ┬┌┐┌┌─┐
  ╚═╗│  ├─┤│││└─┐│ │││││ ┬
  ╚═╝└─┘┴ ┴┴ ┴└─┘└─┘┘└┘└─┘
      ··· d e b l o a t ···
```

# scamsung-debloat

[![Licença: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Plataforma](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue)](#requisitos)
[![Shell: bash 3.2+](https://img.shields.io/badge/shell-bash%203.2%2B-green)](scamsung-debloat)

**Remova o bloatware da Samsung sem root** na One UI 8/9 — macOS, Linux e Windows.

🌐 [Site](https://aureliomo.github.io/scamsung-debloat/) · 📄 [English version](README.md)

Reescrita moderna do arquivado
[debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android),
com presets baseados no
[itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat).

**Não precisa saber terminal: dois cliques no arquivo, escolha números num menu.**

A interface fala **o seu idioma** — o script segue o idioma do sistema
automaticamente (Português, English, Español) e todos os fluxos, menus, avisos e
mensagens de erro são traduzidos. Force com `SCAMSUNG_LANG=pt|en|es` se quiser.
Novos idiomas são um arquivo em `lang/`; o `self-test` confere se as traduções
continuam sincronizadas.

## Sumário

- [⚠️ Leia isto primeiro](#️-leia-isto-primeiro--sempre)
- [Requisitos](#requisitos)
- [Começando — dois cliques, sem digitar](#começando--dois-cliques-sem-digitar)
- [Presets](#presets)
- [Como é aplicar um preset](#como-é-aplicar-um-preset)
- [Tweaks](#tweaks-opção-5-do-menu)
- [Restaurando](#restaurando)
- [O que esta ferramenta NÃO faz](#o-que-esta-ferramenta-não-faz)
- [Desenho de segurança](#desenho-de-segurança)
- [Perguntas frequentes](#perguntas-frequentes)
- [Desinstalando](#desinstalando-a-ferramenta)
- [Testes](#testes)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Créditos](#créditos)
- [Licença](#licença)

---

## ⚠️ Leia isto primeiro — sempre

> **Debloat aqui é reversível, mas nunca é livre de risco.**
>
> - Tudo que a ferramenta faz passa por `adb shell pm ... --user 0`: os apps são
>   removidos do seu perfil de usuário, não da `/system`. Root nunca é tocado,
>   o Knox não estoura, garantia e Play Integrity continuam intactos.
> - **Antes de remover qualquer coisa, você sempre vê a lista completa** e precisa
>   digitar `sim` para continuar. Sem surpresas.
> - Apps removidos podem voltar depois de uma **atualização OTA da Samsung**.
>   É normal — rode de novo.
> - Apps de terceiros que dependem de serviços Samsung (plugins do Samsung Pay,
>   watch faces, conteúdo da Galaxy Store) **podem quebrar** quando a dependência
>   é removida. Leia as linhas do preset; cada uma explica o que para de funcionar.
> - Nada aqui foi testado no **seu** aparelho. Foi validado contra um adb falso
>   que simula um Galaxy (veja `tests/`). Você é a prévia final.
> - Você é responsável pelo que confirmar. Na dúvida, remova menos.

---

## Requisitos

| | O que você precisa |
|---|---|
| Celular | Qualquer Samsung Galaxy na One UI 8/9 (Android 16/17). Versões antigas funcionam, novas disparam um aviso antes |
| Computador | `adb` (platform-tools) instalado e macOS, Linux ou Windows com [Git for Windows](https://git-scm.com/download/win) |
| Cabo | USB, ou Wi-Fi para pareamento sem fio (opção 7 do menu) |

Instale o adb uma vez:

- **macOS:** `brew install --cask android-platform-tools`
- **Windows:** `winget install --id Google.PlatformTools -e`
- **Linux:** `sudo apt install android-tools-adb` (Debian/Ubuntu), `sudo dnf install android-tools` (Fedora), `sudo pacman -S android-tools` (Arch)

Prepare o celular uma vez:

1. **Configurações → Sobre o telefone → Informações do software**
2. Toque 7 vezes em **Número de compilação** → Opções do desenvolvedor liberadas
3. **Configurações → Opções do desenvolvedor → Depuração USB** → ligada
4. Conecte o cabo e toque em **Permitir** no aviso do celular

## Começando — dois cliques, sem digitar

1. Baixe/clone este repositório.
2. Dois cliques em:
   - **Windows:** `scamsung-debloat.cmd`
   - **macOS:** `scamsung-debloat` (só na primeira vez: botão direito → Abrir, e Abrir de novo)
   - **Linux:** `scamsung-debloat` → escolha *Executar no terminal* se perguntado
     (se nada acontecer, falta a permissão de execução: botão direito → Propriedades → "Permitir execução como programa")
3. Um menu numerado aparece. **Digite um número, aperte Enter.** Essa é toda a interface:

```
  ╔═╗┌─┐┌─┐┌┬┐┌─┐┬ ┬┌┐┌┌─┐
  ╚═╗│  ├─┤│││└─┐│ │││││ ┬
  ╚═╝└─┘┴ ┴┴ ┴└─┘└─┘┘└┘└─┘
      ··· d e b l o a t ···
sem root · reversível · One UI 8/9
  1) Diagnóstico do aparelho      ← confere adb + celular + versão da One UI (comece aqui)
  2) Aplicar preset               ← escolha basic / light / heavy, veja a prévia, confirme
  3) Ver o que você já removeu    ← tudo que esta ferramenta já removeu
  4) Restaurar tudo               ← desfaz tudo que esta ferramenta fez
  5) Tweaks (GOS, RAM Plus…)      ← opções de desempenho, cada uma explicada no lugar
  6) Ver pacotes instalados       ← pesquise o que está no celular
  7) Parear por Wi-Fi             ← dispense o cabo
  8) Sair
Escolha:
```

> O menu segue o idioma do seu sistema automaticamente (Português, English,
> Español — exemplo acima em português). Todo caminho destrutivo mostra a prévia
> antes e pede confirmação digitada — entrada inválida nunca aplica nada.

Primeira execução recomendada: **1** (diagnóstico) → **2** → `basic` → leia a
prévia → digite `sim`. Você pode parar em qualquer ponto antes do `sim` e nada
acontece.

## Presets

Cada preset é um arquivo de texto puro em `lists/` — um pacote por linha, cada um
com uma explicação em linguagem simples do que é e do que você perde. Os presets
se encaixam: `heavy` ⊃ `light` ⊃ `basic`.

| Preset | Pacotes | O que sai | Risco |
|--------|--------:|-----------|-------|
| `basic` | 51 | Só lixo pré-instalado: Facebook/Netflix/Booking/Amazon, apps Samsung de usuário duplicados (Notes, Calendar, Clock, Calculator, Messages, Internet, Health, Free, Members), Game Launcher, AR Emoji/Zone | **Baixo.** Nenhum componente de sistema é tocado; conta Samsung, Wallet e Galaxy AI ficam. Pior caso: um app que você gostava sumiu — o restore traz de volta |
| `light` | 98 | Tudo do `basic`, mais: Chrome, Gmail, "Ok Google", Android Auto, Galaxy Themes, Samsung Pass, Wallet, Smart Switch, Bixby wakeup/Vision, Find My Mobile | **Médio.** Você perde pagamentos Samsung e o Find My Mobile. Só escolha se já trocou isso por apps Google/terceiros |
| `heavy` | 126 | Tudo do `light`, mais: YouTube, Maps, Gemini, Docs/Sheets/Slides, pilha de impressão, SmartThings, Interpreter, Samsung Email | **Médio-alto.** Máximo que ainda é reversível. Instale substitutos antes |

O que nunca sai, em nenhum preset: Play Store/Services, SystemUI, Configurações,
launcher One UI, telefone/discador, IMS/VoLTE/Wi-Fi calling, teclado Samsung,
assistente de configuração e qualquer coisa da **deny-list** embutida. A ferramenta
também *pula* qualquer pacote que não esteja instalado no seu aparelho em vez de
dar erro.

## Como é aplicar um preset

A opção **2** sempre começa pela prévia — não existe como pular:

```
  ~ com.facebook.katana  — Facebook
  ~ com.sec.android.app.sbrowser  — Samsung Internet (navegador)
  ...

  remover:              47
  já removidos antes:   2
  ausentes no aparelho: 2 (ignorados)

Digite sim para continuar:
```

Cada pacote aparece com a explicação. Só depois de você digitar `sim` é que algo
sai do celular. Falhas de desinstalação caem automaticamente para *desativar* o
app (dados preservados).

## Tweaks (opção 5 do menu)

Todo tweak grava o valor original e é exatamente reversível com `r`:

| Opção | O que faz | O preço honesto |
|-------|-----------|------------------|
| `p` **performance** (padrão) | Desativa o GOS (estrangulamento de jogos da Samsung), desliga RAM Plus + zram, animações a 0.35x, desliga controle térmico de jogos | Mais calor sob carga; multitarefa pode reabrir mais apps; as estatísticas de jogo do GOS são apagadas (`pm clear`) |
| `a` **leves** | Animações a 0.5x, freezer de apps em segundo plano, bateria adaptativa LIGADA, menos varredura de Wi-Fi/Bluetooth em background | Localização por rede um pouco pior |
| `s` **status** | Mostra cada tweak que esta ferramenta mudou e o valor original | — |
| `r` **reset** | Restaura exatamente o que **esta ferramenta** mudou, reativa o GOS | — |

Ajustes que não existem no seu firmware são pulados com aviso, nunca inventados.

## Restaurando

- **Tudo:** opção **4** do menu (`Restaurar tudo`).
- **Um app, na mão:** `adb shell cmd package install-existing <pacote>` ou
  `adb shell pm enable <pacote>` se foi desativado.
- Log completo de cada ação: `~/.local/share/scamsung-debloat/`
  (`state.tsv`, `tweaks.tsv`, `logs/session-*.tsv`).

## O que esta ferramenta NÃO faz

- ❌ Sem root, sem bootloader, sem recovery custom — nunca.
- ❌ Não flasheia, não apaga nem modifica a `/system`; o espaço em disco não é
  liberado (os APKs ficam na partição de sistema — o ganho é RAM, bateria,
  privacidade e uma gaveta de apps vazia).
- ❌ Não bloqueia atualizações OTA nem garante que um app reinstalado não volte.
- ❌ Não promete benchmark melhor. Ela remove apps que você não quer; ganho de
  desempenho é efeito colateral, não o contrato.

## Desenho de segurança

1. **Deny-list primeiro:** pacotes críticos não podem nem ser digitados à mão.
2. **Filtro pelo aparelho:** só é tocado o que existe no *seu* celular — firmware
   novo com pacotes renomeados degrada para "sobrou bloat", nunca para quebra.
3. **Prévia obrigatória:** a lista de remoção sempre aparece; a confirmação é
   sempre exigida.
4. **Fallback:** falhou a desinstalação ⇒ o app é desativado.
5. **Desfazer:** toda ação é registrada e `Restaurar tudo` reverte.

---

<details>
<summary><b>Avançado: flags não interativas de CLI</b> (opcional — o menu numerado acima cobre o uso normal)</summary>

Para scripts ou execuções repetidas, as mesmas operações existem como flags:

```bash
./scamsung-debloat doctor            # diagnóstico
./scamsung-debloat list              # mostra os presets
./scamsung-debloat apply basic       # prévia → digite "sim" → aplica
./scamsung-debloat apply --only com.facebook.katana
./scamsung-debloat explain <pacote>  # o que é o pacote, em quais presets ele está
./scamsung-debloat scan [termo]      # pacotes instalados que contêm <termo>
./scamsung-debloat status            # o que esta ferramenta já removeu
./scamsung-debloat restore           # desfaz tudo
./scamsung-debloat tweaks [--performance|--status|--reset|--ram-plus off|on]
./scamsung-debloat wireless          # parear por Wi-Fi
./scamsung-debloat self-test         # valida os presets (não precisa de aparelho)

# opções:
#   -y, --yes        pula a digitação (a prévia sempre aparece)
#       --disable    desativa em vez de desinstalar (mantém os dados do app)
#       --skip a,b   pula esses pacotes
#       --serial S   qual aparelho usar quando há vários conectados
#   -v / -q          verbose / quiet
```

Ambiente: `ANDROID_SERIAL` (igual a `--serial`), `SCAMSUNG_LANG=pt|en|es`
(força o idioma da interface), `SCAMSUNG_DEBLOAT_DATA_DIR` (onde ficam estado e
logs), `NO_COLOR=1`.

</details>

## Perguntas frequentes

**O scamsung-debloat precisa de root?**
Não. Ele só executa `adb shell pm … --user 0`, os mesmos comandos ADB que um
usuário avançado digitaria à mão. Os apps saem do seu perfil de usuário, não da
partição de sistema.

**Isso estoura o Knox, anula a garantia ou quebra o Play Integrity?**
Não. Remoção de pacotes com `--user 0` é um recurso nativo do Android exposto
via ADB — nada toca o bootloader, a `/system`, o Knox ou o atestado do aparelho.
Apps de banco e Google Pay continuam funcionando.

**Quais aparelhos são suportados?**
Feito e validado para Samsung Galaxy rodando One UI 8/9 (Android 16/17). Versões
antigas da One UI funcionam do mesmo jeito; versões novas nunca vistas disparam
um aviso mas continuam, porque a ferramenta só toca pacotes que de fato existem
no aparelho.

**Como recupero um app removido?**
A opção **4** do menu (*Restaurar tudo*) traz de volta tudo que esta ferramenta
removeu. Um app só, na mão: `adb shell cmd package install-existing <pacote>`.

**Uma atualização OTA da Samsung traz o bloatware de volta?**
Às vezes. OTAs podem reinstalar apps Samsung — rode o mesmo preset de novo. Nada
quebra nesse meio-tempo.

**O debloat libera espaço de armazenamento?**
Não. Os APKs ficam na partição de sistema, somente leitura. O ganho é RAM,
consumo de bateria em segundo plano, privacidade e gaveta de apps limpa — não
gigabytes.

**E se um app que eu uso depender de algo que o preset remove?**
O recurso dependente para de funcionar (ex.: watch faces precisam de apps
Samsung). Cada linha do preset explica o que quebra, a prévia mostra a lista
completa antes de qualquer ação e o restore sempre traz a dependência de volta.

**Dá para remover um app específico só?**
Sim: `./scamsung-debloat apply --only com.facebook.katana`. A deny-list continua
valendo — `explain <pacote>` conta o que qualquer coisa é antes de você tocar.

**Onde fica o log do que a ferramenta fez?**
`~/.local/share/scamsung-debloat/` — `state.tsv` (restores pendentes),
`tweaks.tsv` (valores originais dos tweaks) e `logs/session-*.tsv` (cada ação).

## Desinstalando a ferramenta

A ferramenta não instala nada no seu computador — é um script só. Para remover
por completo:

1. Rode a opção **4** do menu (*Restaurar tudo*) para o celular voltar ao original.
2. Apague a pasta clonada/baixada.
3. Apague a pasta de estado: `rm -rf ~/.local/share/scamsung-debloat`.

Desligue a Depuração USB no celular se você só ativou por causa disto.

## Testes

A suíte roda contra um **adb falso** que simula um Galaxy na One UI 9 — nenhum
aparelho é necessário e nenhum aparelho real é tocado pelos testes:

```bash
bash tests/run.sh
```

73 verificações: self-test, doctor, scan, prévia obrigatória, apply, deny-list,
pacotes inexistentes, restore, modo disable, `--skip`, presets e todo caminho de
tweak (idempotência, status, reset exato, `--performance`, `--ram-plus`).

## Estrutura do projeto

```
scamsung-debloat          # a ferramenta
scamsung-debloat.cmd      # entrada de dois cliques no Windows (cmd.exe)
scamsung-debloat.ps1      # entrada de dois cliques no Windows (PowerShell)
lists/basic.txt           # 51 pacotes, cada um explicado
lists/light.txt           # 98
lists/heavy.txt           # 126
lists/README.md           # formato dos arquivos de preset
lang/pt-BR.sh             # textos da interface, base completa
lang/en.sh                # camada em inglês
lang/es.sh                # camada em espanhol
tests/adb                 # adb falso (simulador de Galaxy One UI 9)
tests/run.sh              # suíte de testes
docs/oneui-compat.md      # notas de compatibilidade One UI 8/9
docs/auditoria-pacotes.md # auditoria de risco dos pacotes (histórico)
docs/index.html           # site do projeto (GitHub Pages)
README.md                 # este arquivo, in English
```

## Créditos

- [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat) — **base dos presets**,
  testada no aparelho do próprio autor (One UI 8/8.5/9)
- [invinciblevenom/debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android) — ideia original e `Tweaks.bat`
- [Universal Android Debloater NG](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) — níveis de risco e descrições de pacotes
- [TheOneAndOnlyAtlas/Samsung-Debloater](https://github.com/TheOneAndOnlyAtlas/Samsung-Debloater) — referência One UI 7/8

## Licença

MIT — veja [LICENSE](LICENSE). Use por sua conta e risco; há uma prévia antes de
cada remoção por um motivo.
