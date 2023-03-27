/*
    BDAUT.C

    Compute the automorphism group of a block design.

    The program uses nauty/Traces 2.8 by B.D.McKay and A.Piperno. 
    This version calls nauty for dense graphs. It needs to be linked 
    with nauty.c, nautil.c, naugraph.c, schreier.c, naurng.c, and 
    nautinv.c.

    Vedran Krcadinac (krcko@math.hr), 7.1.2023.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>

#include "nauty.h" 
#include "nautinv.h" 

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
  static DEFAULTOPTIONS_GRAPH(options);
  statsblk stats;

  int n,m;

  int b=0,v=0; /* Design parameters */
  int p=0;     /* Point class size for initial coloring */

  int i,j,x,ok;
  int inv=1,mininv=0,maxinv=2,invarg=0;
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
	if (argv[i][j] == 'i') sscanf(argv[i]+j+1,"%d",&inv);
	if (argv[i][j] == 'm') sscanf(argv[i]+j+1,"%d",&mininv);
	if (argv[i][j] == 'x') sscanf(argv[i]+j+1,"%d",&maxinv);
	if (argv[i][j] == 'a') sscanf(argv[i]+j+1,"%d",&invarg);

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: bdaut [options]\n");
  	  printf("The number of points v, the number of blocks b and the design is taken from stdin.\n");
	  printf("Options:\n");
          printf("-d, -D  Allow dual automorphisms, i.e. correlations (default no)\n");
          printf("-pN     Color points in classes of size N (default no)\n");
          printf("-iN     Use vertex invariant...\n");
          printf("   N=0: no invariant\n"); 
          printf("   N=1: twopaths (default)\n"); 
	  printf("   N=2: adjtriang\n"); 
	  printf("   N=3: triples\n"); 
	  printf("   N=4: quadruples\n"); 
	  printf("   N=5: celltrips\n"); 
	  printf("   N=6: cellquads\n"); 
	  printf("   N=7: cellquins\n"); 
	  printf("   N=8: distances\n"); 
	  printf("   N=9: indsets\n"); 
	  printf("   N=10: cliques\n"); 
	  printf("   N=11: cellcliq\n"); 
	  printf("   N=12: cellind\n"); 
	  printf("   N=13: adjacencies\n"); 
	  printf("   N=14: cellfano\n"); 
	  printf("   N=15: cellfano2\n"); 
	  printf("   N=16: refinvar\n"); 
          printf("-mN     Set mininvarlevel to N (default N=0)\n");
          printf("-xN     Set maxinvarlevel to N (default N=2)\n");
          printf("-aN     Set invararg to N (default N=0)\n");
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
  options.schreier = TRUE;
  options.defaultptn = FALSE;
  options.getcanon = FALSE;
  if (inv==0) options.invarproc = NULL;
  if (inv==1) options.invarproc = twopaths;
  if (inv==2) options.invarproc = adjtriang;
  if (inv==3) options.invarproc = triples;
  if (inv==4) options.invarproc = quadruples;
  if (inv==5) options.invarproc = celltrips;
  if (inv==6) options.invarproc = cellquads;
  if (inv==7) options.invarproc = cellquins;
  if (inv==8) options.invarproc = distances; 
  if (inv==9) options.invarproc = indsets;
  if (inv==10) options.invarproc = cliques;
  if (inv==11) options.invarproc = cellcliq;
  if (inv==12) options.invarproc = cellind;
  if (inv==13) options.invarproc = adjacencies; 
  if (inv==14) options.invarproc = cellfano;
  if (inv==15) options.invarproc = cellfano2;
  if (inv==16) options.invarproc = refinvar;
  options.mininvarlevel = mininv;
  options.maxinvarlevel = maxinv;
  options.invararg = invarg;

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

  /* Call nauty */

  densenauty(g,lab,ptn,orbits,&options,&stats,m,n,NULL);

}
