# Auditoria de pacotes: o que é seguro remover

Registro da revisão feita nas listas deste repositório contra bases públicas de debloat.
Serve para responder "posso tirar isso?" com evidência, não com achismo.

Data da auditoria: outubro de 2026 (One UI 8/9, Android 16/17).

> Documento histórico: refere-se às listas anteriores. Os presets atuais têm como
> base o [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat),
> mas as constatações de risco abaixo continuam valendo (a deny-list nasceu delas).

---

## 1. Fontes cruzadas

| Fonte | O que é | Como foi usada |
|-------|---------|----------------|
| [UAD-ng](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) `uad_lists.json` | 5.382 pacotes com nota de remoção (`Recommended`, `Advanced`, `Expert`, `Unsafe`), descrição, dependências e "neededBy" | fonte principal de risco; cobre Samsung, AOSP, Google e operadora |
| [TheOneAndOnlyAtlas/Samsung-Debloater](https://github.com/TheOneAndOnlyAtlas/Samsung-Debloater) | listas One UI 7/8 separadas em Samsung / Google / carrier | conferência de nomes atuais e variantes |
| [itxjobe/samsungdebloat](https://github.com/itxjobe/samsungdebloat) | listas One UI 8, 8.5 e 9 verificadas em S26 Ultra e Z Fold 8 | seções "KEEP" e avisos de bootloop (teclado/Dex, Knox, AI) |
| [Willie169/Samsung-Android-Debloat-List](https://github.com/Willie169/Samsung-Android-Debloat-List) | aparelho real, Android 16 / One UI 8 | confirmação de que os pacotes existem |
| [Tom4tot/Galaxy-S24-Debloat-Script](https://github.com/Tom4tot/Galaxy-S24-Debloat-Script) | S24, One UI 6.1–8.5 | nomes de pacotes e comandos |
| [OutrageousStorm/android-debloat-lists](https://github.com/OutrageousStorm/android-debloat-lists) | listas por OEM | conferência de AOSP/Google |
| [debloat_samsung_android](https://github.com/invinciblevenom/debloat_samsung_android) | projeto original (arquivado) | base histórica; várias entradas foram removidas por risco |

Definições do UAD-ng usadas aqui:

- **Recommended** — seguro remover; normalmente reinstallável pela loja.
- **Advanced** — quebra função obscura/menor ou app substituível.
- **Expert** — quebra função importante, mas não impede o boot.
- **Unsafe** — risco alto de bootloop/tela quebrada. **Nunca entra em lista.**

---

## 2. Regra aplicada nos presets

> As listas por assunto citadas abaixo foram achatadas em três presets
> (`lists/basic.txt`, `lists/light.txt`, `lists/heavy.txt`). O nome do grupo aparece só
> como referência histórica da auditoria.

1. `Recommended` e `Advanced` podem entrar nos perfis, com comentário quando a perda é
   visível.
2. `Expert` só entra no preset `heavy`, com aviso explícito na linha e no README.
3. `Unsafe` não entra em lista nenhuma — e os casos encontrados foram para a deny-list,
   para que `self-test` e `apply` falhem se alguém tentar.
4. Pacote que é app padrão de função básica (SMS, teclado, câmera, telefone, launcher,
   provedor de mídia) fica fora, mesmo quando o UAD permite.
5. Nome que não existe no aparelho é ignorado em runtime — lista desatualizada não quebra
   nada.

---

## 3. Removidos das listas nesta auditoria

| Pacote | Estava em | Nota UAD / motivo |
|--------|-----------|-------------------|
| `com.android.internal.display.cutout.emulation.{corner,double,hole,tall,waterfall}` | `misc` (basic/light/heavy) | **Unsafe**. Overlays de recorte de tela; remover quebra as opções de exibição |
| `com.android.bips` | `misc` (basic) | **Expert**. "Pode fazer o app Configurações crashar e deixar o aparelho lento" |
| `com.android.dynsystem` | `misc-extra` | **Expert**. Dynamic System Updates (imagem GSIs) |
| `com.android.cts.priv.ctsshim` | `misc-extra` | **Expert**. "Pode bagunçar updates OTA" |
| `com.android.managedprovisioning` | `misc-extra` | **Expert**. Configuração de perfil de trabalho/empresa |
| `com.google.android.apps.turbo` | `google-apps` (basic) | **Expert**. Device Health Services; quebra estimativa de bateria e parte do Digital Wellbeing |
| `com.google.android.configupdater` | `google-apps` (basic) | **Expert**. Atualizações de config do sistema/OTA |
| `com.google.android.setupwizard` | `google-apps` (basic) | **Advanced**. Sem ele, configurar o aparelho após reset de fábrica dá errado |
| `com.google.android.apps.carrier.carrierwifi` | `google-apps` | **Advanced**. Provisionamento de Wi-Fi da operadora (Wi-Fi calling) |
| `com.google.android.apps.messaging` | `google-extra` (heavy) | **Advanced**, mas é o app de SMS padrão em várias variantes — remover deixa o aparelho sem SMS |
| `com.google.android.captiveportallogin` | `google-extra` (heavy) | **Advanced**. Sem ele, login em Wi-Fi de hotel/aeroporto falha |
| `com.vzw.apnlib` | `carrier` | **Expert**. Biblioteca de APN da Verizon; remover pode cortar dados móveis |
| `com.google.android.apps.bard` (Gemini) | `google-apps` → `google-extra` | One UI 8 usa Gemini em Photo Assist/Note Assist; saiu do preset `basic` |
| `com.google.android.gms.location.history` | não entrou | colide com a deny-list de GMS; mantido o bloqueio |

Total: 5 pacotes `Unsafe`, 7 `Expert` e 4 `Advanced` removidos, mais 2 movidos para o
preset mais restrito.

---

## 4. Mantidos de propósito, apesar do risco

| Pacote | Onde | Por que continua |
|--------|------|------------------|
| `com.android.printspooler` | `heavy` | só quebra impressão; útil para quem nunca imprime |
| `com.samsung.android.app.routines` | `heavy` | Modes and Routines; automações param — usuário escolhe |
| `com.sec.android.app.samsungapps` | `light`/`heavy` | Galaxy Store; apps instalados por ela deixam de atualizar |
| `com.osp.app.signin` | `light`/`heavy` | conta Samsung; documentado no README (perde Wallet, Find My, backup, Galaxy AI) |
| `com.samsung.android.visionintelligence` | `basic`/`light` | Bixby Vision; UAD dá **Recommended** e não afeta Circle to Search do Google |
| `com.android.stk` / `stk2` | `heavy` | SIM Toolkit; algumas operadoras usam para serviços |
| `com.google.android.googlequicksearchbox` | `heavy` | quebra Assistente/Circle to Search; por isso não está em `basic`/`light` |

---

## 5. Adicionados nesta auditoria

Todos `Recommended` no UAD-ng, presentes em One UI 7–9:

| Pacote | Categoria | O que é |
|--------|-----------|---------|
| `com.samsung.android.app.news` | `samsung-apps` | Samsung News |
| `com.samsung.android.app.headlines` | `samsung-apps` | Flipboard briefing |
| `com.samsung.android.app.appupdater` | `samsung-apps` | atualizador de apps Samsung (descontinuado) |
| `com.samsung.android.app.withtv` / `com.sec.android.app.withtv` | `samsung-apps` | Smart View (TV) |
| `com.samsung.android.dynamiclock` | `samsung-apps` | Wallpaper services / Dynamic Lock |
| `com.samsung.android.livewallpaper.res` | `samsung-apps` | papéis de parede animados |
| `com.samsung.android.app.parentalcare` | `samsung-apps` | controle parental |
| `com.samsung.android.app.sketchbook` | `samsung-apps` | Sketchbook (S Pen) |
| `com.samsung.android.penup` | `samsung-apps` | PENUP (S Pen) |
| `com.samsung.android.app.interpreter` | `samsung-extra` | Intérprete / tradução ao vivo |
| `com.samsung.android.aircommandmanager` | `samsung-extra` | Air Command (S Pen) |
| `com.samsung.storyservice` | `samsung-extra` | Stories do Gallery |
| `com.samsung.android.wallpaper.live` | `samsung-extra` | papéis de parede com IA |
| `com.google.android.apps.docs.editors.docs` | `google-apps` | Google Docs (faltava, Sheets/Slides já estavam) |
| `com.google.android.apps.magazines` | `google-apps` | Google News |
| `com.google.android.apps.chromecast.app` | `google-apps` | Google Home |
| `com.google.android.health.connect.backuprestore` | `google-apps` | backup do Health Connect |
| `com.google.android.apps.googleassistant` | `google-extra` | Google Assistant (heavy) |
| `com.google.android.apps.bard` | `google-extra` | Gemini (heavy) |

---

## 6. O que outros debloats removem e aqui NÃO é removido

| Pacote / grupo | Quem remove | Por que ficamos fora |
|----------------|-------------|----------------------|
| `com.samsung.android.honeyboard` (teclado) | várias listas antigas | bootloop com DeX/Samsung Keyboard; deny-list |
| Qualquer `*knox*` | listas agressivas | pode travar Secure Folder/Work profile; deny-list |
| `com.samsung.android.aicore`, `com.samsung.android.intelligence.voice` | listas de "AI off" | base do Galaxy AI (Live Translate, Photo Assist); usuário perde recurso pago |
| `com.samsung.android.app.aodservice` | listas antigas | AOD + relógio da lockscreen; deny-list |
| `com.samsung.android.kgclient` | projeto original | trava o aparelho com overlay de bloqueio; deny-list |
| `com.android.cellbroadcastreceiver` | projeto original | alertas de emergência; deny-list |
| `com.samsung.android.app.soundpicker` | projeto original | seletor de som do sistema; deny-list |
| `com.samsung.android.app.routines` | nenhuma das novas | heavy só, com aviso |
| `com.samsung.android.sm.policy` | listas agressivas | política do Device Care; deny-list |
| `com.sec.android.soagent` / `com.wssyncmldm` | listas de "no OTA" | sem updates de sistema; não vale o risco |
| `com.google.android.gms`, `com.android.vending`, `com.google.android.gsf` | listas de "Google off" | quebra Play Services/loja; deny-list |

Observação: `com.samsung.android.appseparation` (Separated Apps) é `Advanced` e continua
em `samsung-ecosystem` — só sai no `light`/`heavy`.

---

## 7. Como reconferir depois de uma atualização

```bash
./scamsung self-test     # valida nomes, deny-list, duplicatas e presets
./scamsung apply heavy </dev/null   # vê a prévia sem aplicar (sem digitar "sim")
./scamsung scan <termo>  # confirma o que existe no seu firmware
```

Para reauditar contra o UAD-ng:

```bash
curl -L -o uad_lists.json \
  https://raw.githubusercontent.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/main/resources/assets/uad_lists.json
python3 - <<'PY'
import json, glob
uad = json.load(open('uad_lists.json'))
for f in glob.glob('lists/*.txt'):
    for line in open(f):
        p = line.split('#')[0].strip()
        if p and uad.get(p, {}).get('removal') in ('Unsafe', 'Expert'):
            print(f, uad[p]['removal'], p)
PY
```

Qualquer resultado `Unsafe` aí é erro de lista: tire o pacote ou coloque na deny-list.
