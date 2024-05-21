/*
    TOGAPMAT.C

    Trasform list of integer matrices to GAP format.

    Vedran Krcadinac (krcko@math.hr), 4.12.2023.

    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Global stuff */
/****************/

int mask=1;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Read sets of matrices: -s for yes, -S for no (default yes)
*/



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
    { if (argv[i][j] == 's') mask |= 1;
      if (argv[i][j] == 'S') mask &= ~1; 
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: togapmat [options]\n");
        printf("Matrices are taken from stdin. Options:\n");
	printf("-s, -S  Read sets of matrices (default yes)\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  ok=scanf("%d",&m)==1;
  ok&=scanf("%d",&n)==1;
  if (mask & 1) ok&=scanf("%d",&s)==1;
  if (!(mask & 1)) s=1;

  if ((m<=0) || (n<=0) || (!ok) || (s<=0))
  { printf("Number of rows, columns and size of sets must be entered first!\n");
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
      { if (mask & 1) printf("[");
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
	else if (mask & 1) printf("]");
      }
    } 
  }

  printf("\n];\n");
}

