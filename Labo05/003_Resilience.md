# Task 3 - Add and exercise resilience

By now you should have understood the general principle of configuring, running and accessing applications in Kubernetes. However, the above application has no support for resilience. If a container (resp. Pod) dies, it stops working. Next, we add some resilience to the application.

## Subtask 3.1 - Add Deployments

In this task you will create Deployments that will spawn Replica Sets as health-management components.

Converting a Pod to be managed by a Deployment is quite simple.

  * Have a look at an example of a Deployment described here: <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>

  * Create Deployment versions of your application configurations (e.g. `redis-deploy.yaml` instead of `redis-pod.yaml`) and modify/extend them to contain the required Deployment parameters.

  * Again, be careful with the YAML indentation!

  * Make sure to have always 2 instances of the API and Frontend running. 

  * Use only 1 instance for the Redis-Server. Why?

    > Else if we need to replicate our data between the different redis servers.

  * Delete all application Pods (using `kubectl delete pod ...`) and replace them with deployment versions.

  * Verify that the application is still working and the Replica Sets are in place. (`kubectl get all`, `kubectl get pods`, `kubectl describe ...`)

## Subtask 3.2 - Verify the functionality of the Replica Sets

In this subtask you will intentionally kill (delete) Pods and verify that the application keeps working and the Replica Set is doing its task.

Hint: You can monitor the status of a resource by adding the `--watch` option to the `get` command. To watch a single resource:

```sh
$ kubectl get <resource-name> --watch
```

To watch all resources of a certain type, for example all Pods:

```sh
$ kubectl get pods --watch
```

You may also use `kubectl get all` repeatedly to see a list of all resources.  You should also verify if the application stays available by continuously reloading your browser window.

  * What happens if you delete a Frontend or API Pod? How long does it take for the system to react?
    > The pod is marked as deleted in the cluster. Then a new pod is created automaticaly and it is assigned directly to the service.
    > The time it takes to recreate a Pod depends on multiple things, for example : the image size, startup time (certain application can take
    > longer to start up than others), pod scheduling (if the cluster is loaded, it will take more time) and pesitant storage (detach
    > the volume from the old pod and to attache it to the new pod).
    
  * What happens when you delete the Redis Pod?

    > All todo task have disappeared and we cannot create a new one for several seconds.
    
  * How can you change the number of instances temporarily to 3? Hint: look for scaling in the deployment documentation

    > We can modify the yaml file or we can run the following command
    ```
    kubectl scale deployment/frontend-deploy --replicas=3
    ```
  * What autoscaling features are available? Which metrics are used?

    > In Kubernetes, we can use autoscaling in two different ways HorizontalPodAutoscaler (HPA) or VerticalPodAutoscaler (VPA).
    > The HPA allow you to increase or decrease the number of replicas according to different metrics such as CPU or memory usage.
    > In comparision, The VPA allow you to scale the resources of the managed replicas, it utilizes historical data on CPU and memory usage to 
    > adjust the CPU and memory requests of the Pods.
 
    
  * How can you update a component? (see "Updating a Deployment" in the deployment documentation)

    > Update the deployment yaml file and run the `kubetctl apply` command.
    ```
    kubectl apply -f frontend-deploy.yaml
    ```

## Subtask 3.3 - Put autoscaling in place and load-test it

On the GKE cluster deploy autoscaling on the Frontend with a target CPU utilization of 30% and number of replicas between 1 and 4. 

> The HPA configuration file is available on this [file](./files/frontend-autoscaler.yaml).

Load-test using Vegeta (500 requests should be enough).

```
$ echo "GET http://34.65.8.43/" | vegeta attack -duration=1m -rate=500 | vegeta report --type=text       

Requests      [total, rate, throughput]         30000, 500.02, 329.97
Duration      [total, attack, wait]             1m30s, 59.998s, 29.992s
Latencies     [min, mean, 50, 90, 95, 99, max]  14.377ms, 1.285s, 20.812ms, 4.007s, 6.17s, 23.875s, 30.005s
Bytes In      [total, mean]                     18736914, 624.56
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           98.98%
Status Codes  [code:count]                      0:306  200:29694  
Error Set:
Get "http://34.65.8.43/": context deadline exceeded (Client.Timeout exceeded while awaiting headers)

```

> [!NOTE]
>
> - The autoscale may take a while to trigger.
>
> - If your autoscaling fails to get the cpu utilization metrics, run the following command
>
>   - ```sh
>     $ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
>     ```
>
>   - Then add the *resources* part in the *container part* in your `frontend-deploy` :
>
>   - ```yaml
>     spec:
>       containers:
>         - ...:
>           env:
>             - ...:
>           resources:
>             requests:
>               cpu: 10m
>     ```
>

## Deliverables

Document your observations in the lab report. Document any difficulties you faced and how you overcame them. Copy the object descriptions into the lab report.

