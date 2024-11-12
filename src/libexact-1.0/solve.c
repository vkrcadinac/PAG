/* 
 * libexact v1.0 --- a software library for solving combinatorial 
 *                   exact covering problems
 * 
 * Copyright (C) 2008 Petteri Kaski <petteri.kaski@cs.helsinki.fi>
 *                    Olli Pottonen <olli.pottonen@tkk.fi>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
 * MA  02110-1301, USA.
 * 
 */

/*************************************************** Command-line interface. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include "exact.h"

static int skipws(FILE *in, int *line, int stop_lf)
{
    int c;
    do {
        c = fgetc(in);
        if(c == '\n') {
            if(stop_lf) {
                ungetc(c, in);
                return 1;
            } else {
                (*line)++;
            }
        }
        if(c == EOF)
            break;
    } while(isspace(c));
    if(c != EOF) {
        ungetc(c, in);
        return 1;
    }
    return 0;
}

static int expect_int(FILE *in, int *line)
{
    skipws(in, line, 1);
    int c = fgetc(in);
    ungetc(c, in);
    if(isdigit(c) || c=='-')
        return 1;
    return 0;
}

static void error(const char *fn, int line, const char *format, ...)
{
    va_list args;
    va_start(args, format);
    fprintf(stderr, "error [%s, line %d]: ", fn, line);
    vfprintf(stderr, format, args);
    fprintf(stderr, "\n");
    va_end(args);
    exit(1);
}

#define ERROR(...) error(fn, line, __VA_ARGS__)

static exact_t *parse_input(const char *fn, FILE *in)
{
    exact_t *e = exact_alloc();
    int line = 1;
    while(1) {
        if(!skipws(in, &line, 0))
            break;
        int c = fgetc(in);
        int row, col, b, u;
        switch(c) {
        case '#':
            /* Comment: skip to next input line */
            do {
                c = fgetc(in);
            } while(c != EOF && c != '\n');
            if(c == '\n')
                ungetc(c, in);
            break;
        case 'r':
            /* Row definition */
            if(!expect_int(in, &line))
                ERROR("expecting row identifier");
            if(fscanf(in, "%d", &row) != 1)
                ERROR("expecting row identifier");
            skipws(in, &line, 1);
            c = fgetc(in);
            if(c != EOF)
                ungetc(c, in);
            if(c != '\n' && c != '#' && c != EOF) {
                if(fscanf(in, "%d", &b) != 1) 
                    ERROR("expecting b parameter");
                if(b <= 0)
                    ERROR("nonpositive b parameter");
            } else {
                b = 1;
            }
            if(exact_is_row(e, row))
                ERROR("row %d already defined", row);
            if(!exact_can_declare(e))
                ERROR("cannot declare in current mode");
            exact_declare_row(e, row, b);
            break;
        case 'c':
            /* Column definition */
            if(!expect_int(in, &line))
                ERROR("expecting column identifier");
            if(fscanf(in, "%d", &col) != 1)
                ERROR("expecting column identifier");
            skipws(in, &line, 1);
            c = fgetc(in);
            if(c != EOF)
                ungetc(c, in);
            if(c != '\n' && c != '#' && c != EOF) {
                if(fscanf(in, "%d", &u) != 1)
                    ERROR("expecting u parameter");
                if(u <= 0)
                    ERROR("nonpositive u parameter");
            } else {
                u = 1;
            }           
            if(exact_is_col(e, col))
                ERROR("column %d already defined", col);
            if(!exact_can_declare(e))
                ERROR("cannot declare in current mode");
            exact_declare_col(e, col, u);
            break;
        case 'e':
            /* Entry definition */
            if(!expect_int(in, &line))
                ERROR("expecting row identifier");
            if(fscanf(in, "%d", &row) != 1)
                ERROR("expecting row identifier");
            if(!exact_is_row(e, row))
                ERROR("row %d is undefined", row);
            if(!expect_int(in, &line))
                ERROR("expecting column identifier");
            if(fscanf(in, "%d", &col) != 1)
                ERROR("expecting column identifier");
            if(!exact_is_col(e, col))
                ERROR("column %d is undefined", col);
            if(exact_is_entry(e, row, col))
                ERROR("entry at row %d, column %d already set to 1", 
                      row, col);
            if(!exact_can_declare(e))
                ERROR("cannot declare in current mode");
            exact_declare_entry(e, row, col);
            break;
        case 'p':
            /* Push a column */
            if(!expect_int(in, &line))
                ERROR("expecting column identifier");
            if(fscanf(in, "%d", &col) != 1)
                ERROR("expecting column identifier");
            if(!exact_is_col(e, col))
                ERROR("column %d is undefined", col);
            if(!exact_pushable(e, col))
                ERROR("column %d is conflicting", col);
            exact_push(e, col);
            break;
        default:
            ERROR("parse error");
            break;
        }
    }
    return e;
}

#define CMD_LIST 0
#define CMD_COUNT 1

int main(int argc, char **argv)
{
    int a = 1;
    int cmd = CMD_LIST;
    if(a < argc) {
        if(!strcmp(argv[a], "-c") ||
           !strcmp(argv[a], "--count")) {
            cmd = CMD_COUNT;
            a++;
        } else if(!strcmp(argv[a], "-l") ||
           !strcmp(argv[a], "--list")) {
            cmd = CMD_LIST;
            a++;
        }
    }
    const char *fn;
    FILE *in;
    if(a >= argc) {
        fn = "stdin";
        in = stdin;
    } else {
        fn = argv[a];
        a++;
        in = fopen(fn, "r");
        if(in == NULL) {
            fprintf(stderr, 
                    "solve: error opening input file \"%s\"\n", 
                    fn);
            return 1;
        }
    }
    exact_t *e = parse_input(fn, in);
    const int *soln;
    int n;
    if(cmd == CMD_LIST) {
        while((soln = exact_solve(e, &n)) != NULL) {
            for(int i = 0; i < n; i++) 
                fprintf(stdout, "%d%s", soln[i], i == n-1 ? "" : " ");
            fprintf(stdout, "\n");
        }
    } else if(cmd == CMD_COUNT) {
        long int count = 0;
        while((soln = exact_solve(e, &n)) != NULL)
            count++;
        fprintf(stdout, "%ld\n", count);
    }
    exact_free(e);
    return 0;
}
