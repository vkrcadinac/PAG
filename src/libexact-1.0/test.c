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

/**************************************************************** Test code. */

#include <stdio.h>
#include <stdlib.h>
#include "exact.h"

/*********************************** Library interface breaches for testing. */

extern int exact_mem_alloc_balance; /* libexact memory alloc/free balance */
void exact_check(exact_t *e);       /* libexact internal consistency checks */
#include "util.h"                   /* for testing the map mechanism */

/************************************************** Subroutines for testing. */

/* Report failure. */

#define FAIL() failure(__FILE__,__LINE__)

static void failure(const char *fn, int ln)
{
    fprintf(stdout, "FAIL [file = %s, line = %d]\n", fn, ln);
    fprintf(stdout, "TEST FAILED\n");
    fflush(stdout);
    exit(1);
}

/* Colex rank for a 2-subset of nonnegative integers
 * (j > i >= 0 assumed). */

static int colex2(int i, int j)
{
    return (j*(j-1))/2+i;
}

/* Colex rank for a 3-subset of nonnegative integers 
 * (k > j > i >= 0 assumed). */

static int colex3(int i, int j, int k)
{
    return (k*(k-1)*(k-2))/6+(j*(j-1))/2+i;
}

/* Shellsort for an integer array. */

static void shellsort_int(int n, int *a)
{
    int h = 1;
    for(int i = n/3; h < i; h = 3*h+1)
        ;

    do {
        for(int i = h; i < n; i++) {
            int v = a[i];
            int j = i;
            do {
                int t = a[j-h];
                if(t <= v)
                    break;
                a[j] = t;
                j -= h;
            } while(j >= h);
            a[j] = v;
        }
        h /= 3;
    } while(h > 0);
}

/* Test a solution for duplicate columns. */

static int check_simple(int b, const int *soln)
{
    int buf[b];
    for(int i = 0; i < b; i++)
        buf[i] = soln[i];
    shellsort_int(b, buf);
    for(int i = 1; i < b; i++)
        if(buf[i] == buf[i-1])
            return 0;
    return 1;
}

/* Level and filter functions for testing. */

static int level_check(void *p, int b, const int *soln)
{
    exact_t *e = (exact_t *) p;
    exact_check(e);
    return 1;
}

static int level_simple(void *p, int b, const int *soln)
{
    exact_t *e = (exact_t *) p;
    exact_check(e);
    return check_simple(b, soln);
}

static int filter_simple(void *p, int b, const int *soln, int t)
{
    exact_t *e = (exact_t *) p;
    exact_check(e);
    for(int i = 0; i < b; i++)
        if(soln[i] == t)
            return 0;
    return 1;
}

/*************************************************** Test the map mechanism. */

static int int_cmp(const void *a, const void *b)
{
    const int *aa = (const int *) a;
    const int *bb = (const int *) b;
    return (*aa > *bb) - (*aa < *bb);
}

static void map_trial(int p, int r)
{
    /* r assumed to be a primitive root mod p */

    fprintf(stdout, "p = %d, r = %d: ", p, r);
    fflush(stdout);

    int map_z;
    exact_map_t *m = exact_map_alloc(sizeof(int), &int_cmp);
    int i = 1;
    do {
        i = (i*r)%p;        
        if(exact_map_find(m, &i))
            FAIL();
        for(int j = 10; j >= 0; j--) {
            exact_map_associate(m, &map_z + i + j);
            if(exact_map_value(m) != &map_z + i + j)
                FAIL();
        }
    } while(i != 1);

    i = 1;
    do {
        i = (i*r)%p;        
        if(!exact_map_find(m, &i))
            FAIL();
        if(exact_map_value(m) != &map_z + i)
            FAIL();
    } while(i != 1);

    exact_map_free(m);

    fprintf(stdout, "success\n");
    fflush(stdout);
}

