/*
    TOGAPMARINC.C

    Trasform list of 0/1 matrices to GAP format.

    Vedran Krcadinac (krcko@math.hr), 25.1.2025.
    Department of Mathematics, University of Zagreb, Croatia

*/

#define MAXM 2000     /* Maximal number of rows */
#define MAXN 5000     /* Maximal number of columns */

#include <stdio.h>
#include <stdlib.h>

char A[MAXM][MAXN];  /* Incidence matrix */
char B[MAXM][MAXN];  /* Incidence matrix */
int nu[MAXM], beta[MAXN]; /* Marginal vectors */
int m,n; /* Dimensions */
int count;

int mask=0;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off:
*/


int readmat(int m, int n)
{ int i,j,ok=1,x;
 
  for (i=0; ok && (i<m); ++i)
    for (j=0; ok && (j<n); ++j)
    { ok = scanf("%d",&x) == 1;
      A[i][j] = x;
    }
  
  return ok;
}

void writemat(int *mat, int m, int n)
{ int i,j;

  printf("[");
  for (i=0; i<m; ++i)
  { printf("[");
	for (j=0; j<n; ++j) 
	{ printf("%d",*(mat+MAXN*i+j));
      if (j<(n-1)) printf(",");
	  else printf("]");
	}
    if (i<(m-1)) printf(",");
	else printf("];");
    printf("\n");
  }
  printf("\n");
  fflush(stdout);
}


int readinc(int v, int b)
{ int i,j,ok=1;
  char x;
  
  for (i=0; (ok==1) && (i<v); ++i)
    for (j=0; (ok==1) && (j<b); ++j)
    { x=32;
      while ((ok==1) && ((x==32) || (x==10) || (x==9))) ok = scanf("%c",&x);
      A[i][j] = (x=='1');
    }
  return ok==1;
}           


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,incno=0;

  /* Command line arguments */

  for(i=1; i<argc; ++i)
  if (('0' <= argv[i][0]) && (argv[i][0] <= '9')) sscanf(argv[i],"%d",&incno);
  else
  { j = 0;
    while (argv[i][j] != '\0')
    { /* if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1; */
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: togapmatinc [options]\n");
        printf("The 0/1 matrices are taken from stdin.\n");
	/* printf("Options (lowercase for yes, uppercase for no):\n");
        printf("-p, -P   Print points of subdesigns (default no)\n"); */
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  /* Read dimensions */

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


  printf("return [\n");
  ok = readinc(m,n);
  count=1;

  for (i=0; i<m; ++i) for (j=0; j<n; ++j) B[i][j]=A[i][j];

  /*************/
  /* Main loop */
  /*************/

  while (ok && readinc(m,n))
  { ++count; 
    printf("[");
	for (i=0; i<m-1; ++i)
    { printf("[");
	  for (j=0; j<n-1; ++j) printf("%d,",B[i][j]);
	  printf("%d],\n",B[i][j]);
	}
	printf("[");
	for (j=0; j<n-1; ++j) printf("%d,",B[i][j]);
	printf("%d]],\n",B[i][j]);
	for (i=0; i<m; ++i) for (j=0; j<n; ++j) B[i][j]=A[i][j];
  }

  if (ok) {
  printf("[");
  for (i=0; i<m-1; ++i)
  { printf("[");
	for (j=0; j<n-1; ++j) printf("%d,",B[i][j]);
	printf("%d],\n",B[i][j]);
  }
  printf("[");
  for (j=0; j<n-1; ++j) printf("%d,",B[i][j]);
  printf("%d]]\n];\n",B[i][j]);
  } else printf("];\n");

}
