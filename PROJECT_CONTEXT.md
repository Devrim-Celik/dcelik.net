# dcelik.net — Project Context / Handoff

> Paste this into a fresh chat to bring Claude up to speed on the course-website
> project. It describes the idea, the infrastructure, the repo layout, the key
> files and scripts, the conventions, and where things currently stand.

---

## 1. Who & what

- **Owner:** Devrim Celik — independent university lecturer.
- **Course:** *Grundlagen der Offensiven IT-Sicherheit* (Foundations of Offensive
  Cybersecurity) — offensive security / pentesting, currently taught at the
  University of Bonn (Winter term 2026/27).
- **Goal:** a self-owned, reusable course website at **dcelik.net** that replaces
  the university portal. It must be **independent of which university** hosts the
  course and **reusable per cohort/edition** (e.g. `ws2026`, future `ws2027`, …).
  It hosts slides, cheat sheets, setup/lab guides, lab distribution, and exam info.

## 2. Infrastructure

- **Static site generator:** Hugo (extended, ~v0.167.0) + **PaperMod** theme.
- **Hosting:** GitHub Pages, deployed via **GitHub Actions** (`.github/workflows/hugo.yml`).
- **Repo:** `Devrim-Celik/dcelik.net` on GitHub — **public** (the site is public
  content; the separate labs repo stays private).
- **DNS:** Namecheap. Apex `dcelik.net` → A records `185.199.108–111.153`;
  `www` → CNAME `devrim-celik.github.io`. HTTPS via GitHub Pages.
- **Mail:** ProtonMail — MX/SPF/DKIM/DMARC records are **preserved and must never
  be touched** when changing DNS. The site is web-only; mail is independent.
- **Local machine:** Linux PC. Repo lives at
  `~/Cloud/OFFICIAL_ETHICAL_HACKING/dcelik.net/`.

> **Known deploy gotcha (already fixed):** the Actions workflow pins
> `hugo --gc --minify --baseURL "https://dcelik.net/"`. Using the Pages
> `github.io` output URL instead produced an unstyled site. Keep the pinned baseURL.

## 3. Repo layout

```
dcelik.net/
├── archetypes/
├── assets/
│   └── css/extended/custom.css      # terminal/green theme (dark #0d1117, green #3fb950, mono headings)
├── cheatsheets-src/                 # AUTHORING SOURCE for cheat sheets (markdown)
├── content/
│   └── teaching/offensive-cybersecurity/ws2026/
│       ├── _index.md                # edition page: sessions front matter + {{< sessions >}}
│       ├── setup/                   # Environment Setup guide
│       ├── lab-guide/               # Lab Guide
│       ├── lab-submissions/         # Submissions / exam admission info
│       └── cheatsheets/             # RENDERED cheat sheet pages (generated, see §5)
│           ├── _index.md
│           └── <name>.md            # one per cheat sheet, built by publish-cheatsheet.sh
├── data/
├── hugo.toml
├── i18n/
├── layouts/
│   └── shortcodes/
│       └── sessions.html            # renders the course table (# / Slides / Cheat sheet / Lab) + exam row
├── public/                          # build output (ignore)
├── publish-cheatsheet.sh            # md in cheatsheets-src/ -> rendered Hugo page (see §5)
├── static/
│   └── teaching/offensive-cybersecurity/ws2026/
│       ├── slides/NN_name.pdf       # slide decks (PDF, exported from Google Slides)
│       └── dl/ws2026/               # lab distribution: manage.sh + per-lab docker-compose.yml
└── themes/                          # PaperMod
```

## 4. The session/edition model

`content/.../ws2026/_index.md` has a `sessions:` front-matter list that drives the
course table. Each entry maps: `title`, `file` (the token used for slide + cheat
sheet filenames/URLs), `lab` (a lab token), and boolean flags `released` and
`cheatsheet`. The page ends with `{{< sessions >}}`.

- `layouts/shortcodes/sessions.html` renders the table with columns
  **# / Slides / Cheat sheet / Lab**, plus a final exam/capstone row.
- Slides link → `slides/{{ $s.file }}.pdf`.
- Cheat sheet link → `cheatsheets/{{ $s.file }}/` (the rendered page; label is a
  plain text link such as "view", **not** "PDF").
- Lab token renders as `<code>`; shows "not yet released" until `released: true`.
- `released` / `cheatsheet` booleans gate what is visible per session.

Session `file` tokens (WS2026): `02_linux-and-bash-basics`, `03_reconnaissance`,
`04_shells-for-the-ethical-hacker`, `05_web_exploitation`, `06_public_exploits`,
`07` (LPE, not yet done), `08_attacking_passwords`, `09_pivoting`, plus pivoting
and web-frameworks labs. (00 Formalities, 01 Intro have no cheat sheet.)

## 5. Cheat sheet pipeline (current — HTML pages, no PDF)

Cheat sheets are authored as markdown in `cheatsheets-src/` and **rendered as Hugo
pages** (not PDFs). `publish-cheatsheet.sh` converts one source file into a content
page.

