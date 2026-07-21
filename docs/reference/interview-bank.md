# Senior Kubernetes interview bank

Answer aloud using **mechanism → failure effect → evidence → mitigation → tradeoff/prevention**. The cue is not a script; expand it in your own words and use a production example.

## Architecture and API

| Question | Strong-answer cue |
|---|---|
| Explain Kubernetes architecture. | Declarative API; API server/etcd; scheduler/controllers; kubelet/runtime/CNI/CSI; reconciliation. |
| What happens during `kubectl apply`? | kubeconfig/discovery, TLS, authn/authz/admission/validation, persist, asynchronous controllers/scheduler/kubelet/status. |
| Why is API server central? | Policy-enforced coordination and persistence boundary used by all reconcilers. |
| What if every API server fails? | Existing node processes may continue; changes/reconciliation/status coordination fail; restore endpoint/API/etcd safely. |
| Why etcd and what is quorum? | Consistent transactional/watchable state; majority commit; 3 tolerates 1, 5 tolerates 2. |
| Scheduler down—what happens? | Existing Pods continue; unbound Pods Pending; direct bound/static workload nuance; restore leader and backlog. |
| Controller manager down—what happens? | API/scheduling may work, but replicas/endpoints/jobs/node lifecycle and many loops stop converging. |
| How do watches work? | LIST snapshot/resourceVersion, WATCH incremental events, reconnect/relist on expiry; events are hints. |
| Spec versus status? | User/controller intent vs observed state; generation/observedGeneration and conditions. |
| How does server-side apply work? | Field managers/managedFields and ownership conflicts; not a merge of arbitrary intent without rules. |

## Pods and nodes

| Question | Strong-answer cue |
|---|---|
| Pod versus container? | Scheduled shared-lifecycle/isolation envelope vs runtime process/filesystem unit. |
| Why pause/sandbox container? | Stable namespaces/Pod IP across workload container restarts. |
| Can containers use localhost? | Shared network namespace/port space; filesystem/PID not necessarily shared. |
| Init versus sidecar? | Ordered completion gates vs ongoing support; mention restartable-init sidecar semantics/version awareness. |
| What happens when a Pod dies? | Kubelet container restart vs controller Pod replacement; identity/IP/emptyDir implications. |
| How does kubelet work? | Watches assigned Pods, CRI/runtime, coordinates CNI/CSI, probes, status/heartbeats. |
| Kubelet stops—what happens? | Runtime containers may continue; status/probes reconciliation stop; node NotReady and possible replacement. |
| What is CRI? | gRPC abstraction between kubelet and runtime implementations. |
| What causes ContainerCreating? | Image, sandbox/CNI, volume/CSI, Secret/ConfigMap, runtime; events reveal stage. |

## Scheduling

| Question | Strong-answer cue |
|---|---|
| How does scheduler pick a node? | Queue, filter, score, reserve/permit if configured, bind; requests and hard/soft constraints. |
| NodeSelector vs node affinity? | Exact match vs expressive required/preferred rules. |
| Taint vs toleration? | Repel vs permit; toleration does not attract. |
| Pod affinity vs anti-affinity? | Co-locate/separate relative to selected Pods across a topology key. |
| Topology spread vs anti-affinity? | Count skew across domains vs pairwise placement relation. |
| Why Pending while nodes look idle? | Scheduler uses requests/allocatable plus constraints, not current utilization. |
| What is priority/preemption? | Order and possible lower-priority victim eviction; capacity/termination/PDB tradeoffs. |
| Why can hard anti-affinity break rollout? | Replicas/surge exceed domains; no feasible node despite physical capacity. |

## Networking

| Question | Strong-answer cue |
|---|---|
| Explain Kubernetes network model. | Pod IP per sandbox, direct Pod reachability intent, node reachability; CNI-specific implementation. |
| What is CNI? | Runtime plugin contract for network attach/delete plus IPAM/routing implementation. |
| Pod-to-Pod across nodes? | veth/interface then routes, overlay, cloud network, or eBPF; explain actual implementation. |
| What is a Service? | Stable virtual IP/discovery mapping to ready EndpointSlice backends. |
| What does kube-proxy do? | Watches Service/EndpointSlice and programs node dataplane; may be replaced by eBPF. |
| iptables vs IPVS vs eBPF? | Different kernel mechanisms/data models; avoid universal performance claims; operations vary. |
| Why EndpointSlice? | Scalable endpoint representation, readiness/serving/terminating conditions, Service dataplane input. |
| How does DNS work? | Pod resolver → CoreDNS Service; API-backed cluster records; forward external names. |
| What is `ndots` impact? | Search expansion can amplify queries/latency for dotted external names. |
| Service unreachable—runbook? | Pod listener/IP → EndpointSlice → Service port/IP → DNS → policy/dataplane. |
| Ingress vs LoadBalancer Service? | HTTP route/controller across backends vs L4 exposure of one Service. |
| Ingress 502 vs 404? | backend communication/protocol vs route/class/host/path mismatch. |
| NetworkPolicy model? | Selected-direction isolation plus additive allows; CNI enforcement required. |
| Same-node works, cross-node fails? | CNI routes/tunnels, node firewall/security, MTU, peer health. |

## Storage and workloads

