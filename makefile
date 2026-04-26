all:
	nvcc main.cu test_cpu.cu test_gpu.cu shared.cu utils.cu -o wave_sim