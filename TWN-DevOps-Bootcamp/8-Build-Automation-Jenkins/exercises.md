# Module 8 - Build Automation & CI/CD with Jenkins
Your team members want to collaborate on your NodeJS application, where you list developers with their associated projects. So they ask you to set up a git repository for it.

Also, you think it's a good idea to add tests to the process, to test that no one accidentally breaks the existing code.

Moreover, you all decide every change should be immediately built and pushed to the Docker repository, so everyone can access it right away.

For that they ask you to set up a continuous integration pipeline.


## Repo:
https://gitlab.com/IrinaRoiter/jenkins-exercises
  

# Solution

<details>
<summary><b>EXERCISE 1: Dockerize your NodeJS App</b></summary>

* Configure your application to be built as a Docker image. 

Dockerfile: </br>
https://gitlab.com/IrinaRoiter/jenkins-exercises/-/blob/master/Dockerfile?ref_type=heads

* Test locally
```
PS C:\Repos\jenkins-exercises> docker build -t node-app:1.0.0 .
PS C:\Repos\jenkins-exercises> docker images

IMAGE                                 ID             DISK USAGE   CONTENT SIZE   EXTRA
amazoncorretto:17-alpine              9e6c3ad81171        452MB          153MB
debian:latest                         55a15a112b42        186MB         52.5MB
node-app:1.0.0                        2b5c50317034        446MB         96.9MB    U 
```
```
PS C:\Repos\jenkins-exercises> docker run -d `                    
>> --name node-app `
>> -p 3000:3000 `
>> node-app:1.0.0
c9aaa4f0e1f3de80fee42a80319e0932670e9dfcaa5ed57a735451d88dd20d19
```
```
PS C:\Repos\jenkins-exercises> docker ps
CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS         PORTS                                         NAMES
c9aaa4f0e1f3   node-app:1.0.0   "docker-entrypoint.s…"   7 minutes ago   Up 7 minutes   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   node-app
```

Connect http://localhost:3000/

* Commit Dockerfile to GitLab

https://gitlab.com/IrinaRoiter/jenkins-exercises/-/blob/master/Dockerfile?ref_type=heads

</details>
<details>
<summary><b>EXERCISE 2: Create a full pipeline for your NodeJS App</b></summary>

Steps to be included in your pipeline:

Increment version
The application's version and docker image version should be incremented.

Run tests
You want to test the code, to be sure to deploy only working code. When tests fail, the pipeline should abort.

Build docker image with incremented version
Push to Docker repository
Commit to Git
The application version increment must be committed and pushed to a remote Git repository.

* Create Jenkinsfile

https://gitlab.com/IrinaRoiter/jenkins-exercises/-/blob/b7ea1b78067f5bb170635c67acd3d4f0af45aabd/Jenkinsfile

* Create and configure a pipeline in Jenkins
```
Name: node-app-multibranch-type
Type: multibranch pipeline

Branch Sources:
Git: 
Project repository: https://gitlab.com/IrinaRoiter/jenkins-exercises.git
Credentials: select a GitLab credential from the list - 'pat-gitlab-read-write'

Behaviours->Add->choose 'Filer by name with reqular expressions'
Accept default regular expression '.*' - matches all the branches

Build strategies:
Select plugin: "Ignore committer strategy"
List of authors email to ignore: jenkins@example.com
Select "Allow builds when a changeset contains non-ignored author(s)"

Scan Multibranch Pipeline Triggers
Select 'Scan by webhook' - gitlab-token

Save
```
* Configure Webhook in GitLab to ensure continius integration
```
Connect to https://gitlab.com/IrinaRoiter/jenkins-exercises
Settings->Webhooks->Add webhook
Name: jenkins-webhook
URL: 
```
ℹ️ To construct an URL, go back to Jenkins
'node-app-multibranch-type' job->Configure
Scan Multibranch Pipeline Triggers-> select 'Scan by webhook'->Trigger token 'gitlab-token'
Find the url as shown on the picture:
![webhook-url](images/webhook-url.png)

```
URL template is JENKINS_URL/multibranch-webhook-trigger/invoke?token=[Trigger token]
My URL is
URL: http://165.227.47.177:8080//multibranch-webhook-trigger/invoke?token=gitlab-token

Trigger: select "Push events"
Add Webhook
```
👉🏻 Configuring a trigger in the pipeline and creating a Webhook in GitLab makes the pipeline run on push event except of the push from a pipeline itself => It implements continious integration requirement.
* Run pipeline 
![Green run](images/green-run.png)

* Inspect build log and verify that pipeline meets descrived requirements
```Jenkins
node-app-multibranch-type
master
#3

