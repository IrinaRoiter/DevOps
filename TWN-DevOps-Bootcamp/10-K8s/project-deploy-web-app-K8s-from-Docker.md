# Module 10 - Kubernetes
## Demo Project:
Deploy our web application in K8s cluster from private Docker registry
## Technologies used:
Kubernetes, Helm, AWS ECR, Docker
## Project Description:
Create Secret for credentials for the private Docker registry
Configure the Docker registry secret in application Deployment component
Deploy web application image from our private Docker registry in K8s cluster


# Solution


<details>
<summary><b>Login to Docker from AWS</b></summary>

* Get the command from AWS
```
AWS->ecr->js-app (my private repository)->Images tab->'View push commands'->Windows tab
```  
* Set default region and login to Docker from aws
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> Get-DefaultAWSRegion 👈🏻 No region is set as default

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> Set-DefaultAWSRegion -Region ca-central-1
```
* Login to Docker
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> aws ecr get-login-password --region ca-central-1 |
>> docker login --username AWS --password-stdin `
>> 654353650965.dkr.ecr.ca-central-1.amazonaws.com
Login Succeeded

iroiter@WINDOWS-CTBM1LI:/mnt/c/tmp$ cat /mnt/c/Users/user/.docker/config.json 👈🏻 The login command saves credentials in config.json file
{
        "auths": {
                "165.22.230.88:8083": {},
                "654353650965.dkr.ecr.ca-central-1.amazonaws.com": {},
                "https://index.docker.io/v1/": {}
        },
        "credsStore": "desktop",
        "currentContext": "desktop-linux"
}
```
ℹ️ The login allows Docker to pull an image from AWS private registry (ecr)

⚠️ Since I use minikube the method above won't work  becuase minikube does not have an access to credStore.
So, I have to login to Docker manually from minikube directly

* Get password
```
PS C:\tmp> aws ecr get-login-password
<password> 👈🏻 Command output shows a password multiline string. Copy it and save it aside 
```
* Get inside minikube container
```
PS C:\tmp> minikube ssh
Linux minikube 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```
* Login to Docker
```
docker login --username AWS --password <password> 654353650965.dkr.ecr.ca-central-1.amazonaws.com

WARNING! Using --password via the CLI is insecure. Use --password-stdin.

WARNING! Your credentials are stored unencrypted in '/home/docker/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
```
⚠️ construct the command in Notepad first. The password is a multiline string. Then, copy the command and paste it in the command prompt and hit Enter.
The command won't be displied properly.

* Verify that config.json has been created in minikube
```
docker@minikube:~$ ls -a
.   .bash_history  .bashrc  .profile  .sudo_as_admin_successful
..  .bash_logout   .docker  .ssh
docker@minikube:~$ ls -a ./.docker
.  ..  config.json 👈🏻 file is created and contains authentication credentials to my privite ecr repository

docker@minikube:~$ exit
logout
```
* Replace exisitng C:\Users\user\.docker\config.json file with the one we created inside the minikube
```
PS C:\tmp> Remove-Item -Path C:\Users\user\.docker\config.json

PS C:\tmp> minikube cp minikube:/home/docker/.docker/config.json C:\Users\user\.docker\config.json
PS C:\tmp>
```

* Use ./.docker/config.json file to create a docker secret in minikube


Docker secret file:

```
apiVersion: v1
kind: Secret
metadata:
  name: my-registry-key
data:
  .dockerconfigjson: 👈🏻 The value of it will contain the 64-base encoded contens of ./.docker/config.json file
