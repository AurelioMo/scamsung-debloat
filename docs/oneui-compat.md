# Compatibilidade com One UI 8 e 9

Notas técnicas sobre por que este script funciona em firmware novo sem depender de uma
lista congelada de pacotes, o que muda entre versões e como validar num aparelho real.

Referências de versão usadas no desenvolvimento:

| One UI | Android | Situação do script |
|--------|---------|--------------------|
| 2.5 – 6.1 | 10 – 14 | listas do projeto original; devem funcionar, não testadas |
| 7.x | 15 | pacotes conferidos contra listas públicas (UAD-ng, Atlas) |
| 8.x | 16 | alvo principal de teste (Galaxy simulado) |
| 9.x | 17 | alvo principal de teste (Galaxy simulado) |
| > 9 | > 17 | roda em "modo seguro", com aviso em `doctor`/`apply` |

> Nenhuma dessas versões foi validada em aparelho físico neste repositório. A suíte
> `tests/run.sh` usa um `adb` falso que responde como um Galaxy com Android 17 / One UI 9.

---

## 1. Detecção de versão

`load_device_info()` em `scamsung` lê, nesta ordem:

```bash
getprop ro.build.version.release    # Android, ex. 17
getprop ro.build.version.oneui      # One UI codificado, ex. 90000
getprop ro.build.version.sem        # fallback quando `oneui` não existe
getprop ro.product.model            # ex. SM-S931B
getprop ro.product.device           # ex. e1s
getprop ro.build.PDA                # build completa
```

Decodificação da One UI:

```
ONEUI_MAJOR = raw / 10000
ONEUI_MINOR = (raw % 10000) / 100
```

Exemplos: `90000` → 9.0, `80000` → 8.0, `61100` → 6.11 (o campo é numérico, não
semântico — `61100` é One UI 6.1.1).

Comportamento:

- campo vazio ou não numérico → tenta `ro.build.version.sem`; se também falhar, mostra
  `One UI desconhecida` e continua;
- `ONEUI_MAJOR > 9` → imprime aviso, mas **não aborta**. O script continua porque as
  proteções não dependem do número da versão (seção 2);
- `doctor` mostra modelo, build, serial e versão detectada antes de qualquer ação.

Não há parsing de string tipo `"9.0"`: builds de teste e firmware de operadora às vezes
trazem o campo em formatos diferentes, e o cálculo por divisão evita falso negativo.

---

## 2. Por que continua funcionando em versão futura

Três mecanismos, nesta ordem, absorvem mudanças de firmware:

### 2.1 Filtro pelo que está instalado

Antes de agir, o script roda:

```bash
adb shell pm list packages --user 0     # instalados no perfil 0
adb shell pm list packages -u --user 0  # instalados + desinstalados (histórico)
```

Cada entrada da lista passa por `is_known()` (está em `-u`) e `is_installed()` (está na
lista ativa). Resultado:

- pacote renomeado ou removido pela Samsung → contado como `missing`, ignorado, sem erro;
- pacote novo de bloat que não está na lista → simplesmente não é tocado;
- pacote já removido por você antes → contado como `already`, ignorado.

Isso é o oposto do original, que executava `pm uninstall` em ~100–330 pacotes fixos e
produzia `Failure [not installed for 0]` em cascata.

### 2.2 Deny-list aplicada por último

`is_denied()` é consultada imediatamente antes de cada ação, mesmo quando o pacote veio
de `--only`. Ela cobre:

- núcleo Android/Google: `android`, GMS, GSF, Play Store, SystemUI, Settings, shell,
  permission controller, WebView, telefonia/telecom, providers de contatos/mídia/downloads,
  DocumentsUI, launcher AOSP, teclado AOSP;
- Samsung essencial: SettingsReceiver, InCallUI, dialer, CommunicationService,
  networkstack, Wi-Fi, overlays de conectividade, timezone, NetworkUI, MTP, Sound Picker,
  AppLock, clipboard UI, SIM settings, teclado Samsung, One UI Home;
- risco conhecido: `com.samsung.android.kgclient` (remover deixa o aparelho preso num
  overlay de bloqueio), `com.samsung.android.sm.policy`, TelephonyUI;
- voz/IMS: `com.samsung.android.ims*`, `com.sec.ims*`, `com.sec.epdg*`,
  `com.sec.unifiedwfc` (Wi-Fi calling / VoLTE);
- `com.samsung.android.app.aodservice` (AOD e relógio da tela de bloqueio).

`./scamsung self-test` falha se qualquer arquivo em `lists/` contiver um pacote negado —
então a deny-list também protege contra edição errada das listas.

### 2.3 Fallback `uninstall` → `disable`

```
pm uninstall --user 0 <pkg>     # tentativa 1: remove para o usuário 0
pm disable-user --user 0 <pkg>  # tentativa 2: desativa mantendo os dados
```

Firmware novo frequentemente bloqueia `uninstall` em pacotes que passaram a ser
considerados críticos pelo fabricante (retorna `Failure [DELETE_FAILED_...]` ou
`not installed for 0`). O fallback garante que a ação ainda tenha efeito, e o estado
gravado registra qual dos dois foi usado — o `restore` usa o comando correspondente
(`cmd package install-existing` vs `pm enable`).

Se ambos falharem, o pacote entra em `FAILED`, aparece no resumo e não interrompe o lote.

---

## 3. O que muda entre One UI 8 e 9

Observado em firmware e em listas públicas (UAD-ng, Atlas, XDA/Technastic). Isto é
orientação, não garantia — confirme com `./scamsung apply <preset>` (a prévia é obrigatória).

