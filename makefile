all:
	nvcc main.cu test_cpu.cu test_gpu.cu utils.cu -o wave_sim -gencode arch=compute_50,code=compute_50