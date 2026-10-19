---
title: "Attacking Passwords"
ShowToc: true
TocOpen: false
build:
  list: never
---

[← Cheat Sheets](../) · {{< download "/dl/cheatsheets/08_attacking_passwords.md" "Download this sheet (.md)" >}}


> Two jobs: **brute forcing** live services (guess credentials over the network)
> and **hash cracking** (recover plaintext from a stolen hash).

## Where Password Hashes Live

| location | note |
| -------- | ---- |
| `/etc/shadow` | Linux system account hashes (needs root) |
| `%SystemRoot%/system32/config/SAM` | Windows system accounts |
| web app config (e.g. `/var/www/html/config.php`) | app/db credentials |
| password-protected files | zip, pdf, SSH keys, KeePass DBs (extract the hash first) |

## Brute Forcing — Hydra

> guess credentials against a live service. Tools: Hydra (focus), Medusa, NetExec,
> Burp Intruder. Hydra supports 50+ protocols (ssh, ftp, smb, http, ...).

> **You need:** target, service, username(s), password(s).

| command | usage |
| ------- | ----- |
| `hydra -l <user> -P <wordlist> <target> <service>` | one user, many passwords |
| `hydra -L <userlist> -p <pass> <target> <service>` | many users, one password |
| `hydra -L <userlist> -P <wordlist> <target> <service>` | both lists |
| `hydra -l <user> -p <pass> <target> <service>` | single pair |

| flag | usage |
| ---- | ----- |
| `-o <file>` | save output to file |
| `-f` | stop at first valid credential |
| `-s <port>` | non-default port |
| `-M <file>` | multiple targets from file |
| `-R` | restore a crashed/cancelled session |
| `-I` | ignore existing restore file (skip the 10s wait) |
| `-V` / `-vV` | verbose (show each attempt) |
| `-t <n>` | parallel tasks (lower if the service is flaky) |

```bash
hydra -l ftpuser -P /usr/share/wordlists/rockyou.txt <target> ftp
hydra -l admin  -P rockyou.txt <target> ssh -s 2222
```

**Web login forms** (`http-post-form`): give the path, the body, and the failure string.
```bash
# ^USER^ / ^PASS^ are the injection points; last field = "failure" marker
hydra -l admin -P /usr/share/wordlists/rockyou.txt <target> http-post-form \
  "/login.php:username=^USER^&password=^PASS^:Invalid Password!"
```
> the failure string is text shown on a *failed* login. Hydra flags any attempt
> that does NOT return it. (`http-get-form` for GET-based forms.)

## Wordlists

| path | note |
| ---- | ---- |
| `/usr/share/wordlists/rockyou.txt` | the classic (may be `.gz` — `gunzip` it first) |
| `/usr/share/wordlists/seclists/Usernames/` | username lists |
| `/usr/share/wordlists/seclists/Passwords/` | password lists |

> choose the list to fit the situation. Brute force is most effective once you
> already have a username, a leaked hint, or know a weak password policy.

## Hash Cracking — identify the hash first

| tool | usage |
| ---- | ----- |
| `hash-identifier` | interactive guesser |
| `hashid <hash>` | prints likely types + hashcat/john modes |
| hashcat wiki "example hashes" | compare format by eye |
| dcode.fr hash-identifier | web lookup |

## Hash Cracking — John the Ripper

| mode | command | note |
| ---- | ------- | ---- |
| wordlist | `john --wordlist=<list> hashes.txt` | hash each word, compare; add `--rules` for mutations |
| single crack | `john --single hashes.txt` | builds its own list from GECOS/username fields |
| incremental | `john --incremental hashes.txt` | pure brute force (slow, eventually everything) |

| action | command |
| ------ | ------- |
| specify format | `john --format=<fmt> hashes.txt` |
| show cracked results | `john --show hashes.txt` |
| list formats | `john --list=formats` |

> JtR auto-detects the format, but state it explicitly (`--format=`) when unsure.

**Cracking Linux `/etc/shadow`** — combine passwd + shadow first with `unshadow`:
```bash
unshadow /etc/passwd /etc/shadow > hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
john --show hashes.txt
```

## Hash Cracking — hashcat (GPU alternative)

| command | usage |
| ------- | ----- |
| `hashcat -m <mode> -a 0 hashes.txt <wordlist>` | straight (wordlist) attack |
| `hashcat -m <mode> -a 3 hashes.txt '?a?a?a?a'` | brute-force mask |
| `hashcat -m <mode> hashes.txt <wordlist> -r <rules>` | wordlist + rules |
| `hashcat --show -m <mode> hashes.txt` | show cracked |

> `-m` = hash type (e.g. 0 = MD5, 1800 = sha512crypt); `-a` = attack mode.
> faster than JtR on a GPU; JtR is simpler for one-off CPU cracking.

## Hash Cracking — extract hashes from files

> password-protected files have no `/etc/shadow`; extract the crackable hash with
> a `*2john` helper, then feed it to john/hashcat.

| command | for |
| ------- | --- |
| `zip2john file.zip > hash.txt` | zip archive |
| `pdf2john file.pdf > hash.txt` | pdf |
| `ssh2john id_rsa > hash.txt` | encrypted SSH private key |
| `keepass2john file.kdbx > hash.txt` | KeePass database |
| `office2john file.docx > hash.txt` | MS Office document |

```bash
ssh2john id_rsa > hash.txt
john --wordlist=rockyou.txt hash.txt
```

## Online vs Offline Cracking

| approach | pro | con |
| -------- | --- | --- |
| **online** (crackstation.net) | instant (precomputed tables) | only common unsalted hashes; exposes the hash to a third party |
| **offline** (john / hashcat) | flexible, private | costs compute time |

## General Tips

- Always **identify the hash type** before cracking — wrong format wastes hours.
- `rockyou.txt` + rules cracks a huge share of real-world passwords; try it first.
- Brute forcing a live service is noisy and slow — prefer it when you have a lead.
- For Linux system hashes: `unshadow` first, then crack.
- Lower hydra's `-t` if a service drops connections under load.
