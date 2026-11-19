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
  `~/projects/offensive-cybersecurity/dcelik.net/`, beside the private labs repo
  (`../labs/`), the lab-hosting PoC (`../lab-hosting/`) and exam material (`../exams/`).

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
│   ├── _index.md, privacy.md        # plain homepage, privacy page (linked in the footer)
│   ├── about.md                     # parked: draft: true, menu entry commented out in hugo.toml
│   └── teaching/offensive-cybersecurity/ws2026/
│       ├── _index.md                # edition page: sessions front matter + {{< sessions >}}
│       ├── setup/                   # Environment Setup guide
│       ├── lab-guide/               # Lab Guide
│       ├── exam-admission/          # submission rules, grading criteria, use of AI
│       │   ├── example-bash.md      # rendered example writeup (raw copy in static/dl/examples/)
│       │   └── example-web.md       # rendered example for a fictional web box (same setup)
│       ├── exam/                    # Final exam: format, dates, practice exam PDF
│       └── cheatsheets/             # RENDERED cheat sheet pages (generated, see §5)
│           ├── _index.md
│           └── <name>.md            # one per cheat sheet, built by publish-cheatsheet.sh
├── hugo.toml
├── layouts/
│   ├── shortcodes/
│   │   ├── sessions.html            # renders the course table (# / Slides / Cheat sheet / Lab) + exam row
│   │   └── download.html            # forced-download link (used on cheat sheet pages)
│   └── teaching/list.html
├── public/                          # build output (ignore)
├── publish-cheatsheet.sh            # md in cheatsheets-src/ -> rendered Hugo page (see §5)
├── static/
│   ├── teaching/offensive-cybersecurity/ws2026/
│   │   └── slides/NN_name.pdf       # slide decks (PDF, exported from Google Slides)
│   ├── dl/ws2026/                   # lab distribution: manage.sh + <lab>/docker-compose.yml (from make release)
│   ├── dl/cheatsheets/<name>.md     # raw cheat sheet copies (written by publish-cheatsheet.sh)
│   ├── dl/tmux.conf                 # attacker tmux config (copy of labs/base/attacker/resources/tmux.conf; keep equal)
│   ├── dl/examples/                 # downloadable example writeup(s)
│   └── img/                         # setup/lab-guide diagrams
└── themes/                          # PaperMod (submodule, never edited)
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

Session `file` tokens (WS2026): `00_formaties-and-setup`, `01_introduction-to-ethical-hacking`,
`02_linux-and-bash-basics`, `03_reconnaissance`, `04_shells-for-the-ethical-hacker`,
`05_web_exploitation`, `06_public_exploits`, `07_attacking_passwords`,
`08_linux_privilege_escalation`, `09_pivoting`. (00 and 01 have no cheat sheet or lab; 04 has
no lab.)

`released: false` is used deliberately to hide a session's lab link even when the lab's
compose file is already published under `static/dl/ws2026/` (currently LPE and Pivoting).

## 5. Cheat sheet pipeline (current: HTML pages, no PDF)

Cheat sheets are authored as markdown in `cheatsheets-src/` and **rendered as Hugo
pages** (not PDFs). `publish-cheatsheet.sh` converts one source file into a content
page.

**Workflow:** drop/update `cheatsheets-src/<name>.md`, then:
```bash
./publish-cheatsheet.sh <name>        # name WITHOUT .md, and must match the session `file` token
```
The script: reads the first `# ` as the page title, strips that H1, prepends front
matter (`title`, `ShowToc`, `build.list: never`) plus a nav line (back to the cheat
sheet index + a `{{< download >}}` link to the raw `.md`), writes
`content/teaching/offensive-cybersecurity/ws2026/cheatsheets/<name>.md`, and copies the
source to `static/dl/cheatsheets/<name>.md` (served at `/dl/cheatsheets/<name>.md`).

- `build.list: never` keeps cheat sheets **out of the homepage feed** (they're
  reached via the course table, not browsed).
- CSS for rendered tables/code is appended in `assets/css/extended/custom.css`
  (`.post-content table { overflow-x:auto }` etc. for wide tables on mobile).
- There are **no cheat sheet PDFs** anymore; the table links to pages, and each page
  offers the raw markdown as a download.

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
     ~/projects/offensive-cybersecurity/dcelik.net/static/teaching/offensive-cybersecurity/ws2026/slides/NN_name.pdf
  ```

## 7. Lab distribution (separate private labs repo)

- Labs live in the **private** repo `offensive-security-labs`, checked out at
  `../labs/`: base/attacker + base/lab-assistant images, `content/<name>/` with
  docker-compose + targets, a Makefile, grading tooling. Kept private because it holds
  solutions/flags. Its `CLAUDE.md` is the full instructor reference.
- `make release TAG=ws2026` (in the labs repo) copies the `RELEASED` labs' compose files
  and `manage.sh` into this repo's `static/dl/ws2026/`. Commit + push here to deploy.
- Images published to **Docker Hub** under namespace `dc3lik/`, image names use an
  `osl-` prefix, tagged via `${TAG}` (the cohort tag).
- Students get a **`manage.sh`** wrapper (served at `/dl/ws2026/manage.sh`) that
  fetches per-lab `docker-compose.yml` files on demand, plus one `.env` with
  `TAG=` / `STUDENT_ID=`. Flags are per student: `DC{md5(identifier + matrikelnummer)}`.
- Tutor sessions: Mondays and Tuesdays 13:00 to 14:00, drop-in on the student Discord.
- Exam admission: 5 of 6 writeup units (`recon`, `web-part1`, `web-part2`,
  `public-passwords`, `lpe`, `pivoting`). A unit passes on completeness (>= 90% of
  objectives with the correct per-student flag), reasoning and presentation. The
  student-facing rules are on the Exam Admission page.

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

## 9. Status (as of 2026-11-17)

**Done:**
- Site live at dcelik.net, mail preserved, HTTPS working.
- All slide decks 00 to 09 are published.
- All 8 cheat sheets (02 to 09) are published as rendered pages with a raw `.md` download.
- Labs released on the course page: bash, recon, web, public-exploits, passwords.
  LPE and pivoting compose files are already published but their links stay hidden
  (`released: false`) until the matching session. The web2 lab is retired for now.
- Exam page live: dates (05.03.2027, resit 02.04.2027), format, practice exam PDF.
- Homepage is plain (title `dcelik.net`, no profile mode), Privacy page + footer link; About is
  parked as a draft.
- Exam Admission explains what a writeup must show (structure, code blocks + output, Burp
  requests as text, common mistakes, use of AI) and links two rendered example writeups (Bash lab, fictional web box).
- Setup has an "Optional: notes and copy and paste" section (CherryTree/Obsidian, VirtualBox
  shared clipboard, UTM spice-vdagent).
- Web cheat sheet notes that Firefox does not proxy `localhost` (allow_hijacking_localhost or
  Burp's browser).

**Pending / next:**
- Flip `released: true` for LPE and Pivoting as those sessions arrive.

## 10. How to resume

Tell Claude which piece you're working on (a slide deck review, a new cheat sheet, a
site/CSS change, or the labs repo). For a new cheat sheet: write it to the §5 style
guide, save in `cheatsheets-src/<token>.md` (token must match the session `file`),
run `publish-cheatsheet.sh`, then flip the flags in `_index.md`.
