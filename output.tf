output "cluster_info" {
  value = <<-EOT
    Ray cluster has been set up!
    
    Head node: ${var.head_node_ip}
    Worker node: ${var.worker_node_ip}
    
    Ray dashboard: http://${var.head_node_ip}:8265
    
    To connect to the cluster from Python:
    ```python
    import ray
    ray.init(address="${var.head_node_ip}:6379")
    ```
  EOT
}