**Workflow:** drop/update `cheatsheets-src/<name>.md`, then:
```bash
./publish-cheatsheet.sh <name>        # name WITHOUT .md, and must match the session `file` token
```
The script: reads the first `# ` as the page title, strips that H1, prepends front
matter (`title`, `ShowToc`, `build.list: never`) and writes
`content/teaching/offensive-cybersecurity/ws2026/cheatsheets/<name>.md`.

- `build.list: never` keeps cheat sheets **out of the homepage feed** (they're
  reached via the course table, not browsed).
- CSS for rendered tables/code is appended in `assets/css/extended/custom.css`
  (`.post-content table { overflow-x:auto }` etc. for wide tables on mobile).
- There are **no cheat sheet PDFs** anymore (the old `static/.../cheatsheets/*.pdf`
  were removed, and the table links to pages).

**Cheat sheet style guide (all sheets follow this):**
1. Line 1 = `# <Plain Topic Title>` (becomes the page title).
2. One `>` intro blockquote (1–2 sentences, the mental model).
3. Sections are `##`, subsections `###`.
4. Table-driven; standard headers like `command | usage`, `flag | usage`.
5. Ends with a `## General Tips` section.
6. **No direct mention of "the labs"** or lab-specific targets/flags — written to
   be usable for anything, even though labs are their main use. Use generic
   `<target>`/`<ip>` placeholders. No `# kali` host comments.

## 6. Slides

- Authored in Google Slides, exported to PDF, stored in
  `static/teaching/offensive-cybersecurity/ws2026/slides/NN_name.pdf`.
- Clickable TOC: Google Slides internal links survive PDF export (link color set to
  black, no underline, with a "Tip: click any entry" note).
- Deploy a deck:
  ```bash
  cp ~/Downloads/NN_name.pdf \
     ~/Cloud/OFFICIAL_ETHICAL_HACKING/dcelik.net/static/teaching/offensive-cybersecurity/ws2026/slides/NN_name.pdf
  ```

## 7. Lab distribution (separate private labs repo)

- Labs live in a **private** repo (`~/projects/ethical-hacking-labs` on the dev box):
  base/attacker + base/lab-assistant images, `labs/<name>/` with docker-compose +
  targets, a Makefile, legacy reference. Kept private because it holds solutions/flags.
- Images published to **Docker Hub** under namespace `dc3lik/`, image names use an
  `osl-` prefix, tagged via `${TAG}` (the cohort tag).
- Students get a **`manage.sh`** wrapper (served from `static/.../dl/ws2026/`) that
  fetches per-lab `docker-compose.yml` files on demand, plus one `.env` with
  `TAG=` / `STUDENT_ID=`.
- Tutor session time is picked via a self-hosted poll (Rallly); exam admission is
  5-of-6 units, write-ups graded on engagement/coverage (not flag count), with an
  oral spot-check backstop.

## 8. Conventions & preferences

- **Theme:** terminal/green — dark bg `#0d1117`, green accent `#3fb950`, monospace
  headings, `$ ` prompt before `h2`.
- **Everything nested under `ws2026`** for clean breadcrumbs (accepts per-year
  duplication cost).
- **Slides:** keep wording compact ("too long for slide" is a recurring note).
- **Two guides split:** Environment Setup (once) + Lab Guide (per-lab).
- **Cheat sheets:** include lab-relevant *techniques* but never lab-spoiling flag
  paths; no direct lab references (see §5 style guide).
- Prefer no em dashes / host prefixes when asked; `manage.sh` served clean of
  trailing whitespace (`sed -i 's/[[:space:]]*$//'`).

## 9. Status (as of 2026-10-18)

**Done:**
- Site live at dcelik.net, mail preserved, HTTPS working.
- Cheat sheets converted to rendered HTML pages; all 7 existing sheets
  (02, 03, 04, 05, 06, 08, 09) unified to the style guide in §5.
- Slide decks reviewed/corrected through 09 (pivoting). 09 includes an `ssh -J`
  (ProxyJump) slide; the one real bug (a `-L` that should be `-R`) is fixed.

**Pending / next:**
- Publish the unified cheat sheets: overwrite `cheatsheets-src/` and run
  `publish-cheatsheet.sh` for each (loop in §5).
- Flip `released: true` / `cheatsheet: true` per session in `_index.md` as content
  goes live.
- **07 LPE** deck + cheat sheet not yet produced. Web-frameworks (optional lab #10)
  not yet done.
- A few cosmetic slide typos remain in earlier decks (tracked separately).
- Optional: give each rendered cheat sheet page a small polish pass if needed.

## 10. How to resume

Tell Claude which piece you're working on (a slide deck review, a new cheat sheet, a
site/CSS change, or the labs repo). For a new cheat sheet: write it to the §5 style
guide, save in `cheatsheets-src/<token>.md` (token must match the session `file`),
run `publish-cheatsheet.sh`, then flip the flags in `_index.md`.
