# 🐳 Docker & Docker Compose Cheat Sheet (Module 7)

This cheat sheet summarizes all essential commands and concepts used throughout Module 7.

---

# 🔹 Docker Basics

## Build Image
```bash
docker build -t <image-name>:<tag> .
```

## List Images
```bash
docker images
```

## Remove Image
```bash
docker rmi <image-id>
```

---

# 🔹 Running Containers

## Run Container
```bash
docker run -d -p <host-port>:<container-port> --name <container-name> <image>
```

## Run with Environment Variables
```bash
docker run -d \
  -p 8080:8080 \
  -e DB_USER=user \
  -e DB_PWD=password \
  --name my-app \
  <image>
```

## Run with Volume
```bash
docker run -d \
  -v <volume-name>:/path/in/container \
  <image>
```

---

# 🔹 Container Management

## List Running Containers
```bash
docker ps
```

## List All Containers
```bash
docker ps -a
```

## Stop Container
```bash
docker stop <container-id>
```

## Start Container
```bash
docker start <container-id>
```

## Remove Container
```bash
docker rm <container-id>
```

---

# 🔹 Logs & Debugging

## View Logs
```bash
docker logs <container-id>
```

## Follow Logs
```bash
docker logs -f <container-id>
```

## Execute Command Inside Container
```bash
docker exec -it <container-id> /bin/bash
```

---

# 🔹 Networking

## List Networks
```bash
docker network ls
```

## Inspect Network
```bash
docker network inspect <network-name>
```

## Run Container in Specific Network
```bash
docker run -d --network <network-name> <image>
```

---

# 🔹 Volumes

## List Volumes
```bash
docker volume ls
```

## Inspect Volume
```bash
docker volume inspect <volume-name>
```

---

# 🔹 Docker Compose

## Start Services
```bash
docker-compose up -d
```

## Stop Services
```bash
docker-compose down
```

## Rebuild & Start
```bash
docker-compose up -d --build
```

## View Logs
```bash
docker-compose logs
```

## Follow Logs
```bash
docker-compose logs -f
```

## Run Specific File
```bash
docker-compose -f docker-compose.yaml up -d
```

## Use Environment File
```bash
docker-compose --env-file ./sandbox.env up -d
```

---

# 🔹 Environment Variables

## Export Variables (Linux)
```bash
export DB_USER=user
export DB_PWD=password
```

## Use in docker-compose.yaml
```yaml
environment:
  - DB_USER=${DB_USER}
  - DB_PWD=${DB_PWD}
```

---

# 🔹 Health Checks

Example:
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 5s
  timeout: 5s
  retries: 5
```

---

# 🔹 Troubleshooting

## Check Container Health
```bash
docker inspect <container-id>
```

## Check OOM Kill
```bash
dmesg | grep -i kill
```

## Check Open Ports
```bash
ss -tuln
```

---

# 🔹 Useful Linux Commands

## Check IP Address
```bash
hostname -I
```

## Get Public IP
```bash
curl -s ifconfig.me
```

## Check Running Processes
```bash
ps aux
```

## Check Disk Space
```bash
df -h
```

## Check Memory Usage
```bash
free -m
```

---

# 🔹 Cleanup

## Remove Unused Resources
```bash
docker system prune -a
```
## Common Issues & Fixes

### MySQL container unhealthy
Cause: Low memory (512MB VM)

Solution:
- Upgrade to 1GB OR
- Tune MySQL memory settings

### Frontend not showing data
Cause: Hardcoded localhost in API calls

Solution:
- Use relative paths (/api)
- Or window.location.origin
---

# ✅ Best Practices

- Use environment variables instead of hardcoding values
- Use docker-compose for multi-container apps
- Avoid using localhost in frontend code
- Use relative paths for API calls
- Always check logs when debugging

---

# 🚀 Summary

This cheat sheet covers:
- Docker basics
- Container lifecycle
- Networking & volumes
- Docker Compose
- Debugging & troubleshooting
- Linux commands for server management

Keep this as a quick reference while working with Docker in real projects.

