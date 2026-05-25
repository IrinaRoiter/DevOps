# Module 10 - Kubernetes
## Demo Project:
Deploy Mosquitto message broker with ConfigMap and Secret Volume Types
## Technologies used:
Kubernetes, Docker, MongoDB, Mosquitto
## Project Description:
Define configuration and passwords for Mosquitto message broker with ConfigMap and Secret Volume types


# Solution

## Repo:
 

<details>
<summary><b>Configure and start MongoDB deployment</b></summary>

* Configure Mosquitto deployment without volumes

Deployment config file:
https://github.com/IrinaRoiter/DevOps/blob/1809a0b3a749b32f9dcdd769ad3c45e13ff7054f/TWN-DevOps-Bootcamp/10-K8s/mosquitto-without-volumes.yaml

* Create deployment, inspect its contents, remove deployment
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f mosquitto-without-volumes.yaml
deployment.apps/mosquitto created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get deployment mosquitto
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
mosquitto   1/1     1            1           30s

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                                 READY   STATUS    RESTARTS   AGE
mongo-express-5747d566b9-6hvzk       1/1     Running   0          10d
mongodb-deployment-df5cd6568-vfrn6   1/1     Running   0          10d
mosquitto-8bbb9c957-vvqhw            1/1     Running   0          59s

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl exec -it mosquitto-8bbb9c957-vvqhw -- /bin/sh
/ # ls
bin                     home                    mosquitto               root                    sys
dev                     lib                     mosquitto-no-auth.conf  run                     tmp
docker-entrypoint.sh    media                   opt                     sbin                    usr
etc                     mnt                     proc                    srv                     var

/mosquitto/config # ls
mosquitto.conf 👈🏻 configuration file inside of the container with default values

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl delete -f .\mosquitto-without-volumes.yaml
deployment.apps "mosquitto" deleted from default namespace
```
* Overwrite a default config file with external config file by mounting it inside the container

Config-map file:

Secret file:


```
```
</details> 