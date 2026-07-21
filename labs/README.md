# Runnable labs

The `manifests/` directory contains small, composable resources used throughout the course.

| File | Used for |
|---|---|
| `00-namespace.yaml` | Course namespace and labels |
| `01-web.yaml` | Deployment, Service, rollout, networking, and probe labs |
| `02-pod-internals.yaml` | Init container, sidecar, and shared volume |
| `03-scheduling.yaml` | Node selection, anti-affinity, topology spread, priority |
| `04-storage.yaml` | PVC and mounted volume |
| `05-workloads.yaml` | StatefulSet, headless Service, DaemonSet, Job, CronJob |
| `06-rbac.yaml` | Least-privilege ServiceAccount, Role, RoleBinding |
| `07-security.yaml` | Pod Security Admission compatible workload and NetworkPolicies |
| `08-scaling-reliability.yaml` | Requests, HPA, probes, PDB, termination |
| `09-failures.yaml` | Deliberately broken Pods for Day 26 |
| `10-crd.yaml`, `10-widget.yaml` | A small CRD and Custom Resource, applied in discovery-safe order |

## Apply a lab

```powershell
kubectl apply -f labs/manifests/00-namespace.yaml
kubectl apply -f labs/manifests/01-web.yaml
kubectl get all -n k8s-30d
```

## Reset one lab

```powershell
kubectl delete -f labs/manifests/01-web.yaml --ignore-not-found
kubectl apply -f labs/manifests/01-web.yaml
```

## Cleanup everything namespaced

```powershell
./labs/Remove-Lab.ps1
```

Read every manifest before applying it. The failure manifest is intentionally unhealthy; that is its expected state.
