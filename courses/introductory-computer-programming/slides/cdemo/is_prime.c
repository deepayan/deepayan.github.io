

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

