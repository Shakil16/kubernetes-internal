# Lab setup

## Recommended environment

The labs target a disposable local cluster. Rancher Desktop, Kind, and Minikube all work. The lab configuration is packaged as a Helm chart, so the host operating system and shell do not affect the install workflow.

> Never point failure labs at a shared, customer, or production cluster. Several exercises intentionally create invalid workloads, consume resources, or alter scheduling and network policy.

## 1. Verify tools and context

```console
kubectl version --client
docker version
helm version
kubectl config get-contexts
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
```

The client should be within one minor version of the cluster. A connection-refused error on `127.0.0.1:6443` usually means Rancher Desktop's Kubernetes service is disabled or still starting.

## 2. Install the base course release

Run the course commands from the repository root so the relative chart path resolves.

```console
helm lint labs/kubernetes-internals
helm upgrade --install k8s-30d labs/kubernetes-internals --namespace default
helm status k8s-30d --namespace default
kubectl get namespace k8s-30d
```

The release is intentionally stored in the existing `default` namespace and creates the separate `k8s-30d` namespace for course workloads. This lets Helm own and remove the course namespace. If `k8s-30d` already exists and is not owned by this release, either remove that disposable namespace first or install with `--set namespace.create=false` to reuse it.

Enable a lab module with an upgrade. `--reuse-values` retains modules enabled on earlier days:

```console
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.web.enabled=true
```

See [Runnable labs](/labs/README.md) for the complete module list and reset commands.

## 3. Optional multi-node cluster

Multi-node scheduling and cross-node networking are easiest with Kind. Install it using its official quick-start instructions, then:

```console
kind create cluster --name k8s-30d --config labs/kind-multinode.yaml
kubectl cluster-info --context kind-k8s-30d
kubectl get nodes -o wide
```

Kind requires Docker or Podman. If using Minikube instead:

```console
minikube start --nodes 3 --driver=docker --profile k8s-30d
kubectl config use-context k8s-30d
```

## 4. Check capabilities

Some labs depend on add-ons provided by your distribution:

```console
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

## 5. Platform-neutral lab commands

```console
# Watch objects (stop with Ctrl+C)
kubectl get pods --namespace k8s-30d --watch

# Sort events chronologically
kubectl get events --namespace k8s-30d --sort-by=.metadata.creationTimestamp

# Start a temporary diagnostic shell
kubectl run netshoot --namespace k8s-30d --rm -it --restart=Never --image=nicolaka/netshoot -- sh
```

Commands that need a generated resource name first print it with `kubectl get`; copy the result into the explicit `<name>` placeholder. This avoids host-shell variables.

## 6. Cleanup

```console
helm uninstall k8s-30d --namespace default
```

This removes the release, the Helm-owned `k8s-30d` namespace, and enabled cluster-scoped chart resources. Confirm that the release is gone:

```console
helm list --namespace default
kubectl get namespace k8s-30d
kubectl get priorityclass k8s-30d-important
kubectl get customresourcedefinition widgets.course.example.com
```

For a dedicated Kind cluster, deletion is complete and isolated:

```console
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

- [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Install Helm](https://helm.sh/docs/intro/install/)
- [Kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Minikube start](https://minikube.sigs.k8s.io/docs/start/)
