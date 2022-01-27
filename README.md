# ArgoCD Getting Started

## Requirements
* A local Kubernetes cluster (Some examples below)
  * [K3D](https://k3d.io/v5.2.2/)
  * [Rancher Desktop](https://rancherdesktop.io/)
  * [Minikube](https://minikube.sigs.k8s.io/docs/start/)
* [Helm](https://helm.sh/docs/intro/install/)
* [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

## Initial Setup
Perform the following steps to setup ArgoCD on your local Kubernetes cluster.

**BE SURE THAT YOUR `kubctl` CONTEXT IS POINTING TO YOUR LOCAL CLUSTER**

## Install

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm -n argocd upgrade --install --create-namespace argocd argo/argo-cd -f argocd/helm/values.yaml
```

## Setup
In a separate teminal run the following.
```sh
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Retrieve the current admin password
```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Login to ArgoCD with the cli
```sh
argocd login localhost:8080
```
Answer yes to Proceed insecurely and use `admin` for the username and the value form the preious step as the password.

Change the ArgoCD admin password.
```sh
argocd account update-password
```

Create the inital ArgoCD application (App of Apps pattern)
```sh
argocd app create apps --repo <this repo url> --path apps --dest-namespace argocd --dest-server https://kubernetes.default.svc  --sync-policy automated
```