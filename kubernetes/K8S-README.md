# JHipster-generated Kubernetes configuration

## Preparation

You will need to push your image to a registry. If you have not done so, use the following commands to tag and push the images:

```
$ docker image tag deploygo lokeshkarakala/deploygo
$ docker push lokeshkarakala/deploygo
```

## Deployment

You can deploy all your apps by running the below bash command:

```
./kubectl-apply.sh -f (default option)  [or] ./kubectl-apply.sh -k (kustomize option) [or] ./kubectl-apply.sh -s (skaffold run)
```

If you want to apply kustomize manifest directly using kubectl, then run

```
kubectl apply -k ./
```

If you want to deploy using skaffold binary, then run

```
skaffold run [or] skaffold deploy
```

## Endpoints

Please find the below useful endpoints

Gateway - http://minikube_ip_placeholder:30003

Grafana - http://grafana.istio-system.shopt.gq

Kiali - http://kiali.istio-system.shopt.gq

Keycloak - http://minikube_ip_placeholder:30001/

Elasticsearch - https://minikube_ip_placeholder:30221/

Kibana - https://minikube_ip_placeholder:31810/

## Destroy

You can delete all your apps by running the below bash command:

```
./kubectl-delete.sh -f (default option)  [or] ./kubectl-apply.sh -k (kustomize option)
```

If you want to delete kustomize manifest directly using kubectl, then run

```
kubectl delete -k ./
```

## Exploring your services

```

## Scaling your deployments

You can scale your apps using:

```

kubectl scale deployment <app-name> --replicas <replica-count> -n go

```

## Zero-downtime deployments

The default way to update a running app in kubernetes, is to deploy a new image tag to your docker registry and then deploy it using:

```

kubectl set image deployment/<app-name>-app <app-name>=<new-image> -n go

```

Using livenessProbes and readinessProbe allow you to tell Kubernetes about the state of your applications, in order to ensure availability of your services. You will need a minimum of two replicas for every application deployment if you want to have zero-downtime.
This is because the rolling upgrade strategy first stops a running replica in order to place a new. Running only one replica, will cause a short downtime during upgrades.



## Keycloak

Keycloak deployment in production mode requires the installation of [cert-manager](https://cert-manager.io/docs/installation/) Kubernetes add-on for the TLS certificate generation.

```

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.1/cert-manager.yaml

```

The certificate will be issued automatically by Let's Encrypt staging environment. You must set your email address in the issuer definition in `cert-manager/letsencrypt-staging-issuer.yml`.

Keycloak ingress is defined with the application ingress, and requires a static IP with the name specified in the ingress annotation `kubernetes.io/ingress.global-static-ip-name`.

You can create a global public IP with `gcloud` before running `jhipster k8s` with the following command:

```

gcloud compute addresses create <ip-name> --global

```

You can find out the assigned IP address using:

```

gcloud compute addresses describe <ip-name> --global --format='value(address)'

```

When running the `jhipster k8s` generator, it will prompt for a root FQDN (fully qualified domain name). You can use `nip.io` as the DNS provider and set `<ip-address>.nip.io`.

It might take up to 15 minutes for the Let's Encrypt certificates to be issued. Use the following command to check the status:

```

kubectl describe certificate keycloak-ssl -n go

````

You need to look for the following two events to determine success:

```text
Events:
  Type    Reason     Age   From                                       Message
  ----    ------     ----  ----                                       -------
  ...
  Normal  Issuing    10m   cert-manager-certificates-issuing          Issued temporary certificate
  Normal  Issuing    4m    cert-manager-certificates-issuing          The certificate has been successfully issued
````

cert-manager first creates a temporary certificate. Once you see the event "The certificate has been successfully issued", it means Let's Encrypt staging has issued the certificate. The staging certificate will be trusted by deployed applications, but not by browsers. Let's Encrypt production certificates are trusted by browsers, but the production issuer will probably not work with nip.io, and fail with "too many certificates already issued for nip.io".

## Troubleshooting

> my app doesn't get pulled, because of 'imagePullBackof'

Check the docker registry your Kubernetes cluster is accessing. If you are using a private registry, you should add it to your namespace by `kubectl create secret docker-registry` (check the [docs](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/) for more info)

> my applications are stopped, before they can boot up

This can occur if your cluster has low resource (e.g. Minikube). Increase the `initialDelaySeconds` value of livenessProbe of your deployments

> my applications are starting very slow, despite I have a cluster with many resources

The default setting are optimized for middle-scale clusters. You are free to increase the JAVA_OPTS environment variable, and resource requests and limits to improve the performance. Be careful!

> my applications don't start, because of 'Remote host terminated the handshake' or 'PKIX path building failed'

The k8s sub-generator configures Let's Encrypt staging environment, which is not trusted by browsers and Java applications by default. In the Kubernetes descriptors, the staging CAs are added to the applications truststore and registry truststore. Note that cert-manager issues a temporary certificate first, but the applications and registry don't trust the ad-hoc CA, and will fail the startup until the Let's Encrypt certificate is ready and updated in the ingress service. You will see the application pod STATUS as Error and CrashLoopBackOff during the multiple startup attempts. You can check the certificate status with the following command:

```
kubectl describe certificate keycloak-ssl  -n go
```
