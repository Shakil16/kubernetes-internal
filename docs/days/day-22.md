# Day 22 · Probes, disruption, eviction, drain, and graceful shutdown

## Outcome

Design health checks that reflect traffic safety, preserve availability during voluntary maintenance, and trace graceful Pod termination.

```mermaid
sequenceDiagram
    participant D as Delete or eviction
    participant A as API and EndpointSlice
    participant K as kubelet
    participant C as container
    D->>A: set deletionTimestamp and grace period
    A->>A: endpoint becomes not ready/terminating
    K->>C: run preStop if configured
    K->>C: send TERM
    C->>C: stop accepting, drain, flush
    K->>C: send KILL after grace if needed
    K->>A: final status; object removed
```

## Health semantics

- **Startup probe:** gates liveness/readiness until slow initialization succeeds.
- **Readiness probe:** determines whether the container should receive Service traffic. Failure does not restart it.
- **Liveness probe:** detects a process that cannot recover without restart. Bad liveness probes amplify incidents.

HTTP, TCP, gRPC, and exec probes have different cost and semantics. A useful readiness check covers the minimum local ability to serve; including every downstream dependency can remove all replicas during a shared dependency outage. Liveness should not fail merely because an external service is unavailable.

A PDB limits voluntary disruption through the eviction API using `minAvailable` or `maxUnavailable`. It does not protect against node failure, OOM, direct Pod deletion, or every involuntary event. Draining cordons a node, evicts eligible workload Pods, respects PDBs, and normally ignores DaemonSet Pods after warning.

## Lab · Observe probes and PDB

```console
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.scalingReliability.enabled=true
kubectl get pod -n k8s-30d -l app=scalable-web -w
kubectl describe pod -n k8s-30d -l app=scalable-web
kubectl get pdb scalable-web -n k8s-30d
kubectl describe pdb scalable-web -n k8s-30d
```

Scale to one replica and request eviction:

```console
kubectl scale deployment/scalable-web -n k8s-30d --replicas=1
kubectl wait deployment/scalable-web -n k8s-30d --for=condition=Available --timeout=120s
kubectl get pod -n k8s-30d -l app=scalable-web
kubectl create poddisruptionbudget pdb-test-copy -n k8s-30d --selector=app=scalable-web --min-available=1 --dry-run=client -o yaml
kubectl delete pod <scalable-web-pod-name> -n k8s-30d --dry-run=server
```

Replace `<scalable-web-pod-name>` with a Pod from the first command. Direct delete is not blocked by PDB. To exercise eviction safely, use a disposable multi-node cluster and drain a worker hosting the Pod:

```console
kubectl cordon <worker-node>
kubectl drain <worker-node> --ignore-daemonsets --delete-emptydir-data --timeout=2m
kubectl uncordon <worker-node>
```

Do not drain a single-node cluster or control-plane node needed by the lab. Watch PDB and events from another terminal.

## Break/fix · Probe storm

Patch liveness to a missing path, observe restarts, then restore:

```console
kubectl patch deployment scalable-web -n k8s-30d --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/missing"}]'
kubectl get pod -n k8s-30d -l app=scalable-web -w
kubectl describe pod -n k8s-30d -l app=scalable-web
helm upgrade k8s-30d labs/kubernetes-internals --namespace default --reuse-values --set labs.scalingReliability.enabled=true
```

## Production issues

- Probe timeouts coincide with CPU throttling or GC pauses: fix resources/probe budget before restarting harder.
- Drain hangs: inspect PDB allowed disruptions, terminating Pods/finalizers, emptyDir, unmanaged Pods, and eviction errors.
- 5xx during rollout: readiness becomes true too early or termination ends before endpoints/connections drain.
- Node pressure eviction: inspect QoS, requests/limits, ephemeral storage/inodes, eviction thresholds, and workload priority.
- PDB with `minAvailable: 100%`: zero voluntary disruptions; ensure maintenance policy has intentional headroom.

## Interview practice

1. **Liveness versus readiness?** Liveness decides restart; readiness decides traffic eligibility.
2. **What does startup probe add?** It protects slow initialization from liveness and delays readiness evaluation until startup succeeds.
3. **What happens during drain?** Node is made unschedulable; evictable workload Pods are requested through eviction, PDBs are honored, DaemonSets remain, controllers replace elsewhere.
4. **What does PDB protect?** Budgeted voluntary evictions, not all causes of unavailability.
5. **Describe graceful shutdown.** Endpoint removal/termination state, preStop if any, TERM, app drain/flush, grace deadline, then KILL.
