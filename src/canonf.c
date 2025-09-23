/*
    CANONFILTER.C

    The program takes a list of integral matrices and
    returns the ones that are in canonical form, or a 
    representative for each isomorphism class.

    Input: Dimensions m, n. Optional an m-vector and an 
           n-vector (for tactical decomposition matrices).
           A list of m x n matrices with non-negative 
           integer entries.

    Output: m, n, the vectors (optional), canonical/non-isomorphic matrices

    Vedran Krcadinac (krcko@math.hr), 16.5.2000.
    Department of Mathematics, University of Zagreb, Croatia
*/


#define MAXM 25   /* Maximal number of rows */ 
#define MAXN 100   /* Maximal number of columns */
#define MAXMEM 10000  /* Maximal number of partial permutations 
                         that can be memorised at each step */
#define NULL 0    /* The null pointer */

#include <stdio.h>
#include <stdlib.h>

int A[MAXM][MAXN], C[MAXM][MAXN]; /* The matrices */

char rperm[MAXM], cperm[MAXN]; /* Row and column permutations */

int mask=1;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1,2  Incidence matrix (-i) (default)
        Integral matrix (-m) 
        Tactical decomposition matrix (-t)
     4  Return non-isomorphic matrices (-n, -N)
     8  Print details (-d, -D)
    16  Return canonical representatives (-c, -C)
*/


int readinc(int m, int n)
{ int i,j,ok=1;
  char x;
  
  for (i=0; (ok==1) && (i<m); ++i)
    for (j=0; (ok==1) && (j<n); ++j)
    { x=32;
      while ((ok==1) && ((x==32) || (x==10) || (x==9))) ok = scanf("%c",&x);
      A[i][j] = (x=='1');
    }
  return ok==1;
}           

int readN0(int m, int n)
{ int i,j,ok=1,x;
 
  for (i=0; ok && (i<m); ++i)
    for (j=0; ok && (j<n); ++j)
    { ok = scanf("%d",&x) == 1;
      A[i][j] = x;
    }
  
  return ok;
}

int readmat(int m, int n)
{ if (mask & 1) return readinc(m,n);
  else return readN0(m,n);
}

void writemat(int *M, int m, int n)
{ int i,j;

  for (i=0; i<m; ++i)
  { for (j=0; j<n; ++j)
    { printf("%d",*(M+i*MAXN+j));
      if (!(mask & 1)) printf(" ");
    }
    printf("\n");
  }
  printf("\n");
}

int cmp(int *v1, int *v2, int n)
{ int i=0,c=0;

  while ((c==0) && (i<n))
  { c = *(v1+i)-*(v2+i);
    ++i;
  }
  
  return c;
}


int canon(int m, int n, int *A, int *C, int *nu, int *beta)
{ char K[MAXMEM][MAXN], K2[MAXMEM][MAXN];
  int nK,nK2;
  int d[MAXM],v[MAXN];
  int r,s,i,j,jj,k,c,ok,tmp;
  char rperm[MAXM], cperm[MAXN]; /* Row and column permutations */
  
 
  /* Compute C = canon(A) */

  nK = 1;
  
  for (r=0; r<m; ++r)
  { *(C+r*MAXN) = -1;
    for (s=0; s<nK; ++s)
    { 
      /* d = {1,..,m}\K[s] that preserve nu */

      for (i=0; i<m; ++i) d[i] = *(nu+r) == *(nu+i);
      for (i=0; i<r; ++i) d[K[s][i]] = 0; 
 
      for (j=0; j<m; ++j) if (d[j])
      { for (i=0; i<r; ++i) rperm[i] = K[s][i];
        rperm[r] = j;
        for (i=0; i<n; ++i) cperm[i] = i;

        /* Lexicographical sort */

        for (i=0; i<n-1; ++i)
          for (jj=i+1; jj<n; ++jj) if (*(beta+i)==*(beta+jj))
          { c=0;
            k=0;
            while ((c==0) && (k<r+1))
            { c = *(A+rperm[k]*MAXN+cperm[i]) - *(A+rperm[k]*MAXN+cperm[jj]);
              ++k;
            }
            if (c<0)
            { tmp = cperm[i];
              cperm[i] = cperm[jj];
              cperm[jj] = tmp;
            }
          }

        for (i=0; i<n; ++i) v[i] = *(A+rperm[r]*MAXN+cperm[i]);
        c = cmp(C+r*MAXN,v,n);
        if (c==0) 
        { for (i=0; i<=r; ++i) K2[nK2][i] = rperm[i];
          ++nK2;
          if (nK2==MAXMEM)
          { printf("\nIncrease MAXMEM!\n");
            exit(0);
          }
        }
        if (c<0)
        { for (i=0; i<n; ++i) *(C+r*MAXN+i)= v[i];
          for (i=0; i<=r; ++i) K2[0][i] = rperm[i];
          nK2=1;
        }
      }
    }
    nK = nK2;
    for (i=0; i<nK; ++i)
      for (j=0; j<=r; ++j) K[i][j] = K2[i][j];
  } 

  /* Is A == C ? */

  ok = 1;

  for (i=0; ok && (i<m); ++i)
    for (j=0; ok && (j<n); ++j) ok = *(A+i*MAXN+j) == *(C+i*MAXN+j);

  return ok;
}



