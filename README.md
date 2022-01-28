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

## UI Tour
Once you are logged in the ArgoCD web UI you will see a page with several boxes. These boxes represent your Application

![ArgoCD Login](imgs/login.gif)

In this tutorial we are following the App of Apps pattern. With this pattern, an ArgoCD Application named `apps` is a manifest that points to a Helm chart that will generate more ArgoCD Application manifests.
**Note:** you do not have to use Helm to deploy your Kubernetes manifests; generic manifests and Kustomize are also supported.

![ArgoCD App of Apps](imgs/app-of-apps.gif)

The remaining Application blocks represent actual Helm charts or Kustomize manifests that deploy Kubernetes resources. Each Application will display the various Kubernetes resources that will be deployed into the cluster for that specific Application.

![ArgoCD Apps](imgs/app.gif)

Some detail on Kubernetes can be viewed in these Applications as well such as pod logs.

![ArgoCD Pod Logs](imgs/pod-logs.gif)

## Configure Applications
### Guestbook
Edit `guestbook/local/ingress-patches.yaml` to set the Guestbook ingress to match your local machine's IP address
```yaml
- op: replace
  path: /spec/rules/0/host
  value: guestbook-<your-ip-address>.sslip.io
```
### Wordpress
Edit `helm-values/wordpress/values.yaml` to set Wordpress ingress to match your local machine's IP address
```yaml
...
ingress:
  enabled: true
  hostname: wordpress-<your-ip-address>.sslip.io
...
```

## Sync Apps
### UI
Login to the ArgoCD URL at `https://localhost:8080/`. Use the credentials that were used form above to log into the CLI. Click on the 'SYNC APPS` button towards the top of the page to sync your cluster with the applications in this Git repo.
### CLI
```sh
argocd app sync -l argocd.argoproj.io/instance=apps
```