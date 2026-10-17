# Linux File Structure

| dir/file | usage |
| -------- | ----- |
| `/etc/hosts` | local "DNS" |
| `/etc/passwd` | user config |
| `/etc/shadow` | password hashes |
| `/home`  | user homes (for those that have homes) |
| `/tmp`   | "temporary" files, usually located on RAM |
| `.`      | current dir |
| `..`     | parent dir |
| `~`      | home dir of current user |

# Bash Basics

| variable | usage |
| -------- | ----- |
| HOME     | used for ~ |
| USER     | current username |
| PATH     | paths for dirs with apps |
| SHELL    | default shell |
| PWD      | present working directory |

> use `$<variable>` to reference them

| information command | usage |
| ------------------- | ----- |
| `man <command>`     | system's manual pager |
| `<command> --help`  | internal manual |
| `history`           | command history |
| `file <file>`       | determine file type |

| navigation command | usage |
| ------------------ | ----- |
| `pwd`              | present working directory |
| `cd <dir>`         | change directory |
| `ls [<dir>]`       | list content of dir |
| `ls -la [<dir>]`   | ... with hidden files and detailed info |

| management command | usage |
| ------------------ | ------ |
| `cp <src> <dst>`   | copy src to dst |
| `mv <src> <dst>`   | move src to dst |
| `rm <file>`        | remove file |
| `rm -rf <file/dir>` | remove recursively with force (also dirs) |
| `cat <file>`       | print file to standard output |
| `more <file>`      | print with pager |

| search command | usage |
| -------------- | ----- |
| `which <executable>` | locate path |
| `grep "regex" <file>` | g/re/p: global, reg. ex., print; search for pattern in file |
| `find <path> -name <filename>` | search recursively by name |
| `find <path> -type <filetype>` | search recursively by type |
| `find <path> -size <filesize>` | search recursively by size |

**pipe**: `cat data.txt | grep "keyword"`
- creates temporary storage to chain commands

**asterisk**: `ls *.txt`
- matches any file or dir

**escape** special characters like: `echo "He said \"Hi\""`
- use `"` or `'` to print spaces `echo "Hello world!"`
- or `echo 'He said "Hi"'`

# Stream Control

| command | usage |
| ------- | ----- |
| `cmd > file` | STDOUT -> new file |
| `cmd >> file` | STDOUT -> append file |
| `cmd < file`  | file -> STDIN |

search for patterns: `<cmd> | grep "keywords"`
sort lines: `<cmd> | sort`
remove adjacent duplicates: `<cmd> | sort | uniq`
keep only lines appearing once: `<cmd> | sort | uniq -u`
map characters: `<cmd> | tr 'a-z' 'A-Z'`

# Permissions

**read**, **write**, **execute** for **user**, **group**, **other**

| command | usage |
| ------- | ----- |
| `whoami` | get username |
| `groups` | get groups of current user |
| `id`    | get UID and GID's |
| `su [<user>]` | switch user (default root) |
| `sudo <cmd>` | execute cmd with root |
| `chown [<user>]:[<group>] <file>` | change ownership |
| `chmod 600 <file>` | change permissions (to `rw-------`) |
| `chmod u=rw,g=r,o=r <file>` | set permissions `rw-r--r--` |

# Process Management

| command | usage |
| ------- | ----- |
| `ps`    | processes associated with current shell |
| `ps aux` | snapshot of all current processes |
| `top`   | `ps aux`, but updated |
| `sleep <n>` | sleep for n seconds |
| `<cmd> &` | run command in background |
| `jobs`  | show background processes |
| `bg [<pid>]` | background current process or pid |
| `fg [<pid>]` | foreground latest process or pid |
| `kill <pid>` | send SIGTERM to pid |
| `kill -9 <pid>` | send SIGKILL to pid |

> systemctl for services/daemons

# Networking Commands

| command | usage |
| ------- | ----- |
| `ping [-c <n>] <host>` | ping host (n times)|
| `traceroute <host>` | show hops |
| `dig <host>` | dns query for host |
| `ip [-br] a` | list interfaces (short format) |
| `ss -tulpn` | show listening ports |
| `tcpdump -i <interface>` | capture traffic on interface |

# Transfer and Communication

get http via command line
- `wget <url> -O <file>`
- `curl <url> -o <file>`

unencrypted communication: `nc <url> <port>`
ssh: `ssh [<user>@]<host> [-i <id_file>]`

# Shortcuts

- for the default kali terminal: QTerminal

| shortcut | usage |
| -------- | ----- |
| CTRL + SHIFT + C | copy selection |
| CTRL + SHIFT + V | paste clipboard |
| CTRL + C | SIGTERM to current process |
| CTRL + D | send EOF (close terminal, python, ...) |
| CTRL + Z | suspend current process |
| Up Arrow Key | cycle through previous commands in history |
| Down Arrow Key | cycle through next commands in history |
| Tab      | auto-complete |
| Tab twice | list all possible completions |

## tmux

| command | usage |
| ------- | ----- |
| `tmux [new -s <name>]` | start new session (named) |
| `tmux ls` | list sessions |
| `tmux a` | attach most recently detached session |

> modified config by Vocke in his [blog](https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/)

| shortcut | vocke | usage |
| -------- | ----- | ----- |
| CTRL + B | CTRL + A | prefix (release before actual command) | 
| C        |       | create new window |
| W        |       | display all open windows |
| {0,...9} |       | display window 0,...9 |
| "        | -     | split horizontally |
| %        | \|    | split vertically |
| X        |       | close current pane |
| D        |       | detach from current session |
| ,        |       | rename window |
| arrow    | ALT + arrow | switch between panes |
| z        |       | toggle zoom active pane |
