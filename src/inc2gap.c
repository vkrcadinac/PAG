/*
    INC2GAP.C

    Vedran Krcadinac (krcko@math.hr), 13.9.2018.
    Department of Mathematics, University of Zagreb, Croatia

*/

#define MAXM 2000     /* Maximal number of rows */
#define MAXN 5000     /* Maximal number of columns */

#include <stdio.h>
#include <stdlib.h>

char A[MAXM][MAXN];  /* Incidence matrix */
char B[MAXM][MAXN];  /* Incidence matrix */
int nu[MAXM], beta[MAXN]; /* Marginal vectors */
int m=0,n=0; /* Dimensions */
int count;

int mask=0;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off:
*/

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
      { printf("Usage: inc2gap\n");
        printf("The matrices are taken from stdin.\n");
	/* printf("Options (lowercase for yes, uppercase for no):\n"); */
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  /* Read dimensions */

  ok=scanf("%d",&m)==1;
  ok&=scanf("%d",&n)==1;
  if (ok!=1 || m<=0 || n<=0)
  { printf("\nDimensions of the matrices must be entered first!\n");
    exit(0);
  }
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
