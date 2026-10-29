# SEO — configuração manual (pendências do proprietário)

Passos que **só o dono da conta** pode executar. O site já sai do repositório
com sitemap, robots.txt, canonical e meta tags prontos — aqui está o que falta
para acelerar a indexação. Links oficiais em cada etapa.

Pré-requisito: o GitHub Pages estar ativo (seção 0).

---

## 0. Ativar o GitHub Pages (uma vez)

1. Repositório → **Settings → Pages** (ou via API, já preparado pelo agente).
2. Source: **Deploy from a branch** → branch `main`, pasta `/docs` → Save.
3. Em ~1 minuto o site sobe em `https://aureliomo.github.io/scamsung-debloat/`.
4. Verificar: abrir a URL e `https://aureliomo.github.io/scamsung-debloat/robots.txt`.

Documentação oficial: https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site

---

## 1. Google Search Console

1. Acesse https://search.google.com/search-console e entre com a conta Google.
2. **Adicionar propriedade → Prefixo do URL**: `https://aureliomo.github.io/scamsung-debloat/`
   (o tipo "Domínio" **não funciona** aqui — requer DNS e o domínio `github.io` é do GitHub).
3. Método de verificação: **Tag HTML**. O Google fornece uma meta
   `<meta name="google-site-verification" content="CODIGO">`.
4. Cole essa meta no `<head>` de `docs/index.html` (e idealmente das outras 3
   páginas), faça push e clique em **Verificar**.
   - Alternativa sem editar HTML: método **Arquivo HTML** — suba o arquivo
     `google<hash>.html` fornecido em `docs/`. Ambos funcionam em Pages.
5. Depois de verificado: **Sitemaps** → enviar
   `https://aureliomo.github.io/scamsung-debloat/sitemap.xml`.
6. **Inspeção de URL**: cole a URL da home e peça **Solicitar indexação**. Repita
   para `install.html`, `safety.html`, `compatibility.html` (cota diária limitada).

Docs oficiais:
- Verificação: https://support.google.com/webmasters/answer/9008080
- Sitemaps: https://support.google.com/webmasters/answer/7451001

## 2. Bing Webmaster Tools

1. https://www.bing.com/webmasters → entre (Microsoft/Google/Facebook).
2. Caminho rápido: **Importar do Google Search Console** — traz site e sitemap
   já verificados (depois que o passo 1 estiver pronto).
3. Ou manualmente: **Adicionar site** → verificar por tag HTML/arquivo (mesma
   mecânica do Google) → enviar o mesmo `sitemap.xml`.
4. **Envio de URL** (Submit URLs): cole as 4 URLs do site — cota imediata para
   sites novos.

Docs: https://www.bing.com/webmasters/help/home

## 3. IndexNow (Bing/Yandex — opcional, oficial)

Notifica indexação em segundos a cada mudança. **Limitação real:** o arquivo de
chave precisa ficar na **raiz do host** (`https://aureliomo.github.io/CHAVE.txt`),
que pertence ao user-site `AurelioMo.github.io`, não a este repositório.

Opções:
- **Simples (recomendada):** pule o IndexNow. O envio manual de URLs no Bing
  (passo 2.4) cobre um site de 4 páginas.
- **Completa:** crie o repositório `AurelioMo/AurelioMo.github.io`, coloque nele
  um arquivo `CHAVE.txt` (a chave = o nome do arquivo, hex aleatório de 8–128
  chars). Depois, a cada atualização do site:
  ```bash
  curl "https://api.indexnow.org/indexnow?url=https://aureliomo.github.io/scamsung-debloat/&key=SUA_CHAVE"
  ```
Docs: https://www.indexnow.org/documentation

## 4. O que NÃO fazer

- ❌ Não mexer em robots/meta do `github.com` — não administramos esse domínio;
  o GitHub já é plenamente rastreável.
- ❌ Não usar serviços de "indexação garantida" ou ping em massa — inúteis ou
  contra as diretrizes.
- ❌ Não marcar páginas com `noindex` (nenhuma tem).
- ❌ Não criar `llms.txt`: não há padrão estabelecido nem evidência de uso pelos
  mecanismos; o conteúdo rastreável do site já serve às IAs.

## 5. Checklist pós-publicação

| # | Verificação | Onde | Critério de sucesso |
|---|-------------|------|---------------------|
| 1 | Site no ar | browser | HTTP 200 nas 4 páginas + robots.txt + sitemap.xml |
| 2 | Sitemap aceito | GSC → Sitemaps | status "Sucesso", 4 URLs descobertas |
| 3 | Indexação Google | buscar `site:aureliomo.github.io/scamsung-debloat` | 4 resultados (pode levar dias–semanas em domínio novo) |
| 4 | Indexação Bing | mesma query `site:` no Bing | idem (costuma ser mais lento) |
| 5 | Inspeção de URL | GSC | "URL está no Google" + canonical detectada = a nossa |
| 6 | Rich/OG preview | https://metatags.io | título/descrição corretos |
| 7 | Repo → site | GitHub About | link do site no campo Website (agente configura) |

**Expectativa honesta:** GitHub Pages em user-site novo indexa em dias no Google
após solicitação manual; sem backlinks externos, ranquear para termos genéricos
("samsung debloat") leva tempo e depende das referências do PROMOTION-PLAN.md.
Presença em respostas de IA (ChatGPT/Perplexity/Gemini) é consequência indireta
de indexação + conteúdo claro — **não há botão de inscrição** e nenhum crawler
permitido garante citação.
