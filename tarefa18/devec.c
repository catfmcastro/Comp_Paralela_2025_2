/*
    devec.c:7:21: missed: not vectorized: control flow in loop. devec.c:31:3: -> if/else quebra fluxo de controle
    missed: statement clobbers memory: devec (&a, &b, &c, &p, 1024); -> a função pode ler ou modificar qualquer parte da memória de forma imprevisível
*/

#include <stdio.h>
#include <stdlib.h>

#define N 1024

void devec(int *a, int *b, int *c, int *p, int n) {
  for (int i = 0; i < n; i++) {
    if (a[i] > 10) {
      c[i] = b[p[i]] * 5;
    } else {
      c[i] = a[i] + b[i];
    }

    a[i] = c[i - 1] * 2;
  }
}

int main() {
  int a[N], b[N], c[N], p[N];
  int n = N;

  for (int i = 0; i < N; i++) {
    a[i] = i % 20;
    b[i] = i;
    c[i] = 0;

    p[i] = (N - 1) - i;
  }
  a[0] = 0;

  devec(a, b, c, p, n);

  // for (int i = 0; i < 10; i++) {
  //     printf("c[%d] = %d\n", i, c[i]);
  // }

  return 0;
}