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

All deadlines are **23:55** on the stated day. You complete **any 5 of these 6** for admission.

> The **Bash** lab and the **Web Frameworks** lab are **optional**. They are worth doing (Bash to get comfortable with the environment and the basics, Web Frameworks because it's an interesting topic), but neither is a submission and neither is required for admission.

## What a submission must show
One Markdown document per lab, uploaded on eCampus, with one section per objective (in the order the lab-assistant lists them). It is graded on three things, and passes only if all three hold:

1. **Completeness:** the commands and output needed to fulfil the objective, and the flag where there is one. Cover at least 90% of the lab-assistant's objectives.
2. **Reasoning:** write it so that someone who takes the course but did not do this task can understand what you did and why. Explain the non-obvious steps, above all when an output decided your next move; skip what the lecture already covers, and mention a failed attempt only if its output led somewhere.
3. **Presentation:** a readable document with full sentences (English or German), code and text clearly separated, and long output trimmed to the lines that matter.

Flags are individual to your Matrikelnummer, so a copied writeup shows the wrong flags.

## File name
Upload a single `.md` file named:

`<family_name>-<first_name>_<matrikelnummer>_<labname>.md`

where `<labname>` is one of `recon`, `web-part1`, `web-part2`, `public-passwords`, `lpe`, `pivoting`. A skeleton to start from:

```markdown
---
lab: <labname>
matrik: <your Matrikelnummer>
---

# <labname> writeup

## <first objective from the lab-assistant>

## <next objective>
```

Keep the `---` block at the very top exactly as shown: it lets us check your flags automatically. `lab` must be one of the `<labname>` values above, and `matrik` must be the same Matrikelnummer you entered in `manage.sh` (it is what generated your flags), with no spaces. Your name comes from the file name, so it does not need to be repeated inside the document.
