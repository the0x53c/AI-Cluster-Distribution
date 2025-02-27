# Mac Mini Distributed AI Cluster

A Terraform-based solution for setting up a distributed AI system using Ray and vLLM on Mac Minis with Apple Silicon.

## Overview

This project provides infrastructure-as-code and scripts to create a distributed AI system across multiple Mac Minis. It leverages Ray for distributed computing and adapts vLLM concepts for efficient language model inference on Apple Silicon.

Key features:
- Automated setup using Terraform and bash scripts
- Distributed inference across multiple Mac Minis
- Optimized for Apple Silicon using MPS backend
- Performance testing and monitoring tools
- Support for running various language models

## Requirements

### Hardware
- 2+ Mac Minis with Apple Silicon (M1/M2/M3/M4)
- 16GB+ RAM per machine (32GB recommended)
- Ethernet connection between machines (recommended)

### Software
- macOS Sonoma or newer
- Terraform 1.0+
- SSH access between machines

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/yourusername/mac-mini-ai-cluster.git
cd mac-mini-ai-cluster
```

2. Update the `terraform.tfvars` file with your Mac Mini IP addresses and SSH username:
```hcl
head_node_ip  = "192.168.1.100"  # Replace with your head node IP
worker_node_ip = "192.168.1.101"  # Replace with your worker node IP
ssh_username  = "yourusername"    # Replace with your SSH username
```

3. Initialize and apply the Terraform configuration:
```bash
terraform init
terraform apply
```

4. Test the cluster:
```bash
python test_cluster.py
```

5. Run a language model:
```bash
python run_model.py
```

## Project Structure

```
mac-mini-ai-cluster/
├── README.md                 # This file
├── main.tf                   # Terraform configuration
├── terraform.tfvars          # Terraform variables
├── setup.sh                  # Initial environment setup script
├── ray_head_setup.sh         # Ray head node setup script (generated)
├── ray_worker_setup.sh       # Ray worker node setup script (generated)
├── vllm_setup.sh             # vLLM setup script (generated)
├── test_cluster.py           # Cluster testing script
└── run_model.py              # Model inference script
```

## Detailed Setup Guide

### 1. Environment Setup

Before running Terraform, ensure both Mac Minis have the necessary prerequisites:

```bash
chmod +x setup.sh
./setup.sh
```

This script installs:
- Homebrew
- Python 3.11
- Miniforge (Conda for Apple Silicon)
- Ray and PyTorch dependencies

### 2. SSH Configuration

Ensure passwordless SSH access from the machine running Terraform to both Mac Minis:

```bash
ssh-keygen -t ed25519 -C "mac-mini-cluster"
ssh-copy-id username@head-node-ip
ssh-copy-id username@worker-node-ip
```

### 3. Terraform Deployment

The Terraform configuration creates and executes scripts to:
- Set up a Ray head node
- Connect a Ray worker node
- Install and configure vLLM for Apple Silicon

After running `terraform apply`, you'll see connection information for your Ray cluster.

### 4. Running Models

The `run_model.py` script demonstrates how to run distributed inference on your cluster. By default, it uses TinyLlama-1.1B-Chat, but you can modify it to use other models compatible with Apple Silicon.

## Supported Models

The following models have been tested and work well with this setup:

- TinyLlama (1.1B)
- Phi-2 (2.7B)
- Mistral-7B (with quantization)
- Gemma-2B

Larger models may require quantization or model sharding techniques.

## Performance Considerations

- **Memory Usage**: Monitor memory usage when loading models. Apple Silicon's unified memory architecture means both CPU and GPU share the same memory pool.
- **Network Bandwidth**: Ensure high-speed connections between machines for optimal performance.
- **Thermal Management**: Mac Minis may throttle under sustained load. Ensure adequate cooling.

## Extending the Cluster

To add more worker nodes:

1. Add the new node's IP to `terraform.tfvars`:
```hcl
worker_node_ips = ["192.168.1.101", "192.168.1.102"]
```

2. Update the Terraform configuration to handle multiple worker nodes.

3. Apply the updated configuration:
```bash
terraform apply
```

## Troubleshooting

### Common Issues

**Ray connection errors**:
- Ensure firewalls allow connections on port 6379
- Verify all nodes are on the same network
- Check Ray dashboard at `http://head-node-ip:8265`

**Model loading failures**:
- Reduce model size or implement quantization
- Increase available memory by closing other applications
- Check for MPS compatibility issues with specific models

**Performance issues**:
- Ensure Ethernet (not Wi-Fi) connections between nodes
- Monitor CPU/GPU temperature for thermal throttling
- Verify MPS acceleration is enabled

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Ray Project](https://ray.io/)
- [vLLM Project](https://github.com/vllm-project/vllm)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers/index)
- [PyTorch MPS Documentation](https://pytorch.org/docs/stable/notes/mps.html)

