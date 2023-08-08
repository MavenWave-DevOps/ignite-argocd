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

The following export command will change your kubeconfig file path to the kubeconfig file created after running make create. **Please note** this is permanent within the shell. To rerun this tutorial or work on something seperate, use a new shell or set the KUBECONFIG variable appropiately.
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
Should return `ArgoCD is listening on https://localhost:8080`

Retrieve the login credentials
```sh
make get-password
```
Should return something like `Login with admin/{password}`

### UI
Login to the ArgoCD URL at `https://localhost:8080/`. The default user name is admin and your password is obtained from the output above. Click on the 'SYNC APPS` button towards the top of the page to sync your cluster with the applications in this Git repo.


### Using a DIfferent Repo or Branch
```sh
make argocd-app GIT_URL=<Git HTTP url> REVISION=<Git branch>
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

## Access Applications
### Guestbook
http://guestbook-127.0.0.1.sslip.io:8000
### Wordpress
https://wordpress-127.0.0.1.sslip.io:4430
## Sync Apps

## Cleanup

This will delete the local cluster. Don't forget to close the shell to undo the change to the KUBECONFIG variable.

```sh
make clean
```

### CLI

The UI for argocd is what makes the application a great gitops tool. However, you can interact with it through the CLI.
```sh
argocd app sync -l argocd.argoproj.io/instance=apps
```

## CLI Logout
```sh
argocd logout localhost:8080
```
