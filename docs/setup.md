# Lab setup

## Recommended environment

The labs target a disposable local cluster. On this Windows workstation, the shortest path is Rancher Desktop because `kubectl`, Docker, and Helm are already installed. Enable Kubernetes in Rancher Desktop before running the checks below. Kind or Minikube also work.

> Never point failure labs at a shared, customer, or production cluster. Several exercises intentionally create invalid workloads, consume resources, or alter scheduling and network policy.

## 1. Verify tools and context

```powershell
kubectl version --client
docker version
helm version
kubectl config get-contexts
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
```

The client should be within one minor version of the cluster. A connection-refused error on `127.0.0.1:6443` usually means Rancher Desktop's Kubernetes service is disabled or still starting.

## 2. Prepare the course namespace

```powershell
kubectl apply -f labs/manifests/00-namespace.yaml
kubectl config set-context --current --namespace=k8s-30d
kubectl get namespace k8s-30d
```

Or use the checked script:

```powershell
./labs/Initialize-Lab.ps1
```

The script prints the current context and asks for explicit confirmation before making changes.

## 3. Optional multi-node cluster

Multi-node scheduling and cross-node networking are easiest with Kind. Install it using its official quick-start instructions, then:

```powershell
kind create cluster --name k8s-30d --config labs/kind-multinode.yaml
kubectl cluster-info --context kind-k8s-30d
kubectl get nodes -o wide
```

Kind requires Docker or Podman. If using Minikube instead:

```powershell
minikube start --nodes 3 --driver=docker --profile k8s-30d
kubectl config use-context k8s-30d
```

## 4. Check capabilities

Some labs depend on add-ons provided by your distribution:

```powershell
kubectl get storageclass
kubectl get pods -n kube-system
kubectl api-resources
kubectl top nodes
kubectl get ingressclass
```

Interpretation:

- No `kubectl top` output: install or enable Metrics Server before Day 21.
- No default StorageClass: Day 15 needs a local provisioner or a static PV.
- No IngressClass: enable the distribution's ingress controller before Day 14.
- NetworkPolicy objects are accepted but traffic is unchanged: the installed CNI probably does not enforce policy.

## 5. Useful PowerShell patterns

```powershell
# Select the first Pod with label app=web
$pod = kubectl get pod -l app=web -o jsonpath='{.items[0].metadata.name}'

# Watch objects (stop with Ctrl+C)
kubectl get pods --watch

# Sort events chronologically
kubectl get events --sort-by='.metadata.creationTimestamp'

# Start a temporary diagnostic shell
kubectl run netshoot --rm -it --restart=Never --image=nicolaka/netshoot -- bash
```

On Bash, use `pod=$(kubectl ...)` instead of `$pod = kubectl ...`.

## 6. Cleanup

```powershell
./labs/Remove-Lab.ps1
```

This deletes only the `k8s-30d` namespace after confirmation. Cluster-scoped objects used by a day are named with the `k8s-30d-` prefix and must be reviewed separately:

```powershell
kubectl get clusterrole,clusterrolebinding,customresourcedefinition | Select-String 'k8s-30d'
```

For a dedicated Kind cluster, deletion is complete and isolated:

```powershell
kind delete cluster --name k8s-30d
```

## Troubleshooting setup

| Symptom | Check | Likely correction |
|---|---|---|
| `connection refused` | `kubectl config view --minify` | Start local Kubernetes or select a live context |
| `x509` error | Check server address and certificate dates | Regenerate local cluster or correct kubeconfig |
| `Forbidden` | `kubectl auth can-i '*' '*'` | Select the local admin context; do not weaken shared RBAC |
| image pull timeout | `kubectl describe pod` and runtime proxy settings | Fix DNS/proxy/registry access or preload an image |
| Pods Pending | `kubectl describe pod` | Add capacity or reduce requests/constraints |

## Official setup references

- [Install Kubernetes tools](https://kubernetes.io/docs/tasks/tools/)
- [Install kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
- [Kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Minikube start](https://minikube.sigs.k8s.io/docs/start/)

