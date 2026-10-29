# Plano de divulgação legítima (rascunhos — NADA foi publicado)

Objetivo: referências reais que alimentem autoridade orgânica. Regras do jogo:

- 1 post por comunidade; conta com histórico; **disclosure** de que é projeto seu.
- Responder comentários nas primeiras 24–48h. Não cross-postar no mesmo dia.
- Respeitar as regras de self-promotion de cada sub (geralmente ~10% da sua
  atividade pode ser autopromoção — participe antes de divulgar).
- Proibido: contas novas farmando posts, compra de backlinks, cópia de artigos,
  fabricação de métricas.

---

## 1. Onde o público de debloat realmente está

| Canal | Formato adequado | Observação |
|-------|------------------|-----------|
| **XDA Forums** (Android General / Galaxy S-series) | thread de ferramenta | Maior concentração histórica de debloat Samsung. Conta nova precisa de alguns posts antes de anexar links. |
| **r/samsung** | post de anúncio | Tolerante a ferramentas da comunidade com disclosure. |
| **r/GalaxyS24 / r/GalaxyS25…** | resposta contextual quando perguntarem de debloat | Nunca post standalone — os subs de modelo veem autopromo com maus olhos. |
| **r/android** | thread de apps/open-source quando houver; comentários | Regras rígidas contra self-promo; cheque as threads semanais oficiais. |
| **r/androidapps** | post com flair adequado | Aceita "App / Tool by author". |
| **Awesome lists** (GitHub) | PRs adicionando o projeto | Ver seção 3. |
| **AlternativeTo** | cadastro como alternativa a Canta/UAD/Package Disabler | Gratuito, boa autoridade de domínio: https://alternativeto.net |
| **dev.to / Medium** | guia original com link canonical para o site | Ver seção 4. |
| Comentários úteis em vídeos/tutoriais desatualizados sobre debloat | resposta pontual | Só onde agregar — o invinciblevenom arquivado ainda ranqueia e avisa que não deve ser usado: nosso posicionamento honesto é "sucessor espiritual mantido". |

## 2. Posicionamento (verdadeiro, usar sempre)

1. Sem root, só `pm --user 0` — Knox/garantia intactos.
2. Prévia obrigatória + `sim` digitado — impossível aplicar sem olhar a lista.
3. Reversível por design (restore completo + tweaks com valores originais).
4. Presets da comunidade (itxjobe, testados em aparelho real One UI 8/8.5/9),
   cada pacote explicado em linguagem simples.
5. Interface em pt/en/es — único debloater de terminal que fala português.
6. 73 testes automatizados contra adb simulado; código auditável (1 script).

Diferencial honesto vs Canta/UAD (apps GUI que exigem Shizuku/conta) e vs
listas copiáveis: é o caminho de menor fricção para quem tem medo de terminal.

## 3. PRs em awesome lists (buscar e confirmar atividade antes do PR)

- `mzlogin/awesome-adb` — seção de ferramentas baseadas em adb.
- Listas "awesome android" ativas — procurar `awesome-android` com commits < 6 meses.
- `awesome-selfhosted` não se aplica. Não abrir PR em lista morta (≥1 ano parada).
- **itxjobe/samsungdebloat**: propor nos issues/discussions um link mútuo na seção
  "related" — é a base dos nossos presets, relação natural. (Rascunho abaixo.)

## 4. Rascunhos prontos

### 4.1 XDA (EN) — thread de ferramenta
> **Title:** [TOOL][NO ROOT] scamsung-debloat — One UI 8/9 debloater, menu-driven, fully reversible
>
> Hi all. I built a small bash tool after the classic debloat_samsung_android was
> archived: https://github.com/AurelioMo/scamsung-debloat
>
> - No root — only `adb shell pm ... --user 0`
> - Numbered menu (double-click, no typing), or full CLI flags for scripting
> - Presets basic/light/heavy (51/98/126 pkgs) based on itxjobe's One UI 8/9 lists,
>   each package explained inline
> - Mandatory preview + typed confirmation; restore brings everything back
> - Deny-list for critical packages (Play, dialer, VoLTE, SystemUI, setup wizard…)
> - macOS/Linux/Windows (Git Bash), UI in EN/PT/ES
> - 73 automated tests against a fake adb (no device needed to hack on it)
>
> Honest limits: doesn't free storage (APKs stay in /system), OTAs can reinstall
> apps, and package renames just leave the bloat behind instead of breaking things.
> Feedback and package reports welcome — issues on GitHub.

### 4.2 r/samsung (EN)
> **Title:** I made a no-root debloat tool for One UI 8/9 that doesn't require terminal skills (open source)
>
> Two-click menu, sees your exact phone first, shows the whole removal list with
> plain-language explanations, and only applies after you type confirm. Undo is
> one menu option. Presets are community-tested lists (itxjobe), heavy preset caps
> at 126 packages. Interface also in Portuguese/Spanish.
> Repo: https://github.com/AurelioMo/scamsung-debloat — feedback welcome.

### 4.3 dev.to / guia (EN título, estrutura) — publicar com canonical para o site
> **Title:** Debloat a Samsung Galaxy without root in 2026 (One UI 8/9)
> 1. What `--user 0` removal really does (and why Knox survives)
> 2. Safe presets vs. copy-paste mega-lists
> 3. Step-by-step with scamsung-debloat
> 4. How to restore everything
> 5. FAQ (OTA re-installs, storage myth, dependent apps)
> Canonical URL → `https://aureliomo.github.io/scamsung-debloat/install.html`

### 4.4 Versão PT-BR (fóruns/comentários brasileiros)
> Fiz uma ferramenta open source pra tirar bloatware de Galaxy sem root:
> https://github.com/AurelioMo/scamsung-debloat — menu em português, mostra a
> lista completa antes de remover, tudo reversível. Presets basic/light/heavy
> com cada pacote explicado. Funciona em Windows/Mac/Linux.

### 4.5 Issue proposta em itxjobe/samsungdebloat (pedir link, com humildade)
> **Title:** Related tool: menu-driven wrapper around your lists (link exchange?)
>
> Hey! Your preset lists are the base of my no-root debloat CLI
> (https://github.com/AurelioMo/scamsung-debloat) — full credit in the README.
> It's a numbered-menu bash tool for people who don't want to use Canta/ADB by hand.
> If you find it useful, would you consider adding a "related tools" line?
> Happy to link back (already do). Thanks for the maintainer work!

## 5. Ordem sugerida (espaçar 3–7 dias entre ações)

1. AlternativeTo (cadastro, 10 min).
2. dev.to guia EN (gera backlink de autoridade + canonical).
3. XDA thread.
4. Issue no itxjobe.
5. r/samsung.
6. PRs em awesome lists.
7. Respostas contextuais (contínuo, onde perguntarem).

Cada publicação exige **sua autorização** e sua conta. Nada aqui foi enviado.
