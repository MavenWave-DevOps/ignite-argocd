MKFILEPATH = $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILEDIR = $(dir ${MKFILEPATH})
WORKDIR = ${MKFILEDIR}.work
KIND = ${WORKDIR}/kind
HELM = ${WORKDIR}/helm
KUSTOMIZE = ${WORKDIR}/kustomize
KUBECTL = ${WORKDIR}/kubectl
ARGOCD_HOST = localhost

UNAME_S := $(shell uname -s)
UNAME_P := $(shell uname -p)

ifeq ($(UNAME_S),Darwin)
	ifneq ($(filter %86,$(UNAME_P)),)
  	KIND_DOWNLOAD := curl -Lo ${KIND} https://kind.sigs.k8s.io/dl/v0.14.0/kind-darwin-amd64
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-darwin-amd64.tar.gz
		HELM_ARCH := ${WORKDIR}/darwin-amd64
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_darwin_amd64.tar.gz
		KUBECTL_DOWNLOAD := curl -Lo ${WORKDIR}/kubectl "https://storage.googleapis.com/kubernetes-release/release/$$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl"
  endif
  ifneq ($(filter arm%,$(UNAME_P)),)
  	KIND_DOWNLOAD := curl -Lo ${KIND} https://kind.sigs.k8s.io/dl/v0.14.0/kind-darwin-arm64
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-darwin-arm64.tar.gz
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_darwin_arm64.tar.gz
		KUBECTL_DOWNLOAD := curl -Lo ${WORKDIR}/kubectl "https://storage.googleapis.com/kubernetes-release/release/$$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/arm64/kubectl"
  endif
endif
ifeq ($(UNAME_S),Linux)
	ifneq ($(filter %86,$(UNAME_P)),)
		KIND_DOWNLOAD := curl -Lo ${KIND} https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-linux-amd64.tar.gz
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_amd64.tar.gz
		KUBECTL_DOWNLOAD := curl -Lo ${WORKDIR}/kubectl "https://storage.googleapis.com/kubernetes-release/release/$$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
	endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		HELM_DOWNLOAD := curl -Lo ${WORKDIR}/helm.tar.gz https://get.helm.sh/helm-v3.9.4-linux-arm64.tar.gz
		KUSTOMIZE_DOWNLOAD := curl -Lo ${WORKDIR}/kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_arm64.tar.gz
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

## Create Kind cluster
create-cluster: install-kind
	${KIND} create cluster --name ignite-argocd --config=${MKFILEDIR}kind/config.yaml --kubeconfig=${MKFILEDIR}kubeconfig || true

## Delete Kind cluster
delete-cluster: install-kind
	${KIND} delete cluster --name ignite-argocd

## Install ingress-nginx onto Kind cluster
install-ingress-nginx: install-kustomize install-kubectl
	${KUSTOMIZE} build ingress-nginx/dev | ${KUBECTL} apply -f -

## Install Argocd
install-argocd: install-helm
	${HELM} repo add argo https://argoproj.github.io/argo-helm || true
	${HELM} -n argocd upgrade --install --create-namespace argocd argo/argo-cd -f argocd/helm/values.yaml --set server.config.url=${ARGOCD_HOST} --set server.ingress.hosts[0]=${ARGOCD_HOST} --wait

## Create ArgoCD environment
create: create-cluster install-argocd install-ingress-nginx

## Clean ArgoCD environment
clean: delete-cluster
	rm -Rf ${WORKDIR}