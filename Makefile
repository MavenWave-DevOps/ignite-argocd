MKFILEPATH = $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILEDIR = $(dir ${MKFILEPATH})
WORKDIR = ${MKFILEDIR}.work
KIND = ${WORKDIR}/kind
HELM = ${WORKDIR}/helm
KUSTOMIZE = ${WORKDIR}/kustomize
KUBECTL = ${WORKDIR}/kubectl
ARGOCDCLI = ${WORKDIR}/argocd
ARGOCD_HOST = localhost
GIT_URL := https://github.com/MavenWave-DevOps/ignite-argocd.git
REVISION := HEAD

UNAME_S := $(shell uname -s)
UNAME_P := $(shell uname -p)

ifeq ($(UNAME_S),Darwin)
	ifneq ($(filter %86,$(UNAME_P)),)
  	KIND_DOWNLOAD := curl -Lo ${KIND} https://kind.sigs.k8s.io/dl/v0.14.0/kind-darwin-amd64
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-darwin-amd64.tar.gz
		HELM_ARCH := ${WORKDIR}/darwin-amd64
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_darwin_amd64.tar.gz
		KUBECTL_DOWNLOAD := curl -Lo ${WORKDIR}/kubectl "https://storage.googleapis.com/kubernetes-release/release/$$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
		ARGOCDCLI_DOWNLOAD := curl -Lo ${WORKDIR}/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.11/argocd-darwin-amd64
  endif
  ifneq ($(filter arm%,$(UNAME_P)),)
  	KIND_DOWNLOAD := curl -Lo ${KIND} https://kind.sigs.k8s.io/dl/v0.14.0/kind-darwin-arm64
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-darwin-arm64.tar.gz
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_darwin_arm64.tar.gz
		KUBECTL_DOWNLOAD := curl -Lo ${WORKDIR}/kubectl "https://storage.googleapis.com/kubernetes-release/release/$$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/arm64/kubectl"
		ARGOCDCLI_DOWNLOAD := curl -Lo ${WORKDIR}/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.11/argocd-darwin-arm64
  endif
endif
ifeq ($(UNAME_S),Linux)
	ifneq ($(filter %86,$(UNAME_P)),)
		KIND_DOWNLOAD := curl -Lo ${KIND} https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-linux-amd64.tar.gz
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz
		KUBECTL_DOWNLOAD := curl -Lo ${WORKDIR}/kubectl "https://storage.googleapis.com/kubernetes-release/release/$$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
		ARGOCDCLI_DOWNLOAD := curl -Lo ${WORKDIR}/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.11/argocd-linux-amd64
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-linux-arm64.tar.gz
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_arm64.tar.gz
		ARGOCDCLI_DOWNLOAD := curl -Lo ${WORKDIR}/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.11/argocd-linux-arm64
	endif
endif

export KUBECONFIG=${MKFILEDIR}kubeconfig

.PHONY: help directories package

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


help: ## Show this help message.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
					helpMessage = match(lastLine, /^## (.*)/); \
					if (helpMessage) { \
									helpCommand = substr($$1, 0, index($$1, ":")-1); \
									helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
									printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
					} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

workdir:
	@mkdir -p ${WORKDIR}

install-kind: workdir
ifneq ($(wildcard ${KIND}), ${KIND})
	$(KIND_DOWNLOAD) ;\
	chmod +x ${KIND}
endif

install-helm: workdir
ifneq ($(wildcard ${HELM}), ${HELM})
	$(HELM_DOWNLOAD) ;\
	tar -zxvf ${WORKDIR}/helm.tar.gz -C ${WORKDIR} ;\
	mv ${HELM_ARCH}/helm ${WORKDIR} ;\
	rm -Rf ${HELM_ARCH} ;\
	rm ${WORKDIR}/helm.tar.gz
endif

install-kustomize: workdir
ifneq ($(wildcard ${KUSTOMIZE}), ${KUSTOMIZE})
	$(KUSTOMIZE_DOWNLOAD) ;\
	tar -zxvf ${WORKDIR}/kustomize.tar.gz -C ${WORKDIR} ;\
	rm ${WORKDIR}/kustomize.tar.gz
endif

install-kubectl: workdir
ifneq ($(wildcard ${KUBECTL}), ${KUBECTL})
	$(KUBECTL_DOWNLOAD) ;\
	chmod +x ${KUBECTL}
endif

install-argocdcli: workdir
ifneq ($(wildcard ${ARGOCDCLI}), ${ARGOCDCLI})
	$(ARGOCDCLI_DOWNLOAD) ;\
	chmod +x ${ARGOCDCLI}
endif

## Create Kind cluster
create-cluster: install-kind
	${KIND} create cluster --name ignite-argocd --config=${MKFILEDIR}kind/config.yaml --kubeconfig=${MKFILEDIR}kubeconfig || true

## Delete Kind cluster
delete-cluster: install-kind
	${KIND} delete cluster --name ignite-argocd

## Install Argocd
install-argocd: install-helm
	${HELM} repo add argo https://argoproj.github.io/argo-helm || true
	${HELM} -n argocd upgrade --install --create-namespace argocd argo/argo-cd -f argocd/helm/values.yaml --wait

## ArgoCD port-forward
port-forward: install-kubectl
	@${KUBECTL} port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 || true &
	@echo "ArgoCD is listening on https://localhost:8080"

## Login to ArgoCD cli
argocd-login: install-argocdcli port-forward
	${ARGOCDCLI} login --core --config ${WORKDIR}/.argocd/config ${ARGOCD_HOST}:8080 ;\
	kubectl config set-context --current --namespace=argocd

## Install initial ArgoCD app
argocd-app: argocd-login
	${ARGOCDCLI} --core --config ${WORKDIR}/.argocd/config app create apps --repo ${GIT_URL} --path apps --revision ${REVISION} --dest-namespace argocd --dest-server https://kubernetes.default.svc  --sync-policy automated --helm-set repoURL=${GIT_URL} --upsert --validate=false

## Get ArgoCD admin password
get-password:
	@echo "Login with admin/$(shell ${KUBECTL} -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)"

## Create ArgoCD environment
create: create-cluster install-argocd argocd-app

## Clean ArgoCD environment
clean: delete-cluster
	rm -Rf ${WORKDIR}