# Module 10 - Kubernetes
## Demo Project:
Create Helm Chart for Microservices
## Technologies used:
Kubernetes, Helm
## Project Description:
Create 1 shared Helm Chart for all microservices, to reuse
common Deployment and Service configurations for the services

# Repo:

# Solution

<details>
<summary><b>Create a default helm chart</b></summary>

* Create a default Helm chart
```
PS C:\Repos\helm-chart-microservices> helm create microservice
Creating microservice
```
* Create deployment.yaml template

https://github.com/IrinaRoiter/helm-chart-microservices/blob/cdac2b956b96b50fa9e524a5ade5d690d21f5c14/microservice/templates/deployment.yaml

* Create services.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/cdac2b956b96b50fa9e524a5ade5d690d21f5c14/microservice/templates/service.yaml

* Create values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/cdac2b956b96b50fa9e524a5ade5d690d21f5c14/microservice/values.yaml

ℹ️ Values.yaml: </br>
- contains default values </br>
- combines variables for both deployment and services
- acts as a template for all microservices (deployments) and their respective services

</details>
<details>
<summary><b>Create final (top) YAML for each microservice containing specific values</b></summary>

* Email service

email-service-values.yaml
https://github.com/IrinaRoiter/helm-chart-microservices/blob/cdac2b956b96b50fa9e524a5ade5d690d21f5c14/email-service-values.yaml

* See final values for e-mail service
```
PS C:\Repos\helm-chart-microservices> helm template -f email-service-values.yaml microservice

ℹ️ 'microservice' - chart name (folder name that was created by 'helm create microservice' command)
Helm template engine renders all the resources (provided templates) and replaces the vars with actual values from 3 different sources as shown in output below.
The command also accepts setting values manually in addition to provided sources. Example: we defined 2 replicas per microservice. We can easly set replicas to 3 for e-mail service like this:
helm template -f email-service-values.yaml --set appReplicas 3 microservice 
---
# Source: microservice/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: emailservice
spec: 
  type: ClusterIP
  selector:
    app: emailservice
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 8080

---
# Source: microservice/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: emailservice
  labels:
    app: emailservice
spec:
  replicas: 2
  selector:
    matchLabels:
      app: emailservice
  template:
    metadata:
      labels:
        app: emailservice
    spec:
      containers:
      - name: emailservice
        imagePullPolicy: Always
        image: "gcr.io/google-samples/microservices-demo/emailservice:"
        ports:
        - containerPort: 8080
        env:
        - name: PORT
          value: "8080"
```  
* Validate  email-service-values.yaml     
```
PS C:\Repos\helm-chart-microservices> helm lint -f email-service-values.yaml microservice    
==> Linting microservice
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
``` 
* Install e-mail service helm chart in the cluster
```
🟡 Cluster is created on Linode platform and I am connected to it
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl get node
NAME                            STATUS   ROLES    AGE   VERSION
lke621765-911879-142a94f60000   Ready    <none>   16m   v1.35.3
lke621765-911879-3f5c62580000   Ready    <none>   17m   v1.35.3
lke621765-911879-5ea2000f0000   Ready    <none>   17m   v1.35.3

🟡 a namespace 'microservices' is added
PS C:\repos\DevOps\TWN-DevOps-Bootcamp\10-K8s> kubectl create ns microservices
namespace/microservices created

PS C:\repos\helm-chart-microservices> helm install -f .\email-service-values.yaml emailservice microservice --namespace microservices
NAME: emailservice
LAST DEPLOYED: Wed Jun 24 11:21:57 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

ℹ️ email-service-values.yaml - file that overwrite value in values.yaml
emailservice - release name
microservice - chart name

PS C:\repos\helm-chart-microservices> helm ls --namespace microservices
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
emailservice    microservices   1               2026-06-24 11:21:57.5375817 -0400 EDT   deployed        microservice-0.1.0      1.16.0

PS C:\repos\helm-chart-microservices> kubectl get pod
NAME                            READY   STATUS    RESTARTS   AGE
emailservice-5bfb757754-85z9g   1/1     Running   0          3m32s 👈🏻 Containers inside the pods are up and running
emailservice-5bfb757754-vj4dm   1/1     Running   0          3m32s
```
* Create final (top) YAML for other microservices except redis and save all of them under subfolder 'values'

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/ad-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/cart-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/checkout-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/currency-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/email-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/frontend-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/payment-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/productcatalog-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/recommendation-service-values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/f2606351bda92a151de213ef584cecac59d0eb9a/values/shipping-service-values.yaml

</details>
<details>
<summary><b>Create a separate helm chart for redis</b></summary>

* Create a folder 'charts' and move microservies chart there

* Create a new chart for redis under the folder 'charts'
```
PS C:\Repos\helm-chart-microservices\charts> helm create redis
Creating redis
```
* Prepare YAML manifests files of the chart

https://github.com/IrinaRoiter/helm-chart-microservices/blob/0380d4989c17231b0ee4ded650d840374539dd78/charts/redis/templates/deployment.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/0380d4989c17231b0ee4ded650d840374539dd78/charts/redis/templates/service.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/0380d4989c17231b0ee4ded650d840374539dd78/charts/redis/values.yaml

https://github.com/IrinaRoiter/helm-chart-microservices/blob/0380d4989c17231b0ee4ded650d840374539dd78/values/redis-values.yaml


