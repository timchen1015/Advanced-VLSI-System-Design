extern const int array_size;
extern const int array_addr;
extern int _test_start;

int main(void) {
    int count = array_size;
    if (count <= 0) {
        return 0;
    }

    if (count > 64) {
        count = 64;
    }

    int buffer[64];
    const int *input = &array_addr;
    int *output = &_test_start;

    for (int i = 0; i < count; ++i) {
        buffer[i] = input[i];
    }

    for (int i = 1; i < count; ++i) {
        int key = buffer[i];
        int j = i - 1;

        while (j >= 0 && buffer[j] > key) {
            buffer[j + 1] = buffer[j];
            --j;
        }

        buffer[j + 1] = key;
    }

    for (int i = 0; i < count; ++i) {
        output[i] = buffer[i];
    }

    return 0;
}
