/*
    MATAUT.C

    Compute the automorphism group of an integer matrix.
    Permutations of rows, columns and symbols are allowed.

    The program uses nauty/Traces 2.8 by B.D.McKay and A.Piperno. 
    This version calls Traces. It needs to be linked with nauty.c, 
    nautil.c, naugraph.c, schreier.c, naurng.c, nausparse.c, gtools.c,
    and traces.c. 

    Vedran Krcadinac (krcko@math.hr), 7.1.2023.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>

#include "traces.h" 

/****************/
/* Global stuff */
/****************/

int mask=0;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
*/


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ 
  DYNALLSTAT(graph,g,g_sz);
  DYNALLSTAT(int,lab,lab_sz);
  DYNALLSTAT(int,ptn,ptn_sz);
  DYNALLSTAT(int,orbits,orbits_sz);
  static DEFAULTOPTIONS_TRACES(options);
  TracesStats stats;
  sparsegraph *sgp;

  int n,m;

  int vr=0, vc=0, vs=0; /* Number of rows, columns, and distinct entries of the matrix */

  int i,j,x,ok;
  char c;

  /* Command line arguments */
  for(i=1; i<argc; ++i)
    if (('0' <= argv[i][0]) && (argv[i][0] <= '9'))
    {  /* if (k==0) sscanf(argv[i],"%d",&k);
       else if (b==0) sscanf(argv[i],"%d",&b); */
    }
    else
    { j = 0;
      while (argv[i][j] != '\0')
      { if (argv[i][j] == 'd') mask |= 1;
	if (argv[i][j] == 'D') mask &= ~1;

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: mataut [options]\n");
  	  printf("The number of rows, columns, symbols and the matrix are taken from stdin.\n");
	  /* printf("Options:\n");
          printf("-d, -D  Allow transpositions (default no)\n"); */
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&vr)==1;
  ok&=scanf("%d",&vc)==1;
  ok&=scanf("%d",&vs)==1;

  if ((vr<=0) || (vc<=0) || (vs<=0) || (!ok))
  { printf("The number of rows, columns, and distinct entries of the matrix must be entered first!\n");
    exit(0);
  }

  options.writeautoms = TRUE;
  options.cartesian = TRUE;
  options.defaultptn = FALSE;
  options.getcanon = FALSE;

  n=vr+vc+vs+vr*vc;
  m = SETWORDSNEEDED(n);

  nauty_check(WORDSIZE,m,n,NAUTYVERSIONID);

  DYNALLOC2(graph,g,g_sz,m,n,"malloc");
  DYNALLOC1(int,lab,lab_sz,n,"malloc");
  DYNALLOC1(int,ptn,ptn_sz,n,"malloc");
  DYNALLOC1(int,orbits,orbits_sz,n,"malloc");
  EMPTYGRAPH(g,m,n);

  for (i=0; i<n; ++i) 
  { lab[i] = i; 
    ptn[i] = 1; 
  }
  ptn[vr-1] = 0;
  ptn[vr+vc-1] = 0;
  ptn[vr+vc+vs-1] = 0;
  ptn[n-1] = 0;

  /* Read matrix and define graph */

  for (i=0; i<vr; ++i) for (j=0; j<vc; ++j)
  { ADDONEEDGE(g,i,vr+vc+vs+i*vc+j,m); 
    ADDONEEDGE(g,vr+j,vr+vc+vs+i*vc+j,m); 
  }

  c=0;
  while (ok==1 && c!='[') ok= scanf("%c",&c);
  if (ok!=1)
  { printf("Error reading matrix.\n");
    exit(0);
  }
	   
  i=0;
  while (i<vr)
  { /* printf("Block %d: ",i+1); */
    c=0;
    while (ok==1 && c!='[') ok= scanf("%c",&c);
    if (ok!=1)
    { printf("Error reading matrix.\n");
      exit(0);
    }
    c=',';
    j=-1;
    while (ok==1 && c==',')
    { ok=scanf("%d",&x);
      if (x<0 && x>=vs) 
      { printf("Error reading entry of matrix.\n");
        exit(0);
      }
      ++j;
      /* printf("(%d,%d)=%d ",i,j,x); */
      ADDONEEDGE(g,vr+vc+x,vr+vc+vs+i*vc+j,m); 
      c=0;
      while (ok==1 && c!=']' && c!=',') ok= scanf("%c",&c);
      if (ok!=1)
      { printf("Error reading matrix.\n");
        exit(0);
      }
    }
    /* printf("\n"); */
    ++i;
  }

  /* Convert to sparse graph */

  sgp=nauty_to_sg(g,NULL,m,n);

  /* Call Traces */

  Traces(sgp,lab,ptn,orbits,&options,&stats,NULL);

}
