resource "shoreline_notebook" "slow_etcd_grpc_requests" {
  name       = "slow_etcd_grpc_requests"
  data       = file("${path.module}/data/slow_etcd_grpc_requests.json")
  depends_on = [shoreline_action.invoke_resource_check,shoreline_action.invoke_etcd_node_scale_up]
}

resource "shoreline_file" "resource_check" {
  name             = "resource_check"
  input_file       = "${path.module}/data/resource_check.sh"
  md5              = filemd5("${path.module}/data/resource_check.sh")
  description      = "Resource contention on the etcd cluster."
  destination_path = "/agent/scripts/resource_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "etcd_node_scale_up" {
  name             = "etcd_node_scale_up"
  input_file       = "${path.module}/data/etcd_node_scale_up.sh"
  md5              = filemd5("${path.module}/data/etcd_node_scale_up.sh")
  description      = "Increase the number of etcd nodes to improve the capacity of the cluster."
  destination_path = "/agent/scripts/etcd_node_scale_up.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_resource_check" {
  name        = "invoke_resource_check"
  description = "Resource contention on the etcd cluster."
  command     = "`chmod +x /agent/scripts/resource_check.sh && /agent/scripts/resource_check.sh`"
  params      = ["CPU_LIMIT","MEMORY_LIMIT","NETWORK_LIMIT","DISK_LIMIT"]
  file_deps   = ["resource_check"]
  enabled     = true
  depends_on  = [shoreline_file.resource_check]
}

resource "shoreline_action" "invoke_etcd_node_scale_up" {
  name        = "invoke_etcd_node_scale_up"
  description = "Increase the number of etcd nodes to improve the capacity of the cluster."
  command     = "`chmod +x /agent/scripts/etcd_node_scale_up.sh && /agent/scripts/etcd_node_scale_up.sh`"
  params      = ["NEW_NODE_COUNT","NEW_NODE_IP"]
  file_deps   = ["etcd_node_scale_up"]
  enabled     = true
  depends_on  = [shoreline_file.etcd_node_scale_up]
}