type: kubernetes.io/dockerconfigjson
```
* Encode the content of .docker/config.json in 64 bit
```
PS C:\tmp> [Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\Users\user\.docker\config.json"))
<64 bit encoded string>
```
* Add <64 bit encoded string> to secret file
```
apiVersion: v1
kind: Secret
metadata:
  name: my-registry-key
data:
  .dockerconfigjson: <64 bit encoded string>
type: kubernetes.io/dockerconfigjson
```
ℹ️ Another way of creating a secret without secret yaml file is as follows:

```
PS C:\tmp> kubectl create secret generic my-registry-key --from-file=.dockerconfigjson=C:\Users\user\.docker\config.json --type=kubernetes.io/dockerconfigjson
secret/my-registry-key created

PS C:\tmp> kubectl get secret
NAME                    TYPE                             DATA   AGE
mongodb-secret          Opaque                           2      21d
mosquitto-secret-file   Opaque                           1      10d
my-registry-key         kubernetes.io/dockerconfigjson   1      2m47s 👈🏻 secret is created
```

* Get the secret in YAML format
```
PS C:\tmp> kubectl get secret -o yaml
apiVersion: v1
items:
- apiVersion: v1
  data:
    mongo-root-password: bW9uZ28tZGItcGFzc3dvcmQ=
    mongo-root-username: bW9uZ28tZGItcm9vdA==
  kind: Secret
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","data":{"mongo-root-password":"bW9uZ28tZGItcGFzc3dvcmQ=","mongo-root-username":"bW9uZ28tZGItcm9vdA=="},"kind":"Secret","metadata":{"annotations":{},"name":"mongodb-secret","namespace":"default"},"type":"Opaque"}
    creationTimestamp: "2026-05-14T18:44:19Z"
    name: mongodb-secret
    namespace: default
    resourceVersion: "17838"
    uid: 5307359f-4ce0-4b83-aec9-82bf693288c5
  type: Opaque
- apiVersion: v1
  data:
    secret.file: VGVjaFdvcmxkMjAyMyEgLW4K
  kind: Secret
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","data":{"secret.file":"VGVjaFdvcmxkMjAyMyEgLW4K\n"},"kind":"Secret","metadata":{"annotations":{},"name":"mosquitto-secret-file","namespace":"default"},"type":"Opaque"}
    creationTimestamp: "2026-05-25T15:25:19Z"
    name: mosquitto-secret-file
    namespace: default
    resourceVersion: "152462"
    uid: b6501eef-99af-4b79-96af-2a76aaf92493
  type: Opaque
- apiVersion: v1
  data:
    .dockerconfigjson: <64 bit encoded content>
  kind: Secret
  metadata:
    creationTimestamp: "2026-06-04T19:57:37Z"
    name: my-registry-key
    namespace: default
    resourceVersion: "315247"
    uid: 1f463fa9-6f8e-45d5-9f62-905d64687f6a
  type: kubernetes.io/dockerconfigjson
kind: List
metadata:
  resourceVersion: ""
```
ℹ️ Another method to create a secret. The method combines docker login and secret creation in one command
```
PS C:\tmp> kubectl create secret docker-registry my-registry-key-two `
>> --docker-server=hhtps://654353650965.dkr.ecr.ca-central-1.amazonaws.com `
>> --docker-username=AWS `
>> --docker-password=<encoded 64 bit config.json>
secret/my-registry-key-two created

👉🏻 'docker-registry' - this parameter instead of 'generic' defines type and logs in to Dockers

PS C:\tmp> kubectl get secret
NAME                    TYPE                             DATA   AGE
mongodb-secret          Opaque                           2      21d
mosquitto-secret-file   Opaque                           1      10d
my-registry-key         kubernetes.io/dockerconfigjson   1      36m
my-registry-key-two     kubernetes.io/dockerconfigjson   1      12m
```
</details>
<details>
<summary><b>Configure the Docker registry secret in application Deployment component</b></summary>

My-app deployment file:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      imagePullSecrets: 👈🏻 Attribute that makes a secret available to deployment
      - name: my-registry-key 👈🏻 References creaated secret by it's name
      containers:
      - name: my-app
        imagePullPolicy: Always
        image: 654353650965.dkr.ecr.ca-central-1.amazonaws.com/js-app:1.1 👈🏻 Image on ecr
        ports:
        - containerPort: 3000
```


* Create deployment
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f .\my-app-deployment.yaml
deployment.apps/my-app created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                                 READY   STATUS    RESTARTS   AGE
mongo-express-5747d566b9-6hvzk       1/1     Running   0          20d
mongodb-deployment-df5cd6568-vfrn6   1/1     Running   0          21d
mosquitto-b4f5ffb64-vgsqn            1/1     Running   0          10d
my-app-7c784886c9-xbdx8              1/1     Running   0          18s 👈🏻 Pod is running

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl describe pod my-app-7c784886c9-xbdx8
Name:             my-app-7c784886c9-xbdx8
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Thu, 04 Jun 2026 16:48:19 -0400
Labels:           app=my-app
                  pod-template-hash=7c784886c9
Annotations:      <none>
Status:           Running
IP:               10.244.0.26
IPs:
  IP:           10.244.0.26
Controlled By:  ReplicaSet/my-app-7c784886c9
Containers:
  my-app:
    Container ID:   docker://344c9c34cdafbdb56f68c71c0096bf0507736a14fb2eaaaabbfef36e13ac33ec
    Image:          654353650965.dkr.ecr.ca-central-1.amazonaws.com/js-app:1.1
    Image ID:       docker-pullable://654353650965.dkr.ecr.ca-central-1.amazonaws.com/js-app@sha256:d97f87850f7b37f5e894f235df7e05037abd49711961c1debd1ec4afe78a06cc
    Port:           3000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Thu, 04 Jun 2026 16:48:35 -0400
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-gfqrz (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-gfqrz:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m17s  default-scheduler  Successfully assigned default/my-app-7c784886c9-xbdx8 to minikube
  Normal  Pulling    6m16s  kubelet            Pulling image "654353650965.dkr.ecr.ca-central-1.amazonaws.com/js-app:1.1" 👈🏻 Successfully pulled image from AWS ERC
  Normal  Pulled     6m2s   kubelet            Successfully pulled image "654353650965.dkr.ecr.ca-central-1.amazonaws.com/js-app:1.1" in 14.377s (14.377s including waiting). Image size: 172866789 bytes.
  Normal  Created    6m1s   kubelet            Container created
  Normal  Started    6m1s   kubelet            Container started
```
ℹ️ Secret must be in the same namespace as Deployment, or other component that references the secret
</details> 