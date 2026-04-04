# Module 7 - Containers with Docker
## Demo Project:
Deploy Nexus as Docker container
## Technologies used:
Docker, Nexus, DigitalOcean, Linux
## Project Description:
* Create and configure droplet
* Set up and run Nexus as Docker container


# Solution

<details>
<summary><b>Create and configure droplet</b></summary>

* Create a new droplet on Digital Ocean
```
Region: Toronto (closest to my location)
OS: Ubuntu
Version: 24.04
Droplet type: Shared CPU
CPU options: Regular
Plan: $48/mo (8 GB, 160 GB SSD Disk, 5 TB transfer)
Authentication method: SSH Key
Hostname: docker-nexus

```
* Add it to a firewall
```
DigitalOcean->Networking->Firewalls->my-droplet-firewall->Droplet Tab->Add Droplets
Search for a new droplet and add it
```
* Rename it to docker-nexus

</details>
<details>
<summary><b>Set up and run Nexus as Docker container</b></summary>

* Connect to a droplet
```
PS C:\repos\js-app> ssh root@137.184.161.94
The authenticity of host '137.184.161.94 (137.184.161.94)' can't be established.
ED25519 key fingerprint is SHA256:+wiTR/F30bNL90zJyykMpitZ/lVrg6cab81GhPPvfhE.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? Y
...
root@ubuntu-s-4vcpu-8gb-tor1-01:~#
```
* Install docker
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# apt update
...
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
162 packages can be upgraded. Run 'apt list --upgradable' to see them.
```
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# apt  install docker.io
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
```
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# docker -v
Docker version 28.2.2, build 28.2.2-0ubuntu1~24.04.1
```
* Find a Nexus image on DockerHub
```
Search for nexus3
An image: https://hub.docker.com/r/sonatype/nexus3

Follow documentation 
```
* Create volume
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# docker volume create --name nexus-data
nexus-data

root@ubuntu-s-4vcpu-8gb-tor1-01:~# docker volume ls
DRIVER    VOLUME NAME
local     nexus-data
root@ubuntu-s-4vcpu-8gb-tor1-01:~#
```
* Run Nexus Docker container
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# docker run -d -p 8081:8081 --name nexus -v nexus-data:/nexus-data sonatype/nexus3
Unable to find image 'sonatype/nexus3:latest' locally
latest: Pulling from sonatype/nexus3
75bed6ef625f: Pull complete
216d4adbc345: Pull complete
16a25e9a3b42: Pull complete
efc8118ebf67: Pull complete
c0f50b17a150: Pull complete
d4f9c5e135da: Pull complete
Digest: sha256:2cc6d2aa089cd8c4953c0bb24963e2dea2005c01f7ef5ff7ef649c9b965c81c7
Status: Downloaded newer image for sonatype/nexus3:latest
9ba08bd3c55d2b80e14c2c24ef05a8364d46f458f077d19818f15588340d3b47
```
* Install netstat 
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# apt install net-tools
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
....

```
* Validate that the port 8081 is open
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# netstat -lnpt
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      745/systemd-resolve
tcp        0      0 0.0.0.0:8081            0.0.0.0:*               LISTEN      3448/docker-proxy
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      745/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1/init
tcp        0      0 127.0.0.1:42897         0.0.0.0:*               LISTEN      2601/containerd
tcp6       0      0 :::8081                 :::*                    LISTEN      3456/docker-proxy
tcp6       0      0 :::22                   :::*                    LISTEN      1/init
root@ubuntu-s-4vcpu-8gb-tor1-01:~#
```
* Validate that container is running
```
root@ubuntu-s-4vcpu-8gb-tor1-01:~# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED         STATUS         PORTS                                         NAMES
9ba08bd3c55d   sonatype/nexus3   "/opt/sonatype/nexus…"   4 minutes ago   Up 4 minutes   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp   nexus
root@ubuntu-s-4vcpu-8gb-tor1-01:~#
```
</details>
<details>
<summary><b>Connect to Nexus and login first time</b></summary>

Nexus URL: http://137.184.161.94:8081/

* Inspect volume 
```
root@ubuntu-s-4vcpu-8gb-tor1-01:/# docker volume inspect nexus-data
[
    {
        "CreatedAt": "2026-03-30T21:48:01Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/nexus-data/_data",
        "Name": "nexus-data",
        "Options": null,
        "Scope": "local"
    }
]
```
*    Find admin.password file under "Mountpoint"

```
root@ubuntu-s-4vcpu-8gb-tor1-01:/# ls /var/lib/docker/volumes/nexus-data/_data
admin.password  blobs  clean_cache  db  downloads  etc  javaprefs  keystores  log  restore-from-backup  tmp
```

* Grab the autogenerated password and login to Nexus with 'admin' and autogenerated password

* Follow Wizard, change admin password, accept license, enable Anonumus access

</details>
<details>
<summary><b>Validate and inspect</b></summary>

* Validate that Nexus is running under it's own user
```
root@ubuntu-s-4vcpu-8gb-tor1-01:/# docker ps
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                         NAMES
9ba08bd3c55d   sonatype/nexus3   "/opt/sonatype/nexus…"   45 minutes ago   Up 45 minutes   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp   nexus

root@ubuntu-s-4vcpu-8gb-tor1-01:/# docker exec -it 9ba08bd3c55d /bin/bash
bash-5.1$ whoami
nexus
bash-5.1$
```
* Check how an image is built

Go to Dockerhub->Nexus3 image->Tags Tab->lick on the latest image available. 
It is the image that was pulled.
https://hub.docker.com/layers/sonatype/nexus3/3.70.5-java17-alpine/images/sha256-116b6702bceeba64d00f156f8d1304952c0221bc4a9538d461957bb31b976a9f

Image Layers show you how the image is built.

* Check how volume is mounted inside of the container
```
bash-5.1$ pwd
/opt/sonatype
bash-5.1$ cd /
bash-5.1$ ls
afs  bin  boot  dev  etc  home  lib  lib64  media  mnt  nexus-data  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
bash-5.1$ ls nexus-data
blobs  clean_cache  db  downloads  etc  javaprefs  keystores  log  restore-from-backup  tmp
```
* Compare to the location on the host VM (outside of container)
```
root@ubuntu-s-4vcpu-8gb-tor1-01:/# ls /var/lib/docker/volumes/nexus-data/_data
blobs  clean_cache  db  downloads  etc  javaprefs  keystores  log  restore-from-backup  tmp
```
</details>

