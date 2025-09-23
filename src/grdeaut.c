/*
    GRDEAUT.C
    Compute the automorphism group of a graph decomposition. 

    Vedran Krcadinac (krcko@math.hr), 10.5.2025.
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

  int gv=0, ge=0; /* Number of vertices and edges of the decomposed graph */
  int b=0, he; /* Number of blocks and edges in a block */
  int *edg;

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
        { printf("Usage: grdeaut\n");
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&gv)==1;
  ok&=scanf("%d",&ge)==1;
  ok&=scanf("%d",&b)==1;

  if ((gv<=0) || (ge<=0) || (b<=0) || (!ok))
  { fprintf(stderr,"The number of vertices and edges of the decomposed graph must be given first,\n");
    fprintf(stderr,"then the number of blocks\n");
    exit(0);
  }

  if ((ge%b)!=0)
  { fprintf(stderr,"Number of edges not divisible by number of blocks!\n");
    exit(0);
  }
  he=ge/b;

  /* printf("gv=%d, ge=%d, b=%d, he=%d\n",gv,ge,b,he);
  exit(0); */

  options.writeautoms = TRUE;
  options.cartesian = TRUE;
  options.defaultptn = FALSE;
  options.getcanon = FALSE;

  n=gv+ge+b;
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
  ptn[gv-1]=0;
  ptn[gv+ge-1]=0;
  ptn[n-1] = 0;

  /* Read edges of the decomposed graph */

  edg=(int *)calloc(2*ge,sizeof(int));
  for (i=0; ok && i<ge; ++i)
  { ok&=scanf("%d",edg+2*i)==1;
    ok&=scanf("%d",edg+2*i+1)==1;
    --(*(edg+2*i));
    --(*(edg+2*i+1));
  }

  /* Read decomposition */

  for (i=0; i<ge; ++i)
  { ADDONEEDGE(g,*(edg+2*i),gv+i,m);
    ADDONEEDGE(g,*(edg+2*i+1),gv+i,m);
  }

  for (i=0; ok && i<b; ++i) for (j=0; ok && j<he; ++j)
  { ok=scanf("%d",&x)==1;
    if (ok) ADDONEEDGE(g,gv+x-1,gv+ge+i,m);
  }

  if (!ok)
  { fprintf(stderr,"Error reading graph decomposition!\n");
    exit(0);
  }

  /* Convert to sparse graph */

  sgp=nauty_to_sg(g,NULL,m,n);

  /* Call Traces */

  Traces(sgp,lab,ptn,orbits,&options,&stats,NULL);

}
