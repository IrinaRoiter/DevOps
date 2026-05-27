# Module 10 - Kubernetes
## Demo Project:
Install a stateful service (MongoDB) on Kubernetes using  Helm
## Technologies used:
K8s, Helm, MongoDB, Mongo Express, Linode LKE, Linux
## Project Description:
Create a managed K8s cluster with Linode Kubernetes Engine
Deploy replicated MongoDB service in LKE cluster using a Helm chart
Configure data persistence for MongoDB with Linode’s cloud storage
Deploy UI client Mongo Express for MongoDB
Deploy and configure nginx ingress to access the UI application from browser


# Solution

### Helm install:
https://helm.sh/docs/intro/install/ 

### The bitnami helm chart repository information commands can be found here: 
https://github.com/bitnami/charts/tree/main/bitnami/mongodb

<details>
<summary><b>Create a cluster in Linode using LKE, connect to it from my computer</b></summary>

* Create a cluster in Linode using LKE
```
https://cloud.linode.com/
Compute->Kubernetes->Create
Name: test
Region: Toronto Canada (closest geographical location)
Nodes: under 'Shared CPU' tab select 4GB Memory, 2 CPU ->Add to pool
Number of nodes: 2
Create
```
* Donwload kubeconfig YAML file and make it read-only for other users
```
iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ ls -l test-kubeconfig.yaml
-rwxrwxrwx 1 iroiter iroiter 2825 May 26 14:28 test-kubeconfig.yaml

iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ sudo chmod 400 test-kubeconfig.yaml
[sudo] password for iroiter:
iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ ls -l test-kubeconfig.yaml
-r-xr-xr-x 1 iroiter iroiter 2825 May 26 14:28 test-kubeconfig.yaml
```
* Set the cluster as a current context
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> $env:KUBECONFIG=".\test-kubeconfig.yaml" 👈🏻 assigning a test-kubeconfig.yaml to an env. var KUBECONFIG
ℹ️ export KUBECONFIG=test-kubeconfig.yaml in Bash/shell

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get node
NAME                            STATUS   ROLES    AGE   VERSION
lke608080-892489-164faa2f0000   Ready    <none>   29m   v1.35.3
lke608080-892489-185493c00000   Ready    <none>   29m   v1.35.3 
```
</details> 

<details>
<summary><b>Deploy MongoDB Statefullset in the cluster</b></summary>

* Install helm locally
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> winget install Helm.Helm
Found Helm [Helm.Helm] Version 4.2.0
...
Successfully installed
```
* Add Bitnami Helm repo to helm
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
ℹ️ The command is executed against the cluster I am connected to. Helm uses kubectl in the background.

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm search repo bitnami 👈🏻 now we can search bitnami charts
NAME                                            CHART VERSION   APP VERSION     DESCRIPTION                             
bitnami/airflow                                 25.0.2          3.0.5           Apache Airflow is a tool to express and execute...

```
* Find a MongoDB helm chart
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm search repo bitnami/mongodb
NAME                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/mongodb         19.0.7          8.3.2           MongoDB(R) is a relational open source NoSQL da...
bitnami/mongodb-sharded 9.4.12          8.0.13          MongoDB(R) is an open source NoSQL database tha...
```
* Create a YAML file with my custom values

Helm-mongodb.yaml

https://github.com/IrinaRoiter/DevOps/blob/8e931310132faa35c5ea9017850878ebeae75c64/TWN-DevOps-Bootcamp/10-K8s/helm-mongodb.yaml

* Install MongoDb helm chart on cluster
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm install mongodb --values helm-mongodb.yaml bitnami/mongodb
NAME: mongodb
LAST DEPLOYED: Wed May 27 09:44:38 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
CHART NAME: mongodb
CHART VERSION: 19.0.7
APP VERSION: 8.3.2

** Please be patient while the chart is being deployed **

