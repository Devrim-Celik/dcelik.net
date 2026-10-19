---
title: "Lab Guide"
---
[← Back to the course](../)

How to download, run, and navigate the hands-on labs. This is your weekly reference. It assumes you've already done the one-time [Environment Setup](../setup/) (VirtualBox, Kali VM, Docker).

Everything runs inside Docker on your Kali VM. You manage the labs with a single script, `manage.sh`, which you download once. It handles downloading each lab, starting it, and wiring in your details. You never edit compose files or type long Docker commands.

![Inside the Kali VM, Docker runs the lab: the attacker-system and lab-assistant containers are reachable over SSH on your loopback interface, and some labs expose extra target ports.](/img/lab-connection-ports.png)

## 1. Get manage.sh (once)
Download the script into a folder of your choice on your Kali VM:
```bash
# kali
mkdir -p ~/OITS-labs && cd ~/OITS-labs
curl -fsSLO https://dcelik.net/dl/ws2026/manage.sh
chmod +x manage.sh
```
You only do this once. Keep it in that folder; the labs it downloads will live alongside it.

## 2. Start a lab
From that folder, start any lab by name (the lab names are in the course table):
```bash
# kali
./manage.sh start <lab-name>
```
The **first time** you ever run it, it asks for two things:

- the **cohort tag** for this edition (e.g. `ws2026`)
- your **student ID**: use your **Matrikelnummer**, entered exactly and with no spaces

It saves these to a local `.env` file so you're never asked again. Enter your Matrikelnummer carefully: every lab derives its flags from it, so your flags are **individual to you**. You therefore cannot use a classmate's flag, and a mistyped or inconsistent ID silently produces the wrong flags. To change it later, edit the `.env` file in your labs folder. Then it downloads that lab's configuration, pulls the images (first time only, this can take a few minutes), and starts the containers. When it finishes it prints how to connect.

Check what's running at any time:
```bash
# kali
./manage.sh status
```

## 3. Connect to the attacker system
Each lab gives you a Kali **attacker** container, your base of operations. Connect to it over SSH (the exact port is printed when the lab starts):
```bash
# kali
ssh -p <attacker-port> attacker@localhost	# password: attacker
```
All tools are pre-installed. You can open as many SSH sessions to it as you like; each is an independent shell on the same container.

## 4. Read the lab instructions
The objectives live inside a **lab-assistant** container, not in any file. Connect to it:
```bash
# kali
ssh -p <assistant-port> student@localhost # password: student
```
You're dropped straight into a menu. Arrow keys to navigate, Enter to select, Escape to go back, Ctrl-D to exit. Every lab's menu has:

- **Setup**: the target hostnames and credentials for *this* lab. Your source of truth.
- **Description**: background on the topic.
- **Objectives**: the tasks, in order, sometimes with hints.

> The lab-assistant is read-only. All your actual work happens from the attacker container, not here.

## 5. Reach the targets
From **inside the attacker container**, targets are reachable by hostname, no IP addresses needed. The hostnames are listed in the Setup menu. For example:
```bash
# attacker
nmap -sV <target-hostname>
ssh <user>@<target-hostname>
curl http://<target-hostname>/
```

## 6. Stop the lab
When you're done for the session:
```bash
# kali
./manage.sh stop <lab-name>
```
The containers are stateless: work inside them is **not saved**. Keep your notes outside the containers. Run `./manage.sh start <lab-name>` again to resume.

## Wordlists
Some labs need a password or directory wordlist. **Use the ones already on the attacker container**. The labs are tuned to them, and swapping in a different list gives different (often empty) results and a lot of wasted time:

- **Passwords** (cracking hashes, brute-forcing logins): `/usr/share/wordlists/rockyou.txt`
- **Directory / content discovery** (`gobuster`, `ffuf`, `dirb`, ...): `/usr/share/wordlists/seclists/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-medium.txt`

Both are already unpacked and ready on the attacker, no download needed.

## manage.sh reference
| Command | What it does |
|---|---|
| `./manage.sh start <lab-name>` | Download (if needed) and start a lab; prints connection info |
| `./manage.sh stop <lab-name>` | Stop a lab |
| `./manage.sh status` | Show which labs are running |
| `./manage.sh refresh <lab-name>` | Re-download a lab's configuration (if it changed) |
| `./manage.sh clean <lab-name>` | Stop a lab and remove its data for a full reset |

## Troubleshooting

**SSH connection refused**: the container may still be starting. Wait a few seconds, check `./manage.sh status`, and try again.

**Remote host identification has changed**: appears when a port was reused by a new container. Clear the old key (the command is the same on host and Kali):
```bash
# kali
ssh-keygen -R '[localhost]:<port>'
```

**"Couldn't reach dcelik.net"**: the script can't reach the server. Check your VM's internet connection.

**"Lab isn't available for this edition"**: either the lab name is misspelled, or it hasn't been released yet. Check the course table for released labs and exact names.

**A lab was updated**: run `./manage.sh refresh <lab-name>` to pull the new version, then start it again.

## Weekly tutor session
Stuck on a lab? There is a weekly drop-in tutor session, **Mondays 13:00 to 14:00**, in the voice channel of the **offensive-sicherheit** room on the Info & Cyber-Sec Bonn student Discord (a student-run server). Just show up with your questions.

To join the Discord: open the [Fachschaft Informatik site](https://www.fachschaft.info/en/), scroll to its **Social Media** section (under **Unofficial Channels**), and use the **Info & Cyber-Sec Bonn** Discord link. Then open the **offensive-sicherheit** room and join its voice channel at the session time.
