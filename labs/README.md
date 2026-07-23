# Runnable labs

The `kubernetes-internals/` directory is the single Helm chart used throughout the course. Its modules are disabled by default so the base install creates only the `k8s-30d` namespace.

| Value | Used for |
|---|---|
| `labs.web.enabled` | Deployment, Service, rollout, networking, and probe labs |
| `labs.podInternals.enabled` | Init container, sidecar, and shared volume |
| `labs.scheduling.enabled` | Node selection, anti-affinity, topology spread, priority |
| `labs.storage.enabled` | PVC and mounted volume |
| `labs.workloads.enabled` | StatefulSet, headless Service, DaemonSet, Job, CronJob |
| `labs.rbac.enabled` | Least-privilege ServiceAccount, Role, RoleBinding |
| `labs.security.enabled` | Pod Security Admission compatible workload and NetworkPolicies |
| `labs.scalingReliability.enabled` | Requests, HPA, probes, PDB, termination |
| `labs.failures.enabled` | Deliberately broken Pods for Day 26 |
| `labs.crd.enabled`, `labs.crd.widget.enabled` | A small CRD and Custom Resource, enabled in discovery-safe order |

## Install and enable a lab

```console
helm upgrade --install k8s-30d labs/kubernetes-internals --namespace default
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.web.enabled=true
kubectl get all --namespace k8s-30d
```

Use `--reuse-values` whenever an upgrade should keep earlier modules enabled. Inspect the effective configuration with:

```console
helm get values k8s-30d --namespace default
helm get manifest k8s-30d --namespace default
```

## Reset one lab

Disable and re-enable its module. The first upgrade removes the module’s managed resources; the second recreates them:

```console
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.web.enabled=false
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.web.enabled=true
```

For the CRD exercise, enable the CRD first, wait for discovery, and then enable the custom resource:

```console
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.crd.enabled=true
kubectl wait --for=condition=Established customresourcedefinition/widgets.course.example.com --timeout=60s
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.crd.widget.enabled=true
```

## Cleanup

```console
helm uninstall k8s-30d --namespace default
```

Read the templates and [default values](/labs/kubernetes-internals/values.yaml) before installing them. The failures module is intentionally unhealthy; that is its expected state.
