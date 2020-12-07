#include <stdio.h>
#include <stdlib.h>

int is_prime_c(int n) 
{
    int i = 2;
    while (i * i <= n) {
	if (n % i == 0) {
	    return 0;
	}
	i = i + 1;
    }
    return 1;
}


int main(int argc, char *argv[])
{
    int i, n;
    if (argc > 1) {    /* one or more arguments supplied  */
	for (i = 1; i < argc; i++) {
	    n = atoi(argv[i]); 	/* converts string to integer */
	    printf("%d -> %d\n", n, is_prime_c(n));
	}
    }
    else printf("Usage: %s <n1> <n2> ...\n", argv[0]);
    return 0;
}