static void map_test(void)
{
    fprintf(stdout, "test: map mechanism\n");
    map_trial(11, 2);      /*  2 is a primitive root mod 11 */
    map_trial(101, 2);     /*  2 is a primitive root mod 101 */
    map_trial(1009, 11);   /* 11 is a primitive root mod 1009 */
    map_trial(10007, 2);   /*  2 is a primitive root mod 10007 */
    map_trial(100003, 2);  /*  2 is a primitive root mod 100003 */
    map_trial(1000003, 2); /*  2 is a primitive root mod 1000003 */
}

/***************************************************** Subset covering test. */

static void check_covering(int n, int q, int simple, int ss, const int *soln)
{
    int deg[n];
    for(int j = 0; j < n; j++)
        deg[j] = 0;
    for(int i = 0; i < ss; i++)
        for(int j = 0; j < n; j++)
            if(soln[i] & (1<<j))
                deg[j]++;
    for(int j = 0; j < n; j++)
        if(deg[j] != q)
            FAIL();
    if(simple && !check_simple(ss, soln))
        FAIL();
}

static void subset_covering_trial(int n, int q, int simple, int count)
{
    fprintf(stdout, 
            "n = %d, q = %d, simple = %d: ",
            n, q, simple);
    fflush(stdout);

    exact_t *e = exact_alloc();     
    int m = 1 << n;
    for(int i = 0; i < n; i++)
        exact_declare_row(e, i, q);
    for(int j = 1; j < m; j++) { 
        exact_declare_col(e, j, simple ? 1 : q);
        for(int i = 0; i < n; i++)
            if(j & (1 << i))
                exact_declare_entry(e, i, j);
    }
    exact_level(e, &level_check, e);
    int c = 0;
    int ss;
    const int *soln;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, q, simple, ss, soln);
        c++;
    }
    int cc = 0;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, q, simple, ss, soln);
        cc++;
    }
    if(c != cc)
        FAIL();
    if(c != count)
        FAIL();
    exact_free(e);

    /* Test level and filter functions for simple coverings. */
    if(simple) {
        e = exact_alloc();     
        m = 1 << n;
        for(int i = 0; i < n; i++)
            exact_declare_row(e, i, q);
        for(int j = 1; j < m; j++) { 
            exact_declare_col(e, j, q+1);
            for(int i = 0; i < n; i++)
                if(j & (1 << i))
                    exact_declare_entry(e, i, j);
        }
        exact_level(e, &level_simple, e);
        c = 0;
        while((soln = exact_solve(e, &ss)) != NULL) {
            check_covering(n, q, simple, ss, soln);
            c++;
        }
        cc = 0;
        while((soln = exact_solve(e, &ss)) != NULL) {
            check_covering(n, q, simple, ss, soln);
            cc++;
        }
        if(c != cc)
            FAIL();
        if(c != count)
            FAIL();
        exact_level(e, &level_check, e);
        exact_filter(e, &filter_simple, e);
        c = 0;
        while((soln = exact_solve(e, &ss)) != NULL) {
            check_covering(n, q, simple, ss, soln);
            c++;
        }
        cc = 0;
        while((soln = exact_solve(e, &ss)) != NULL) {
            check_covering(n, q, simple, ss, soln);
            cc++;
        }
        if(c != cc)
            FAIL();
        if(c != count)
            FAIL();
        exact_free(e);
    }
    fprintf(stdout, "success (%d)\n", c);
    fflush(stdout);
}

