/*
    GAP2RAW.C

    Vedran Krcadinac (krcko@math.hr), 8.8.2007.
    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h>
#include <stdlib.h>

int mask=0;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off:
*/


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
      { printf("Usage: gap2raw [options]\n");
        printf("Input is taken from stdin.\n");
	    printf("Options (lowercase for yes, uppercase for no):\n");
        /* printf("-p, -P   Print points of subdesigns (default no)\n"); */
        printf("\n");
	    exit(0);
      }
      ++j;
    }
  }

  /*************/
  /* Main loop */
  /*************/

  while (scanf("%c",&c)==1)
    if (c!='[' && c!=']' && c!=',') printf("%c",c);

}
