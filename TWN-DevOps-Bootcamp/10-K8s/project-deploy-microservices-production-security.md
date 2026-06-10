# Module 10 - Kubernetes
## Demo Project:
Deploy Microservices application in Kubernetes with Production & Security Best Practices
## Technologies used:
Kubernetes, Redis, Linux, Linode LKE
## Project Description:
Create K8s manifests for Deployments and Services for all microservices of an online shop application
Deploy microservices to Linode’s managed Kubernetes cluster

# Repo:
https://github.com/IrinaRoiter/microservices-demo


# Solution

<details>
<summary><b>Create K8s manifests for Deployments and Services for all microservices of an online shop application</b></summary>

![Microservices relationship graph](images/microservices-connection-graph.png)

K8s manifest for Deployments and Services - initial version
https://github.com/IrinaRoiter/DevOps/blob/375645958dece0e0ce06ae1fad2a19861ffbd2fe/TWN-DevOps-Bootcamp/10-K8s/config.yaml

</details> 

<details>
<summary><b>Create K8s manifests for Deployments and Services for all microservices of an online shop application</b></summary>

* Create a cluster on Linode
```
Linode->Kubernetes->Create Cluster
Cluster label: online-shop-microservices
Region: CA, Toronto (ca-central)
HA Control plane: No
Node Pools: Shared CPU, 3 nodes of 2 GB RAM, 1 CPU, 50 GB storage
Create Cluster
```
* Download online-shop-microservices-kubeconfig.yaml and connect to Cluster 
```
iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ chmod 400 ./online-shop-microservices-kubeconfig.yaml

iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ ls -l ./online-shop-microservices-kubeconfig.yaml
-r------- 1 iroiter iroiter 2825 Jun 10 13:33 ./online-shop-microservices-kubeconfig.yaml

iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ export KUBECONFIG=/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s/online-shop-microservices-kubeconfig.yaml

iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ printenv KUBECONFIG
/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s/online-shop-microservices-kubeconfig.yaml

iroiter@WINDOWS-CTBM1LI:/mnt/c/repos/DevOps/TWN-DevOps-Bootcamp/10-K8s$ kubectl get node
NAME                            STATUS   ROLES    AGE   VERSION
lke615508-902710-1650287a0000   Ready    <none>   54m   v1.35.3
lke615508-902710-5a3d36d40000   Ready    <none>   54m   v1.35.3
lke615508-902710-685514290000   Ready    <none>   54m   v1.35.3

```



</details>