static void subset_covering_test(void)
{
    fprintf(stdout, "test: Bell numbers (A000110)\n");
    subset_covering_trial(0,1,1,1);
    subset_covering_trial(1,1,1,1);
    subset_covering_trial(2,1,1,2);
    subset_covering_trial(3,1,1,5);
    subset_covering_trial(4,1,1,15);
    subset_covering_trial(5,1,1,52);
    subset_covering_trial(6,1,1,203);
    subset_covering_trial(7,1,1,877);
    subset_covering_trial(8,1,1,4140);
    subset_covering_trial(9,1,1,21147);
    subset_covering_trial(10,1,1,115975);

    fprintf(stdout, "test: bicoverings (A020554)\n");
    subset_covering_trial(0,2,0,1);
    subset_covering_trial(1,2,0,1);
    subset_covering_trial(2,2,0,3);
    subset_covering_trial(3,2,0,16);
    subset_covering_trial(4,2,0,139);
    subset_covering_trial(5,2,0,1750);
    subset_covering_trial(6,2,0,29388);
    subset_covering_trial(7,2,0,624889);

    fprintf(stdout, "test: simple bicoverings (A002718)\n");
    subset_covering_trial(0,2,1,1);
    subset_covering_trial(1,2,1,0);
    subset_covering_trial(2,2,1,1);
    subset_covering_trial(3,2,1,8);
    subset_covering_trial(4,2,1,80);
    subset_covering_trial(5,2,1,1088);
    subset_covering_trial(6,2,1,19232);
    subset_covering_trial(7,2,1,424400);

    fprintf(stdout, "test: tricoverings (n/a)\n");
    subset_covering_trial(0,3,0,1);
    subset_covering_trial(1,3,0,1);
    subset_covering_trial(2,3,0,4);
    subset_covering_trial(3,3,0,39);
    subset_covering_trial(4,3,0,862);
    subset_covering_trial(5,3,0,35775);
    subset_covering_trial(6,3,0,2406208);

    fprintf(stdout, "test: simple tricoverings (A060486)\n");
    subset_covering_trial(0,3,1,1);
    subset_covering_trial(1,3,1,0);
    subset_covering_trial(2,3,1,0);
    subset_covering_trial(3,3,1,5);
    subset_covering_trial(4,3,1,205);
    subset_covering_trial(5,3,1,11301);
    subset_covering_trial(6,3,1,904580);
}

/******************************************************* Regular graph test. */

static void check_graph(int n, int k, int simple, int ss, const int *soln, 
                        int *edge_tab)
{
    int deg[n];
    for(int i = 0; i < n; i++)
        deg[i] = 0;
    for(int i = 0; i < ss; i++) {
        deg[edge_tab[2*soln[i]+0]]++;
        deg[edge_tab[2*soln[i]+1]]++;
    }
    for(int i = 0; i < n; i++)
        if(deg[i] != k)
            FAIL();
    if(simple && !check_simple(ss, soln))
        FAIL();
}

static void regular_graph_trial(int n, int k, int simple, int count)
{
    fprintf(stdout, 
            "n = %d, k = %d, simple = %d: ",
            n, k, simple);
    fflush(stdout);

    exact_t *e = exact_alloc();
    for(int i = 0; i < n; i++)
        exact_declare_row(e, i, k);
    int edge_tab[n*(n-1)];
    for(int i = 0; i < n; i++) {
        for(int j = i+1; j < n; j++) {
            int r = colex2(i,j);
            edge_tab[2*r+0] = i;
            edge_tab[2*r+1] = j;            
            exact_declare_col(e, r, simple ? 1 : k+1);
            exact_declare_entry(e, i, r);
            exact_declare_entry(e, j, r);
        }
    }
    exact_level(e, &level_check, e);
    int c = 0;
    int ss;
    const int *soln;    
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_graph(n, k, simple, ss, soln, edge_tab);
        c++;
    }
    int cc = 0;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_graph(n, k, simple, ss, soln, edge_tab);
        cc++;
    }
    exact_free(e);
    if(c != cc)
        FAIL();
    if(c != count)
        FAIL();
    fprintf(stdout, "success (%d)\n", c);
    fflush(stdout);
}

