# Module 8 - Containers with Docker
## Demo Project:
Create a CI Pipeline with Jenkinsfile (Freestyle, Pipeline, Multibranch
Pipeline)
## Technologies used:
Jenkins, Docker, Linux, Git, Java, Maven
## Project Description:
### CI Pipeline for a Java Maven application to build and push to the repository
* Install Build Tools (Maven, Node) in Jenkins
* Make Docker available on Jenkins server
* Create Jenkins credentials for a git repository
* Create different Jenkins job types (Freestyle, Pipeline, Multibranch
pipeline) for the Java Maven project with Jenkinsfile to:

    * Connect to the application’s git repository
    * Build Jar
    * Build Docker Image
    * Push to private DockerHub repository

# Solution

<details>
<summary><b>Install Build Tools - Maven in Jenkins</b></summary>

* Install Maven tools
```
After Jenkins has been initialized, Jenins offers installing either default tools, or customized the list. I installed default tools
```
* Configure tools
```
Manage Jenkins->Tools->Maven installations->Add Maven->select latest available version->Save
The version is 3.9.14
```
</details>
<details>
<summary><b>Install Build Tools - NodeJS and NPM in Jenkins</b></summary>

👉NodeJS and NPM does not appear under 'Tools' section => I will install it directly in Jenkins Docker container. </br>
👉I must login as root to the container to have admin priviladges to install tools


* Login into the container as ROOT user

```
root@ubuntu-s-2vcpu-4gb-tor1-01:~# docker ps
CONTAINER ID   IMAGE                 COMMAND                  CREATED       STATUS       PORTS                                                                                          NAMES
9da29d19fb28   jenkins/jenkins:lts   "/usr/bin/tini -- /u…"   2 hours ago   Up 2 hours   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp, 0.0.0.0:50000->50000/tcp, [::]:50000->50000/tcp   hungry_wright

root@ubuntu-s-2vcpu-4gb-tor1-01:~# docker exec -it -u 0 9da29d19fb28 bash
root@9da29d19fb28:/#
```
* Check Linux distro inside of the container
```
root@9da29d19fb28:/# cat /etc/issue
Debian GNU/Linux 13 \n \l
```
```
root@9da29d19fb28:/# apt update
...
Fetched 10.0 MB in 2s (6026 kB/s)
10 packages can be upgraded. Run 'apt list --upgradable' to see them.
root@9da29d19fb28:/#
```
* Find a NodeJS for Debian distro and download it
```
root@9da29d19fb28:/# curl -sL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
root@9da29d19fb28:/# ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  nodesource_setup.sh  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```
* Execute the script
```
root@9da29d19fb28:/# bash nodesource_setup.sh
2026-04-06 18:20:49 - Installing pre-requisites
....
```
* Install NodeJS and npm
```
root@9da29d19fb28:/# apt install nodejs
Installing:
  nodejs
....

root@9da29d19fb28:/# node -v
v20.20.2

root@9da29d19fb28:/# npm -v
10.8.2

```
</details>
<details>
<summary><b>Install Stage View Plugin in Jenkins</b></summary>

* Find a Stage View Plugin under Avaialble Plugins
```
Manage Jenkins->Plugins->Available Plugins->search for Stage View->select->install with restart.
```
* Start Jenkins container manually
```
root@9da29d19fb28:/# root@ubuntu-s-2vcpu-4gb-tor1-01:~# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

root@ubuntu-s-2vcpu-4gb-tor1-01:~# docker ps -a
CONTAINER ID   IMAGE                 COMMAND                  CREATED       STATUS                          PORTS     NAMES
9da29d19fb28   jenkins/jenkins:lts   "/usr/bin/tini -- /u…"   3 hours ago   Exited (5) About a minute ago             hungry_wright

root@ubuntu-s-2vcpu-4gb-tor1-01:~# docker start 9da29d19fb28
9da29d19fb28
```
* Verify from UI that Stage view Plugin is installed

![Stage View](images/stage-view-plugin-installed.png)
</details>


<details>
<summary><b>Create a freestyle job</b></summary>

* Create new job
```
New job:
name: irina-job
type: freestyle
Save
```
* Add step - 'Execute shell'
```
npm -version
```
* Add step - 'Invoke top-level Maven targets'
```
Maven version: maven-3.9
Goals: --version
Save
```
* Run a build
* Inspect build results - Click on #1 -> Console Output
```
Started by user Admin
Running as SYSTEM
Building in workspace /var/jenkins_home/workspace/irina-job
[irina-job] $ /bin/sh -xe /tmp/jenkins17554465995757960896.sh
+ npm -version
10.8.2
Unpacking https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.14/apache-maven-3.9.14-bin.zip to /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven-3.9 on Jenkins
[irina-job] $ /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven-3.9/bin/mvn --version
Apache Maven 3.9.14 (996c630dbc656c76214ce58821dcc58be960875b)
Maven home: /var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/maven-3.9
Java version: 21.0.9, vendor: Eclipse Adoptium, runtime: /opt/java/openjdk
Default locale: en, platform encoding: UTF-8
OS name: "linux", version: "6.8.0-71-generic", arch: "amd64", family: "unix"
Finished: SUCCESS
```
</details>

<details>
<summary><b>Source Control</b></summary>

https://gitlab.com/IrinaRoiter/java-maven-app.git

</details>