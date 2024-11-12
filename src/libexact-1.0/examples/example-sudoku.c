
/* 
 * Example program:
 *
 * Outputs all solutions of an instance of sudoku given as input.
 *
 */

/*
 * Usage: 
 *   example-sudoku <input file(s)>
 *
 * File format: 
 *   9 x 9 text array with entries in "123456789.", where '.' is a blank. 
 *   See the files "sudoku-input*" for examples.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "exact.h"

#define UNDEF -1

static void solve_sudoku(int *a)
{
    exact_t *e = exact_alloc();

    /* Row--column */
    for(int r = 0; r < 9; r++)
        for(int c = 0; c < 9; c++)
            exact_declare_row(e, 9*r+c, 1);
    /* Row--value */
    for(int r = 0; r < 9; r++)
        for(int v = 0; v < 9; v++)
            exact_declare_row(e, 81+9*r+v, 1);
    /* Column--value */
    for(int c = 0; c < 9; c++)
        for(int v = 0; v < 9; v++)
            exact_declare_row(e, 162+9*c+v, 1);
    /* Subsquare--value */
    for(int s = 0; s < 9; s++)
        for(int v = 0; v < 9; v++)
            exact_declare_row(e, 243+9*s+v, 1); 
    /* Row--column--value */
    for(int r = 0; r < 9; r++) {
        for(int c = 0; c < 9; c++) {
            int s = 3*(r/3)+c/3;
            for(int v = 0; v < 9; v++) {
                exact_declare_col(e, 9*9*r+9*c+v, 1);

                /* Row--column */
                exact_declare_entry(e, 9*r+c, 9*9*r+9*c+v); 

                /* Row--value */
                exact_declare_entry(e, 81+9*r+v, 9*9*r+9*c+v); 

                /* Column--value */
                exact_declare_entry(e, 162+9*c+v, 9*9*r+9*c+v); 

                /* Subsquare--value */
                exact_declare_entry(e, 243+9*s+v, 9*9*r+9*c+v); 
            }
        }
    }

    /* Push the columns corresponding to the given partial solution. */
    for(int r = 0; r < 9; r++) {
        for(int c = 0; c < 9; c++) {
            if(a[9*r+c] != UNDEF) {
                int j = 9*9*r+9*c+a[9*r+c];
                if(!exact_pushable(e, j)) {
                    /* The partial solution is conflicting. */
                    fprintf(stdout, 
                            "\nconflicting input: "
                            "value %d at row %d, column %d\n",
                            a[9*r+c]+1, r+1, c+1);                  
                    goto solve_done;
                }
                exact_push(e, j);
            }
        }
    }

    /* List all complete solutions. */
    int n;
    const int *b;
    while((b = exact_solve(e, &n)) != NULL) {
        /* Put the solution into matrix form. */
        for(int i = 0; i < n; i++) {
            int r = b[i]/81;
            int c = b[i]/9; c = c%9;
            int v = b[i]%9;
            a[9*r+c] = v;
        }
        /* Print the solution in matrix form. */
        fprintf(stdout, "\n");
        for(int r = 0; r < 9; r++) {
            for(int c = 0; c < 9; c++)
                fprintf(stdout, "%d", a[9*r+c]+1);
            fprintf(stdout, "\n");
        }
        /* Rewind the matrix. */
        for(int i = exact_num_push(e); i < n; i++) {
            int r = b[i]/81;
            int c = b[i]/9; c = c%9;
            a[9*r+c] = UNDEF;
        }
    }   
solve_done:
    exact_free(e);
}

static void skipws(FILE *in)
{
    int z;
    do {
        z = fgetc(in);
    } while(z != EOF && isspace(z));
    if(z != EOF)
        ungetc(z, in);
}

int main(int argc, char **argv)
{
    if(argc < 2) {
        fprintf(stdout, "%s: no input file(s) given\n", argv[0]);
        return 0;
    }
    for(int i = 1; i < argc; i++) {
        fprintf(stdout, "%s: ", argv[i]);
        FILE *in = fopen(argv[i], "r");
        if(in == NULL) {
            fprintf(stdout, "error opening file\n");
            return 1;
        }
        int a[9*9];
        for(int r = 0; r < 9; r++) {
            for(int c = 0; c < 9; c++) {
                skipws(in);
                int z = fgetc(in);
                if(z == '.') {
                    a[9*r+c] = UNDEF;
                } else {
                    if(isdigit(z) && z != '0') {
                        a[9*r+c] = z-'1';
                    } else {
                        fprintf(stdout, "parse error\n");
                        return 1;
                    }
                }
            }
        }
        fclose(in);
        fprintf(stdout, "\n");
        for(int r = 0; r < 9; r++) {
            for(int c = 0; c < 9; c++)
                if(a[9*r+c] != UNDEF)
                    fprintf(stdout, "%d", a[9*r+c]+1);
                else
                    fprintf(stdout, ".");
            fprintf(stdout, "\n");
        }
        solve_sudoku(a);
        fprintf(stdout, "\n");
    }
    return 0;
}
