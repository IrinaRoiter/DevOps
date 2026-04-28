# Module 9 - AWS Services
## Demo Project:
CD - Deploy Application from Jenkins Pipeline to EC2 Instance
(automatically with docker)
## Technologies used:
AWS, Jenkins, Docker, Linux, Git, Java, Maven, Docker Hub
## Project Description:
* Prepare AWS EC2 Instance for deployment (Install Docker)
* Create ssh key credentials for EC2 server on Jenkins
* Extend the previous CI pipeline with deploy step to ssh into the
remote EC2 instance and deploy newly built image from Jenkins
server
* Configure security group on EC2 Instance to allow access to our
web application


# Solution

## Repo:
https://gitlab.com/IrinaRoiter/react-nodejs-example

<details>
<summary><b>Prepare AWS EC2 Instance for deployment (Install Docker)</b></summary>

ℹ️ See 'Install Docker on remote EC2 Instance' section under
https://github.com/IrinaRoiter/DevOps/blob/7355fad1b788eedfd1aaea7d6f7600c8ff3c305d/TWN-DevOps-Bootcamp/9-AWS%20Services/project-deploy-web-app-aws.md

</details>

<details>
<summary><b>Create a Jenkins multibranch pipeline</b></summary>

* Install 'ssh agent' plugin on Jenkins
```
Jenkins Manage->Plugins->Available plugings->Search for 'ssh agent' plugin, slect and install
```
* Create a new multibranch pipeline in Jenkins
```
Name: aws-multibranch-pip

Git repo: https://gitlab.com/IrinaRoiter/react-nodejs-example.git
Credentials: pat-gitlab

Behaviours->Add->choose 'Filer by name with reqular expressions'
Accept default regular expression '.*' - matches all the branches
```
</details>

<details>
<summary><b>Create ssh key credentials for EC2 server on Jenkins</b></summary>

* Add credentials to AWS scoped to a pipeline only
```
Kind: ssh username with private key
ID: ec2-server-key
Private Key: enter directly
Extract the content of "C:\Users\user\.ssh\irina-vms.pem" file, copy and paste it in the provided area. Make sure to copy/paste everything including:
-----BEGIN OPENSSH PRIVATE KEY-----
-----END OPENSSH PRIVATE KEY-----
```

</details>
<details>
<summary><b>Extend the previous CI pipeline with deploy step to ssh into the
remote EC2 instance and deploy newly built image from Jenkins
server</b></summary>

* Get 'sample syntax' for ssh agent plugin
```
Select 'aws-multibranch-pip'->left menu->"Pipeline syntax"->Steps->Sample step->
choose 'sshagent' from a drop down menu
Credentials: 'ec2-server-key'
click on "Generate pipeline script"
```
* Integrate it in Jenkinsfile

Jenkinsfile: </br>
https://gitlab.com/IrinaRoiter/react-nodejs-example/-/blob/b24fb74fd5e1d743b13eabe8b710c8d104f5b28a/Jenkinsfile

* Open ssh on port 22 for Jenkins server to connect to ec2 server
```
EC2
Security Groups
sg-0fcb92eef1920f473 - security-group-irina-vms
Add rule
Type: ssh
Protocol: TCP
Port: 22
Source: 159.203.26.80/32 (Jenkins public IPv4)
```

* Run a build
```
ℹ️ From Console output:

Jenkins
aws-multibranch-pip
master
#5
...
Running command: docker run -d -p 3080:3080 --name react-node irinaroiter/demo-app:react-node-1.0
[Pipeline] sshagent
[ssh-agent] Using credentials ec2-user (ec2-server-key)
$ ssh-agent
SSH_AUTH_SOCK=/tmp/ssh-hJvmx9bQfvR1/agent.7200
SSH_AGENT_PID=7203
...
Digest: sha256:a92af9d11cfcc058f6d42c790102eb53dd89c10cf1804962b9c69ff2b3e2263d
Status: Downloaded newer image for irinaroiter/demo-app:react-node-1.0
734fffa84c0bbcc201c46a93424e6974e0317ad1372fd65cd899f7cbd3464cff
[Pipeline] }
$ ssh-agent -k
unset SSH_AUTH_SOCK;
unset SSH_AGENT_PID;
echo Agent pid 7203 killed;
...
[Pipeline] End of Pipeline
Finished: SUCCESS
Jenkins 2.555.1
```
* Check on ec2 server
```
[ec2-user@ip-172-31-31-18 ~]$ docker images
REPOSITORY             TAG              IMAGE ID       CREATED        SIZE
irinaroiter/demo-app   react-node-1.0   f957f45edac3   24 hours ago   1.13GB

[ec2-user@ip-172-31-31-18 ~]$ docker ps
CONTAINER ID   IMAGE                                 COMMAND                  CREATED          STATUS          PORTS                                       NAMES
734fffa84c0b   irinaroiter/demo-app:react-node-1.0   "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes   0.0.0.0:3080->3080/tcp, :::3080->3080/tcp   react-node
```
</details>
<details>
<summary><b>Configure security group on EC2 Instance to allow access to our
web application</b></summary>