Running in /var/jenkins_home/workspace/node-app-multibranch-type_master/app
[Pipeline] {
[Pipeline] sh
+ npm version patch --no-git-tag-version
v1.0.1
[Pipeline] sh
+ node -p require('./package.json').version
[Pipeline] }
[Pipeline] // dir
[Pipeline] echo
Updated version: 1.0.1
...
+ echo ****
+ docker login -u irinaroiter --password-stdin
Login Succeeded
[Pipeline] sh
+ docker build -t irinaroiter/demo-app:node-1.0.1-3 .
...
[Pipeline] sh
+ docker push irinaroiter/demo-app:node-1.0.1-3
...
node-1.0.1-3: digest: sha256:2aea736b0c1818e09ddc91d7863006aeef7dd33eff24ad49649d9de6c1994738 size: 2624

[Pipeline] withCredentials
...
+ echo ****
+ docker login -u irina --password-stdin 165.22.230.88:8083
Login Succeeded

+ docker tag ****/demo-app:node-1.0.1-3 165.22.230.88:8083/node-app:1.0.1-3
[Pipeline] sh
+ docker push 165.22.230.88:8083/node-app:1.0.1-3
The push refers to repository [165.22.230.88:8083/node-app]
1.0.1-3: digest: sha256:e4f0c438a65127a77efda218905fd422cecb56c93b4dce43b3e2611db20da774 size: 2624
...
+ git config --global user.name jenkins
+ git config --global user.email jenkins@example.com
+ git status
HEAD detached at f514712
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   app/package-lock.json
	modified:   app/package.json

+ git remote set-url origin https://irinaroiter:****@gitlab.com/IrinaRoiter/jenkins-exercises.git
+ git add app/package.json
+ git commit -m Increment version to 1.0.1 [skip ci]
[detached HEAD b7ea1b7] Increment version to 1.0.1 [skip ci]
 1 file changed, 1 insertion(+), 1 deletion(-)
+ git push origin HEAD:master
To https://gitlab.com/IrinaRoiter/jenkins-exercises.git
   f514712..b7ea1b7  HEAD -> master
...
Finished: SUCCESS
Jenkins 2.541.3
```

* Verify incremented patch version is commited to GitLab

https://gitlab.com/IrinaRoiter/jenkins-exercises/-/blob/b7ea1b78067f5bb170635c67acd3d4f0af45aabd/app/package.json

* Verify that Docker image is uploaded to DockerHub with correct tag (incremented patch version and build number)

https://hub.docker.com/repository/docker/irinaroiter/demo-app/tags/node-1.0.1-3/sha256-2aea736b0c1818e09ddc91d7863006aeef7dd33eff24ad49649d9de6c1994738

* Verify that Docker image is uploaded to Nexus with correct tag (incremented patch version and build number)

![Node-app Docker image on Nexus](images/node-app-image-Nexus.png)

</details>

<details>
<summary><b>EXERCISE 3: Manually deploy new Docker Image on server</b></summary>

After the pipeline has run successfully, you:
Manually deploy the new docker image on the droplet server.

* Create a new Droplet on Digital Ocean
IP: 178.128.231.25
```
Digital Ocean-> Create -> Droplets
* Choose Region -> Toronto (closest to my location)
* Choose Image -> Ubuntu -> Version 24.04 (LTS)x64 
(LTS - long term support)
* Choose Droplet type, CPU options, size
* Choose Authentication Method - SSH key
* Create Droplet
* Rename it to 'node-app-remote-server'
* Add Droplet to Firewall
* Open open 3000 on Firewall
```
* Install docker engine on 'node-app-remote-server'
```
PS C:\repos\jenkins-exercises> ssh root@178.128.231.25
root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# apt update
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
170 packages can be upgraded. Run 'apt list --upgradable' to see them.

root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# apt install docker.io

root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# docker -v
Docker version 29.1.3, build 29.1.3-0ubuntu3~24.04.1
root@ubuntu-s-1vcpu-512mb-10gb-tor1:~#
```
* Allow insecure connections to Nexus and restart Docker Engine
```
root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# vim /etc/docker/daemon.json

Add the following lines:
{
  "insecure-registries" : ["165.22.230.88:8083"]
}
Save and exit

Restart  Docker Engine
root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# sudo systemctl restart docker