| Question | Strong-answer cue |
|---|---|
| PV vs PVC vs StorageClass? | Capacity object, consumer claim, provisioning/policy class. |
| How dynamic provisioning works? | PVC selects class; external CSI provisioner creates backing volume/PV; binding. |
| Why WaitForFirstConsumer? | Defer provisioning/binding until scheduler knows topology. |
| CSI attach path? | scheduler/topology, controller publish/VolumeAttachment, node stage/publish via kubelet/plugin. |
| hostPath vs PVC? | Node-coupled security/local data vs abstract managed persistent lifecycle. |
| Deployment vs ReplicaSet? | Revision/rollout manager vs fixed-template replica count. |
| Deployment vs StatefulSet? | Interchangeable replicas vs stable ordinal network/storage association and ordered behavior. |
| Why headless Service? | Direct endpoint/per-Pod discovery, especially stable StatefulSet names. |
| When DaemonSet? | Per eligible node infrastructure agent. |
| Job vs CronJob? | Finite completion/retries vs schedule that creates Jobs. |
| Exactly once batch? | Kubernetes retries are at-least-once-like; require idempotency/transactional business keys. |
| Rollout stuck—how debug? | Deployment conditions, ReplicaSets/Pods/events, capacity, image, readiness, surge math, rollback. |

## Security

| Question | Strong-answer cue |
|---|---|
| Authentication vs authorization vs admission? | Identity, permission, then object mutation/validation/policy. |
| User vs ServiceAccount? | External human identity vs namespaced workload identity/projected token. |
| Role/ClusterRole and bindings? | Rule scope/definition vs grant scope; binding ClusterRole into namespace nuance. |
| Why 401 vs 403? | Unknown/invalid credentials vs authenticated identity denied action. |
| Are Secrets encrypted? | Base64 only by default representation; configure at-rest encryption/KMS plus RBAC/rotation. |
| ConfigMap/Secret updates? | Eventual volume projection; no subPath refresh; env fixed; app reload needed. |
| Pod Security Standards? | Privileged/Baseline/Restricted profiles enforced/warned/audited by admission. |
| Why admission webhooks risky? | Synchronous API dependency: latency, TLS, reachability, failurePolicy, scope and HA. |
| Why NetworkPolicy not enough? | Covers supported network flows only; needs identity/RBAC/admission/runtime/secret layers. |
| Why Pod create permission is powerful? | Can select ServiceAccounts/mount data/run code and potentially reach node resources. |

## Scaling and reliability

| Question | Strong-answer cue |
|---|---|
| HPA formula? | ceil(current replicas × current/target); requests, tolerance, missing metrics, behavior. |
| HPA vs VPA vs Cluster Autoscaler? | replicas vs per-Pod requests vs nodes; coordinate feedback loops. |
| Why Metrics Server? | Resource metrics API for top/basic HPA, not long-term monitoring. |
| HPA unknown? | metrics API/adapter, requests, selector, readiness, scrape/TLS. |
| Liveness vs readiness vs startup? | restart, traffic eligibility, initialization gate. |
| Why can liveness worsen outage? | dependency/overload failure triggers restart storm and destroys capacity/evidence. |
| What does PDB protect? | voluntary eviction budget only; not failure/direct delete/all preemption. |
| What happens during drain? | cordon and eviction; PDB; DaemonSet/local data/unmanaged Pod considerations. |
| Graceful termination path? | deletion timestamp/endpoints, preStop, TERM, drain, grace, KILL. |
| How avoid rollout 5xx? | correct readiness, termination drain, endpoint propagation, compatibility, capacity, observe SLO. |

## Advanced controllers and operations

| Question | Strong-answer cue |
|---|---|
| What is CRD? | Custom stored/schema/API-discovered type; behavior requires controller. |
| Operator pattern? | Domain reconciliation of declarative custom resources and operational knowledge. |
| What is informer? | Shared list/watch cache and handlers feeding work queues. |
| Why idempotent reconciliation? | duplicate/lost/coalesced events and partial failure are normal. |
| Finalizer? | Metadata deletion gate until controller cleanup; not executable hook. |
| OwnerReference? | UID-based lifecycle/garbage-collection relation, unlike label. |
| Namespace stuck terminating? | discovery/APIService, remaining objects/finalizers/controller; never blind force. |
| API server latency? | verbs/resources, APF/inflight, webhooks, etcd, clients, audit/KMS, resources/network. |
| etcd full? | stop churn, snapshot, alarms/quota, safe compact/defrag, fix producer, quorum-aware. |
| Node NotReady? | condition/Lease, kubelet/runtime/disk/certs/API path/CNI; fence stateful workloads. |
| Safe upgrade? | compatibility/deprecation inventory, tested backup/restore, control plane then nodes per current skew, canary/stop criteria. |
| HA design? | failure-domain spread, LB, API replicas, odd etcd quorum, leaders, worker spare capacity. |
| What does etcd backup miss? | PV application data and external dependencies/configuration. |
| Metrics/logs/traces/events roles? | trend/alert, detail, causality, short-lived control breadcrumbs. |
| Describe your hardest incident. | impact/timeline, evidence and false hypotheses, mitigation, contributing controls, prevention with verification. |

## Self-scoring rubric

Score each dimension 0, 1, or 2:

- **Mechanism:** names components and their interaction, not just definitions.
- **Evidence:** gives exact conditions/events/logs/metrics/commands that discriminate causes.
- **Mitigation:** proposes a bounded, reversible restoration action.
- **Tradeoff:** acknowledges availability, consistency, security, cost, or blast-radius consequences.
- **Prevention:** provides a testable guardrail, alert, capacity change, design improvement, or runbook.

Aim for 8/10. If you cannot draw the path or state what evidence would disprove you, revisit that day.

