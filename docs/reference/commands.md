# Kubernetes command field guide

The most valuable command is the one that tests a specific hypothesis. Start read-only, preserve evidence, and change the owning object only after locating the failed transition.

## Context and API discovery

```powershell
kubectl config get-contexts
kubectl config current-context
kubectl config use-context <context>
kubectl config view --minify
kubectl cluster-info
kubectl version
kubectl api-resources
kubectl api-versions
kubectl explain deployment.spec.strategy
kubectl get --raw /version
kubectl get --raw '/readyz?verbose'
```

Before any write, say the context and namespace aloud. Prefer `-n <namespace>` even if a default is configured.

## Inventory and structured output

```powershell
kubectl get pod -A -o wide
kubectl get deployment,replicaset,pod -n <ns> --show-labels
kubectl describe pod <pod> -n <ns>
kubectl get pod <pod> -n <ns> -o yaml
kubectl get pod <pod> -n <ns> -o json
kubectl get pod -n <ns> --field-selector=status.phase=Pending
kubectl get pod -n <ns> -l app=web
kubectl get pod -n <ns> -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,PHASE:.status.phase,IP:.status.podIP
kubectl get pod <pod> -n <ns> -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}{"`n"}'
```

Use `get` to compare many objects, `describe` for human-focused state/events, and YAML/JSON for exact fields/ownership.

## Events

```powershell
kubectl get events -n <ns> --sort-by='.metadata.creationTimestamp'
kubectl get events -A --field-selector reason=FailedScheduling
kubectl get events -n <ns> --field-selector involvedObject.name=<name>
kubectl events -n <ns> --for pod/<pod> --watch
```

Events expire and may aggregate. Capture them early; do not treat them as durable logging.

## Logs

```powershell
kubectl logs <pod> -n <ns>
kubectl logs <pod> -n <ns> -c <container> --tail=200 --timestamps
kubectl logs <pod> -n <ns> -c <container> --previous
kubectl logs -n <ns> -l app=web --all-containers --prefix --since=15m
kubectl logs deployment/web -n <ns> --all-pods=true --all-containers=true
kubectl logs <pod> -n <ns> -f
```

Always check `--previous` for restarted containers before another restart overwrites the evidence window.

## Exec, port forwarding, proxy, and debug

```powershell
kubectl exec <pod> -n <ns> -c <container> -- <command>
kubectl exec -it <pod> -n <ns> -- sh
kubectl port-forward -n <ns> service/<service> 8080:80
kubectl proxy
kubectl debug <pod> -n <ns> -it --image=nicolaka/netshoot --target=<container>
kubectl debug <pod> -n <ns> -it --copy-to=<pod>-debug --container=<container> -- sh
kubectl debug node/<node> -it --image=ubuntu --profile=sysadmin
```

Ephemeral debug containers can have elevated visibility. Audit and remove debug copies; use node debug only on authorized environments.

## Declarative changes and diff

```powershell
kubectl diff -f <file>
kubectl apply -f <file> --server-side --dry-run=server
kubectl apply -f <file> --server-side --field-manager=<manager>
kubectl apply -f <directory>
kubectl patch <kind> <name> -n <ns> --type=merge -p '<json>'
kubectl patch <kind> <name> -n <ns> --type=json -p='<json-patch-array>'
kubectl edit <kind> <name> -n <ns>
```

Prefer reviewed files/GitOps for repeatability. `edit` and imperative patches are useful mitigation tools but must be reconciled back to source to prevent drift.

## Rollouts and workload control

```powershell
kubectl rollout status deployment/<name> -n <ns> --timeout=2m
kubectl rollout history deployment/<name> -n <ns>
kubectl rollout pause deployment/<name> -n <ns>
kubectl rollout resume deployment/<name> -n <ns>
kubectl rollout undo deployment/<name> -n <ns> --to-revision=<n>
kubectl rollout restart deployment/<name> -n <ns>
kubectl set image deployment/<name> <container>=<image> -n <ns>
kubectl set resources deployment/<name> -n <ns> --requests=cpu=100m,memory=128Mi
kubectl scale deployment/<name> -n <ns> --replicas=5
```

Do not use restart as diagnosis. Inspect the revision, conditions, ReplicaSets, Pods, events, and user signal first.

## Nodes, placement, and maintenance

```powershell
kubectl get node -o wide
kubectl describe node <node>
kubectl get lease <node> -n kube-node-lease -o yaml
kubectl top node
kubectl get pod -A --field-selector spec.nodeName=<node> -o wide
kubectl label node <node> key=value
kubectl taint node <node> key=value:NoSchedule
kubectl cordon <node>
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data --timeout=5m
kubectl uncordon <node>
```

Review PDBs, storage, local data, unmanaged Pods, quorum, and replacement capacity before drain. Remove a lab label/taint with `key-` or `key=value:Effect-`.

## Resources, metrics, and autoscaling

```powershell
kubectl top node
kubectl top pod -n <ns> --containers
kubectl describe resourcequota -n <ns>
kubectl describe limitrange -n <ns>
kubectl get hpa -A
kubectl describe hpa <name> -n <ns>
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes
```

`top` is recent utilization, while scheduling uses requests against allocatable capacity.

## Networking and DNS

```powershell
kubectl get service -n <ns> -o wide
kubectl get endpointslice -n <ns> -l kubernetes.io/service-name=<service> -o wide
kubectl get networkpolicy -A
kubectl get ingress,ingressclass -A
kubectl run netshoot -n <ns> --image=nicolaka/netshoot --restart=Never -- sleep 1d
kubectl exec netshoot -n <ns> -- dig <service>.<ns>.svc.cluster.local
kubectl exec netshoot -n <ns> -- curl -sv --connect-timeout 2 http://<service>:<port>
kubectl exec netshoot -n <ns> -- ip route
kubectl get pods -n kube-system -o wide
```

Trace application listener → Pod IP → EndpointSlice → ClusterIP → DNS → Ingress/external path.

## Storage

```powershell
kubectl get pvc,pv -A
kubectl describe pvc <pvc> -n <ns>
kubectl get storageclass -o yaml
kubectl get csidriver,csinode
kubectl get volumeattachment
kubectl get pod <pod> -n <ns> -o jsonpath='{.spec.volumes}'
```

Distinguish provisioning, binding/topology, controller attachment, node staging/mount, and filesystem capacity.

## Security and identity

```powershell
kubectl auth whoami
kubectl auth can-i <verb> <resource> -n <ns>
kubectl auth can-i --list -n <ns>
kubectl auth can-i get secrets -n <ns> --as=system:serviceaccount:<ns>:<sa>
kubectl get role,rolebinding -n <ns>
kubectl get clusterrole,clusterrolebinding
kubectl get serviceaccount -n <ns>
kubectl create token <serviceaccount> -n <ns> --duration=10m
```

Never put tokens, Secret values, certificate private keys, or full kubeconfigs in tickets/transcripts.

## API ownership and advanced objects

```powershell
kubectl get <kind> <name> -o yaml --show-managed-fields
kubectl get <kind> --watch --output-watch-events
kubectl get crd
kubectl get apiservice
kubectl get mutatingwebhookconfiguration,validatingwebhookconfiguration
kubectl get lease -A
kubectl delete <kind> <name> --cascade=foreground
kubectl delete <kind> <name> --cascade=orphan
```

Before forced finalizer removal, identify its controller and incomplete external cleanup.

## Command habits for interviews and incidents

1. State the hypothesis before the command.
2. Prefer selectors and structured fields to manual scanning.
3. Add namespace/context explicitly.
4. Capture current and previous state.
5. Change the controller/template, not a disposable child Pod.
6. Verify from the affected user's network and original SLO signal.