* Open port 3080 for Jenkins server to connect to ec2 server
```
EC2
Security Groups
sg-0fcb92eef1920f473 - security-group-irina-vms
Add rule
Type: Custom TCP
Protocol: TCP
Port: 3080
Source: 108.162.140.99/32 (my computer's public IPv4)
```

* Access the application
Connect: http://35.183.44.148:3080/

![Reach Node app running on AWS after automatic deployment with Jenkins](images/react-node-app-aws-jenkins.png)

</details>

## Repo:
https://gitlab.com/IrinaRoiter/java-maven-app/-/tree/jenkins-shared-library
Branch: jenkins-shared-library

<details>
<summary><b>Automate end-to-end: build an image, push it to DockerHub, deploy on EC2 instance with jenkins pip</b></summary>

* Create a new multibranch pipeline for 'java-maven-app' repo. 
```
Name: aws-multibranch-java-maven-pip
```
* Add credentials to AWS scoped to a pipeline only
```
Kind: ssh username with private key
ID: ec2-server-key
Private Key: enter directly
Extract the content of "C:\Users\user\.ssh\irina-vms.pem" file, copy and paste it in the provided area. Make sure to copy/paste everything including:
-----BEGIN OPENSSH PRIVATE KEY-----
-----END OPENSSH PRIVATE KEY-----
```
* Integrate deployment to EC2 in Jenkinsfile

Jenkinsfile:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/cfc7f4bc0f1b04065d4f5dc8d696df1408e6984e/Jenkinsfile

* Run a build 
```
ℹ️ From Console output:
+ docker build -t irinaroiter/demo-app:jma-3.0 .
#0 building with "default" instance using docker driver


Logging into registry - DockerHub
+ docker login -u irinaroiter --password-stdin
+ echo ****
Login Succeeded
...
+ docker push irinaroiter/demo-app:jma-3.0

jma-3.0: digest: sha256:19ea3d33f77b689e9d39448e8c386a80e0efeaaecfdb3c48f3269147331105cf size: 856
...
Deploying Docker image to EC2 instance...
[Pipeline] echo
Running command: docker run -d -p 8080:8080 --name java-maven irinaroiter/demo-app:jma-3.0
[Pipeline] sshagent
[ssh-agent] Using credentials ec2-user (ec2-server-key)
$ ssh-agent
...
Digest: sha256:19ea3d33f77b689e9d39448e8c386a80e0efeaaecfdb3c48f3269147331105cf
...
[Pipeline] End of Pipeline
Finished: SUCCESS
```
* Validate deployment on EC2 instance
```
[ec2-user@ip-172-31-31-18 ~]$ docker images
REPOSITORY             TAG              IMAGE ID       CREATED          SIZE
irinaroiter/demo-app   jma-3.0          bc474643b0bf   22 minutes ago   321MB
irinaroiter/demo-app   react-node-1.0   f957f45edac3   33 hours ago     1.13GB
[ec2-user@ip-172-31-31-18 ~]$
👉🏻 2 images are deployed now.


[ec2-user@ip-172-31-31-18 ~]$ docker ps
CONTAINER ID   IMAGE                                 COMMAND                  CREATED          STATUS          PORTS                                       NAMES
e171205438d3   irinaroiter/demo-app:jma-3.0          "/bin/sh -c 'java -j…"   20 minutes ago   Up 20 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   java-maven
734fffa84c0b   irinaroiter/demo-app:react-node-1.0   "docker-entrypoint.s…"   8 hours ago      Up 8 hours      0.0.0.0:3080->3080/tcp, :::3080->3080/tcp   react-node
```
👉🏻 2 applications are running in containers.

</details>
