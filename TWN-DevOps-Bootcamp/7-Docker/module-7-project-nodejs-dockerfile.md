# Module 7 - Containers with Docker
## Demo Project:
Dockerize NodeJS application
## Technologies used:
Docker, Node.js
## Project Description:
Write a Dockerfile to build a Docker image for NodeJS app 
## Repo:
https://gitlab.com/IrinaRoiter/js-app


# Solution

<details>
<summary><b>Structure a NOdeJS project and create Dockerfile</b></summary>

* Isolate Node JS app under separate folder to ensure that we copy only what app needs to run inside of the container. The app folder structure should be like this:

```
\js-app
    Dockerfile
    \app
       server.js
       index.html
       package.json 
```

* Create a Dockerfile for NodeJS

Dockerfile: 
```
FROM node:20-alpine

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

RUN mkdir -p /home/app

COPY ./app /home/app

# set default dir so that next commands executes in /home/app dir
WORKDIR /home/app

# will execute npm install in /home/app because of WORKDIR
RUN npm install

# no need for /home/app/server.js because of WORKDIR
CMD ["node", "server.js"]
```
</details>

<details>
<summary><b>How to build an image</b></summary>

``` 
docker build -t irina-app:1.0 . 
```
```
docker run -d `
>> --network mongo-network `
>> --name irina-node-app `
>> -p 3000:3000 `
>> irina-app:1.0
```

</details>