static void regular_graph_test(void)
{
    fprintf(stdout, 
            "test: 1-regular labeled loopless graphs (A001147)\n");
    regular_graph_trial(0,1,1,1);
    regular_graph_trial(2,1,1,1);
    regular_graph_trial(4,1,1,3);
    regular_graph_trial(6,1,1,15);
    regular_graph_trial(8,1,1,105);
    regular_graph_trial(10,1,1,945);
    regular_graph_trial(12,1,1,10395);
    regular_graph_trial(14,1,1,135135);
    regular_graph_trial(16,1,1,2027025);

    fprintf(stdout, 
            "test: 2-regular labeled loopless graphs (A001205)\n");
    regular_graph_trial(0,2,1,1);
    regular_graph_trial(1,2,1,0);
    regular_graph_trial(2,2,1,0);
    regular_graph_trial(3,2,1,1);
    regular_graph_trial(4,2,1,3);
    regular_graph_trial(5,2,1,12);
    regular_graph_trial(6,2,1,70);
    regular_graph_trial(7,2,1,465);
    regular_graph_trial(8,2,1,3507);
    regular_graph_trial(9,2,1,30016);
    regular_graph_trial(10,2,1,286884);

    fprintf(stdout, 
            "test: 2-regular labeled loopless multigraphs (A002137)\n");
    regular_graph_trial(0,2,0,1);
    regular_graph_trial(1,2,0,0);
    regular_graph_trial(2,2,0,1);
    regular_graph_trial(3,2,0,1);
    regular_graph_trial(4,2,0,6);
    regular_graph_trial(5,2,0,22);
    regular_graph_trial(6,2,0,130);
    regular_graph_trial(7,2,0,822);
    regular_graph_trial(8,2,0,6202);
    regular_graph_trial(9,2,0,52552);
    regular_graph_trial(10,2,0,499194);

    fprintf(stdout, 
            "test: 3-regular labeled loopless graphs (A002829)\n");
    regular_graph_trial(0,3,1,1);
    regular_graph_trial(2,3,1,0);
    regular_graph_trial(4,3,1,1);
    regular_graph_trial(6,3,1,70);
    regular_graph_trial(8,3,1,19355);

    fprintf(stdout, 
            "test: 3-regular labeled loopless multigraphs (A108243)\n");
    regular_graph_trial(0,3,0,1);
    regular_graph_trial(2,3,0,1);
    regular_graph_trial(4,3,0,10);
    regular_graph_trial(6,3,0,760);
    regular_graph_trial(8,3,0,190050);
}

/******************************************************* Triple system test. */

static void check_triple_system(int v, int lambda, int simple, 
                                int ss, const int *soln, int *triple_pair_tab)
{
    int deg[v*(v-1)];
    int n = (v*(v-1))/2;
    for(int i = 0; i < n; i++)
        deg[i] = 0;
    for(int i = 0; i < ss; i++) {
        deg[triple_pair_tab[3*soln[i]+0]]++;
        deg[triple_pair_tab[3*soln[i]+1]]++;
        deg[triple_pair_tab[3*soln[i]+2]]++;
    }
    for(int i = 0; i < n; i++)
        if(deg[i] != lambda)
            FAIL();
    if(simple && !check_simple(ss, soln))
        FAIL();
}

static void triple_system_trial(int v, int lambda, int simple, int count)
{

    fprintf(stdout, 
            "v = %d, lambda = %d, simple = %d: ",
            v, lambda, simple);
    fflush(stdout);

    exact_t *e = exact_alloc();
    for(int i = 0; i < v; i++)
        for(int j = i+1; j < v; j++)
            exact_declare_row(e, colex2(i,j), lambda);
    int triple_pair_tab[v*(v-1)*(v-2)];
    for(int i = 0; i < v; i++) {
        for(int j = i+1; j < v; j++) {
            for(int k = j+1; k < v; k++) {
                int r = colex3(i,j,k);
                triple_pair_tab[3*r+0] = colex2(i,j);
                triple_pair_tab[3*r+1] = colex2(i,k);            
                triple_pair_tab[3*r+2] = colex2(j,k);
                exact_declare_col(e, r, simple ? 1 : k+1);
                exact_declare_entry(e, colex2(i,j), r);
                exact_declare_entry(e, colex2(i,k), r);
                exact_declare_entry(e, colex2(j,k), r);
            }
        }
    }
    exact_level(e, &level_check, e);
    int c = 0;
    int ss;
    const int *soln;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_triple_system(v, lambda, simple, ss, soln, triple_pair_tab);
        c++;
    }
    int cc = 0;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_triple_system(v, lambda, simple, ss, soln, triple_pair_tab);
        cc++;
    }
    exact_free(e);
    if(c != cc)
        FAIL();
    if(c != count)
        FAIL();
    fprintf(stdout, "success (%d)\n", c);
    fflush(stdout);
}

