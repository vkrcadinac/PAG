/*
    BDAUTTR.C

    Compute the automorphism group of a block design.

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
   1  Allow dual automorphisms, i.e. correlations (default no)
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

  int b=0,v=0; /* Design parameters */
  int p=0;     /* Point class size for initial coloring */

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
	if (argv[i][j] == 'p') sscanf(argv[i]+j+1,"%d",&p);

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: bdauttr [options]\n");
  	  printf("The number of points v, the number of blocks b and the design is taken from stdin.\n");
	  printf("Options:\n");
          printf("-d, -D  Allow dual automorphisms, i.e. correlations (default no)\n");
          printf("-pN     Color points in classes of size N (default no)\n");
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&v)==1;
  ok=ok && scanf("%d",&b)==1;

  if ((v<=0) || (b<=0) || (!ok))
  { printf("Parameters v and b must be entered first!\n");
    exit(0);
  }

  options.writeautoms = TRUE;
  options.cartesian = TRUE;
  options.defaultptn = FALSE;
  options.getcanon = FALSE;

  n=v+b;
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
  if (!(mask & 1)) ptn[v-1] = 0;
  ptn[n-1] = 0;
  if (p>0) for (i=0; i<v; ++i) if ((i+1)%p==0) ptn[i]=0;

  /* Read design and define graph */

  c=0;
  while (ok==1 && c!='[') ok= scanf("%c",&c);
  if (ok!=1)
  { printf("Error reading design.\n");
    exit(0);
  }
	   
  i=0;
  while (i<b)
  { /* printf("Block %d: ",i+1); */
    c=0;
    while (ok==1 && c!='[') ok= scanf("%c",&c);
    if (ok!=1)
    { printf("Error reading design.\n");
      exit(0);
    }
    c=',';
    while (ok==1 && c==',')
    { ok=scanf("%d",&x);
      if (x<1 || x>v) 
      { printf("Error reading point of design.\n");
        exit(0);
      }
      /* printf("%d ",x); */
      --x;
      ADDONEEDGE(g,v+i,x,m);
      c=0;
      while (ok==1 && c!=']' && c!=',') ok= scanf("%c",&c);
      if (ok!=1)
      { printf("Error reading design.\n");
        exit(0);
      }
    }
    /* printf("\n"); */
    /* for (j=0; j<vb; ++j) printf("%d ",db1[j]);
    printf("\n"); */
    ++i;
  }

  /* Convert to sparse graph */

  sgp=nauty_to_sg(g,NULL,m,n);

  /* Call Traces */

  Traces(sgp,lab,ptn,orbits,&options,&stats,NULL);

}
