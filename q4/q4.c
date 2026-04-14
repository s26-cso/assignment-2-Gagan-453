#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main() {
    char op[10]; // op name
    int num1, num2;

    while (scanf("%9s %d %d", op, &num1, &num2) == 3) {
        
        // "./lib<op>.so" is the shared library file
        char lib_name[32];
        snprintf(lib_name, sizeof(lib_name), "./lib%s.so", op);

        // Open the shared library dynamically
        // RTLD_LAZY tells the OS to only resolve symbols as the code needs them.
        void *handle = dlopen(lib_name, RTLD_LAZY);
        if (!handle) {
            fprintf(stderr, "Failed to load library: %s\n", dlerror());
            continue; 
        }

        // Clear any linker errors
        dlerror();

        // define func ptr
        typedef int (*operation_func)(int, int);
        
        // Ask system to find the memory address of the function named op
        operation_func func = (operation_func)dlsym(handle, op);
        
        // if dlsym failed to find the function
        char *error = dlerror();
        if (error != NULL) {
            fprintf(stderr, "Failed to find function '%s': %s\n", op, error);
            dlclose(handle);
            continue;
        }

        int result = func(num1, num2);
        printf("%d\n", result);

        // unload the library.. ccalling multiple times may cross 3gb
        dlclose(handle);
    }

    return 0;
}