static void triple_system_test(void)
{
    fprintf(stdout, "test: Steiner triple systems (A001201)\n");
    triple_system_trial(3, 1, 1, 1);
    triple_system_trial(7, 1, 1, 30);
    triple_system_trial(9, 1, 1, 840);

    fprintf(stdout, "test: twofold triple systems (n/a)\n");
    triple_system_trial(3, 2, 0, 1);
    triple_system_trial(4, 2, 0, 1);
    triple_system_trial(6, 2, 0, 12);
    triple_system_trial(7, 2, 0, 465);
    triple_system_trial(9, 2, 0, 4409916);

    fprintf(stdout, "test: simple twofold triple systems (n/a)\n");
    triple_system_trial(3, 2, 1, 0);
    triple_system_trial(4, 2, 1, 1);
    triple_system_trial(6, 2, 1, 12);
    triple_system_trial(7, 2, 1, 120);
    triple_system_trial(9, 2, 1, 1929816);

    fprintf(stdout, "test: threefold triple systems (n/a)\n");
    triple_system_trial(5, 3, 0, 1);
    triple_system_trial(7, 3, 0, 5045);

    fprintf(stdout, "test: simple threefold triple systems (n/a)\n");
    triple_system_trial(5, 3, 0, 1);
    triple_system_trial(7, 3, 1, 120);
}

/***************************************************** Test reset mechanism. */

static void reset_trial(int n, int q, int simple, int count, int niter)
{
    fprintf(stdout, 
            "n = %d, q = %d, simple = %d, count = %d, niter = %d: ",
            n, q, simple, count, niter);
    fflush(stdout);

    exact_t *e = exact_alloc();     
    exact_t *ref = exact_alloc();     
    int m = 1 << n;
    for(int i = 0; i < n; i++) {
        exact_declare_row(e, i, q);
        exact_declare_row(ref, i, q);
    }
    for(int j = 1; j < m; j++) { 
        exact_declare_col(e, j, simple ? 1 : q);
        exact_declare_col(ref, j, simple ? 1 : q);
        for(int i = 0; i < n; i++)
            if(j & (1 << i)) {
                exact_declare_entry(e, i, j);
                exact_declare_entry(ref, i, j);
            }
    }
    exact_level(e, &level_check, e);
    exact_level(ref, &level_check, ref);
    
    int c = 0;
    int ss, refss;
    const int *soln, *refsoln;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, q, simple, ss, soln);
        c++;
        if(c == count)
            break;
    }
    if(c < count)
        FAIL();
    for(int u = 0; u < niter; u++) {
        exact_reset_solve(e);
        for(int v = 0; v < count; v++) {
            soln = exact_solve(e, &ss);
            refsoln = exact_solve(ref, &refss);
            if(soln == NULL || refsoln == NULL)
                FAIL();
            if(ss != refss)
                FAIL();
            for(int i = 0; i < ss; i++)
                if(soln[i] != refsoln[i])
                    FAIL();
            check_covering(n, q, simple, ss, soln);
            check_covering(n, q, simple, refss, refsoln);
        }
        exact_reset_solve(ref);
    }
    exact_free(ref);
    exact_free(e);
    fprintf(stdout, "success\n");
    fflush(stdout);
}

static void reset_test(void)
{
    fprintf(stdout, "test: reset mechanism\n");
    int niter = 5;
    for(int c = 1; c <= 101; c+=10) {
        reset_trial(6,1,1,c,niter);
        reset_trial(7,1,1,c,niter);
        reset_trial(8,1,1,c,niter);
        reset_trial(9,1,1,c,niter);
        reset_trial(10,1,1,c,niter);
        reset_trial(4,2,0,c,niter);
        reset_trial(5,2,0,c,niter);
        reset_trial(6,2,0,c,niter);
        reset_trial(7,2,0,c,niter);
        reset_trial(5,2,1,c,niter);
        reset_trial(6,2,1,c,niter);
        reset_trial(7,2,1,c,niter);
        reset_trial(4,3,0,c,niter);
        reset_trial(5,3,0,c,niter);
        reset_trial(4,3,1,c,niter);
        reset_trial(5,3,1,c,niter);
        reset_trial(6,3,1,c,niter);
    }
}

