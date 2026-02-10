extern const unsigned int div1;
extern const unsigned int div2;
extern unsigned int _test_start;

unsigned int binary_gcd(unsigned int a, unsigned int b) {
    if (a == 0u) {
        return b;
    }
    if (b == 0u) {
        return a;
    }

    unsigned int shift = 0u;
    while (((a | b) & 1u) == 0u) {
        a >>= 1;
        b >>= 1;
        ++shift;
    }

    while ((a & 1u) == 0u) {
        a >>= 1;
    }

    do {
        while ((b & 1u) == 0u) {
            b >>= 1;
        }

        if (a > b) {
            unsigned int tmp = a;
            a = b;
            b = tmp;
        }

        b -= a;
    } while (b != 0u);

    return a << shift;
}

int main(void) {
    unsigned int result = binary_gcd(div1, div2);
    _test_start = result;
    return 0;
}