> I had to configure the resources part in the frontend-deploy.yaml.

```````sh
# Others objects did not change from the previous task.
# I have listed the ones that have created.

# Object : deployment/frontend-deploy

$ kubectl describe deployment/frontend-deploy

Name:                   frontend-deploy
Namespace:              default
CreationTimestamp:      Wed, 15 May 2024 14:16:30 +0200
Labels:                 app=todo
                        component=frontend
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=todo,component=frontend
Replicas:               4 desired | 4 updated | 4 total | 2 available | 2 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=todo
           component=frontend
  Containers:
   frontend:
    Image:      icclabcna/ccp2-k8s-todo-frontend
    Port:       8080/TCP
    Host Port:  0/TCP
    Requests:
      cpu:  10m
    Environment:
      API_ENDPOINT_URL:  http://api-svc:8081
    Mounts:              <none>
  Volumes:               <none>
  Node-Selectors:        <none>
  Tolerations:           <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  frontend-deploy-67879ff5df (0/0 replicas created)
NewReplicaSet:   frontend-deploy-859d5f8544 (4/4 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  21m   deployment-controller  Scaled up replica set frontend-deploy-67879ff5df to 2
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled up replica set frontend-deploy-859d5f8544 to 1
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled down replica set frontend-deploy-67879ff5df to 1 from 2
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled up replica set frontend-deploy-859d5f8544 to 2 from 1
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled down replica set frontend-deploy-67879ff5df to 0 from 1
  Normal  ScalingReplicaSet  11m   deployment-controller  Scaled up replica set frontend-deploy-859d5f8544 to 4 from 2


# Object : deployment/api-deploy

$ kubectl describe deployment/api-deploy

Name:                   api-deploy
Namespace:              default
CreationTimestamp:      Wed, 15 May 2024 14:16:36 +0200
Labels:                 app=todo
                        component=api
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=todo,component=api
Replicas:               2 desired | 2 updated | 2 total | 1 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=todo
           component=api
  Containers:
   api:
    Image:      icclabcna/ccp2-k8s-todo-api
    Port:       8081/TCP
    Host Port:  0/TCP
    Environment:
      REDIS_ENDPOINT:  redis-svc
      REDIS_PWD:       ccp2
    Mounts:            <none>
  Volumes:             <none>
  Node-Selectors:      <none>
  Tolerations:         <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  <none>
NewReplicaSet:   api-deploy-664fbdf7d9 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  19m   deployment-controller  Scaled up replica set api-deploy-664fbdf7d9 to 2


# Object : deployment/redis-deploy

$ kubectl describe deployment/redis-deploy

Name:                   redis-deploy
Namespace:              default
CreationTimestamp:      Wed, 15 May 2024 14:16:40 +0200
Labels:                 app=todo
                        component=redis
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=todo,component=redis
Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=todo
           component=redis
  Containers:
   redis:
    Image:      redis
    Port:       6379/TCP
    Host Port:  0/TCP
    Args:
      redis-server
      --requirepass ccp2
      --appendonly yes
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      False   MinimumReplicasUnavailable
OldReplicaSets:  <none>
NewReplicaSet:   redis-deploy-56fb88dd96 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  20m   deployment-controller  Scaled up replica set redis-deploy-56fb88dd96 to 1

```````

```yaml
# redis-deploy.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deploy
  labels:
    component: redis
    app: todo
spec:
  replicas: 1
  selector:
    matchLabels:
      component: redis
      app: todo
  template:
    metadata:
      labels:
        component: redis
        app: todo
    spec:
      containers:
        - name: redis
          image: redis
          ports:
            - containerPort: 6379
          args:
            - redis-server 
            - --requirepass ccp2 
            - --appendonly yes

```

```yaml
# api-deploy.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-deploy
  labels:
    component: api
    app: todo
spec:
  replicas: 2
  selector:
    matchLabels:
      component: api
      app: todo
  template:
    metadata:
      labels:
        component: api
        app: todo
    spec:
      containers:
      - name: api
        image: icclabcna/ccp2-k8s-todo-api
        ports:
        - containerPort: 8081
        env:
        - name: REDIS_ENDPOINT
          value: redis-svc
        - name: REDIS_PWD
          value: ccp2
```

```yaml
# frontend-deploy.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deploy
  labels:
    component: frontend
    app: todo
spec:
  replicas: 2
  selector:
    matchLabels:
      component: frontend
      app: todo
  template:
    metadata:
      labels:
        component: frontend
        app: todo
    spec:
      containers:
      - name: frontend
        image: icclabcna/ccp2-k8s-todo-frontend
        ports:
        - containerPort: 8080
        env:
        - name: API_ENDPOINT_URL
          value: http://api-svc:8081
        resources:
          requests:
            cpu: 10m
```
