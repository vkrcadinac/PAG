/*
    DELGEN.C

    Prepare Traces output by deleting parts of text file 
    between 'G' and ':'.

    Vedran Krcadinac (krcko@math.hr), 3.1.2023.
    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h>
#include <stdlib.h>


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ char c;
  int i,j;

  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { /* if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1; */
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: delgen [options]\n");
        printf("Input is taken from stdin.\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  /*************/
  /* Main loop */
  /*************/

  i=1;
  while (scanf("%c",&c)==1)
  { if (c=='G') i=0;
    if (i) printf("%c",c);
    if (c==':') i=1;
  }

}
