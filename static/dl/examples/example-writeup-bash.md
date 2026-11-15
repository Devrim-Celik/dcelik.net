---
lab: bash
matrik: 1234567
---

# bash writeup

All challenges run on the target `bash-trainer`. I connect from the attacker system with
`ssh challenge01@bash-trainer` (password `challenge01`). Each challenge yields the password for
the next account, so every section starts with an SSH login as the next user.

## Challenge 01

In a new home directory, the first step is to look at what is there.

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

The file is called `-`. Passed directly to `cat`, it is read as "standard input" instead of a
file name. Referring to it with a relative path (`./`, the current directory) avoids that.

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

The file name contains a space, so `cat read me.txt` would look for two files. Quoting the name
passes it as one argument.

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

The home directory looks empty, but `ls -a` also lists hidden files (names starting with `.`).

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

There are 1000 files, and opening a few with `cat` shows only unreadable binary data. `file`
identifies the type of each file by its content; filtering for `ASCII` finds the one text file.

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

The character set and the `==` padding at the end are typical for base64.

```
$ cat readme.txt | base64 -d
48thlh74KCeh
```

## Challenge 07

```
$ cat readme.txt
4CCM90Md5phv
```

Decoding this with `base64 -d` only prints unreadable bytes, so it is not base64. The text has
the same length and character mix as the previous passwords, which suggests a simple letter
substitution such as ROT13. `tr` shifts every letter by 13 places.

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

The name `doubles.txt` hints that every line appears twice except one. `uniq -u` prints only
lines that occur once, but it compares neighbouring lines, so the file has to be sorted first.

```
$ sort doubles.txt | uniq -u
r3vP3WP4k1xH
```

## Challenge 09

```
$ ls
dir01  dir02  dir03  ...  dir30
```

The home directory holds 30 directories with 30 subdirectories each. Instead of opening them one
by one, `find` searches the whole tree for regular files.

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

The zip contains a gzip compressed tar archive. `tar` unpacks it with `x` (extract), `z` (gzip)
and `f` (the archive file).

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

There are no files to read this time, not even hidden ones. Besides files, a shell also carries
information in its environment variables, which `env` lists.

```
$ env | grep FLAG
FLAG=8g5C6IrGtn8v
```

## Challenge 12

```
$ ls
id_rsa
```

The file is an SSH private key, and according to the lab assistant it belongs to `challenge13`.
SSH refuses to use a private key that other users can read, so the permissions have to be
reduced to owner only (`600`) first. Since the key is on this machine, I log in to `localhost`.

```
$ chmod 600 id_rsa
$ ssh -i id_rsa challenge13@localhost
...
challenge13@bash-trainer:~$
```

## Challenge 13

The lab assistant mentions a web server on this machine on port 8080. `curl` sends a GET request
to its root path.

```
$ curl http://localhost:8080/
193VxpT7bk75
```

## Challenge 14

The lab assistant mentions a service on port 1337 that answers the command `GETFLAG`. `nc` opens a
plain TCP connection, and I type the command once the welcome message appears.

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

The file has thousands of lines, far too many to read. According to the lab assistant, the flag is on the line that starts
with `ethicalhacking`, so `grep` can pick it out.

```
$ grep ethicalhacking bigfile.txt
ethicalhacking DC{...}
```
