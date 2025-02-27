resource "local_file" "ray_head_script" {
  filename = "${path.module}/ray_head_setup.sh"
  content  = <<-EOT
    #!/bin/bash
    # Script to set up Ray head node
    
    # Exit on error
    set -e
    
    echo "Setting up Ray head node..."
    
    # Activate conda environment
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate ai-cluster
    
    # Start Ray head node
    ray stop
    ray start --head --port=6379 --dashboard-host=0.0.0.0
    
    echo "Ray head node is running!"
    echo "Dashboard available at http://${var.head_node_ip}:8265"
  EOT
}

resource "local_file" "ray_worker_script" {
  filename = "${path.module}/ray_worker_setup.sh"
  content  = <<-EOT
    #!/bin/bash
    # Script to set up Ray worker node
    
    # Exit on error
    set -e
    
    echo "Setting up Ray worker node..."
    
    # Activate conda environment
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate ai-cluster
    
    # Start Ray worker node
    ray stop
    ray start --address="${var.head_node_ip}:6379"
    
    echo "Ray worker node is connected to the head node!"
  EOT
}

resource "local_file" "vllm_setup_script" {
  filename = "${path.module}/vllm_setup.sh"
  content  = <<-EOT
    #!/bin/bash
    # Script to set up vLLM for Apple Silicon
    
    # Exit on error
    set -e
    
    echo "Setting up vLLM for Apple Silicon..."
    
    # Activate conda environment
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate ai-cluster
    
    # Install dependencies
    pip install accelerate transformers
    
    # Clone vLLM repository
    if [ ! -d "vllm" ]; then
      git clone https://github.com/vllm-project/vllm.git
    fi
    
    cd vllm
    
    # Install vLLM in development mode
    pip install -e .
    
    echo "vLLM setup complete!"
  EOT
}

resource "null_resource" "make_scripts_executable" {
  depends_on = [
    local_file.ray_head_script,
    local_file.ray_worker_script,
    local_file.vllm_setup_script
  ]
  
  provisioner "local-exec" {
    command = "chmod +x ${local_file.ray_head_script.filename} ${local_file.ray_worker_script.filename} ${local_file.vllm_setup_script.filename}"
  }
}

resource "null_resource" "setup_head_node" {
  depends_on = [null_resource.make_scripts_executable]
  
  provisioner "local-exec" {
    command = "scp ${local_file.ray_head_script.filename} ${local_file.vllm_setup_script.filename} ${var.ssh_username}@${var.head_node_ip}:~/"
  }
  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_username
      host        = var.head_node_ip
    }
    
    inline = [
      "bash ~/ray_head_setup.sh",
      "bash ~/vllm_setup.sh"
    ]
  }
}
resource "null_resource" "setup_worker_node" {
  depends_on = [null_resource.setup_head_node]
  
  provisioner "local-exec" {
    command = "scp ${local_file.ray_worker_script.filename} ${local_file.vllm_setup_script.filename} ${var.ssh_username}@${var.worker_node_ip}:~/"
  }
  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.ssh_username
      host        = var.worker_node_ip
    }
    
    inline = [
      "bash ~/ray_worker_setup.sh",
      "bash ~/vllm_setup.sh"
    ]
  }
}
