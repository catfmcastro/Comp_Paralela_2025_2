// 


#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define CUDA_CHECK(err) { \
  if(err != cudaSuccess) { \
    fprintf(stderr, "Erro CUDA: %s em %s:%d\n", cudaGetErrorString(err), __FILE__, __LINE__); \
    exit(EXIT_FAILURE); \
  } \
}

// kernel
__global__ void mm_kernel(double* d_a, double* d_b, double* d_c, int width) 
{
    // Calcula o índice global da thread na matriz (linha e coluna)
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    int row = threadIdx.y + blockIdx.y * blockDim.y;

    // Checagem de limites: garante que a thread está dentro dos limites da matriz
    if (row < width && col < width) {
        double sum = 0;
        
        // Loop 'k' original para calcular o produto escalar
        for (int k = 0; k < width; k++) {
            double x = d_a[row * width + k]; // Elemento da linha 'row' de 'a'
            double y = d_b[k * width + col]; // Elemento da coluna 'col' de 'b'
            sum += x * y;
        }
        
        // Armazena o resultado na posição correta em 'c'
        d_c[row * width + col] = sum;
    }
}

// função host
int main()
{
    int width = 2000;
    size_t size = (size_t)width * width * sizeof(double);

    // alocar memória no host (CPU)
    double *a = (double*) malloc (size);
    double *b = (double*) malloc (size);
    double *c = (double*) malloc (size);

    // inicializar dados no host
    for(int i = 0; i < width; i++) {
        for(int j = 0; j < width; j++) {
            a[i*width+j] = (double)i;
            b[i*width+j] = (double)j;
            c[i*width+j] = 0;
        }
    }

    // alocar memória no devide (GPU)
    double *d_a, *d_b, *d_c;
    CUDA_CHECK(cudaMalloc((void**) &d_a, size));
    CUDA_CHECK(cudaMalloc((void**) &d_b, size));
    CUDA_CHECK(cudaMalloc((void**) &d_c, size));

    // copiar dados do host para o device
    CUDA_CHECK(cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice));

    // tamanho do bloco de threads
    dim3 threadsPerBlock(16, 16);
    
    // define o tamanho do grid
    dim3 numBlocks((width + threadsPerBlock.x - 1) / threadsPerBlock.x,
                   (width + threadsPerBlock.y - 1) / threadsPerBlock.y);

    
    // inicia o kernel
    mm_kernel<<<numBlocks, threadsPerBlock>>>(d_a, d_b, d_c, width);
    
    // sincroniza
    CUDA_CHECK(cudaDeviceSynchronize());

    // copia resultados do device para o host
    CUDA_CHECK(cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost));

    free(a);
    free(b);
    free(c);
    
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}