MongoDB&reg; can be accessed on the following DNS name(s) and ports from within your cluster:

    mongodb-0.mongodb-headless.default.svc.cluster.local:27017 👈🏻3 replicasets are being deployed
    mongodb-1.mongodb-headless.default.svc.cluster.local:27017
    mongodb-2.mongodb-headless.default.svc.cluster.local:27017

To get the root password run:

    export MONGODB_ROOT_PASSWORD=$(kubectl get secret --namespace default mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)

To connect to your database, create a MongoDB&reg; client container:

    kubectl run --namespace default mongodb-client --rm --tty -i --restart='Never' --env="MONGODB_ROOT_PASSWORD=$MONGODB_ROOT_PASSWORD" --image docker.io/bitnamisecure/mongodb:latest --command -- bash

Then, run the following command:
    mongosh admin --host "mongodb-0.mongodb-headless.default.svc.cluster.local:27017,mongodb-1.mongodb-headless.default.svc.cluster.local:27017,mongodb-2.mongodb-headless.default.svc.cluster.local:27017" --authenticationDatabase admin -u $MONGODB_ROOT_USER -p $MONGODB_ROOT_PASSWORD

```
ℹ️
helm -tool
install - command
mongodb - name
helm-mongodb.yaml - custom values file
bitnami/mongodb - chart name

* Verify that pods are running  
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                READY   STATUS    RESTARTS   AGE
mongodb-0           1/1     Running   0          27m
mongodb-1           1/1     Running   0          26m
mongodb-2           1/1     Running   0          25m
mongodb-arbiter-0   1/1     Running   0          27m
```
* List all the components of the cluster
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get all
NAME                    READY   STATUS    RESTARTS   AGE
pod/mongodb-0           1/1     Running   0          33m
pod/mongodb-1           1/1     Running   0          33m
pod/mongodb-2           1/1     Running   0          31m
pod/mongodb-arbiter-0   1/1     Running   0          33m

NAME                               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
service/kubernetes                 ClusterIP   10.128.0.1   <none>        443/TCP     19h
service/mongodb-arbiter-headless   ClusterIP   None         <none>        27017/TCP   33m
service/mongodb-headless           ClusterIP   None         <none>        27017/TCP   33m

NAME                               READY   AGE
statefulset.apps/mongodb           3/3     33m
statefulset.apps/mongodb-arbiter   1/1     33m
```
* List clister secrets
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get secret
NAME                            TYPE                 DATA   AGE
mongodb                         Opaque               2      36m
sh.helm.release.v1.mongodb.v1   helm.sh/release.v1   1      36m
```
</details> 
<details>
<summary><b>DeployCreate MongoExpress deployment</b></summary>

* Create a deployment YAML file

Helm-MongoExpress.yaml
https://github.com/IrinaRoiter/DevOps/blob/8e931310132faa35c5ea9017850878ebeae75c64/TWN-DevOps-Bootcamp/10-K8s/helm-mongo-express.yaml

Remarks:
```
        - name: ME_CONFIG_MONGODB_ADMINPASSWORD 
          valueFrom:
            secretKeyRef:
              name: mongodb (⭐)
              key: mongodb-root-password (⭐⭐)

⭐ Name 'mongodb' is from 'kubectl get secret' command
⭐⭐ 'mongodb-root-password' is from 'kubectl get secret -o yaml' command
```
```- name: ME_CONFIG_MONGODB_URL
          value: "mongodb://$(ME_CONFIG_MONGODB_ADMINUSERNAME):$(ME_CONFIG_MONGODB_ADMINPASSWORD)@mongodb-0.mongodb-headless:27017" (⭐)

⭐ mongodb-0.mongodb-headless:27017
mongodb-0 - pod name
mongodb-headless - service name
```
![Pod-service](images/headless-service.png)