/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int m,n; /* Number of rows & columns */
  int i,j,k;
  int countin=0,countout=0; 
  int nu[MAXM], beta[MAXN]; /* Vectors for tactical decompositions */
  /* Stuff for the tree */
  int depth; 
  typedef struct node {
     int elem;
     struct node *right;
     struct node *down;
  } NODE;
  NODE *root, *work, *new;
  /* NODE *malloc(); */

  
  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'i') { mask &= ~3; mask |= 1; }
      if (argv[i][j] == 'm') mask &= ~3; 
      if (argv[i][j] == 't') { mask &= ~3; mask |= 2; }
      if (argv[i][j] == 'n') mask |= 4;
      if (argv[i][j] == 'N') mask &= ~4;
      if (argv[i][j] == 'd') mask |= 8;
      if (argv[i][j] == 'D') mask &= ~8;
      if (argv[i][j] == 'c') mask |= 20;
      if (argv[i][j] == 'C') mask &= ~16;

      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: canonfilter [options]\n");
	printf("Dimensions and the matrices will be taken from stdin.\n");
	printf("Options:\n");
        printf("-i  Read incidence matrices (default)\n");
        printf("-m  Read general integral matrices\n");
        printf("-t  Read tactical decomposition matrices\n");
        printf("-n  Return non-isomorphic matrices\n");
        printf("-N  Return canonical matrices (default)\n");
        printf("-d  Print details\n");
        printf("-c  Return canonical representatives\n");
	exit(0);
      }

      ++j;
    }
  }

  scanf("%d",&m);
  scanf("%d",&n);
  if (m > MAXM)
  { printf("\nIncrease MAXM!\n");
    exit(0);
  }
  if (n > MAXN)
  { printf("\nIncrease MAXN!\n");
    exit(0);
  }

  /* Depth of the tree */

  depth = m*n;
  root = NULL;

  if (mask & 2) /* Read vectors for tactical decompositions */
  { for (i=0; i<m; ++i) scanf("%d",nu+i);
    for (i=0; i<n; ++i) scanf("%d",beta+i);
  }
  else
  { for (i=0; i<m; ++i) nu[i]=0;
    for (i=0; i<n; ++i) beta[i]=0;
  }

  printf("%d %d\n\n",m,n);
  if (mask & 2)
  { for (i=0; i<m; ++i) printf("%d ",nu[i]);
    printf("\n");
    for (i=0; i<n; ++i) printf("%d ",beta[i]);
    printf("\n\n");
  }


  /*************/
  /* Main loop */
  /*************/

  if (mask & 4)
  { while (readmat(m,n))
    { ++countin;
      canon(m,n,A[0],C[0],nu,beta);

      /* Memorise canonical incidence matrix, if necessary */

      /* First matrix */

      if (root == NULL)
      { if (mask & 16) writemat(C[0],m,n);
        else writemat(A[0],m,n);
        ++countout;
        if (mask & 8) printf("Matrix #%d is new (memorised as #%d).\n",countin,countout);
        root = malloc(sizeof(NODE));
        if (root==NULL)
        { printf("Out of memory!\n");
          exit(0);
        }
        work = root;
        work->elem = C[0][0];
        work->down = NULL;
        for (i=1; i<depth; ++i)
        { new = malloc(sizeof(NODE));
          if (new==NULL)
          { printf("Out of memory!\n");
            exit(0);
          }
          work->right = new;
          work = new;
          work->elem = C[i/n][i%n];
          work->down = NULL;
        }
        new = malloc(sizeof(NODE));
        if (new==NULL)
        { printf("Out of memory!\n");
          exit(0);
        }
        work->right = new;
        new->elem = countout;
        new->right = NULL;
        new->down = NULL;
      }

      /* Not the first matrix */

      else
      { work = root;
        k = 0;      
        while ((k<depth) && ((work->elem == C[k/n][k%n]) || (work->down != NULL)))
        if (work->elem == C[k/n][k%n])
        { work = work->right;
          ++k;
        }
        else work = work->down;
 
        if (k<depth) /* Rest of the matrix needs to be memorised */
        { if (mask & 16) writemat(C[0],m,n);
          else writemat(A[0],m,n);
          ++countout;
          if (mask & 8) printf("Matrix #%d is new (memorised as #%d).\n",countin,countout);
          new = malloc(sizeof(NODE));
          if (new==NULL)
          { printf("Out of memory!\n");
            exit(0);
          }
          work->down = new;
          work = new;
          work->elem = C[k/n][k%n];
          work->down = NULL;
          for (++k ; k<depth; ++k)
          { new = malloc(sizeof(NODE));
            if (new==NULL)
            { printf("Out of memory!\n");
              exit(0);
            }
            work->right = new;
            work = new;
            work->elem = C[k/n][k%n];
            work->down = NULL;
          }
          new = malloc(sizeof(NODE));
          if (new==NULL)
          { printf("Out of memory!\n");
            exit(0);
          }
          work->right = new;
          new->elem = countout;
          new->right = NULL;
          new->down = NULL;
        }
        else if (mask & 8) printf("Matrix #%d is isomorphic to #%d.\n",countin,work->elem);
      }    
    }
  }
  else while (readmat(m,n))
  { if (canon(m,n,A[0],C[0],nu,beta))
    { writemat((int *)A,m,n);
      fflush(stdout);
    }
  } /* End of main loop */

}

