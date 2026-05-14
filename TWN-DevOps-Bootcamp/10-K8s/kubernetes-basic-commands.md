# Module 10 - Kubernetes
## Demo Project:
Deploy MongoDB and Mongo Express into local K8s
cluster
## Technologies used:
Kubernetes, Docker, MongoDB, Mongo Express
## Project Description:
Setup local K8s cluster with Minikube Deploy MongoDB and MongoExpress with configuration and credentials extracted into ConfigMap and Secret


# Solution

## Repo:
 

<details>
<summary><b>Install mini-kube and kubectl</b></summary>

* Install mini-kube and kubectl
https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download

https://minikube.sigs.k8s.io/docs/drivers/

```
PS C:\Users\user> minikube start --driver=docker
😄  minikube v1.38.1 on Microsoft Windows 11 Pro 25H2
...
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
```
PS C:\Users\user> minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```
```
PS C:\Users\user> kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   14m   v1.35.1
```
👉🏻 kubectl is for configuring the minikube cluster </br>
👉🏻 minikube is for deleting / starting the cluster

</details>
<details>
<summary><b>Kubectl basic commands</b></summary>

* Create an nginx deployment

```
PS C:\Users\user> kubectl get pod
No resources found in default namespace.

PS C:\Users\user> kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   19m

PS C:\Users\user>   kubectl create deployment nginx-depl --image=nginx
deployment.apps/nginx-depl created
PS C:\Users\user>   kubectl get deployment
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
nginx-depl   1/1     1            1           20s

PS C:\Users\user>   kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
nginx-depl-569bd7dcf9-bkr4h   1/1     Running   0          29s

PS C:\Users\user>   kubectl get replicaset
NAME                    DESIRED   CURRENT   READY   AGE
nginx-depl-569bd7dcf9   1         1         1       41s
PS C:\Users\user>
```
* Edit an nginx deployment
```
PS C:\Users\user> kubectl edit deployment nginx-depl
ℹ️ it generated a config. file in yaml format. I updated image from 'nginx' to 'nginx:1.25'. Save and close.
deployment.apps/nginx-depl edited

PS C:\Users\user> kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
nginx-depl-7fb6fc4d75-p6cqg   1/1     Running   0          3m

👉🏻 An old pod got terminated and a new pod has started

PS C:\Users\user> kubectl get replicaset
NAME                    DESIRED   CURRENT   READY   AGE
nginx-depl-569bd7dcf9   0         0         0       40m
nginx-depl-7fb6fc4d75   1         1         1       34m

👉🏻 an old replica set does not have any pods in it, but a new one has one pod in it
PS C:\Users\user> kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
nginx-depl-7fb6fc4d75-p6cqg   1/1     Running   0          39m
👉🏻 a new pod that belongs to a new replica set

PS C:\Users\user> kubectl logs nginx-depl-7fb6fc4d75-p6cqg
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/05/13 17:46:58 [notice] 1#1: using the "epoll" event method
2026/05/13 17:46:58 [notice] 1#1: nginx/1.25.5
2026/05/13 17:46:58 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2026/05/13 17:46:58 [notice] 1#1: OS: Linux 6.6.87.2-microsoft-standard-WSL2
2026/05/13 17:46:58 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2026/05/13 17:46:58 [notice] 1#1: start worker processes
2026/05/13 17:46:58 [notice] 1#1: start worker process 30
2026/05/13 17:46:58 [notice] 1#1: start worker process 31
2026/05/13 17:46:58 [notice] 1#1: start worker process 32
2026/05/13 17:46:58 [notice] 1#1: start worker process 33
2026/05/13 17:46:58 [notice] 1#1: start worker process 34
2026/05/13 17:46:58 [notice] 1#1: start worker process 35
2026/05/13 17:46:58 [notice] 1#1: start worker process 36
2026/05/13 17:46:58 [notice] 1#1: start worker process 37
```
* Create a new MongoDB deployment
```
PS C:\Users\user> kubectl create deployment mongo-deployment --image=mongo
deployment.apps/mongo-deployment created

PS C:\Users\user> kubectl describe pod mongo-deployment-5dc7f4b7d7-bp42x
Name:             mongo-deployment-5dc7f4b7d7-bp42x
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Wed, 13 May 2026 14:30:15 -0400
Labels:           app=mongo-deployment
                  pod-template-hash=5dc7f4b7d7
Annotations:      <none>
Status:           Pending
IP:
IPs:              <none>
Controlled By:    ReplicaSet/mongo-deployment-5dc7f4b7d7

PS C:\Users\user> kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
mongo-deployment-5dc7f4b7d7-bp42x   1/1     Running   0          7m38s
nginx-depl-7fb6fc4d75-p6cqg         1/1     Running   0          51m

👉🏻 mongo-deployment-5dc7f4b7d7-bp42x is running now

