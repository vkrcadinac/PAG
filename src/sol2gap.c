/*
    SOL2GAP.C

    Trasform solution vectors from 'solvediophant' to GAP format.

    Vedran Krcadinac (krcko@math.hr), 27.2.2025.

    Department of Mathematics, University of Zagreb, Croatia

*/

#include <stdio.h>
#include <stdlib.h>

int mask=0;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off:
  1 Read integer vectors. By default, 0-1 vectors are read. -i, -I  
  2 Write output by defining variable PAGProcessResult. -v, -V
*/



/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,count,rowlength,first,firstrow,rad,found;
  char c,str[200];

  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'i') mask |= 1;
      if (argv[i][j] == 'I') mask &= ~1; 
      if (argv[i][j] == 'v') mask |= 2;
      if (argv[i][j] == 'V') mask &= ~2; 
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: sol2gap [options]\n");
        printf("Solution vectors are taken from stdin.\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
	printf("-i, -I   Read integer vectors (default: 0-1 vectors)\n"); 
	printf("-v, -V   Write output by defining variable PAGProcessResult (default: 'return' for ReadAsFunction)\n"); 
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  found=0;
  if (mask & 2) printf("PAGProcessResult := [\n");
  else printf("return [\n");
  if (mask & 1)
  {
    firstrow=1;
    ok=1;
    while (ok==1)
    { c=' ';
      first=1;
      rad=1;
      while (rad)
      { while (ok==1 && c==' ') ok=scanf("%c",&c);
        if (ok==1 && '0'<=c && c<='9')
        { i=0;
          while (ok==1 && '0'<=c && c<='9')
	  { str[i]=c;
	    ++i;
	    ok=scanf("%c",&c)==1;
	  }
	  str[i]=0;
	  sscanf(str,"%d",&j);
	  found=1;
	  /* printf("%d(%d) ",j,first); */
	  if (first) 
	  { if (!firstrow) printf("],\n");
            firstrow=0;
	    printf("[%d",j); 
          }
	  else printf(",%d",j);
	  first=0;
	}
	else
	{ if (c=='\n')
	  { rad=0;
	  }
	  else if (ok==1)
	  { printf("Unknown character %d.\n",c);
	    exit(0);
	  }
	}
	if (ok!=1) rad=0;
      }
    }
    if (found) printf("]");

  }
  else
  { ok=1; 
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
  }

  printf("\n];\n");
}

