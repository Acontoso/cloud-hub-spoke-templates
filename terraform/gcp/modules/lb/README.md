# Internal Load Balancer Module

Wraps `GoogleCloudPlatform/lb-internal/google` v6 to create a regional internal
load balancer for Cloud Connector service interfaces.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name_prefix` | `string` | yes | Lowercase prefix for the ILB and health check. |
| `region` | `string` | no | Region for the regional ILB. |
| `lb_vpc_network` | `string` | yes | VPC network self link. |
| `lb_sub_network` | `string` | yes | Service subnetwork self link. |
| `target_ip_address` | `string` | no | Reserved VIP shared with the Cloud Connector module. |
| `nva_target_tags` | `list(string)` | no | Tags used for the health check and backend firewalls. |
| `health_check_interval` | `number` | no | Probe interval in seconds. |
| `health_check_timeout` | `number` | no | Probe timeout in seconds. |
| `healthy_threshold` | `number` | no | Successful probes before healthy (2-10). |
| `unhealthy_threshold` | `number` | no | Failed probes before unhealthy (2-10). |
| `http_probe_port` | `number` | no | Cloud Connector health endpoint port. |
| `session_affinity` | `string` | no | `CLIENT_IP_NO_DESTINATION`, `CLIENT_IP`, `CLIENT_IP_PROTO`, or `NONE`. |
| `allow_global_access` | `bool` | no | Allow clients from all regions. |
| `ilb_health_check_name` | `string` | no | Optional health check name; derived when null. |
| `backends` | `list(object)` | yes | Instance group URLs with description and failover flag. |
| `labels` | `map(string)` | no | Labels for resources that support them. |

## Outputs

| Name | Description |
|------|-------------|
| `ip_address` | ILB VIP address. |
| `forwarding_rule` | Forwarding rule resource. |
| `backend_service` | Backend service resource. |
| `health_check` | Health check resource. |

The health check uses HTTP on `http_probe_port` with request path
`/?cchealth`. Both the health check firewall and backend firewall are created
by the upstream module using `nva_target_tags`.
