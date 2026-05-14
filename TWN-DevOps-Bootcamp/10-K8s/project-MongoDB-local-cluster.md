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

* Starting point - empty cluster, only default service is running
```
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   24h
```  
* Write a config file for MongoDB

File: mongo.yaml

</details>