* Create MongoExpress deployment
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f .\helm-mongo-express.yaml
deployment.apps/mongo-express created
service/mongo-express-service created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                            READY   STATUS    RESTARTS   AGE
mongo-express-fd8bc9dcf-zm8t8   1/1     Running   0          26s
mongodb-0                       1/1     Running   0          114m
mongodb-1                       1/1     Running   0          113m
mongodb-2                       1/1     Running   0          112m
mongodb-arbiter-0               1/1     Running   0          114m

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl logs mongo-express-fd8bc9dcf-zm8t8
.......
Mongo Express server listening at http://0.0.0.0:8081
Server is open to allow connections from anyone (0.0.0.0)
basicAuth credentials are "admin:pass", it is recommended you change this in your config.js!
```
</details> 
<details>
<summary><b>Install Ingress Controller in a cluster</b></summary>

* Add ingress-nginx repo to helm
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
"ingress-nginx" has been added to your repositories

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm search repo ingress
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/nginx-ingress-controller        12.0.7          1.13.1          NGINX Ingress Controller is an Ingress controll...
ingress-nginx/ingress-nginx             4.15.1          1.15.1          Ingress controller for Kubernetes using NGINX a...
bitnami/contour                         21.1.4          1.32.1          Contour is an open source Kubernetes ingress co...
bitnami/apisix                          6.0.0           3.13.0          Apache APISIX is high-performance, real-time AP...
bitnami/contour-operator                4.2.1           1.24.0          DEPRECATED The Contour Operator extends the Kub...
bitnami/envoy-gateway                   2.0.4           1.5.0           Envoy Gateway simplifies traffic management by ...
bitnami/kong                            15.4.22         3.9.1           Kong is an open source Microservice API gateway...
```
* Install Ingress controller
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true
NAME: nginx-ingress
LAST DEPLOYED: Wed May 27 12:08:03 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the load balancer IP to be available.
You can watch the status by running 'kubectl get service --namespace default nginx-ingress-ingress-nginx-controller --output wide --watch'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```
* Verify that Ingress controller is deployed
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get pod
NAME                                                      READY   STATUS    RESTARTS   AGE
mongo-express-fd8bc9dcf-zm8t8                             1/1     Running   0          32m
mongodb-0                                                 1/1     Running   0          146m
mongodb-1                                                 1/1     Running   0          146m
mongodb-2                                                 1/1     Running   0          144m
mongodb-arbiter-0                                         1/1     Running   0          146m
nginx-ingress-ingress-nginx-controller-6fc4c9ff49-n88hd   1/1     Running   0          3m7s
```
</details> 

<details>
<summary><b>Create Ingress rules</b></summary>

* NodeBalancer - public entrypoint to the cluster

![NodeBalancer](images/node-balancer.png)

* Determine an entrypoint of the cluster
![MyNodeBalancer](images/my-nodebalancer.png)

IP: 172.105.1.237

* Inspect services
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get svc
NAME                                               TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
kubernetes                                         ClusterIP      10.128.0.1       <none>          443/TCP                      23h
mongo-express-service                              ClusterIP      10.128.165.147   <none>          8081/TCP                     148m
mongodb-arbiter-headless                           ClusterIP      None             <none>          27017/TCP                    4h21m
mongodb-headless                                   ClusterIP      None             <none>          27017/TCP                    4h21m
nginx-ingress-ingress-nginx-controller             LoadBalancer   10.128.53.208    172.105.1.237   80:32685/TCP,443:30346/TCP   118m
nginx-ingress-ingress-nginx-controller-admission   ClusterIP      10.128.214.222   <none>          443/TCP                      118m
```

* Get host DNS name

![NodeBalancer-DNS](images/host-dns-name.png)

DNS name: 172-105-1-237.ip.linodeusercontent.com

* Create Ingress rule:

Ingress file:

* Apply Ingress rule to the cluster
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl apply -f .\helm-ingress.yaml
ingress.networking.k8s.io/mongo-express created

PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get ingress
NAME            CLASS           HOSTS                                    ADDRESS   PORTS   AGE
mongo-express   nginx-ingress   172-105-1-237.ip.linodeusercontent.com             80      16s
```
* Access "172-105-1-237.ip.linodeusercontent.com" from the browser

error: 404 Not Found
</details> 