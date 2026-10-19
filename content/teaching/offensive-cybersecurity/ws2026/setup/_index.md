---
title: "Environment Setup"
---
[← Back to the course](../)

A one-time setup to prepare your machine for the labs. You do this once at the start of the course. When you're done, continue to the [Lab Guide](../lab-guide/), which you'll use every week.

The labs run inside Docker, on a Kali Linux virtual machine, inside VirtualBox. That means you don't need to install hacking tools or touch your real operating system. Everything lives in the VM.

![The lab environment: Docker runs the labs inside a Kali Linux VM, which runs in VirtualBox on your own computer.](/img/setup-architecture.png)

> **On an Apple Silicon Mac (M1, M2, M3, M4)?** VirtualBox cannot run the x86-64 Kali VM on Apple chips, so the VirtualBox steps below are not for you. Jump to [Apple Silicon Macs](#apple-silicon-macs) at the bottom of this page. (Intel Macs follow the normal steps.)

## 1. Install VirtualBox
Download and install VirtualBox for your operating system from the [official downloads page](https://www.virtualbox.org/wiki/Downloads). If you need help, the [installation manual](https://www.virtualbox.org/manual/topics/installation.html#installation) has per-platform details.

## 2. Install the Kali Linux VM
On the [Kali Linux downloads page](https://www.kali.org/get-kali/#kali-virtual-machines), download the **prebuilt VirtualBox** image of Kali Linux. Extract the downloaded `.7z` archive, then import the VM by following [Kali's import guide](https://www.kali.org/docs/virtualization/import-premade-virtualbox/).

Log in with the default credentials `kali` / `kali`.

> Optional: German keyboard layout. Either set it in the GUI (**Settings Manager > Keyboard > Layout**, add German, remove English), or from a terminal:
> ```bash
> # kali
> sudo sed -i 's/XKBLAYOUT="us"/XKBLAYOUT="de"/' /etc/default/keyboard
> sudo setupcon
> ```
> If the layout resets after a reboot, use the GUI route. The Xfce settings daemon can override the console setting.

Open a terminal inside the Kali VM and run (this may take up to 30 minutes):
```bash
# kali
sudo apt update && sudo apt upgrade -y
```


## 3. Install Docker
Open a terminal **inside the Kali VM** and run:
```bash
# kali
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker --now
```
The `newgrp docker` line applies your new group membership in the current terminal, so you don't have to log out and back in.

## 4. Verify it works
Still inside the Kali VM:
```bash
# kali
docker run hello-world
docker compose version
```
The first command should print a "Hello from Docker!" message. The second should report a Compose version (v2, e.g. `Docker Compose version v2.x`).

If both work, your environment is ready. Continue to the [Lab Guide](../lab-guide/) to run your first lab.

## Apple Silicon Macs
Macs with an Apple chip (M1, M2, M3, M4) cannot use VirtualBox for these labs: VirtualBox on Apple Silicon only runs ARM guests, while the prebuilt Kali image above is x86-64. Use the path below instead. Everything else stays the same afterwards: you still run a Kali VM, start labs with `manage.sh`, and SSH into the attacker container.

### 1. Install UTM
Install [UTM](https://mac.getutm.app/) (free), a virtualization app that runs on Apple Silicon.

### 2. Install an ARM64 Kali VM
Follow Kali's guide [Install Kali as a UTM guest](https://www.kali.org/docs/virtualization/install-utm-guest-vm/), choosing the **ARM64** image. An ARM Kali runs natively on your chip, so it is fast. Log in (`kali` / `kali`), then update it:
```bash
# kali
sudo apt update && sudo apt upgrade -y
```
Keeping Kali current matters here: it brings the up-to-date emulation support the next step relies on.

> Optional: for the German keyboard layout, follow the note in the main **step 2 (Install the Kali Linux VM)** above.

### 3. Install Docker, then enable x86 emulation
Inside the Kali VM, install Docker exactly as in step 3 above. Then let your ARM machine run the course's x86-64 images:
```bash
# kali
sudo apt install -y qemu-user-static binfmt-support
echo 'export DOCKER_DEFAULT_PLATFORM=linux/amd64' >> ~/.bashrc
source ~/.bashrc
```
`qemu-user-static` lets the ARM VM run x86-64 images by emulating them, and the `DOCKER_DEFAULT_PLATFORM` line tells Docker to pull the x86-64 build by default.

### 4. Continue as normal
From here, follow the [Lab Guide](../lab-guide/). Everything works the same; the lab containers simply run emulated, so expect them to be somewhat slower than on an Intel machine.

If a lab misbehaves, first make sure your Kali is fully updated. As heavier fallbacks, you can run a full **x86-64** Kali in UTM (emulates the whole system, slower but maximally compatible), or use the Institute's remote pool computers.

### If the attacker container refuses SSH logins
On older emulation setups the attacker container's SSH can refuse logins. You normally never touch Docker directly; this is the one manual exception.

1. Start the lab once so its config is downloaded: `./manage.sh start <lab-name>`
2. Open `labs/ws2026/<lab-name>/docker-compose.yml` (in the same folder as your `manage.sh`).
3. Find the `attacker:` service and add a `security_opt` entry to it:
   ```yaml
   security_opt:
     - seccomp=unconfined
   ```
4. Restart the lab: `./manage.sh stop <lab-name>`, then `./manage.sh start <lab-name>`. Do not run `refresh` afterwards, or the file is re-downloaded and your edit is lost.
