# Setup local machine for testing

Setup local machine with kind cluster and automation settings

## Description

The propose project is create a simple environment for testing

* [Link](https://kubernetes.io/docs/reference/networking/ports-and-protocols/) Kubernetes ports and protocol

### K8s

* Cluster with control-plane and nodes

## Getting Started

### Dependencies

* kubectl.
* Docker

### Installing

* [Link](https://gist.github.com/guilhermelinhares/c06853c0565c1b02f4c98b1c209e13a4) Install Kubectl
* [Link](https://gist.github.com/guilhermelinhares/9a6fac8b02569fa174e17a3e1de834e3) Install docker
* [Link](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) Install Kind

* [Link](https://metallb.universe.tf/installation/) Install MetalLB - For LoadBalancer

### Executing K8s

* Create Multi-node clusters provisioning

```
kind create cluster --name k8s-lab --config kind-multiclusters.yaml
```

* Create Control-plane HA provisioning

```
kind create cluster --name k8s-lab --config kind-hacontrolplane.yaml
```

* Check cluster

```
kind get clusters                                                 
```

* Check nodes

```
kubectl get nodes
```

* Destroy cluster

```
kind delete cluster --name k8s-lab
```

### Ingress Nginx

* To install Nginx Controller, apply the manifest:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

* Now the Ingress is all setup. Wait until is ready to process requests running:

```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

* Create a example service with nginx ingress

The following example creates simple http-echo services and an Ingress object to route to these services.

```
kubectl create -f nginx-ingress-example.yaml
```
Now verify that the ingress works

```
# should output "foo-app"
curl localhost/foo/hostname
# should output "bar-app"
curl localhost/bar/hostname
```


#### Extras Ingress Nginx

* Fix error

"error when creating "nginx-ingress.yaml": Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": failed to call webhook: Post "https://ingress-nginx-controller-admission.ingress-nginx.svc:443/networking/v1/ingresses?timeout=10s": dial tcp 10.96.8.5:443: connect: connection refused"
```
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
```

### LoadBalancer
Process to install and configure the load balancer with MetalLB

* To install MetalLB, apply the manifest:

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
```

* Wait until the MetalLB pods (controller and speakers) are ready:

```
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=90s
``` 

* Setup address pool used by loadbalancers

Get the address pool

```
docker network inspect -f '{{.IPAM.Config}}' kind
```

Whith the following command before you get the address pool configuration, put in the configuration file metallb-config.yaml in the next line:

```
spec:
  addresses:
  - 172.18.255.200-172.18.255.250
```
When you change the address pool configuration in the configuration file, you should run this command

```
kubectl apply -f metallb-config.yaml
```

* Using LoadBalancer

* Creates a loadbalancer service that routes to two http-echo pods, one that outputs foo and the other outputs bar.

```
kubectl apply -f metallb-pod-loadbalancer.yaml
```