```
* Start an app

```
root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# docker run -d --name node-app -p 3000:3000 165.22.230.88:8083/node-app:1.0.1-3
Unable to find image '165.22.230.88:8083/node-app:1.0.1-3' locally
1.0.1-3: Pulling from node-app
...
Digest: sha256:e4f0c438a65127a77efda218905fd422cecb56c93b4dce43b3e2611db20da774
Status: Downloaded newer image for 165.22.230.88:8083/node-app:1.0.1-3
cc0c73f7a90ff5c1e254d04bc15c3164105c728928d72651d835fe4e1a37921a

root@ubuntu-s-1vcpu-512mb-10gb-tor1:~# docker ps
CONTAINER ID   IMAGE                                 COMMAND                  CREATED          STATUS          PORTS                                         NAMES
cc0c73f7a90f   165.22.230.88:8083/node-app:1.0.1-3   "docker-entrypoint.s…"   11 seconds ago   Up 11 seconds   0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp   node-app
root@ubuntu-s-1vcpu-512mb-10gb-tor1:~#
```
* Verify the app 

Connect to 

![Node-app-remote-server](images/Node-app-remote-server.png)
</details>
<details>
<summary><b>EXERCISE 4: Extract into Jenkins Shared Library</b></summary>

A colleague from another project tells you that they are building a similar Jenkins pipeline and they could use some of your logic. So you suggest creating a Jenkins Shared Library to make your Jenkinsfile code reusable and shareable.

Therefore, you do the following:
Extract all logic into Jenkins-shared-library with parameters and reference it in Jenkinsfile.

* Extract build / push Docker image, commit to Git logic

Jenkinsfile:

https://gitlab.com/IrinaRoiter/jenkins-exercises/-/blob/a3faefd3689ca132402ba3f92ffe17a13350a311/Jenkinsfile

Docker.groovy:

https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/f140852202cec0599fe0c8fc00e556e4a6f52a14/src/com/example/Docker.groovy

commitToGit.groovy:

https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/f140852202cec0599fe0c8fc00e556e4a6f52a14/vars/commitToGit.groovy

dockerLogin.groovy:

https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/f140852202cec0599fe0c8fc00e556e4a6f52a14/vars/dockerLogin.groovy

dockerPush.groovy:

https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/f140852202cec0599fe0c8fc00e556e4a6f52a14/vars/dockerPush.groovy

buildDockerImage.groovy:

https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/f140852202cec0599fe0c8fc00e556e4a6f52a14/vars/buildDockerImage.groovy

tagDockerImage.groovy:

https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/f140852202cec0599fe0c8fc00e556e4a6f52a14/vars/tagDockerImage.groovy

* Verify in build run

![Successfull run](images/extracted-logic-to-shared-library.png)

```
From build log:

Jenkins
node-app-multibranch-type
master
#16

 > git checkout -f 48183ba65d20a5b459539fa06a5b908b831277d9 # timeout=10
Commit message: "Passed appVersion as param"

Fetching upstream changes from https://gitlab.com/IrinaRoiter/jenkins-exercises.git

+ npm version patch --no-git-tag-version
v1.0.3

+ npm ci


Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total

+ docker build -t irinaroiter/demo-app:node-1.0.3-16 .

+ docker login -u irinaroiter --password-stdin
Login Succeeded

+ docker push irinaroiter/demo-app:node-1.0.3-16

node-1.0.3-16: digest: sha256:cd999230a3bbbfd38c9282369ae230cfff4f09338ab46a76b2b0fe9fc33a878f size: 2624
[Pipeline] echo
Tagging the docker image as 165.22.230.88:8083/node-app:1.0.3-16
[Pipeline] sh
+ docker tag irinaroiter/demo-app:node-1.0.3-16 165.22.230.88:8083/node-app:1.0.3-16

Logging into registry: 165.22.230.88:8083

+ echo ****
+ docker login -u irina --password-stdin 165.22.230.88:8083

+ docker push 165.22.230.88:8083/node-app:1.0.3-16
The push refers to repository [165.22.230.88:8083/node-app]

1.0.3-16: digest: sha256:e89c1695e49f219811c49249b8575e0d3ce41e4145f15f560f07b8b8725edfa5 size: 2624

+ git config --global user.name jenkins
+ git config --global user.email jenkins@example.com
+ git status
...
+ git remote set-url origin https://irinaroiter:****@gitlab.com/IrinaRoiter/jenkins-exercises.git
+ git add app/package.json
+ git commit -m Increment version to 1.0.3 [skip ci]
[detached HEAD a3faefd] Increment version to 1.0.3 [skip ci]
 1 file changed, 1 insertion(+), 1 deletion(-)
+ git push origin HEAD:master
...
[Pipeline] End of Pipeline
Finished: SUCCESS
Jenkins 2.541.3
```
</details>