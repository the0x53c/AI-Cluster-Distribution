import ray
import time
import platform
import torch
import psutil

ray.init(address="auto")
@ray.remote
def get_system_info():
    return {
        "hostname": platform.node(),
        "platform": platform.platform(),
        "python_version": platform.python_version(),
        "cpu_count": psutil.cpu_count(logical=False),
        "total_memory_gb": round(psutil.virtual_memory().total / (1024**3), 2),
        "available_memory_gb": round(psutil.virtual_memory().available / (1024**3), 2),
        "torch_version": torch.__version__,
        "mps_available": torch.backends.mps.is_available(),
    }
system_infos = ray.get([get_system_info.remote() for _ in range(2)])

print("\n=== Cluster Information ===")
for i, info in enumerate(system_infos):
    print(f"\nNode {i+1}: {info['hostname']}")
    print(f"Platform: {info['platform']}")
    print(f"Python version: {info['python_version']}")
    print(f"CPU cores: {info['cpu_count']}")
    print(f"Total memory: {info['total_memory_gb']} GB")
    print(f"Available memory: {info['available_memory_gb']} GB")
    print(f"PyTorch version: {info['torch_version']}")
    print(f"MPS available: {info['mps_available']}")
@ray.remote
def compute_intensive_task(size):
    start_time = time.time()
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    
    a = torch.randn(size, size, device=device)
    b = torch.randn(size, size, device=device)
  
    for _ in range(10):
        c = torch.matmul(a, b)
    
    end_time = time.time()
    return end_time - start_time

print("\n=== Performance Test ===")
matrix_size = 2000
print(f"Running matrix multiplication test with size {matrix_size}x{matrix_size}...")
futures = [compute_intensive_task.remote(matrix_size) for _ in range(4)]
results = ray.get(futures)
print(f"Average execution time: {sum(results)/len(results):.2f} seconds")
print(f"Total computation time saved: {sum(results) - max(results):.2f} seconds")
print("\nRay cluster is working correctly!")
