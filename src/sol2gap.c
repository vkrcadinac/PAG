/*
    SOL2GAP.C

    Trasform solution vectors from 'solvediophant' to GAP format.

    Vedran Krcadinac (krcko@math.hr), 28.4.2022.

    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,count,rowlength,first,firstrow;
  char c;

  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { /* if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1; */
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: sol2gap\n");
        printf("Solution vectors are taken from stdin.\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  printf("return [\n");
  ok=1; 
  rowlength=0;
  count=0;
  first=1;
  firstrow=1;
  while (ok==1)
  { ok=scanf("%c",&c);

    /* printf("%d *%c* %d\n",ok,c,c); */

    if (ok==1) 
    { if (c==49) 
      { ++count; 
        if (first) 
        { if (firstrow) firstrow=0;
	  else printf(",\n");
	  printf("[%d",count); first=0; 
        }
        else printf(",%d",count);
      }

      if (c==48) ++count;


      if (c==10)
      { printf("]");
	if (rowlength==0) rowlength=count;
        else if (rowlength!=count)
        { printf("Error - vectorst of different lentghs!\n");
          exit(0);
        }
        count=0;
        first=1;
      }
    }
    else if (count) printf("]"); 

  }

  printf("\n];\n");
}

