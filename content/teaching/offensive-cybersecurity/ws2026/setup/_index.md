---
title: "Environment Setup"
---
[← Back to the course](../)

A one-time setup to prepare your machine for the labs. You do this once at the start of the course. When you're done, continue to the [Lab Guide](../lab-guide/), which you'll use every week.

The labs run inside Docker, on a Kali Linux virtual machine, inside VirtualBox. That means you don't need to install hacking tools or touch your real operating system. Everything lives in the VM.

![The lab environment: Docker runs the labs inside a Kali Linux VM, which runs in VirtualBox on your own computer.](/img/setup-architecture.png)

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
