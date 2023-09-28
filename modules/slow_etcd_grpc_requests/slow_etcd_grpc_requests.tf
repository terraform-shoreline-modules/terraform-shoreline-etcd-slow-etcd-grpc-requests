resource "shoreline_notebook" "slow_etcd_grpc_requests" {
  name       = "slow_etcd_grpc_requests"
  data       = file("${path.module}/data/slow_etcd_grpc_requests.json")
  depends_on = [shoreline_action.invoke_resource_check,shoreline_action.invoke_increase_etcd_capacity]
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

resource "shoreline_file" "increase_etcd_capacity" {
  name             = "increase_etcd_capacity"
  input_file       = "${path.module}/data/increase_etcd_capacity.sh"
  md5              = filemd5("${path.module}/data/increase_etcd_capacity.sh")
  description      = "Increase the number of etcd nodes to improve the capacity of the cluster."
  destination_path = "/agent/scripts/increase_etcd_capacity.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_resource_check" {
  name        = "invoke_resource_check"
  description = "Resource contention on the etcd cluster."
  command     = "`chmod +x /agent/scripts/resource_check.sh && /agent/scripts/resource_check.sh`"
  params      = ["MEMORY_LIMIT","CPU_LIMIT","NETWORK_LIMIT","DISK_LIMIT"]
  file_deps   = ["resource_check"]
  enabled     = true
  depends_on  = [shoreline_file.resource_check]
}

resource "shoreline_action" "invoke_increase_etcd_capacity" {
  name        = "invoke_increase_etcd_capacity"
  description = "Increase the number of etcd nodes to improve the capacity of the cluster."
  command     = "`chmod +x /agent/scripts/increase_etcd_capacity.sh && /agent/scripts/increase_etcd_capacity.sh`"
  params      = ["NEW_NODE_COUNT","NEW_NODE_IP"]
  file_deps   = ["increase_etcd_capacity"]
  enabled     = true
  depends_on  = [shoreline_file.increase_etcd_capacity]
}

