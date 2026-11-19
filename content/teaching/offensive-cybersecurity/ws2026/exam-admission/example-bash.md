---
title: "Example writeup: Bash"
ShowToc: true
TocOpen: false
build:
  list: never
---

[← Exam Admission](../) · {{< download "/dl/examples/example-writeup-bash.md" "Download this example (.md)" >}}

An example of a complete writeup for the optional Bash lab, written to the rules on the [Exam Admission](../) page. Download the `.md` to see the source, including the front matter it starts with:

```markdown
---
lab: bash
name: Max Mustermann
matrik: 1234567
---

# bash writeup
```

All challenges run on the target `bash-trainer`. I connected from the attacker system with
`ssh challenge01@bash-trainer` (password `challenge01`). Every challenge gives the password for the
next account, so each section starts with an SSH login as the next user.

## Challenge 01
First I looked at what is in the home directory:

```
$ ls
readme.txt
$ cat readme.txt
dFf5bU8kS7u3
```

## Challenge 02
```
$ ls
-
```

The file is called `-`. When I give that to `cat` directly, it waits for input instead of opening
the file, because `-` means "standard input" to most commands. With `./` in front it is clearly a
file name:

```
$ cat ./-
PYzH65290r8K
```

## Challenge 03
```
$ ls
checkmeout
$ cd checkmeout; ls
'read me.txt'
```

There is a space in the name, so `cat read me.txt` would look for two files, `read` and `me.txt`.
With quotes it stays one name:

```
$ cat "read me.txt"
nrAq8XczhT91
```

## Challenge 04
```
$ ls
$ ls -a
.  ..  .bash_logout  .bashrc  .cache  .profile  .readme.txt
```

`ls` showed nothing at all, but a file starting with a dot is hidden, and `ls -a` lists those too.

```
$ cat .readme.txt
U918O5QfIrKp
```

## Challenge 05
```
$ ls | head -3
file000.txt
file001.txt
file002.txt
```

There are 1000 files. The few I opened with `cat` were just binary garbage, and I didn't want to go
through all of them. `file` tells me what kind of data each file really contains, so I let it check
all of them and kept only the text ones:

```
$ file * | grep ASCII
file008.txt: ASCII text
$ cat file008.txt
PuCseJB159sK
```

## Challenge 06
```
$ cat readme.txt
NDh0aGxoNzRLQ2VoCg==
```

The `==` at the end looks like base64 padding, so I decoded it:

```
$ cat readme.txt | base64 -d
48thlh74KCeh
```

## Challenge 07
```
$ cat readme.txt
4CCM90Md5phv
```

I tried `base64 -d` again first, but that only gave unreadable bytes. The text has the same length
and mix of letters and digits as the passwords before, so I guessed that only the letters were
shifted, like ROT13. `tr` can do that by mapping every letter 13 places further:

```
$ cat readme.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m'
4PPZ90Zq5cui
```

## Challenge 08
```
$ ls
doubles.txt
$ head -3 doubles.txt
r3vP3WP4k1xH
SHnitZ
j7t8ei
```

From the name I guessed that every line is in there twice except one. `uniq -u` prints the lines
that are not repeated, but it only compares neighbouring lines, so I sorted the file first:

```
$ sort doubles.txt | uniq -u
r3vP3WP4k1xH
```

## Challenge 09
```
$ ls
dir01  dir02  dir03  ...  dir30
```

30 directories with 30 subdirectories each is too many to open by hand. `find` searches the whole
tree for me:

```
$ find . -type f -name readme.txt
./dir07/dir25/readme.txt
$ cat ./dir07/dir25/readme.txt
8VDOlC02IL9Z
```

## Challenge 10
```
$ ls
pack.zip
$ unzip pack.zip
Archive:  pack.zip
  inflating: pack.tar.gz
```

Inside the zip is another archive, a gzip compressed tar. `tar xzf` unpacks it (`x` extract,
`z` gzip, `f` the file):

```
$ tar xzf pack.tar.gz
$ cat pack/readme.txt
m3Jor7AeSC6C
```

## Challenge 11
```
$ ls -a
.  ..  .bash_logout  .bashrc  .cache  .profile
```

No files this time, not even hidden ones. Apart from files, the shell also keeps information in
environment variables, so I listed them with `env` and searched for anything called flag:

```
$ env | grep FLAG
FLAG=8g5C6IrGtn8v
```

## Challenge 12
```
$ ls
id_rsa
```

That is an SSH private key, and the lab assistant says it belongs to `challenge13`. SSH refuses a
private key that other users can read, so I limited it to the owner (`600`) first. The key is on
this machine already, so I logged in to `localhost`:

```
$ chmod 600 id_rsa
$ ssh -i id_rsa challenge13@localhost
...
challenge13@bash-trainer:~$
```

## Challenge 13
The lab assistant mentions a web server on port 8080 on this machine. I asked for its start page
with `curl`:

```
$ curl http://localhost:8080/
193VxpT7bk75
```

## Challenge 14
This time there is a service on port 1337 that answers to `GETFLAG`. With `nc` I opened a plain
connection, waited for the welcome message and typed the command:

```
$ nc localhost 1337
Welcome. Send GETFLAG to receive the flag.
GETFLAG
FLAG: e8DD40zEI428
```

## Challenge 15
```
$ ls
bigfile.txt
```

The file has thousands of lines, way too many to read. The lab assistant says the flag is on the
line starting with `ethicalhacking`, so I let `grep` find it:

```
$ grep ethicalhacking bigfile.txt
ethicalhacking DC{5fbbe94af518bd69ca793a58ad1451f2}
```
