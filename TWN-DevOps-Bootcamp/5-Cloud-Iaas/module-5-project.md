# Module 5 - Cloud and IaS Basics
## Demo Project:
Create server and deploy application on DigitalOcean
## Technologies used:
DigitalOcean, Linux, Java, Gradle
## Project Description:
* Setup and configure a server on DigitalOcean
* Create and configure a new Linux user on the Droplet
(Security best practice)
* Deploy and run a Java Gradle application on Droplet


# Solution

<details>
<summary><b>Setup and configure a server on DigitalOcean</b></summary>

* Create SSH key on Digital Ocean
```
Settings -> Security ->Add SSH Key
```
* Create Firewall
```
ℹ️ My public IP address: https://whatismyipaddress.com/

Networking -> Firewalls -> Create Firewall
```
* Open only port 22 to outside connections
```
Inboubd rules -> New rule -> Type: SSH -> Port 22 is selected automatically -> Sources -> my public IP only  -> Save
```
* Create Ubuntu VM
```
* Create -> Droplets
* Choose Region -> Toronto (closest to my location)
* Choose Image -> Ubuntu -> Version 24.04 (LTS)x64 
(LTS - long term support)
* Choose Droplet type, CPU options, size
* Choose Authentication Method - SSH key
* Create Droplet
* Add Droplet to Firewall
```
</details>

<details>
<summary><b>Create and configure a new Linux user on the Droplet</b></summary>

* connect to Ubuntu VM
```
iroiter@irina-ubuntu:~/repos/java-react-example$ ssh root@138.197.152.215
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-101-generic x86_64)
```
* create service account and add it to sudo group
```
root@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~# adduser service
info: Adding user `service' ...
info: Selecting UID/GID from range 1000 to 59999 ...
info: Adding new group `service' (1001) ...

root@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~# usermod -aG sudo service
root@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~# 
```
* allow ssh connection with service account
```
Get the public key of my personal computer
iroiter@irina-ubuntu:~$ cat ~/.ssh/id_rsa.pub

root@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~# su - service
To run a command as administrator (user "root"), use "sudo <command>".

service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ mkdir .ssh

service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ vim ~/.ssh/authorized_keys
Insert public key of my personal computer, Save, Exit

service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ exit
logout
root@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~# exit
logout
Connection to 138.197.152.215 closed.

iroiter@irina-ubuntu:~/repos/java-react-example$ ssh service@138.197.152.215
Welcome to Ubuntu 24.04.3 LTS (GNU/Linux 6.8.0-101-generic x86_64)
service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$
```
</details>

<details>
<summary><b>Deploy and run a Java Gradle application on Droplet</b></summary>

* create a directory for an application
```
service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ sudo mkdir /opt/java-app
[sudo] password for service:

service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ sudo chown service:service /opt/java-app
service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ ls -l /opt
total 12
drwxr-xr-x 4 root    root    4096 Mar  5 21:37 digitalocean
drwxr-xr-x 2 service service 4096 Mar 11 22:04 java-app
drwxr-xr-x 3 root    root    4096 Mar  5 22:19 my-app

```
* deploy application to Droplet
```
iroiter@irina-ubuntu:~/repos/java-react-example/build/libs$ scp java-react-example.jar service@138.197.152.215:/opt/java-app
java-react-example.jar                                                                            100%   20MB   3.1MB/s   00:06     
```
* install java 
```
service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ java
Command 'java' not found, but can be installed with:
sudo apt install default-jre              # version 2:1.17-75, or
sudo apt install openjdk-17-jre-headless  # version 17.0.18+8-1~24.04.1
sudo apt install openjdk-21-jre-headless  # version 21.0.10+7-1~24.04
sudo apt install openjdk-11-jre-headless  # version 11.0.30+7-1ubuntu1~24.04

service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ sudo apt update
Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:2 http://mirrors.digitalocean.com/ubuntu noble InRelease               

service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:~$ sudo apt install openjdk-17-jre-headless
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done

```
* Start the application in background mode 
```
service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:/opt/java-app$ java -jar java-react-example.jar &
[1] 6783
service@ubuntu-s-1vcpu-512mb-10gb-tor1-01:/opt/java-app$ 
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/

 :: Spring Boot ::                (v3.5.5)
 2026-03-11T22:32:01.505Z  INFO 6783 --- [           main] com.coditorium.sandbox.Application       : Starting Application using Java 17.0.18 with PID 6783 (/opt/java-app/java-react-example.jar started by service in /opt/java-app)
2026-03-11T22:32:01.516Z  INFO 6783 --- [           main] com.coditorium.sandbox.Application       : No active profile set, falling back to 1 default profile: "default"
2026-03-11T22:32:01.738Z  INFO 6783 --- [           main] .e.DevToolsPropertyDefaultsPostProcessor : For additional web related logging consider setting the 'logging.level.web' property to 'DEBUG'
2026-03-11T22:32:05.894Z  INFO 6783 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port 7071 (http)
2026-03-11T22:32:05.963Z  INFO 6783 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2026-03-11T22:32:05.967Z  INFO 6783 --- [           main] o.apache.catalina.core.StandardEngine    : Starting Servlet engine: [Apache Tomcat/10.1.44]
2026-03-11T22:32:06.452Z  INFO 6783 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2026-03-11T22:32:06.456Z  INFO 6783 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 4713 ms
2026-03-11T22:32:07.601Z  INFO 6783 --- [           main] o.s.b.a.w.s.WelcomePageHandlerMapping    : Adding welcome page: class path resource [static/index.html]
2026-03-11T22:32:08.513Z  INFO 6783 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port 7071 (http) with context path '/'
2026-03-11T22:32:08.586Z  INFO 6783 --- [           main] com.coditorium.sandbox.Application       : Started Application in 9.236 seconds (process running for 11.303)
```
* The application is running on port 7071. Open port 7071 to outside connections in Digital Ocean
```
Networking -> Firewalls -> Inboubd rules -> New rule -> Type: Custom -> Port 7071 -> Save
```
* Connect to Java app from a browser
http://138.197.152.215:7071/ 
</details>

<details>
<summary><b>Add project to GIT on GitLab</b></summary>

* add SSH public key to my GitLab account to establish connection
```
Profile -> Preferences -> Access -> SSH key -> Add new key 
```
* Check connection to GitLab using ssh protocol: 
```
iroiter@irina-ubuntu:~/repos/java-react-example$ ssh -T git@gitlab.com
Welcome to GitLab, @IrinaRoiter!
```
* Convert local Java project to GIT project and make it available on GitLab
```
iroiter@irina-ubuntu:~/repos/java-react-example$ git init
Initialized empty Git repository in /home/iroiter/repos/java-react-example/.git/
iroiter@irina-ubuntu:~/repos/java-react-example$ git add .
iroiter@irina-ubuntu:~/repos/java-react-example$ git commit -m "Initial commit"
[master (root-commit) 6c102a3] Initial commit
 21 files changed, 461 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 build.gradle
 create mode 100644 readme.md
 create mode 100644 src/main/java/com/coditorium/sandbox/Application.java
.......
iroiter@irina-ubuntu:~/repos/java-react-example$ git remote add origin  git@gitlab.com:IrinaRoiter/java-react-example.git 
iroiter@irina-ubuntu:~/repos/java-react-example$ git push -u origin master
Enumerating objects: 40, done.
Counting objects: 100% (40/40), done.
Delta compression using up to 2 threads
Compressing objects: 100% (32/32), done.
...
To gitlab.com:IrinaRoiter/java-react-example.git
 * [new branch]      master -> master
branch 'master' set up to track 'origin/master'.
```
</details>
