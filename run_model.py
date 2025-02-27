import os
import ray
import torch
from transformers import AutoTokenizer, AutoModelForCausalLM
from typing import List, Dict, Any

ray.init(address="auto")
print(f"Connected to Ray cluster: {ray.is_initialized()}")
print(f"Available resources: {ray.available_resources()}")
@ray.remote
def generate_text(
    model_name: str,
    prompt: str,
    max_new_tokens: int = 512,
    temperature: float = 0.7,
    device: str = "mps"
) -> str:
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float16,
        device_map=device
    )
  
    inputs = tokenizer(prompt, return_tensors="pt").to(device)
    with torch.no_grad():
        outputs = model.generate(
            inputs.input_ids,
            max_new_tokens=max_new_tokens,
            temperature=temperature,
            do_sample=True
        )
    return tokenizer.decode(outputs[0], skip_special_tokens=True)
def run_distributed_inference(
    model_name: str,
    prompts: List[str],
    max_new_tokens: int = 512,
    temperature: float = 0.7
) -> List[str]:
    futures = [
        generate_text.remote(
            model_name=model_name,
            prompt=prompt,
            max_new_tokens=max_new_tokens,
            temperature=temperature
        )
        for prompt in prompts
    ]
    
    return ray.get(futures)

if __name__ == "__main__":
    model_name = "TinyLlama/TinyLlama-1.1B-Chat-v1.0" 
    
    prompts = [
        "Explain quantum computing in simple terms.",
        "Write a short poem about artificial intelligence.",
        "What are the main challenges in distributed computing?",
        "How does machine learning differ from traditional programming?"
    ]
    
    print("Running distributed inference...")
    results = run_distributed_inference(model_name, prompts)
    
    for i, result in enumerate(results):
        print(f"\n--- Result {i+1} ---")
        print(result)
