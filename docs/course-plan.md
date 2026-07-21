# Complete 30-day plan

This plan is deliberately cumulative. Each lab leaves you with evidence—YAML, events, logs, metrics, or a short incident note—not just a working object.

## Daily routine

| Block | Time | What to do |
|---|---:|---|
| Recall | 10 min | Explain yesterday's diagram without notes |
| Learn | 45-60 min | Read the day's mechanism and follow every object transition |
| Lab | 60-90 min | Apply, observe, break, diagnose, repair, verify |
| Production lens | 20 min | Identify signals, blast radius, mitigation, and prevention |
| Interview | 20 min | Answer aloud in 2-3 minutes, then compare with the answer guide |

## Schedule

| Day | Focus | Hands-on outcome | Production scenario |
|---:|---|---|---|
| 1 | Cluster mental model | Inspect API resources and system namespaces | Separate control-plane, node, and workload symptoms |
| 2 | API server, scheduler, controllers, etcd | Inspect component health and static Pod manifests where available | Reason about component loss |
| 3 | `kubectl` and API request flow | Compare client dry-run, server dry-run, discovery, and raw API output | Diagnose rejected or slow API requests |
| 4 | etcd internals | Inspect API object versions and simulate backup commands safely | Handle quota, latency, and restore design |
| 5 | Scheduler and reconciliation | Watch Deployment → ReplicaSet → Pod and scheduling events | Debug unschedulable Pods and stalled controllers |
| 6 | kubelet, CRI, containerd, kube-proxy | Correlate Pod status with node/runtime facts | Diagnose NotReady and runtime failures |
| 7 | Architecture integration | Time-boxed failure game and architecture review | Build a component failure matrix |
| 8 | Pod internals | Run init, sidecar, shared-volume, and namespace experiments | Debug init and multi-container failures |
| 9 | node selection, taints, tolerations | Place Pods using labels and taints | Explain why a Pod remains Pending |
| 10 | affinity, spread, priority, preemption | Create anti-affinity and topology-spread placements | Balance resilience against scheduling constraints |
| 11 | network model and CNI | Trace Pod IPs, routes, interfaces, and cross-node reachability | Diagnose CNI sandbox errors |
| 12 | Services and kube-proxy | Trace Service → EndpointSlice → Pod; test session behavior | Debug unreachable Services |
| 13 | DNS and CoreDNS | Query service records and inspect CoreDNS | Diagnose intermittent resolution and `ndots` amplification |
| 14 | Ingress, TLS, and NetworkPolicy | Expose an app and enforce default-deny/allow rules | Diagnose 404/502/TLS/policy incidents |
| 15 | PV, PVC, StorageClass, CSI | Bind and mount a claim; follow provisioning states | Debug Pending PVC and attach/mount failures |
| 16 | Deployment and ReplicaSet | Perform rollouts, pause, resume, and rollback | Repair a stuck rollout |
| 17 | StatefulSet and DaemonSet | Observe stable identity, ordered rollout, and per-node agents | Operate quorum systems and node agents |
| 18 | Job and CronJob | Test completion, retry, deadlines, and concurrency | Prevent duplicate or runaway batch work |
| 19 | authentication, authorization, RBAC | Build a least-privilege ServiceAccount and verify with `auth can-i` | Debug 401 versus 403 |
| 20 | Secrets, ConfigMaps, PSS, admission, policy | Enforce a restricted namespace and safe workload context | Respond to secret leakage and admission failure |
| 21 | HPA, VPA, metrics, Cluster Autoscaler | Generate load and interpret HPA decisions | Diagnose scaling lag or thrashing |
| 22 | probes, PDB, eviction, drain, shutdown | Break probes and test disruption constraints | Keep traffic safe during node maintenance |
| 23 | CRD, custom controller, operator pattern | Install and inspect a simple custom resource | Diagnose a stuck reconciliation loop |
| 24 | watches, informers, finalizers, owners, GC, webhooks | Observe deletion and ownership propagation | Repair terminating resources and webhook outages |
| 25 | metrics, logs, traces, events | Build a signal map and optional Prometheus stack | Triage latency using RED/USE signals |
| 26 | Pod incident lab | Repair Pending, CrashLoopBackOff, ImagePullBackOff, and OOMKilled | Produce evidence-based incident notes |
| 27 | Network incident lab | Repair Service, DNS, NetworkPolicy, and Ingress failures | Follow a layer-by-layer network runbook |
| 28 | Node, storage, and control-plane incidents | Diagnose NotReady, PVC, scheduler, API, and etcd symptoms | Choose safe mitigation under pressure |
| 29 | HA, backup, upgrades, capacity | Draft upgrade/rollback and etcd restore runbooks | Avoid correlated failure and version skew |
| 30 | Capstone and mock interviews | Deploy, break, recover, explain, and document a small platform | Run a 60-minute senior interview simulation |

## Weekly gates

Do not move on based only on reading. Meet these gates:

- **Day 7:** draw `kubectl apply` to running container from memory; state what continues during each control-plane outage.
- **Day 14:** resolve a failed Service using DNS → virtual IP → EndpointSlice → Pod checks, in that order.
- **Day 20:** design least-privilege RBAC and explain admission versus authorization.
- **Day 25:** connect one user symptom to metrics, logs, events, and traces without jumping between tools randomly.
- **Day 30:** restore a deliberately broken application within 25 minutes and deliver a five-minute incident summary.

## Evidence portfolio

Keep a `journal/` directory locally (ignored if it contains environment details) with:

1. One diagram redrawn per day.
2. The three most useful commands and why they were decisive.
3. A failure symptom, hypothesis, evidence, correction, and prevention.
4. Two interview answers recorded in your own words.
5. A screenshot or redacted command transcript showing the repaired state.

