/*
    INC2DES.C

    The program takes a sequence of incidence matrices 
    and translates them to lists of blocks.

    Vedran Krcadinac (krcko@math.hr), 7.1.2023.
    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h> 
#include <stdlib.h> 

#define MAXV 2000  /* Maximal number of rows */
#define MAXB 5000  /* Maximal number of columns */


char inc[MAXV][MAXB]; /* The matrix */

int readinc(int v, int b)
{ int i,j,ok=1;
  char x;
  
  for (i=0; (ok==1) && (i<v); ++i)
    for (j=0; (ok==1) && (j<b); ++j)
    { x=32;
      while ((ok==1) && ((x==32) || (x==10) || (x==9))) ok = scanf("%c",&x);
      inc[i][j] = (x=='1');
    }
  return ok==1;
}           

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,first;
  int v,b; /* Dimensions */
  long int count=0;

  /* Command line arguments */
  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { /* if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1; */

      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: inc2des\n");
  	printf("Dimensions and matrices are taken from stdin.\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  /* Read dimensions */

  ok=scanf("%d",&v)==1;
  ok&=scanf("%d",&b)==1;
  if (!ok)
  { printf("Error reading dimensions of matrices.\n");
    exit(0);
  }
  if (v > MAXV)
  { printf("\nIncrease MAXV!\n");
    exit(0);
  }
  if (b > MAXB)
  { printf("\nIncrease MAXB!\n");
    exit(0);
  }

  printf("%d %d\n[ ",v,b);

  /*************/
  /* Main loop */
  /*************/
 
  while (readinc(v,b))
  { ++count; 
    
    if (count==1) printf("[ ");
    else printf(",\n[ ");

    for (j=0; j<b; ++j)
    { if (j==0) printf("[ ");
      else printf(",\n[ ");
      first=1;
      for (i=0; i<v; ++i) if (inc[i][j])
      { if (first) printf("%d",i+1);
	else printf(", %d",i+1);
	first=0;
      }
      printf(" ]");
    }
    printf(" ]");

  } /* End of main loop */

  printf(" ]\n");
}
