variable "head_node_ip" {
  description = "IP address of the head node"
  type        = string
}

variable "worker_node_ip" {
  description = "IP address of the worker node"
  type        = string
}

variable "ssh_username" {
  description = "SSH username for both nodes"
  type        = string
}
