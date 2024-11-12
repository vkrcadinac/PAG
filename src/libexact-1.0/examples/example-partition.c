
/* 
 * Example program:
 *
 * Outputs all set partitions of {0,1,...,n-1}. 
 *
 */

#include <stdio.h>
#include "exact.h"

int main(void)
{
    int n = 4;
    int m = 1 << n; /* m == 2^n */

    exact_t *e = exact_alloc();
    for(int i = 0; i < n; i++)
        exact_declare_row(e, i, 1);
    for(int j = 1; j < m; j++) { 
        exact_declare_col(e, j, 1);
        for(int i = 0; i < n; i++) {
            if(j & (1 << i))
                exact_declare_entry(e, i, j);
        }
    }
    int partn_size;
    const int *partn; 
    while((partn = exact_solve(e, &partn_size)) != NULL) {
        printf("{");
        for(int j = 0; j < partn_size; j++) {
            printf("%s{", j == 0 ? "" : ",");
            int k = 0;
            for(int i = 0; i < n; i++)
                if(partn[j] & (1 << i))
                    printf("%s%d", k++ == 0 ? "" : ",", i);
            printf("}");        
        }
        printf("}\n");      
    }
    exact_free(e);

    return 0;
}
