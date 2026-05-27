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
<summary><b>Deploy MOngoDB Statefullset in the cluster</b></summary>

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


</details> 