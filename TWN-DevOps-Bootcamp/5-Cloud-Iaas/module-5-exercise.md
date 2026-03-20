## Module 5 - Cloud & IaaS Basics - DigitalOcean

### Exercise: Start NodeJS application on a cloud server 
`git clone git@gitlab.com:IrinaRoiter/cloud-basics-exercises.git` - clone the repo using SSH protocol <br />
`cd app` - change location to app sub directory <br />
`npm install` - install app dependencies  based on package.json file <br />
`ls -al` - validate that node_modules directory is added <br />
Output: `drwxrwxr-x 260 iroiter iroiter  12288 Mar 10 14:30 node_modules`<br />
`npm pack` - create a package <br />
`ls -al` - validate that bootcamp-node-project-1.0.0.tgz is generated <br />
Output: `-rw-rw-r--   1 iroiter iroiter  79382 Mar 10 14:31 bootcamp-node-project-1.0.0.tgz` <br />

create your Droplet on Digital Ocean and copy IPv4 address<br />
add the droplet to a Firewall<br />
`ssh root@138.197.152.215` - connect to a remote server<br />
`mkdir /opt/my-app` - create my-app dir <br />
`exit` - log out from a remote server<br />

`scp bootcamp-node-project-1.0.0.tgz root@138.197.152.215:/opt/my-app` - securely copy bootcamp-node-project-1.0.0.tgz to server <br />
`ssh root@138.197.152.215` - connect to a remote server<br />
`cd /opt/my-app` -change location to /opt/my-app<br />
`tar -zxvf /opt/my-app/bootcamp-node-project-1.0.0.tgz` - extract tgz file <br />
`npm install` - install app dependencies  based on package.json file <br />

`adduser irina` - add an user<br />
`usermod -aG sudo irina` - add irina to sudo group <br />
`chown irina:irina -R /opt/my-app/package`- change ownership of /opt/my-app/package from root:root to irina:irina<br />
`ls -l /opt/my-app` - validate changing an ownership <br />
Output: `drwxr-xr-x 4 irina irina  4096 Mar  5 22:20 package` <br />
`su - irina` - login as irina <br />

'node server.js &` - start NodeJS app in detached mode <br />

`ps aux | grep node | grep -v grep` - verify that the app is running under Node process and copy the process ID - 1209 <br />
Output: `irina       1209  5.0 12.3 612124 58156 pts/0    Sl   20:19   0:00 node server.js`<br />
`netstat -lpnt | grep 1209` - check port the app listens on <br />
Output: `tcp6       0      0 :::3000                 :::*                    LISTEN      1209/node`<br />

`http://138.197.152.215:3000/ ` - Connect to app from a browser <br />
   