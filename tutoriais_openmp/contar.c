#include <stdio.h>

int main() {

#pragma omp parallel
  {
    int i;

    printf("Vamos contar de 1 a 4\n");

    for (i = 1; i <= 4; i++)
      printf("%d\n", i);
  }
}