# k8s 啟動專案（Kustomize）

純 manifests 骨架，採 **base + overlays** 分層管理，使用 `kubectl` 內建的 Kustomize，無需額外安裝工具。

## 目錄結構

```
.
├── base/                   # 共用基礎層（不直接部署）
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml     # 預設用 nginx 佔位映像，請替換成你的應用
│   ├── service.yaml
│   ├── ingress.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/                # 開發環境（namespace: app-dev，前綴 dev-）
│   │   ├── kustomization.yaml
│   │   └── replicas.yaml
│   └── prod/               # 正式環境（namespace: app-prod，前綴 prod-，3 副本）
│       ├── kustomization.yaml
│       ├── replicas.yaml
│       └── resources.yaml
├── Makefile
└── .gitignore
```

## 快速開始

本機已安裝 minikube（`kubectl` 為 `minikube kubectl --` 別名）。

```bash
# 啟動本機叢集
minikube start

# 先看渲染結果（不會實際套用）
make build-dev

# 部署 dev 環境
make apply-dev

# 查看資源
kubectl get all -n app-dev
```

> `kubectl` 是 minikube 別名，若 `make` 內的 `kubectl` 無法解析，可改用：
> `make apply-dev KUBECTL="minikube kubectl --"`

## 常用指令

| 指令 | 說明 |
| --- | --- |
| `make build-dev` / `make build-prod` | 渲染 YAML 到 stdout |
| `make apply-dev` / `make apply-prod` | 部署到叢集 |
| `make diff-dev` / `make diff-prod` | 比對與叢集的差異 |
| `make delete-dev` / `make delete-prod` | 移除環境 |

## 客製化重點

1. **替換映像**：修改 `base/deployment.yaml` 的 `image`，或在各 overlay 的 `kustomization.yaml` 用 `images:` 覆寫 tag。
2. **環境變數**：非敏感設定改 `base/configmap.yaml`，各環境差異用 overlay 的 `configMapGenerator` merge。
3. **敏感資訊**：請另建 `Secret`（檔名 `*.secret.yaml` 已被 `.gitignore` 排除），切勿提交版控。
4. **Ingress**：`base/ingress.yaml` 預設 host 為 `web.local`，本機可加到 `/etc/hosts` 並啟用 `minikube addons enable ingress`。

## 環境差異對照

| 項目 | dev | prod |
| --- | --- | --- |
| Namespace | `app-dev` | `app-prod` |
| 名稱前綴 | `dev-` | `prod-` |
| 副本數 | 1 | 3 |
| 資源限制 | base 預設 | 較高（見 `resources.yaml`） |
| `APP_DEBUG` | `true` | `false` |
