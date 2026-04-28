# Module 9 - AWS Services
## Demo Project:
CD - Deploy Application from Jenkins Pipeline on EC2
Instance (automatically with docker-compose)
## Technologies used:
AWS, Jenkins, Docker, Linux, Git, Java, Maven, Docker Hub
## Project Description:
* Install Docker Compose on AWS EC2 Instance
* Create docker-compose.yml file that deploys our web
application image
* Configure Jenkins pipeline to deploy newly built image
using Docker Compose on EC2 server
* Improvement: Extract multiple Linux commands that
are executed on remote server into a separate shell
script and execute the script from Jenkinsfile


# Solution

## Repo:
https://gitlab.com/IrinaRoiter/java-maven-app/-/tree/jenkins-shared-library/
Branch: jenkins-shared-library 

<details>
<summary><b>Install Docker Compose on AWS EC2 Instance</b></summary>

* Install Docker Compose on AWS EC2 instance
```
[ec2-user@ip-172-31-31-18 ~]$ sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0   0     0   0     0     0     0  --:--:-- --:--:-- --:--:--     0
  0     0   0     0   0     0     0     0  --:--:-- --:--:-- --:--:--     0
100 31621k 100 31621k   0     0 27763k     0   0:00:01  0:00:01 --:--:--  4362k

[ec2-user@ip-172-31-31-18 ~]$ sudo chmod +x /usr/local/bin/docker-compose
[ec2-user@ip-172-31-31-18 ~]$ docker-compose --version
Docker Compose version v5.1.3
[ec2-user@ip-172-31-31-18 ~]$
```
</details>

<details>
<summary><b>Create docker-compose.yml file that deploys our web
application image  </b></summary>

docker-compose.yaml:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/06927df55679ce0df514b0cb6505f9c4298118db/docker-compose.yaml

</details>

<details>
<summary><b>Configure Jenkins pipeline to deploy newly built image using Docker Compose on EC2 serverb></b></summary>

Jenkinsfile:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/cdcc7627991f0dc1aff9d1ea2f8791e3ec6e88c7/Jenkinsfile


* Run a build
```
ℹ️ From Console output:
Started by user Admin
...
 > git checkout -f f140852202cec0599fe0c8fc00e556e4a6f52a14 # timeout=10
...
[Pipeline] sh
+ scp docker-compose.yaml ec2-user@35.183.44.148:/home/ec2-user
[Pipeline] sh
+ ssh -o StrictHostKeyChecking=no ec2-user@35.183.44.148 docker-compose -f docker-compose.yaml up -d
 Container java-maven-app Running 
 Container postgres-db Running 
...
[Pipeline] End of Pipeline
Finished: SUCCESS
```
* Validate on EC2 instance
```
[ec2-user@ip-172-31-31-18 ~]$ docker ps
CONTAINER ID   IMAGE                          COMMAND                  CREATED         STATUS         PORTS                                       NAMES
03108eb98c18   postgres:15                    "docker-entrypoint.s…"   7 minutes ago   Up 7 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-db
8323d2163809   irinaroiter/demo-app:jma-3.0   "/bin/sh -c 'java -j…"   7 minutes ago   Up 7 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   java-maven-app

👉🏻 postgres and irinaroiter/demo-app:jma-3.0 containers are running

[ec2-user@ip-172-31-31-18 ~]$ ls
docker-compose.yaml 👈🏻 docker-compose file copied by scp command 
[ec2-user@ip-172-31-31-18 ~]$
```
</details>

<details>
<summary><b>Improvement: Extract multiple Linux commands that
are executed on remote server into a separate shell
script and execute the script from Jenkinsfile</b></summary>

* Create a shell script file with commands to execute

Shell script:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/06927df55679ce0df514b0cb6505f9c4298118db/server-commands.sh


* Adjust Jenkinsfile:
 https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/06927df55679ce0df514b0cb6505f9c4298118db/Jenkinsfile


* Run a build
```
ℹ️ From Console output:
Deploying Docker image to EC2 instance with docker-compose...

Running command: bash ./server-commands.sh
...
[Pipeline] sh
+ scp server-commands.sh ec2-user@35.183.44.148:/home/ec2-user
[Pipeline] sh
+ scp docker-compose.yaml ec2-user@35.183.44.148:/home/ec2-user
[Pipeline] sh
+ ssh -o StrictHostKeyChecking=no ec2-user@35.183.44.148 bash ./server-commands.sh
 Container postgres-db Running 
 Container java-maven-app Running 
Success
...
[Pipeline] End of Pipeline
Finished: SUCCESS
```
</details>