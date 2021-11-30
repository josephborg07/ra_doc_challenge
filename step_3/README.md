# Kubernetes and minikube for the metric app

## Pre-requisistes
- Minikube
- kubectl cli 

## File structure
````
├── README.md
├── api/
├── be-deployment.yml
├── dockerfile-build-be
├── dockerfile-build-fe
├── fe-deployment.yml
├── ingress.yml
├── nginx_config/
└── sys-stats/
````

# Overview
In this step we will be achieving what we did in step 1, just using the abstraction benefits provided by kubernetes. Components:
## Pods
At their very core, a pod is a docker container and supports secrets, volumes and configuration for containers.

## Replica set
A replica set is spawned by every deployment to ensure the deployment always maintains the specified number pods.

##  Deployment
A deployment is an abstraction layer which handles the application deployed and ensure it's continuosly available. It allows us to update the configuration without anydowntime 

## Service
A service is what exposes the app running at the deployment level internall to the rest of the kubernetes cluster

## Ingest
An ingest is what allows us to expose the application outside of the cluster; It simple exposes an endpoint and simply routes requests meeting the ingest's conditions to the specified service in the rule.

## Steps


### 1. Start minikube (in our case we've used the hyperv driver)
    
Ensure minikube is running; In our case we use minikube's hyperv driver; on windows using hyper-v daemon:

`minikube start --driver=hyperv`
### 2. Build docker images

First thing to do is create the docker images. We need to ensure that the images are pulled locally as opposed to remotely. On windows it can be achieved by executing the following:
    
1. executing `minikube docker-env`    
2. executing the last command  which should look simialar to: `@FOR /f "tokens=*" %i IN ('minikube -p minikube docker-env') DO @%i`

The above will make ensure that docker uses minikube's docker daemon rather than the host's

The FE image responds with a file (upon request from the browser) that fetches the content from the backend app's ingress (be-ingress.io). Below are the build commands:

`docker build -t devopschallenge_fe_app_k8s -f dockerfile-build-fe .`
`docker build -t devopschallenge_be_app_k8s -f dockerfile-build-be .`

### 3. Deploy both FE and BE applications and their relevant services

Deploy both FE and BE apps and their services by running `kubectl apply -f fe-deployment.yml` and `kubectl apply -f be-deployment.yml`. Both files create the deployments (and it's pods) and services to expose the deployment (and it's pods) internally for kubernetes.
### 4. Create the ingress to access both sites on
To do this you can simple apply the ingress config as we did above; `kubectl apply -f ingress.yml`

The ingress creates 2 configs:
- FE Ingress: uses host fe-ingress.io and routes traffic to the `fe-service` service on port 80
- BE Ingress: Uses host be-ingress.io and routes traffice to the `be-service` service on port 5000 and adding the `/stats` path to incomign request.
### 5. Add the hosts file entry

Since we've exposed the fe-ingress.io and be-ingress.io host names, we'll need to add those entries to the local hosts for translation; we'll need to point them to the cluster's IP. To obtain this simple execute `minikube ip`. You can then proceed to hitting both endpoints.

