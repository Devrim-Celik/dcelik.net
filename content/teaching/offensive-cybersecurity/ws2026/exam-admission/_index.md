---
title: "Exam Admission"
---
[← Back to the course](../)

You *run* the labs with `manage.sh`; for exam admission you *submit* written reports. There are **6 submissions**, and you must complete **any 5** of them, each handed in by its deadline.

The lab work itself is what matters: the report is how you prove you did it, and it doubles as practice in documenting technical work clearly, a core skill in this field.

## The 6 submissions
Most submissions are a single lab. Two are exceptions: the Web lab is large, so it is split across submissions 2 and 3; Public Exploits and Passwords are short, so they share submission 4.

| # | Submission | Covers | Lab(s) to run | Deadline |
|---|---|---|---|---|
| 1 | Recon | reconnaissance | `recon` | 11 Nov 2026 |
| 2 | Web, part 1 | file inclusion, file upload | *not yet released* | 25 Nov 2026 |
| 3 | Web, part 2 | command injection, SQL injection | *not yet released* | 9 Dec 2026 |
| 4 | Public Exploits + Passwords | both labs | *not yet released* | 23 Dec 2026 |
| 5 | LPE | Linux privilege escalation | *not yet released* | 13 Jan 2027 |
| 6 | Pivoting | pivoting | *not yet released* | 20 Jan 2027 |

All deadlines are **23:59** on the stated day. You complete **any 5 of these 6** for admission.

> The **Bash** lab and the **Web Frameworks** lab are **optional**. They are worth doing (Bash to get comfortable with the environment and the basics, Web Frameworks because it's an interesting topic), but neither is a submission and neither is required for admission.

## What a submission must show
One Markdown document per lab, uploaded on eCampus, with one section per objective (in the order the lab-assistant lists them). For each objective include:

- the commands you ran, formatted as code (single backticks inline, or a fenced block for longer commands and their output),
- the relevant output (all of it when every line matters; trim long dumps to the lines that do),
- a short explanation in full sentences of what you did and, where it is not obvious, why (above all when an output decided your next step),
- the flag inline where you captured it.

Keep it tight. Anything from the lecture is a given (opening a terminal, using `curl`, and so on); only explain where you deviate from it. Mention a failed attempt only if its output led to your next step. Plain English or German is fine, but write full sentences. Flags are individual to your Matrikelnummer, so a copied writeup shows the wrong flags.

## File name
Upload a single `.md` file named:

`<family_name>-<first_name>_<matrikelnummer>_<labname>.md`

where `<labname>` is one of `recon`, `web-part1`, `web-part2`, `public-passwords`, `lpe`, `pivoting`. A skeleton to start from:

```markdown
# <labname> writeup
Name: <family name>, <first name>
Matrikelnummer: <number>

## <first objective from the lab-assistant>

## <next objective>
```

## How it is graded
A submission passes if all three hold:

- **Completeness:** at least 90% of the lab-assistant's objectives, done correctly (the right flag and the method that produced it).
- **Reasoning:** the non-obvious steps explain what you did and why, so a classmate who had not done the lab could follow and explain it.
- **Presentation:** full sentences, code and text clearly separated, output sensibly trimmed.

You only need 5 of the 6 submissions, so you can drop the one you find hardest.
