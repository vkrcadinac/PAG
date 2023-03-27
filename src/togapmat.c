/*
    TOGAPMAT.C

    Trasform list of integer matrices to GAP format.

    Vedran Krcadinac (krcko@math.hr), 24.7.2022.

    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,k,ok,count=0; 
  int m=0,n=0,s=0;
  int *mat;

  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { /* if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1; */
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: togapmat\n");
        printf("Matrices are taken from stdin.");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  ok=scanf("%d",&m)==1;
  ok&=scanf("%d",&n)==1;
  ok&=scanf("%d",&s)==1;

  if ((m<=0) || (n<=0) || (!ok) || (s<=0))
  { printf("Number of rows and columns must be entered first!\n");
    exit(0);
  }

  mat=(int *)calloc(s*m*n,sizeof(int));
  if (mat == NULL) 
  { printf("Memory not allocated.\n");
    exit(0);
  }

  printf("return [\n");

  while (ok)
  { for (k=0; ok && k<s; ++k) for (i=0; ok && i<m; ++i) for (j=0; ok && j<n; ++j)
    { ok = scanf("%d",mat+k*m*n+i*n+j)==1;
      /* printf("i=%d, j=%d, ok=%d\n",i,j,ok); */
    }
    if (ok) 
    { if (count>0) printf(",\n");
      ++count;
      printf("[");
      for (k=0; k<s; ++k)
      { printf("[");
        for (i=0; i<m; ++i)
        { printf("["); 
	  for (j=0; j<n; ++j) 
	  { printf("%d",*(mat+k*m*n+i*n+j)); 
            if (j<n-1) printf(",");
	  }	
	  printf("]");
	  if (i<m-1) printf(",");
	  else printf("]");
        }
	if (k<s-1) printf(",\n");
	else printf("]");
      }
    } 
  }

  printf("\n];\n");
}