* Validate redis chart
```
PS C:\Repos\helm-chart-microservices> helm template -f .\values\redis-values.yaml .\charts\redis 
---
# Source: redis/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-cart
spec:
  type: ClusterIP
  selector:
    app: redis-cart
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379

---
# Source: redis/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cart
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis-cart
  template:
    metadata:
      labels:
        app: redis-cart
    spec:
      containers:
      - name: redis-cart
        image: "redis:alpine"
        ports:
        - containerPort: 6379
        livenessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: 6379
          periodSeconds: 5
        readinessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: 6379
          periodSeconds: 5
        resources:
          requests:
            cpu: 70m
            memory: 200Mi
          limits:
            cpu: 125m
            memory: 300Mi
        volumeMounts:
        - name: redis-data
          mountPath:
      volumes:
      - name: redis-data
        emptyDir: {}
```

* Verify redis helm chart with dry-run option
```
PS C:\Repos\helm-chart-microservices> helm install --dry-run  -f .\values\redis-values.yaml redis-cart .\charts\redis

👉🏻 'redis-cart' - release name (appName)
--dry-run - preview mode, no actual install

level=WARN msg="--dry-run is deprecated and should be replaced with '--dry-run=client'"
NAME: redis-cart
LAST DEPLOYED: Thu Jun 25 14:08:52 2026
NAMESPACE: default
STATUS: pending-install
REVISION: 1
DESCRIPTION: Dry run complete
TEST SUITE: None
HOOKS:
MANIFEST:
---
# Source: redis/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-cart
spec:
  type: ClusterIP
  selector:
    app: redis-cart
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379

---
# Source: redis/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-cart
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis-cart
  template:
    metadata:
      labels:
        app: redis-cart
    spec:
      containers:
      - name: redis-cart
        image: "redis:alpine"
        ports:
        - containerPort: 6379
        livenessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: 6379
          periodSeconds: 5
        readinessProbe:
          initialDelaySeconds: 5
          tcpSocket:
            port: 6379
          periodSeconds: 5
        resources:
          requests:
            cpu: 70m
            memory: 200Mi
          limits:
            cpu: 125m
            memory: 300Mi
        volumeMounts:
        - name: redis-data
          mountPath:
      volumes:
      - name: redis-data
        emptyDir: {}
```
* Deploy everything with a script

https://github.com/IrinaRoiter/helm-chart-microservices/blob/84d6bf6497498d8be2626c8927414193352057df/install.ps1

```
PS C:\repos\helm-chart-microservices> .\install.ps1
NAME: redis-cart
LAST DEPLOYED: Thu Jun 25 14:59:46 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: emailservice
LAST DEPLOYED: Thu Jun 25 14:59:47 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: adservice
LAST DEPLOYED: Thu Jun 25 14:59:48 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: cartservice
LAST DEPLOYED: Thu Jun 25 14:59:49 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: checkoutservice
LAST DEPLOYED: Thu Jun 25 14:59:49 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: currencyservice
LAST DEPLOYED: Thu Jun 25 14:59:50 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: frontend
LAST DEPLOYED: Thu Jun 25 14:59:51 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: paymentservice
LAST DEPLOYED: Thu Jun 25 14:59:52 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: productcatalogservice
LAST DEPLOYED: Thu Jun 25 14:59:53 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: recommendationservice
LAST DEPLOYED: Thu Jun 25 14:59:54 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NAME: shippingservice
LAST DEPLOYED: Thu Jun 25 14:59:55 2026
NAMESPACE: microservices
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
PS C:\repos\helm-chart-microservices>
```

* Check pods
```
PS C:\repos\helm-chart-microservices> kubectl get pod
NAME                                     READY   STATUS    RESTARTS   AGE
adservice-6bc97f5c69-cgf7q               1/1     Running   0          71s
adservice-6bc97f5c69-qwb69               1/1     Running   0          71s
cartservice-6685ccbfd5-ls7nq             1/1     Running   0          70s
cartservice-6685ccbfd5-xr2hg             1/1     Running   0          70s
checkoutservice-5ddf6f97dd-qcbwd         1/1     Running   0          70s
checkoutservice-5ddf6f97dd-qkbzf         1/1     Running   0          70s
currencyservice-5f94f77bd9-bm6qd         1/1     Running   0          69s
currencyservice-5f94f77bd9-h2l5h         1/1     Running   0          69s
emailservice-5bfb757754-br4fq            1/1     Running   0          72s
emailservice-5bfb757754-zzqwg            1/1     Running   0          72s
frontend-774d5dddc7-2ltwn                1/1     Running   0          67s
frontend-774d5dddc7-sh4q6                1/1     Running   0          67s
paymentservice-dd989b544-pvp8b           1/1     Running   0          66s
paymentservice-dd989b544-pxwb5           1/1     Running   0          66s
productcatalogservice-6b99844786-2l4jl   1/1     Running   0          65s
productcatalogservice-6b99844786-x4j89   1/1     Running   0          65s
recommendationservice-747db4b555-99wng   1/1     Running   0          65s
recommendationservice-747db4b555-mjlz9   1/1     Running   0          65s
redis-cart-9795bb64c-9vpqs               1/1     Running   0          72s
redis-cart-9795bb64c-dwqd6               1/1     Running   0          72s
shippingservice-7b89dcc654-7brgd         1/1     Running   0          64s
shippingservice-7b89dcc654-pnbnx         1/1     Running   0          64s
```