#include <stdio.h>
#include "exact.h"

int main(void)
{
    exact_t *e = exact_alloc();

    exact_declare_row(e, 1, 1);  exact_declare_row(e, 2, 1);
    exact_declare_row(e, 3, 1);  exact_declare_row(e, 4, 1);
    
    exact_declare_col(e, 1, 1);  exact_declare_col(e, 2, 1);
    exact_declare_col(e, 3, 1);  exact_declare_col(e, 4, 1);
    exact_declare_col(e, 5, 1);

    exact_declare_entry(e, 1, 1);  exact_declare_entry(e, 1, 2);
    exact_declare_entry(e, 1, 5);  exact_declare_entry(e, 2, 1);
    exact_declare_entry(e, 2, 4);  exact_declare_entry(e, 3, 2);  
    exact_declare_entry(e, 3, 5);  exact_declare_entry(e, 4, 1);  
    exact_declare_entry(e, 4, 2);  exact_declare_entry(e, 4, 3);

    int soln_size;
    const int *soln;
    while((soln = exact_solve(e, &soln_size)) != NULL) {
        for(int i = 0; i < soln_size; i++)
            printf("%d ", soln[i]);
        printf("\n");
    }

    exact_free(e);

    return 0;
}
