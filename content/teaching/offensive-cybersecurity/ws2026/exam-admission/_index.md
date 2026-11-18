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
One Markdown document per lab, uploaded on eCampus. The guiding principle: **a classmate who has not done the lab must be able to reproduce every flag using your document alone.** Everything below follows from that. A submission is graded on completeness, reasoning and presentation, and passes only if all three hold.

Each criterion checks something different, and all three count equally:
- **Completeness** shows that you did the lab and understood each step.
- **Reasoning** shows that you can explain what you learned to someone who reads your writeup.
- **Presentation** is how technical work is delivered in this field. A pentest report or a writeup is judged by how clearly it reads, so we take it as seriously as the other two.

### Structure
1. The front matter block (see [File name](#file-name) below), exactly as shown.
2. One section per objective. All flags of one objective go into that objective's section.

Follow the lab assistant's order where you can. You can work on the objectives in any order, but no section may depend on something that only appears further down. If an objective needs information from another one, put the source first and point back to it, for example "the domain comes from `info.txt`, see SMB".

### Completeness
- Every command needed to reach each flag, in the order you ran them. If a step is missing, nobody can reproduce it.
- If the lab needs a port scan, show the scan and every open port it found, not only the ports that led to a flag.
- The flag itself, shown in the output line where it appears.
- At least 90% of the lab assistant's objectives.

### Reasoning
- Say what you do and why: what you expect a command to show, and what the output actually tells you.
- Explain the output that matters, above all when it decides your next step.
- Skip what the lecture already covered (tool options, basic concepts), and leave out attempts that led nowhere. Mention a failed attempt only if its output pointed you somewhere.
- If you use a technique the lecture did not cover, explain in a sentence or two why it works.

### Presentation
- Full sentences, English or German. Short bullet points are fine where they stay readable.
- Every command in a code block, with its output directly below it. Mark commands with `$` so command and output are easy to tell apart.
- Trim the output to the lines that matter, and use `...` for cut parts. Never retype, reconstruct or annotate output inside a code block; point to the important line in the text instead.
- For web labs, copy the relevant requests and responses from Burp as text into code blocks (in Repeater: select the raw request or response and copy it). Trim them to the lines that matter, for example the request line, the changed parameters, and the part of the response with the result. No screenshots.
- A writeup without code blocks or without output does not pass Presentation.

A full example for the optional Bash lab: [example writeup](example-bash/). For taking notes while you work, see the [Environment Setup](../setup/#optional-notes-and-copy-and-paste).

### Common mistakes
- Exporting from Word, LibreOffice or Google Docs: it escapes Markdown characters and breaks headings, code blocks and the front matter. Write the `.md` file directly in a text editor and check it in a Markdown preview before uploading.
- Submitting a raw terminal log, or prose with commands in quotes, instead of a writeup.
- Showing only the flag instead of the output line it appears in.
- Submitting a PDF or a Word/LibreOffice file: we check flags with a script that reads Markdown only.
- Very long writeups are hard to follow: show only the steps that lead to a flag and trim output to what matters.
- Heavy formatting: bold labels on every line, arrows and symbols instead of sentences. It makes the text harder to read, not easier.
- A table of all flags at the end is not necessary. Showing each flag in its own section is enough, and expected.

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

Keep the `---` block at the very top exactly as shown: it lets us check your flags automatically. `lab` must be one of the `<labname>` values above, and `matrik` must be the same Matrikelnummer you entered in `manage.sh` (it is what generated your flags), with no spaces. Use your own Matrikelnummer in `manage.sh`: flags generated with any other number are not valid. Your name comes from the file name, so it does not need to be repeated inside the document.

## Use of AI
You may use AI tools, also to help you write the writeup. Two conditions:

1. **You do the lab yourself.** Every command and every output in your writeup comes from your own terminal. Letting an AI agent run commands against the lab for you does not count as doing it yourself.
2. **AI must not make the writeup worse.** You are responsible for every sentence, so read what comes back and fix it before you submit.

A writeup does not pass if it contains, for example:
- leftover prompts, instructions or placeholders such as `[TODO: paste output here]`
- output or statements about the box that do not match it, or output that was retyped or reconstructed instead of copied
- steps that are described but never shown
- text that contradicts your own commands, misses the point, or does not make sense
- general sections that say nothing about this lab, such as a methodology summary or a list of tricks you did not use

A polished writing style alone is not a problem. If we are unsure, we may ask you to explain a step of your writeup. A step you cannot explain counts as not done.
