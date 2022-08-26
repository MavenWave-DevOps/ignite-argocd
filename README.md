# ArgoCD Getting Started

## Requirements
* Docker
  * [Rancher Desktop](https://rancherdesktop.io/)

## Getting Started
```sh
make create
```
or if wanting to use a different source Git repo and/or Git branch.
```sh
make create GIT_URL=<git HTTP url> REVISION=<Git branch>
```

**BE SURE THAT YOUR `kubectl` CONTEXT IS POINTING TO YOUR LOCAL CLUSTER**
```sh
export KUBECONFIG=$PWD/kubeconfig
kubectl config current-context
```
Should return `kind-ignite-argocd`

## Local Development
Set port-forward
```sh
make port-forward
```
Retrieve the login credentials
```sh
make get-password
```
Login to the ArgoCD UI with the information from the outputs above.

### Using a DIfferent Repo or Branch
```sh
make argocd-app GIT_URL=<Git HTTP url> REVISION=<Git branch>
```

## Cleanup
```sh
make clean
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

## CLI Logout
```sh
argocd logout localhost:8080
```