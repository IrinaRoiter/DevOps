# Module 7 - Containers with Docker
## Demo Project:
Deploy Docker application on a server with Docker Compose
## Technologies used:
Docker, Digital Ocean, NodeJS, MogoDB, Mongo Express
## Project Description:
* Copy Docker-compose file to a remote server
* Login to a private remote regisrty on a remote server to fetch an app image
* Start the application container with Mongo DB and Mongo Express services using docker-compose

## Repo:
https://gitlab.com/IrinaRoiter/js-app

# Solution

<details>
<summary><b>Add my Node JS app as a new service to docker-compose file</b></summary>

* Add my Node JS app as a new service to docker-compose file
```
-----------------
services:
   irina-node-app:
     image: 165.22.230.88:8083/irina-app:1.1
     ports:
      - 3000:3000
-------------------
Note: 165.22.230.88:8083 - registry domain
The image is located in my private Nexus docker-hosted repo
```
* Replace local connection with docker compose connection in server.js
```
-----------
// use when starting application as docker container, part of docker-compose
let mongoUrlDockerCompose = "mongodb://admin:password@mongodb";
------------
Note: mongoDB is service name from docker-compose file
No need to specify the port any more because it is specified in docker-compose file
```
</details>
<details>
<summary><b>Rebuild and push a new image to docker-hosted repo on Nexus</b></summary>

* Remove current image
```
PS C:\repos\js-app> docker images irina

IMAGE                              ID             DISK USAGE   CONTENT SIZE   EXTRA
165.22.230.88:8083/irina-app:1.0   d5d8be540626        250MB         59.6MB
irina-app:1.0                      d5d8be540626        250MB         59.6MB

PS C:\repos\js-app> docker rmi -f d5d8be540626
Untagged: 165.22.230.88:8083/irina-app:1.0
Untagged: irina-app:1.0
Deleted: sha256:d5d8be540626e6ddf608122b604f314b1f19c64e22e9a815f2d5ae600f594596
```
* Build a new image and push it to docker-hosted repo in Nexus
```
PS C:\repos\js-app> docker build -t 165.22.230.88:8083/irina-app:1.1 .
[+] Building 15.7s (11/11) FINISHED
.....

PS C:\repos\js-app> docker push 165.22.230.88:8083/irina-app:1.1
The push refers to repository [165.22.230.88:8083/irina-app]
7ade58ffe11b: Pushed
d7f6aca05b78: Pushed
4f4fb700ef54: Layer already exists
62e0e1181d88: Pushed
445ec8d0ac15: Pushed
c7734204880f: Pushed
c401b6671801: Pushed
faf7d2341eb2: Pushed
589002ba0eae: Layer already exists
1.0: digest: sha256:3b24fe801fec3faea1aaf2e2b0112d5b3c00327ede9bf65f74041c165f67dab4 size: 856

```
</details>

<details>
<summary><b>Copy Docker-compose file to a remote server</b></summary>

* Copy Docker-compose file to a remote server
```
PS C:\repos\js-app> scp docker-compose.yaml root@143.110.208.108:/root
docker-compose.yaml                                                 100%  714    26.8KB/s   00:00

```


</details>

<details>
<summary><b>Login to a private remote regisrty on a remote server to fetch an app image</b></summary>

Note: Remote server is another VM on Digital Ocean with IP - 143.110.208.108

* Login to a remote server

```
PS C:\repos\js-app> ssh root@143.110.208.108
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-101-generic x86_64)
...
root@ubuntu-s-1vcpu-1gb-tor1-01:~#
```

* Install Docker Engine 

```
root@ubuntu-s-1vcpu-1gb-tor1-01:~# apt  update
root@ubuntu-s-1vcpu-1gb-tor1-01:~# apt  install docker.io
```

* Allow insecure connections to Nexus and restart Docker Engine
```
root@ubuntu-s-1vcpu-1gb-tor1-01:~# vim /etc/docker/daemon.json

Add the following lines:
{
  "insecure-registries" : ["165.22.230.88:8083"]
}
Save and exit

Restart  Docker Engine
root@ubuntu-s-1vcpu-1gb-tor1-01:~# sudo systemctl restart docker

```
* Install Docker Compose

```
root@ubuntu-s-1vcpu-1gb-tor1-01:~# apt  install docker-compose  # version 1.29.2-6
Reading package lists... Done
Building dependency tree... Done
```
* Login from Docker to Nexus 

```
root@ubuntu-s-1vcpu-1gb-tor1-01:~# docker login 165.22.230.88:8083
Username: irina
Password:

...

Login Succeeded
root@ubuntu-s-1vcpu-1gb-tor1-01:~#
```
</details>

<details>
<summary><b>Start the application container with Mongo DB and Mongo Express services using docker-compose</b></summary>

* Start the application
```
root@ubuntu-s-1vcpu-1gb-tor1-01:~# docker-compose -f docker-compose.yaml up
Creating root_mongodb_1        ... done
Creating root_irina-node-app_1 ... done
Creating root_mongo-express_1  ... done
Attaching to root_irina-node-app_1, root_mongodb_1, root_mongo-express_1
...

root@ubuntu-s-1vcpu-1gb-tor1-01:~# docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED         STATUS         PORTS                                             NAMES
65c4eebd8375   mongo-express                      "/sbin/tini -- /dock…"   3 minutes ago   Up 3 minutes   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp       root_mongo-express_1
2f811c967b37   165.22.230.88:8083/irina-app:1.0   "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp       root_irina-node-app_1
240a335b6a70   mongo                              "docker-entrypoint.s…"   3 minutes ago   Up 3 minutes   0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp   root_mongodb_1

```
* Connect to Mongo-Express and create a database and collection

URL - http://143.110.208.108:8081/

* Connect to NodeJS app, update profile, validate data persistence

URL: http://143.110.208.108:3000

![verification](images/docker-compose-remote-server.png)


</details>