/************************************************** Test push/pop mechanism. */

static int getidx(int n, int q, int ss, const int *soln)
{
    int deg[n];
    for(int j = 0; j < n; j++)
        deg[j] = q;
    for(int i = 0; i < ss; i++)
        for(int j = 0; j < n; j++)
            if(soln[i] & (1<<j))
                deg[j]--;
    int degfreq[q+1];
    for(int j = 0; j <= q; j++)
        degfreq[j] = 0;
    for(int j = 0; j < n; j++)
        degfreq[deg[j]]++;
    int r = 0;
    int b = 1;
    for(int i = 0; i <= q; i++) {
        r=r+b*degfreq[i];
        b=b*(n+1);      
    }
    return r;
}

static void compute_table(int n, int q, int *t)
{
    int degfreq[q+1];
    for(int j = 0; j <= q; j++)
        degfreq[j] = 0;
    int z = 0;
    int i;
    int deg[n];
    do {
        i = 0;
        int j = 0;
        for(; i <= q; i++) {
            int k;
            for(k = 0; k < degfreq[i]; k++) {
                if(j < n)
                    deg[j++] = i;
                else
                    break;
            }
            if(k < degfreq[i])
                break;
        }
        int c = 0;
        if(i > q && j == n) {
            exact_t *e = exact_alloc();     
            int m = 1 << n;
            for(int k = 0; k < n; k++)
                if(deg[k] > 0)
                    exact_declare_row(e, k, deg[k]);
            for(int k = 1; k < m; k++) { 
                exact_declare_col(e, k, q);
                int l = 0;              
                for(; l < n; l++)
                    if((k & (1 << l)) && deg[l] == 0)
                        break;
                if(l == n) {
                    for(int u = 0; u < n; u++)
                        if(k & (1 << u))
                            exact_declare_entry(e, u, k);
                }
            }
            int ss;
            const int *soln; 
            while((soln = exact_solve(e, &ss)) != NULL)
                c++;
            exact_free(e);
        }
        t[z] = c;
        z++;
        degfreq[0]++;
        i = 0;
        while(i <= q && degfreq[i] > n) {
            degfreq[i] = 0;
            if(i < q)
                degfreq[i+1]++;
            i++;
        }
    } while(i <= q);        
}

static void pushpop_trial(int n, int q, int d)
{
    int size = 1;
    for(int j = 0; j < q+2; j++)
        size*=(n+1);
    int t[size];

    fprintf(stdout, 
            "n = %d, q = %d, d = %d: ",
            n, q, d);
    fflush(stdout);

    compute_table(n, q, t);

    exact_t *e = exact_alloc();     
    int m = 1 << n;
    for(int j = 0; j < n; j++)
        exact_declare_row(e, j, q);
    for(int k = 1; k < m; k++) { 
        exact_declare_col(e, k, q);
        for(int j = 0; j < n; j++)
            if(k & (1 << j))
                exact_declare_entry(e, j, k);
    }
    exact_level(e, &level_check, e);
    int *cols[d];
    for(int j = 0; j < d; j++) {
        cols[j] = malloc(sizeof(int)*m);
        if(cols[j] == NULL)
            FAIL();
    }
    int lvl = 0;
    int i;
    int num[d];
    int pos[d];
    int pushed[n*q];
lvlup:
    if(lvl == d) {
        int np = exact_get_push(e, pushed);     
        int z = getidx(n, q, np, pushed);
        int c = 0;
        int ss;
        const int *soln; 
        while((soln = exact_solve(e, &ss)) != NULL) {
            check_covering(n, q, 0, ss, soln);
            c++;
        }
        int cc = 0;
        while((soln = exact_solve(e, &ss)) != NULL) {
            check_covering(n, q, 0, ss, soln);
            cc++;
        }
        if(c != cc)
            FAIL();
        if(c != t[z])
            FAIL();
        goto lvldown;
    }
    num[lvl] = exact_get_cols(e, cols[lvl]);
    for(i = 0; i < num[lvl]; i++) {
        exact_push(e, cols[lvl][i]);
        exact_check(e);
        pos[lvl] = i;
        lvl++;
        goto lvlup;
    lvldown:
        if(lvl == 0)
            goto stop;
        lvl--;
        i = pos[lvl];
        exact_pop(e);
        exact_check(e);
    }
    goto lvldown;
stop:
    for(int j = 0; j < d; j++)
        free(cols[j]);    
    exact_free(e);

    fprintf(stdout, "success\n");
    fflush(stdout);
}

