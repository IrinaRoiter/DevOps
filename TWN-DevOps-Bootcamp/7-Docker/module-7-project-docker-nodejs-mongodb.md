# Module 7 - Containers with Docker
## Demo Project:
Use Docker for local development
## Technologies used:
Docker, Node.js, MongoDB, MongoExpress
## Project Description:
* Create Dockerfile for NodeJs application and build Docker image
* Run NodeJS application in Docker container and connect to MongoDB database container locally
* Also run MongoExpress container as a UI of the MongoDB database

## Repo:
https://gitlab.com/IrinaRoiter/js-app

# Solution

<details>
<summary><b>Pull MongoDB and MongoExpress images locally and start containers</b></summary>


* Pull mongo DB and mongo express latest version images from Docker Hub
```
PS C:\repos\js-app> docker pull mongo
Using default tag: latest
latest: Pulling from library/mongo
1e41d5f93e35: Pull complete
2605962b0286: Pull complete
0c85015575ad: Pull complete
01a854eada6f: Pull complete
8d1d6859a473: Pull complete
3a5c9bc3c6a6: Pull complete
e8567d1c4785: Pull complete
ee7db4c3583f: Download complete
51deed191cab: Download complete
Digest: sha256:d343c378b5c6e2fe373174abcf4a877be0dfc721b5d0b9d582204dccb1c00b86
Status: Downloaded newer image for mongo:latest
docker.io/library/mongo:latest
```
```
PS C:\repos\js-app> docker pull mongo-express
Using default tag: latest
latest: Pulling from library/mongo-express
619be1103602: Pull complete
0bf3571b6cd7: Pull complete
7e9a007eb24b: Pull complete
5189255e31c8: Pull complete
d8305ae32c95: Pull complete
45b24ec126f9: Pull complete
88f4f8a6bc8d: Pull complete
9f7f59574f7d: Pull complete
337574bd0f5e: Download complete
99ef4db52d2b: Download complete
Digest: sha256:1b23d7976f0210dbec74045c209e52fbb26d29b2e873d6c6fa3d3f0ae32c2a64
Status: Downloaded newer image for mongo-express:latest
docker.io/library/mongo-express:latest
```
```
PS C:\repos\js-app> docker images
IMAGE                  ID             DISK USAGE   CONTENT SIZE   EXTRA
mongo-express:latest   1b23d7976f02        287MB         59.8MB
mongo:latest           d343c378b5c6        1.3GB          341MB
postgres:14.22         705a5d5b5836        628MB          163MB    U
postgres:15.17         c635fa3e3b74        633MB          164MB    U
redis:6.2              83a75a9107fa        159MB         42.6MB    U
redis:latest           315270d16608        204MB         55.3MB    U
ubuntu:latest          186072bba1b2        119MB         31.7MB    U
```
* Create mongo network
```
PS C:\repos\js-app> docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
d7ec814b68d0   bridge    bridge    local
b87940d3cde3   host      host      local
0127b36c9192   none      null      local
PS C:\repos\js-app> docker network create mongo-network
1a85eac87694bd01ca41e238111d6a9c4f014f2405f928eb8fa7c193325310db
PS C:\repos\js-app> docker network ls
NETWORK ID     NAME             DRIVER    SCOPE
d7ec814b68d0   bridge           bridge    local
b87940d3cde3   host             host      local
1a85eac87694   mongo-network    bridge    local
0127b36c9192   none             null      local
```
* Start MongoDB containder
```
PS C:\repos\js-app> docker run -d `
>>   -p 27017:27017 `
>>   -e MONGO_INITDB_ROOT_USERNAME=admin `
>>   -e MONGO_INITDB_ROOT_PASSWORD=password `
>>   --name mongodb `
>>   --network mongo-network `
>>   mongo
567bea80168de67a48a937f59d02ec060ba2984bb9d29e0e59a4dba0993fd8a5
```
```
PS C:\repos\js-app> docker logs 567bea80168de67a48a937f59d02ec060ba2984bb9d29e0e59a4dba0993fd8a5
{"t":{"$date":"2026-03-23T21:12:10.310+00:00"},"s":"I",  "c":"-",        "id":8991200, "ctx":"main","msg":"Shuffling initializers","attr":{"seed":2308446742}}
about to fork child process, waiting until server is ready for connections.
forked process: 29
...
```
* Start Mongo Express container
```
PS C:\repos\js-app> docker run -d `
>>     --network mongo-network `
>>     --name mongo-express `
>>     -p 8081:8081 `
>>     -e ME_CONFIG_MONGODB_SERVER=mongodb `
>> -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin `
>> -e ME_CONFIG_MONGODB_ADMINPASSWORD=password `
>> -e ME_CONFIG_BASICAUTH_USERNAME=user `
>> -e ME_CONFIG_BASICAUTH_PASSWORD=password `
>> -e ME_CONFIG_MONGODB_URL=mongodb://mongodb:27017 `
>> mongo-express
3b66b95562ef86a9b1f1915a2ec06efe3dc3b00893b079a9a3a69ebbb6ab2190
```
```
PS C:\repos\js-app> docker logs 3b66b95562ef86a9b1f1915a2ec06efe3dc3b00893b079a9a3a69ebbb6ab2190
Waiting for mongodb:27017...
No custom config.js found, loading config.default.js
Welcome to mongo-express 1.0.2
------------------------