PS C:\Users\user> kubectl logs mongo-deployment-5dc7f4b7d7-bp42x
{"t":{"$date":"2026-05-13T18:31:23.792+00:00"},"s":"I",  "c":"-",        "id":8991200, "ctx":"main","msg":"Shuffling initializers","attr":{"seed":135398511}}
....
```
* Enter the container 
```
PS C:\Users\user> kubectl exec -it mongo-deployment-5dc7f4b7d7-bp42x -- bin/bash
root@mongo-deployment-5dc7f4b7d7-bp42x:/# ls
bin   data  docker-entrypoint-initdb.d  home        lib    media  opt   root  sbin  sys  usr
boot  dev   etc                         js-yaml.js  lib64  mnt    proc  run   srv   tmp  var
root@mongo-deployment-5dc7f4b7d7-bp42x:/# exit
```
* Delete deployment
```
PS C:\Users\user> kubectl delete deployment mongo-deployment
deployment.apps "mongo-deployment" deleted from default namespace

PS C:\Users\user> kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
nginx-depl-7fb6fc4d75-p6cqg   1/1     Running   0          69m
👉🏻 Only one pod is running 
PS C:\Users\user> kubectl get replicaset
NAME                    DESIRED   CURRENT   READY   AGE
nginx-depl-569bd7dcf9   0         0         0       76m
nginx-depl-7fb6fc4d75   1         1         1       70m

PS C:\Users\user> kubectl delete deployment nginx-depl
deployment.apps "nginx-depl" deleted from default namespace
PS C:\Users\user> kubectl get replicaset
No resources found in default namespace.
PS C:\Users\user>

```
* Create a deployment with yaml config file

Create a yaml file with basic configuration - nginx-deployment.yaml
https://github.com/IrinaRoiter/DevOps/blob/0ea78512d81d80a2097305d3bfbad25de90990a2/TWN-DevOps-Bootcamp/10-K8s/nginx-deployment.yaml
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f nginx-deployment.yaml

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569f95f5cb-dzzm5   1/1     Running   0          6m41s

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   1/1     1            1           7m15s
```
* Update deployment 
```
Edit nginx-deployment.yaml. Increase number of replicas from 1 to 2. Save.

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured 👈🏻 Notice that deployment is now 'configured'

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           12m

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569f95f5cb-5dkkx   1/1     Running   0          3m40s 👈🏻 new pod
nginx-deployment-569f95f5cb-dzzm5   1/1     Running   0          16m 👈🏻 old pod
```
</details>

<details>
<summary><b>Yaml configuration file</b></summary>

Service file:</br>
https://github.com/IrinaRoiter/DevOps/blob/aea907ad8ddf43057f245544bb0bb20a04844497/TWN-DevOps-Bootcamp/10-K8s/nginx-service.yaml

```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f nginx-service.yaml
service/nginx-service created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pods
NAME                                READY   STATUS    RESTARTS      AGE
nginx-deployment-569f95f5cb-5dkkx   1/1     Running   1 (17m ago)   20h
nginx-deployment-569f95f5cb-dzzm5   1/1     Running   1 (17m ago)   21h

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get service
NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
kubernetes      ClusterIP   10.96.0.1     <none>        443/TCP   23h 👈🏻 default service
nginx-service   ClusterIP   10.98.11.13   <none>        80/TCP    11m 👈🏻 the service we created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl describe service nginx-service
Name:                     nginx-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginx 👈🏻 Connects service to deployment
Type:                     ClusterIP
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.98.11.13
IPs:                      10.98.11.13
Port:                     <unset>  80/TCP
TargetPort:               8080/TCP
Endpoints:                10.244.0.9:8080,10.244.0.8:8080 👈🏻 Cluster IPs of the nginx app pods. They match pod IPs of the command below
Session Affinity:         None
Internal Traffic Policy:  Cluster
Events:                   <none>

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod -o wide
NAME                                READY   STATUS    RESTARTS      AGE   IP           NODE       NOMINATED NODE   READINESS GATES
nginx-deployment-569f95f5cb-5dkkx   1/1     Running   1 (34m ago)   21h   10.244.0.9   minikube   <none>           <none>
nginx-deployment-569f95f5cb-dzzm5   1/1     Running   1 (34m ago)   21h   10.244.0.8   minikube   <none>           <none>
                                                                              👆🏻 - pod IPs 

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get deployment nginx-deployment -o yaml > .\nginx-deployment-result.yaml 👈🏻 resulting file from etcd
It contains 'Status' section.
It also contains other auto-generated and default data. To deploy from this file, auto-generated data (ex: created date) has to be cleaned up first.
```
* Delete deployment and service using YAML config file
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl delete -f .\nginx-deployment.yaml
deployment.apps "nginx-deployment" deleted from default namespace

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl delete -f .\nginx-service.yaml
service "nginx-service" deleted from default namespace
```
</details>