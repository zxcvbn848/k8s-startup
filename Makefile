.PHONY: help build-dev build-prod apply-dev apply-prod delete-dev delete-prod diff-dev diff-prod

KUBECTL ?= kubectl

help: ## 顯示可用指令
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

build-dev: ## 渲染 dev overlay 的 YAML 到 stdout
	$(KUBECTL) kustomize overlays/dev

build-prod: ## 渲染 prod overlay 的 YAML 到 stdout
	$(KUBECTL) kustomize overlays/prod

apply-dev: ## 部署 dev 環境
	$(KUBECTL) apply -k overlays/dev

apply-prod: ## 部署 prod 環境
	$(KUBECTL) apply -k overlays/prod

delete-dev: ## 移除 dev 環境
	$(KUBECTL) delete -k overlays/dev

delete-prod: ## 移除 prod 環境
	$(KUBECTL) delete -k overlays/prod

diff-dev: ## 比對 dev 環境差異
	$(KUBECTL) diff -k overlays/dev || true

diff-prod: ## 比對 prod 環境差異
	$(KUBECTL) diff -k overlays/prod || true
