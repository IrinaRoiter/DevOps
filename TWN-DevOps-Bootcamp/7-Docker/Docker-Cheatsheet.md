
`docker pull amazoncorretto:17.0.18-alpine3.23` - pull image locally

`docker build -t irina-app:1.0 . ` - build an image with Dockerfile
```
docker run -d `
>> --network mongo-network `
>> --name irina-node-app `
>> -p 3000:3000 `
>> irina-app:1.0
```
Start container
`docker ps` - lists running containers
`docker ps -a` - lists all the containers
`docker container prune -f` - removes all stopped containers
`docker run -it amazoncorretto:17.0.18-alpine3.23 /bin/sh` - starts container with interactive terminal

`docker container inspect e35c59e98070 | Select-String 'network'` - shows info about network that container connected to