Mongo Express server listening at http://0.0.0.0:8081
Server is open to allow connections from anyone (0.0.0.0)
```
</details>
<details>
<summary><b>Create a DB and a new colection</b></summary>

*  Create a new database "user-account" and a new collection "users" under "user-account" 

URL: localhost:8081

![verification](images/mongo-express.png)

</details>

<details>
<summary><b>Connect Node JS app to Mongo DB </b></summary>

* Add the code below to server.js to configure connection in the NodeJS app and restart the app
```
// use when starting application locally with node command
let mongoUrlLocal = "mongodb://admin:password@mongodb:27017";

// use when starting application as docker container, part of docker-compose
let mongoUrlDockerCompose = "mongodb://admin:password@mongodb";

// pass these options to mongo client connect request to avoid DeprecationWarning for current Server Discovery and Monitoring engine
let mongoClientOptions = { useNewUrlParser: true, useUnifiedTopology: true };

// "user-account" in demo with docker
let databaseName = "user-account";
let collectionName = "users";

app.get('/get-profile', function (req, res) {
  let response = {};
  // Connect to the db using local application or docker compose variable in connection properties
  MongoClient.connect(mongoUrlLocal, mongoClientOptions, function (err, client) {
    if (err) throw err;

    let db = client.db(databaseName);

    let myquery = { userid: 1 };

    db.collection(collectionName).findOne(myquery, function (err, result) {
      if (err) throw err;
      response = result;
      client.close();

      // Send response
      res.send(response ? response : {});
    });
  });
});

app.post('/update-profile', function (req, res) {
  let userObj = req.body;
  // Connect to the db using local application or docker compose variable in connection properties
  MongoClient.connect(mongoUrlLocal, mongoClientOptions, function (err, client) {
    if (err) throw err;

    let db = client.db(databaseName);
    userObj['userid'] = 1;

    let myquery = { userid: 1 };
    let newvalues = { $set: userObj };

    db.collection(collectionName).updateOne(myquery, newvalues, {upsert: true}, function(err, res) {
      if (err) throw err;
      client.close();
    });

  });
  // Send response
  res.send(userObj);
});

```

</details>

<details>
<summary><b>Create Dockerfile for NodeJs application and build Docker image</b></summary>

* Create a Dockerfile for NodeJS

Dockerfile: 

* Build NodeJs image

```
PS C:\repos\js-app> docker build -t irina-app:1.0 .
[+] Building 2.2s (11/11) FINISHED                                                                                                                            docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                                          0.0s
 => => transferring dockerfile: 
 ...
 sha256:4efe9ada6fe4ae6825805f33ad776ca13cbb210e510281908624ad5bd29080e1                                                                        0.0s
 => => naming to docker.io/library/irina-app:1.0                                                                                                                              0.0s
 => => unpacking to docker.io/library/irina-app:1.0                                                                                                                           0.9s

View build details: docker-desktop://dashboard/build/desktop-linux/desktop-linux/40mhx51ovotxhcmprkoiotvat

```
* Validate the image
```
PS C:\repos\js-app> docker image ls

IMAGE                  ID             DISK USAGE   CONTENT SIZE   EXTRA
irina-app:1.0          d5d8be540626        250MB         59.6MB
mongo-express:latest   1b23d7976f02        287MB         59.8MB    U
mongo:latest           d343c378b5c6        1.3GB          341MB    U
postgres:14.22         705a5d5b5836        628MB          163MB
postgres:15.17         c635fa3e3b74        633MB          164MB
redis:6.2              83a75a9107fa        159MB         42.6MB
redis:latest           315270d16608        204MB         55.3MB
ubuntu:latest          186072bba1b2        119MB         31.7MB    U
```
</details>

<details>
<summary><b>Run NodeJS application in Docker container</b></summary>

* Run NodeJS application in Docker container
```
PS C:\repos\js-app> docker run -d `
>> --network mongo-network `
>> --name irina-node-app `
>> -p 3000:3000 `
>> irina-app:1.0
adfdd17cdeaa703e0cccc5160e38f0edd32e7ab30f05c5ec9ab7443ef0a4524c
```
* Verify that container is running
```
PS C:\repos\js-app> docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED             STATUS             PORTS                                             NAMES
adfdd17cdeaa   irina-app:1.0   "docker-entrypoint.s…"   6 seconds ago       Up 6 seconds       0.0.0.0:3000->3000/tcp, [::]:3000->3000/tcp       irina-node-app
b9a50ee0ad78   mongo           "docker-entrypoint.s…"   6 minutes ago       Up 6 minutes       0.0.0.0:27017->27017/tcp, [::]:27017->27017/tcp   mongodb
3e5d462f1272   mongo-express   "/sbin/tini -- /dock…"   About an hour ago   Up About an hour   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp       mongo-express
```
* Inspect container
```
PS C:\repos\js-app> docker logs adfdd17cdeaa703e0cccc5160e38f0edd32e7ab30f05c5ec9ab7443ef0a4524c
app listening on port 3000!

PS C:\repos\js-app> docker exec -it adfdd17cdeaa703e0cccc5160e38f0edd32e7ab30f05c5ec9ab7443ef0a4524c /bin/sh
/home/app # ls
images             index.html         node_modules       package-lock.json  package.json       server.js

```

* Verify that NodeJS app is running

URL: localhost:3000 

* Update the user record profile and verify it

![verification](images/mongo-updated-user-profile.png)

```
{
    _id: ObjectId('69c2bb941c436984478e823c'),
    userid: 1,
    email: 'irina.roiter@yahoo.com',
    interests: 'coding, devops',
    name: 'Irina Roiter'
}
```

</details>

