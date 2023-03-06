
### Extras Docker registry configuration localhost
<!-- https://stackoverflow.com/questions/68908099/kubernetes-image-from-local-registry -->
<!-- https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/ -->
<!-- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-secret-docker-registry-em- -->
<!-- https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account -->
First create a self-signed Certificate

```
mkdir -p certs
cd registry/certs
openssl genrsa 1024 > domain.key
chmod 400 domain.key
openssl req -new -x509 -nodes -sha1 -days 365 -key domain.key -out domain.crt -subj "/C=BR/ST=Ceara/L=Fortaleza/O=LHO/CN=LHO"
```
* Install packages
```
cd .. && mkdir auth
sudo apt-get install apache2-utils -y
htpasswd -Bbn username password > auth/htpasswd
```
* Create a registry container
docker run -d \
  --restart=always \
  --name registry \
  -v `pwd`/auth:/auth \
  -v `pwd`/certs:/certs \
  -v `pwd`/certs:/certs \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
  -p 5000:5000 \
  registry:2
 docker login -u username -p password localhost:5000
```
* Create a secret with secret generic registry 
cd registry/
PATH_CONFIG=~/.docker
kubectl create secret generic --dry-run=true regcred \
    --from-file=.dockerconfigjson=$PATH_CONFIG/config.json \
    --type=kubernetes.io/dockerconfigjson -o yaml >> registry.yaml
```
* Apply and get registry secret

```
kubectl apply -f registry.yaml
kubectl get secret regcred
```

* Create secret with docker-registry
cd registry/

```
kubectl create secret docker-registry myregistrykey --docker-server=localhost:5000 \
        --docker-username=username --docker-password=password \
        --docker-email=localhost@localhost -o yaml >> registry.yaml
```

* Verify it has been created.

```
kubectl get secrets myregistrykey
```
* Add image pull secret to service account 

```
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "myregistrykey"}]}'
```
Show if image pull secret is created

```
kubectl describe serviceaccount default
```
* Output
```
Name:                default
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  myregistrykey
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```