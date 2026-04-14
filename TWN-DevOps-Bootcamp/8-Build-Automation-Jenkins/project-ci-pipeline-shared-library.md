# Module 8 - Containers with Docker
## Demo Project:
Create a Jenkins Shared Library (JSL)
## Technologies used:
Jenkins, Groovy, Docker, Git, Java, Maven
## Project Description:
Create a Jenkins Shared Library to extract common build logic:
* Create separate Git repository for Jenkins Shared
Library project
* Create functions in the JSL to use in the Jenkins pipeline
Integrate and use the JSL in Jenkins Pipeline (globally and
for a specific project in Jenkinsfile)

## Repo:
https://gitlab.com/IrinaRoiter/java-maven-app/-/tree/jenkins-shared-library
  

# Solution

<details>
<summary><b>Create separate Git repository for Jenkins Shared Library project</b></summary>

* Create a groovy project locally and add 2 initials scripts: buildJar.groovy and buildImage.groovy under 'vars' directory

* Follow procedure [Add project to GIT on GitLab](../5-Cloud-Iaas/module-5-project.md) 

[Initial commit](https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/tree/7a1cef18bb4c047a83efebe6f2ce871a8ece49b0/)

</details>
<details>
<summary><b>Define JSL globally in jenkins and use it in Jenkins Pipeline</b></summary>

*  Add Shared Library in Jenkins globally
```
Manage Jenkins->System->Add untrusted pipeline libraries
Version: master
Set 'Allow version to be overwritten' to true
Save
```
* Import JSL into a pipeline

```
Add this in Jenkinsfile
@Library('jenkins-shared-library')

Remove buildJar and buildImage functions from script.groovy since we moved logic to jenkins-shared-library
Replace buildJar and buildImage functions

Jenkinsfile:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/91f82abd33b04f50b66da123ded0a6655584b450/Jenkinsfile
```
* Build a pipeline and validate results
```
From the log of the jenkins build:
...
Obtained Jenkinsfile from 91f82abd33b04f50b66da123ded0a6655584b450
...

+ docker push irinaroiter/demo-app:jma-3.0
The push refers to repository [docker.io/irinaroiter/demo-app]
...
jma-3.0: digest: sha256:41a6e43ee63543b4144ec22c78d130a8c76aed1c80686f7efb197eec71473ec5 size: 1159
Finished: SUCCESS
```
```
Check demo-app:jma-3.0 on DockerHub:
https://hub.docker.com/repository/docker/irinaroiter/demo-app/tags/jma-3.0/sha256-41a6e43ee63543b4144ec22c78d130a8c76aed1c80686f7efb197eec71473ec5
```
* Split commands in BuildImage functions into separate functions
```
Jenkinsfile:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/3399c3e916b8e00ceb99b1a02603fbcab904f060/Jenkinsfile

Docker.groovy
https://gitlab.com/twn-devops-bootcamp/latest/08-jenkins/jenkins-shared-library/-/blob/1551012961b229a26e98f2e2aa06603f07aedbae/src/com/example/Docker.groovy

BuildDockerImage.groovy:
https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/b456a1a1ca73369f471ac3453ead35823a43a614/vars/buildDockerImage.groovy

buildJar.groovy:
https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/b456a1a1ca73369f471ac3453ead35823a43a614/vars/buildJar.groovy

dockerLogin.groovy:
https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/b456a1a1ca73369f471ac3453ead35823a43a614/vars/dockerLogin.groovy

dockerPush.groovy:
https://gitlab.com/IrinaRoiter/jenkins-shared-library/-/blob/b456a1a1ca73369f471ac3453ead35823a43a614/vars/dockerPush.groovy
```
</details>

<details>
<summary><b>Use JSL directly in Jenkins Pipeline without defining it globaly</b></summary>

* Reference JSL directly in Jenkinsfile
```
Replace the line:
@Library('jenkins-shared-library') 
with

https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/jenkins-shared-library/Jenkinsfile?ref_type=heads#L3:~:text=library%20identifier%3A,%5D)

Finale Jenkinsfile:
https://gitlab.com/IrinaRoiter/java-maven-app/-/blob/e7eb342e926aa4946936829a3f9e627238ce5996/Jenkinsfile

```
* Build to validate it
```
From Build log:
...
Obtained Jenkinsfile from e7eb342e926aa4946936829a3f9e627238ce5996
...
+ docker push irinaroiter/demo-app:jma-3.0
The push refers to repository [docker.io/irinaroiter/demo-app]
...
jma-3.0: digest: sha256:41a6e43ee63543b4144ec22c78d130a8c76aed1c80686f7efb197eec71473ec5 size: 1159
Deploying the application...
Finished: SUCCESS
```
</details>