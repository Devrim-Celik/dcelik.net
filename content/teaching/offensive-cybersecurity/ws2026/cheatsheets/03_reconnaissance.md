---
title: "Reconnaissance"
ShowToc: true
TocOpen: false
build:
  list: never
---


> Information gathering: find live hosts, find open ports, and identify the
> service and version behind each one. General flow: host discovery → port
> scan → per-service enumeration. Note software **and version** everywhere — it
> feeds everything that comes later.

## Nmap

| flag | usage |
| ---- | ----- |
| `nmap <ip>` | scan a host |
| `nmap <ip1> <ip2> ...` | scan multiple hosts |
| `nmap <ip>/<numbits>` | scan a CIDR range |
| `nmap 192.168.0-255.0-31` | scan an octet range |
| `nmap -iL <file>` | read targets from a file |

| recipe | usage |
| ------ | ----- |
| `sudo nmap -p- -vvv -Pn -sS -oN tcp_all <target>` | scan all TCP ports |
| `sudo nmap -p<X,Y,...> -vvv -Pn -sSCV -oN tcp_enum <target>` | enumerate found ports |
| `sudo nmap -F -vvv -Pn -sU -oN udp <target>` | scan common UDP ports |

### Host Discovery

| flag | usage |
| ---- | ----- |
| `-sL` | list targets, do not scan |
| `-sn` | host discovery only, no port scan |
| `-Pn` | skip host discovery (treat as online) |

### Port Scanning

| flag | usage |
| ---- | ----- |
| `-sT` | TCP connect scan (default, unprivileged) |
| `-sS` | TCP SYN scan (default, privileged) |
| `-sU` | UDP scan |
| `-F` | fast scan, top 100 ports |
| `--top-ports <n>` | scan top n ports |
| `-p80,400-420` | scan specific ports / ranges |
| `-p-` | scan all 65535 ports |

### Service & OS Detection

| flag | usage |
| ---- | ----- |
| `-sV` | service / version detection (banner) |
| `-O` | OS detection |
| `-sC` | run default NSE scripts |
| `-A` | `-sV` + `-O` + `-sC` combined |
| `-vvv` | very verbose (live results) |

### Output

| flag | usage |
| ---- | ----- |
| `-oN <file>` | normal output |
| `-oG <file>` | greppable output |
| `-oX <file>` | XML output |
| `-oA <file>` | all formats at once |

### Scripting Engine (NSE)

| flag | usage |
| ---- | ----- |
| `--script <name>` | run a script (comma-separated for many) |
| `--script <category>` | run a whole category |
| `--script "http-*"` | wildcard match |
| `--script-help <name>` | what a script does / its args |

> scripts live in `/usr/share/nmap/scripts/` (catalog: `script.db`)

## Unknown Services

> if a port is open but the service is unclear, talk to it by hand.

| command | usage |
| ------- | ----- |
| `nc <target> <port>` | raw TCP connection |
| `telnet <target> <port>` | raw TCP connection |

## FTP (21/tcp)

| command | usage |
| ------- | ----- |
| `ftp <target>` | connect with the ftp client |
| `ftp anonymous@<target>` | try anonymous login (`anonymous` : anything) |
| `ls` | list |
| `cd <dir>` | change directory |
| `cd ..` | test directory traversal / chroot escape |
| `get <file>` | download |
| `put <file>` | upload |
| `passive {on,off}` | switch passive / active mode |

## SSH (22/tcp)

| command | usage |
| ------- | ----- |
| `ssh [<user>@]<target>` | connect |
| `-p <port>` | custom port (default 22) |
| `-i <file>` | custom identity key (needs perms `600`) |
| `ssh-keygen -t <type> -b <bits>` | generate a key pair |

> keys live in `~/.ssh/` (public = `.pub`); a found private key can be a foothold.

## DNS (53/tcp + 53/udp)

| command | usage |
| ------- | ----- |
| `dig [@<server>] <domain>` | query (optionally a specific server) |
| `-x` | reverse lookup (PTR) |
| `axfr` | attempt a full zone transfer |

| record | meaning |
| ------ | ------- |
| `A` | IPv4 address |
| `AAAA` | IPv6 address |
| `CNAME` | alias |
| `MX` | mail server |
| `NS` | name server |
| `PTR` | name for a reverse lookup |
| `TXT` | text notes |

> a misconfigured server allows the full zone (AXFR) → lists every record.

## HTTP (80/tcp) / HTTPS (443/tcp)

| command | usage |
| ------- | ----- |
| `curl <url>` | fetch a page |
| `curl -I <url>` | headers only (HEAD) — tech, custom `x-` headers |

| file | usage |
| ---- | ----- |
| `/robots.txt` | paths the site asks crawlers to skip (hints!) |
| `/sitemap.xml` | overview of pages |

### Fuzzing

| command / flag | usage |
| -------------- | ----- |
| `ffuf -u <url> -w <wordlist>` | fuzz paths (put `FUZZ` in the URL) |
| `-recursion` | recurse into found dirs |
| `-c` | colored output |
| `-v` | show full URLs |
| `-m{c,l,r,s,w} <X>` | match by code / #lines / regex / size / #words |
| `-f{c,l,r,s,w} <X>` | filter by the same |

| wordlist | note |
| -------- | ---- |
| `common.txt` | ~5k entries, good first pass |
| `directory-list-2.3-medium.txt` | ~220k entries, deeper |

## NetBIOS (139/tcp)

| command | usage |
| ------- | ----- |
| `nmblookup -A <target>` | NetBIOS names (hostname, workgroup) |
| `nbtscan -r <target>` | scan NetBIOS over a range |

| code | name |
| ---- | ---- |
| `00` | Workstation Service |
| `03` | Windows Messenger Service |
| `06` | Remote Access Service |
| `20` | File Service (host record) |
| `21` | Remote Access Service client |
| `1B` | Domain Master Browser |
| `1D` | Browser Election |

## SMB (445/tcp)

| command | usage |
| ------- | ----- |
| `smbclient -N -L <target>` | list shares, no auth (null session) |
| `smbclient -U <user> -L <target>` | list shares as a user |
| `smbclient -N //<target>/<share>` | connect to a share |
| `enum4linux -a <target>` | aggregate enumeration (shares, users, NBT, ...) |

> inside `smbclient`, use `recurse ON` + `prompt OFF` + `mget *` to pull everything.
> `IPC$` is a control/communication share, not files.

## SNMP (161/udp, 162/udp)

| command | usage |
| ------- | ----- |
| `snmpwalk -v <version> -c <string> <target>` | walk the MIB (human-readable) |
| `snmp-check <target> -c <string>` | structured dump (needs an IP, not a hostname) |
| `hydra -P <wordlist> <target> snmp` | brute-force the community string |

> default community string: `public` (read-only); `private` is read-write.
> brute list: `/usr/share/wordlists/seclists/Discovery/SNMP/common-snmp-community-strings.txt`

## General Tips

- Enumerate **every** open port, TCP **and** UDP — do not stop at port 80.
- Record software **and version** for each service; it drives later steps.
- Keep organized notes: one section per host, one per service.
- Save scan output (`-oN` / `-oA`) so you never have to re-scan.
- When a service is unidentified, connect by hand and read the banner.