| Área | Mudança relevante | Efeito no script |
|------|-------------------|------------------|
| Galaxy AI | mais componentes em `com.samsung.android.*` (escrita, tradução, transcrição) | já em `samsung-ecosystem`/`samsung-extra`; ausentes são ignorados |
| Bixby | consolidação de pacotes (`bixby.*`, `voice.*`) | as listas cobrem as variantes conhecidas; nomes novos simplesmente não são tocados |
| Conta Samsung | `com.osp.app.signin` centraliza login/wallet/backup | `light`/`heavy` removem; `basic` mantém |
| Quick Share | migrou de `Nearby Share`/`com.samsung.android.beaconmanager` para `com.samsung.android.quickshare` | remoção só no preset `heavy` |
| Device Care | `com.samsung.android.lool` + `com.samsung.android.sm.policy` | `lool` removível em `heavy`; `sm.policy` está na deny-list |
| Mensagens | Google Messages passou a ser padrão em várias regiões | `com.google.android.apps.messaging` **não** está nas listas |
| Telefone/Contatos | apps Google substituíram Samsung em parte dos modelos | nenhum dos dois é removido; só o Samsung está na deny-list |
| Preloads | rotação de parceiros (TikTok, Temu, LinkedIn, Spotify, Netflix) | o `basic` cobre os comuns; novos não são tocados |
| Operadora | variantes US mantêm apps próprios | não entram em nenhum preset (fora do escopo) |

Regra prática: **nome novo não é removido, nome antigo ausente não é erro**. O pior caso
de uma lista desatualizada é deixar bloat para trás, não quebrar função.

---

## 4. Comandos usados e o que eles realmente mudam

Todos rodam sem root, via `adb shell`:

| Comando | Efeito | Reversão |
|---------|--------|----------|
| `pm list packages --user 0` | lista apps visíveis no perfil 0 | — |
| `pm list packages -u --user 0` | inclui apps já removidos (histórico) | — |
| `pm uninstall --user 0 <pkg>` | remove o app **do usuário 0**; APK permanece em `/system` | `cmd package install-existing --user 0 <pkg>` |
| `pm disable-user --user 0 <pkg>` | desativa o app, preserva dados | `pm enable <pkg>` |
| `settings put global ...` | `tweaks`: escalas de animação em 0.5x e `wifi_scan_always_enabled=0` | `./scamsung tweaks --reset` (animações); Wi-Fi scan precisa de `./scamsung shell settings put global wifi_scan_always_enabled 1` |

Consequências que valem repetir:

- não libera espaço na partição de sistema — o ganho é RAM, bateria, notificações e
  superfície de privacidade;
- não afeta Knox, Play Integrity nem OTA (mas o OTA pode **reinstalar** apps removidos);
- remoção por `--user 0` não apaga dados de contas, só os dados locais daquele app quando
  o `uninstall` é usado; com `--disable` os dados ficam.

---

## 5. Depois de uma atualização (OTA)

1. `./scamsung doctor` — confirma modelo, build e versão detectada.
2. `./scamsung status` — mostra o que este script removeu e ainda está fora.
3. `./scamsung apply <preset> </dev/null` — a prévia aparece e, sem `sim`, nada é
   aplicado; veja quantos voltaram como instalados.
4. `./scamsung apply <preset>` — reaplica só o que voltou.
5. Se um app voltou com nome novo, adicione ao preset em `lists/` e rode
   `./scamsung self-test` antes de aplicar.

Estado e logs ficam em `~/.local/share/scamsung/`:

```
state.tsv                  # pkg<TAB>ação<TAB>data  (fonte do restore)
tweaks.tsv                 # setting<TAB>valor original (fonte do tweaks --reset)
logs/session-*.tsv         # uma linha por ação, com saída do pm
```

`SCSUNG_DATA_DIR` troca esse diretório (útil para testar sem sujar o estado real).

---

## 6. Checklist de validação em aparelho físico

Ainda pendente neste repositório. Ordem sugerida, do menor risco para o maior:

```bash
./scamsung doctor
./scamsung list
./scamsung apply basic              # leia a prévia antes de confirmar com "sim"
./scamsung status
./scamsung restore                # confirme que tudo volta
```

Depois de cada etapa, teste manualmente:

- [ ] boot e desbloqueio normais;
- [ ] chamadas, SMS, dados móveis, Wi-Fi, Bluetooth;
- [ ] Wi-Fi calling / VoLTE (se usar);
- [ ] câmera, galeria, compartilhar;
- [ ] Play Store abre e instala/atualiza um app;
- [ ] login Samsung (se manteve conta) e Galaxy Store;
- [ ] notificações de apps não removidos;
- [ ] reinício e segundo boot sem loop.

Se algo quebrar: `./scamsung restore`. Se o aparelho não bootar, recovery → "Wipe cache
partition" (não apaga dados) e, em último caso, restaurar padrão de fábrica — nenhuma
operação aqui altera partições do sistema, então o boot não é perdido por causa de
`--user 0`.

---

## 7. Limitações conhecidas

- **Não validado em hardware real.** As listas vêm do projeto original, UAD-ng, Atlas e
  listas públicas; a execução foi testada contra um `adb` simulado.
- **`oneui` pode não existir** em algumas builds (principalmente operadora). Nesse caso o
  rótulo cai para `sem=<valor>` e o aviso de versão futura não dispara.
- **Não detecta dependências entre apps.** Se um app removido for exigido por outro que
  ficou (ex.: plugin de câmera), o sintoma aparece só no uso — daí o `restore` granular.
- **Não mexe em apps de trabalho** (perfil/work profile) nem em múltiplos usuários: tudo
  é `--user 0`.
- **Não remove atualizações de apps de sistema** já instaladas via Play Store; para isso
  seria necessário `pm uninstall-system-updates`, que não é usado aqui.
