---
title: "Linux & Bash Basics"
ShowToc: true
TocOpen: false
build:
  list: never
---

[← Cheat Sheets](../) · {{< download "/dl/cheatsheets/02_linux-and-bash-basics.md" "Download this sheet (.md)" >}}


> The core Linux and shell commands you lean on constantly: navigating the
> filesystem, manipulating files and streams, managing processes, and basic
> networking. Everything else builds on these.

## Linux File Structure

| dir/file | usage |
| -------- | ----- |
| `/etc/hosts` | local "DNS" (static hostname → IP map) |
| `/etc/passwd` | user accounts config |
| `/etc/shadow` | password hashes |
| `/home` | user home directories |
| `/tmp` | temporary files (often on RAM) |
| `.` | current dir |
| `..` | parent dir |
| `~` | home dir of current user |

## Bash Basics

| variable | usage |
| -------- | ----- |
| `HOME` | used for `~` |
| `USER` | current username |
| `PATH` | dirs searched for executables |
| `SHELL` | default shell |
| `PWD` | present working directory |

> reference a variable with `$<variable>`, e.g. `echo $HOME`

| information command | usage |
| ------------------- | ----- |
| `man <command>` | system manual pager |
| `<command> --help` | built-in usage summary |
| `history` | command history |
| `file <file>` | determine file type |

| navigation command | usage |
| ------------------ | ----- |
| `pwd` | present working directory |
| `cd <dir>` | change directory |
| `ls [<dir>]` | list contents of dir |
| `ls -la [<dir>]` | ... with hidden files and detail |

| management command | usage |
| ------------------ | ----- |
| `cp <src> <dst>` | copy src to dst |
| `mv <src> <dst>` | move / rename |
| `rm <file>` | remove file |
| `rm -rf <file/dir>` | remove recursively, force (also dirs) |
| `cat <file>` | print file to stdout |
| `more <file>` | print with pager |

| search command | usage |
| -------------- | ----- |
| `which <executable>` | locate an executable in `PATH` |
| `grep "<regex>" <file>` | search for a pattern in a file |
| `find <path> -name <name>` | search recursively by name |
| `find <path> -type <type>` | search recursively by type |
| `find <path> -size <size>` | search recursively by size |

| shell syntax | meaning |
| ------------ | ------- |
| `<cmd> \| <cmd>` | pipe: feed stdout of one command into the next |
| `*` | glob: matches any characters (`ls *.txt`) |
| `"..."` / `'...'` | quote to preserve spaces / special chars |
| `\` | escape a single special char (`echo "He said \"Hi\""`) |

## Stream Control

| redirection | usage |
| ----------- | ----- |
| `cmd > file` | stdout → new file (overwrite) |
| `cmd >> file` | stdout → append to file |
| `cmd < file` | file → stdin |

| pipeline | does |
| -------- | ---- |
| `<cmd> \| grep "<keyword>"` | keep only matching lines |
| `<cmd> \| sort` | sort lines |
| `<cmd> \| sort \| uniq` | remove adjacent duplicates |
| `<cmd> \| sort \| uniq -u` | keep only lines that appear once |
| `<cmd> \| tr 'a-z' 'A-Z'` | map characters (here: lower → upper) |

## Permissions

> **read / write / execute**, each set for **user / group / other**.

| command | usage |
| ------- | ----- |
| `whoami` | current username |
| `groups` | groups of current user |
| `id` | UID and GIDs |
| `su [<user>]` | switch user (default root) |
| `sudo <cmd>` | run a command as root |
| `chown [<user>]:[<group>] <file>` | change ownership |
| `chmod 600 <file>` | set permissions numerically (`rw-------`) |
| `chmod u=rw,g=r,o=r <file>` | set permissions symbolically (`rw-r--r--`) |

## Process Management

| command | usage |
| ------- | ----- |
| `ps` | processes of the current shell |
| `ps aux` | snapshot of all processes |
| `top` | like `ps aux`, live-updating |
| `sleep <n>` | sleep for n seconds |
| `<cmd> &` | run command in background |
| `jobs` | list background jobs |
| `bg [<pid>]` | background a process |
| `fg [<pid>]` | foreground a process |
| `kill <pid>` | send SIGTERM |
| `kill -9 <pid>` | send SIGKILL |

> services and daemons are managed with `systemctl`

## Networking Commands

| command | usage |
| ------- | ----- |
| `ping [-c <n>] <host>` | ping host (n times) |
| `traceroute <host>` | show network hops |
| `dig <host>` | DNS query for host |
| `ip [-br] a` | list interfaces (`-br` = short format) |
| `ss -tulpn` | show listening ports |
| `tcpdump -i <interface>` | capture traffic on an interface |

## Transfer & Communication

| command | usage |
| ------- | ----- |
| `wget <url> -O <file>` | download over HTTP(S) |
| `curl <url> -o <file>` | download over HTTP(S) |
| `nc <host> <port>` | raw (unencrypted) connection |
| `ssh [<user>@]<host> [-i <id_file>]` | encrypted remote shell |

## Shortcuts

| shortcut | usage |
| -------- | ----- |
| `CTRL + SHIFT + C` | copy selection |
| `CTRL + SHIFT + V` | paste clipboard |
| `CTRL + C` | SIGINT to current process |
| `CTRL + D` | send EOF (close shell / python / ...) |
| `CTRL + Z` | suspend current process |
| `↑` / `↓` | cycle through command history |
| `Tab` | auto-complete |
| `Tab Tab` | list all possible completions |

### tmux
Multiple windows and panes in one terminal, and sessions that survive a dropped SSH connection.

| command | usage |
| ------- | ----- |
| `tmux` / `tmux new -s <name>` | start a new (named) session |
| `tmux ls` | list sessions |
| `tmux a [-t <name>]` | attach the last (or a named) session |

Inside tmux most keys use a **prefix**: press and release it, then the key. On the attacker the prefix is `Ctrl-a`.

| key | usage |
| --- | ----- |
| `Ctrl-a` | the prefix (press, release, then a key below) |
| `prefix` `c` | new window |
| `prefix` `w` | list and pick windows |
| `prefix` `0` to `9` | jump to that window |
| `prefix` `\|` | split pane left/right |
| `prefix` `-` | split pane top/bottom |
| `Alt + arrow` | switch pane (no prefix needed) |
| `prefix` `z` | toggle zoom on the active pane |
| `prefix` `x` | close pane |
| `prefix` `,` | rename window |
| `prefix` `&` | close window |
| `prefix` `d` | detach (keeps running; reattach with `tmux a`) |

The attacker ships [Hamel Vocke's tmux config](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/), so the bindings differ from vanilla tmux: prefix `Ctrl-a` (not `Ctrl-b`), splits `|` and `-` (not `%` and `"`), and panes switch with `Alt+arrow`. It is already installed, so there is nothing to set up. The same config is available for your own Kali VM; see the [Setup page](/teaching/offensive-cybersecurity/ws2026/setup/).

## General Tips

- `man` and `--help` answer most questions faster than a search engine.
- Quote anything with spaces or special characters to avoid surprises.
- Prefer `find`/`grep` over clicking around — they scale to whole trees.
- Check `ss -tulpn` to see what is actually listening before assuming a service is down.
- Work inside `tmux` so a dropped connection never kills a long-running task.
