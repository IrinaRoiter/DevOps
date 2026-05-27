# Module 10 - Kubernetes
## Demo Project:
Deploy Mosquitto message broker with ConfigMap and Secret Volume Types
## Technologies used:
Kubernetes, Docker, MongoDB, Mosquitto
## Project Description:
Define configuration and passwords for Mosquitto message broker with ConfigMap and Secret Volume types


# Solution


<details>
<summary><b>Deploy Mosquitto without volumes</b></summary>

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
</details>
<details>
<summary><b>Create external configmap file and secret file and apply them</b></summary>

* Overwrite a default config file with external config file by mounting it inside the container

Config-map file:
https://github.com/IrinaRoiter/DevOps/blob/d0177a27fc7a863e61d7612f1031331df2166c96/TWN-DevOps-Bootcamp/10-K8s/config-file.yaml

Secret file:
https://github.com/IrinaRoiter/DevOps/blob/d0177a27fc7a863e61d7612f1031331df2166c96/TWN-DevOps-Bootcamp/10-K8s/secret-file.yaml

```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f config-file.yaml
configmap/mosquitto-config-file created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f secret-file.yaml
secret/mosquitto-secret-file created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get secret
NAME                    TYPE     DATA   AGE
mongodb-secret          Opaque   2      10d
mosquitto-secret-file   Opaque   1      3m24s

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get configmap
NAME                    DATA   AGE
kube-root-ca.crt        1      11d
mongodb-configmap       1      10d
mosquitto-config-file   1      5m50s
```
</details>
<details>
<summary><b>Deploy Mosquitto with config map and secret volumes types</b></summary>

Mosquitto deployment file with volumes:
https://github.com/IrinaRoiter/DevOps/blob/c438eac6125284c30dcf9dbef20b6350a53d1e10/TWN-DevOps-Bootcamp/10-K8s/mosquitto.yaml

```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f .\mosquitto.yaml
deployment.apps/mosquitto created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                                 READY   STATUS    RESTARTS   AGE
mongo-express-5747d566b9-6hvzk       1/1     Running   0          10d
mongodb-deployment-df5cd6568-vfrn6   1/1     Running   0          10d
mosquitto-b4f5ffb64-vgsqn            1/1     Running   0          4s

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl exec -it mosquitto-b4f5ffb64-vgsqn -- /bin/sh
/ # ls
bin                     home                    mosquitto               root                    sys
dev                     lib                     mosquitto-no-auth.conf  run                     tmp
docker-entrypoint.sh    media                   opt                     sbin                    usr
etc                     mnt                     proc                    srv                     var

/ # cd mosquitto/
/mosquitto # ls
config  data    log     secret 👈🏻 secret folder was created
/mosquitto # cd secret
/mosquitto/secret # ls
secret.file 👈🏻 with secret.file mounted 

/mosquitto/secret # cd ..
/mosquitto # cd config
/mosquitto/config # ls
mosquitto.conf
/mosquitto/config # cat mosquitto.conf 
log_dest stdout
log_type all
log_timestamp true
listener 9001

👆🏻 default contents of the mosquitto file were overwrittent with the content of config-file.yaml
```
</details>
<details>
<summary><b>Conclusion</b></summary>

This project demonstrates that values from config.map and secret object can be passed to individual containers as volumes.

To summarize, there are 2 ways:

1. individual key-value pairs
usage: as env. vars
```
          env:
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: mongo-root-username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: mongo-root-password
```

2. create files
mount as volumes types
```
    spec:
        containers:
          - name: mosquitto
            image: eclipse-mosquitto:2.0
            ports:
              - containerPort: 1883
            volumeMounts:
              - name: mosquitto-config
                mountPath: /mosquitto/config
              - name: mosquitto-secret-file
                mountPath: /mosquitto/secret
                readOnly: true
        volumes:
          - name: mosquitto-config
            configMap:
              name: mosquitto-config-file
          - name: mosquitto-secret-file
            secret:
              secretName: mosquitto-secret-file 
```

✅ Config maps and secrets are Kubernetes volumes types

</details> 