static void pushpop_test(void)
{
    fprintf(stdout, "test: push/pop mechanism\n");
    int q = 1;
    for(int n = 1; n <= 8; n++)
        for(int d = 1; d <= n; d++)
            pushpop_trial(n,q,d);
    q = 2;
    for(int n = 1; n <= 6; n++)
        for(int d = 1; d <= n && (d <= 3 || n <= 4); d++)
            pushpop_trial(n,q,d);
    q = 3;
    for(int n = 1; n <= 5; n++)
        for(int d = 1; d <= n && (d <= 2 || n <= 4); d++)
            pushpop_trial(n,q,d);
    q = 4;
    for(int n = 1; n <= 5; n++)
        for(int d = 1; d <= n && (d <= 1 || n <= 4); d++)
            pushpop_trial(n,q,d);
}

/****************************************** Test level and filter functions. */

static int level_f(void *p, int ss, const int *soln)
{
    exact_t *e = (exact_t *) p;
    exact_check(e);
    for(int i = 0; i < ss; i++)
        for(int j = i+1; j < ss; j++)
            if((soln[i] & soln[j]) &&
               soln[i] != soln[j])
                return 0;
    return 1;
}

static int filter_f(void *p, int ss, const int *soln, int t)
{
    exact_t *e = (exact_t *) p;
    exact_check(e);
    for(int i = 0; i < ss; i++)
        if((t & soln[i]) &&
           (t != soln[i]))
            return 0;
    return 1;
}

static void level_filter_trial(int n, int count)
{
    fprintf(stdout, 
            "n = %d: ",
            n);
    fflush(stdout);

    exact_t *e = exact_alloc();
    for(int i = 0; i < n; i++)
        exact_declare_row(e, 1<<i, 2);
    for(int i = 0; i < n; i++) {
        for(int j = i+1; j < n; j++) {
            exact_declare_col(e, (1<<i)|(1<<j), n+1);
            exact_declare_entry(e, 1<<i, (1<<i)|(1<<j));
            exact_declare_entry(e, 1<<j, (1<<i)|(1<<j));
        }
    }
    exact_level(e, &level_f, e);
    int c = 0;
    int ss;
    const int *soln;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, 2, 0, ss, soln);
        c++;
    }
    int cc = 0;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, 2, 0, ss, soln);
        cc++;
    }
    if(c != cc)
        FAIL();
    if(c != count)
        FAIL();
    exact_level(e, NULL, NULL);
    exact_filter(e, &filter_f, e);
    c = 0;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, 2, 0, ss, soln);
        c++;
    }
    cc = 0;
    while((soln = exact_solve(e, &ss)) != NULL) {
        check_covering(n, 2, 0, ss, soln);
        cc++;
    }
    exact_free(e);
    if(c != cc)
        FAIL();
    if(c != count)
        FAIL();

    fprintf(stdout, "success (%d)\n", c);
    fflush(stdout);
}

static void level_filter_test(void)
{
    fprintf(stdout, 
            "test: level and filter functions\n");
    level_filter_trial(0,1);
    level_filter_trial(2,1);
    level_filter_trial(4,3);
    level_filter_trial(6,15);
    level_filter_trial(8,105);
    level_filter_trial(10,945);
    level_filter_trial(12,10395);
    level_filter_trial(14,135135);
}

/****************************************************** Program entry point. */

int main(void)
{
    map_test();
    subset_covering_test();
    regular_graph_test();
    triple_system_test();
    pushpop_test();
    level_filter_test();
    reset_test();

    if(exact_mem_alloc_balance != 0)
        FAIL(); /* Memory alloc/free balance fails. */

    fprintf(stdout, "test successful\n");
    return 0;
}
