/*
     MOLSAUT.C

     A program that takes as its input a list of MOLS sets and 
     computes their autotopism / autoparatopism / automorphism 
     groups.

     The program uses nauty 2.7 by B.D.McKay and A.Piperno. 
     It needs to be linked with nauty.c, nautil.c, naugraph.c, 
     schreier.c, naurng.c and nautinv.c.

     Vedran Krcadinac (krcko@math.hr), 24.7.2022.
     Department of Mathematics, University of Zagreb, Croatia
*/

#define MAXORD 50   /* Maximal order of Latin squares  */
#define MAXGS 1000  /* Maximal number of different group sizes */

#define MAXN 5100   /* Maximal number of vertices for the graph */
                    /* MAXN = 2*MAXORD*(MAXORD+1) */

#include "nautinv.h"

int ls[MAXORD-1][MAXORD][MAXORD];   /* Set of MOLS */

int mask=2;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
     1  Print MOLS sets: -p for yes, -P for no (default no)
     2  Print generators of the groups: -g for yes, -G for no (default yes)
     4  Compute distribution by group size: -d for yes, -D for no (default no)
     8  Print size of groups: -s for yes, -S for no (default no)
    16  Include parastrophisms: -c for yes, -C for no (default no)
    32  Restrict to isomorphisms: -i for yes, -I for no (default no)
*/


int readmols(int r, int c, int s)
{ int i,j,k,ok=1;

  for (k=0; (ok==1) && (k<s); ++k)
    for (i=0; (ok==1) && (i<r); ++i)
      for (j=0; (ok==1) && (j<c); ++j)
        ok=scanf("%d",&ls[k][i][j]); 
  return ok==1;
}           

void writemols(int r, int c, int s)
{ int i,j,k;

  for (k=0; k<s; ++k)
  { for (i=0; i<r; ++i)
    { for (j=0; j<c; ++j) printf("%d ",ls[k][i][j]);
      printf("\n");
    }
    printf("\n");
  } 
  printf("\n");
}


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{
  graph g[MAXN*MAXM];
  nvector lab[MAXN],ptn[MAXN],orbits[MAXN];
  static DEFAULTOPTIONS_GRAPH(options);
  statsblk(stats);
  setword workspace[50*MAXM];
  set *gv;

  int r=0,c=0,s=0,count=0;
  int n,m,i,j,k,ok;
  double gs[MAXGS], tmp1;
  int ngs=0, gsc[MAXGS], tmp2;

 
  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1;
      if (argv[i][j] == 'g') mask |= 2;
      if (argv[i][j] == 'G') mask &= ~2;
      if (argv[i][j] == 'd') mask |= 4;
      if (argv[i][j] == 'D') mask &= ~4;
      if (argv[i][j] == 's') mask |= 8;
      if (argv[i][j] == 'S') mask &= ~8;
      if (argv[i][j] == 'c') mask |= 16;
      if (argv[i][j] == 'C') mask &= ~16;
      if (argv[i][j] == 'i') mask |= 32;
      if (argv[i][j] == 'I') mask &= ~32;
        
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: molsaut [options]\n");
	printf("Dimensions and size of MOLS sets are taken from stdin.\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
	printf("-p, -P   Print MOLS sets (default no)\n");
	printf("-g, -G   Print generators (default yes)\n");
	printf("-d, -D   Report distribution by group size (default no)\n");
        printf("-s, -S   Print size of groups (default no)\n");
	printf("-c, -C   Include parastrophisms (default no)\n");
	printf("-i, -I   Restrict to isomorphisms (default no)\n");
	exit(0);
      }

      ++j;
    }
  }

  /* Read dimensions and size of MOLS sets */

  ok=scanf("%d",&r);
  if (ok!=1)
  { printf("Cound not read number of rows.\n");
    exit(0);
  }
  ok=scanf("%d",&c);
  if (ok!=1)
  { printf("Cound not read number of columns.\n");
    exit(0);
  }
  ok=scanf("%d",&s);
  if (ok!=1)
  { printf("Cound not read size of MOLS sets.\n");
    exit(0);
  }

  if ((r<1) || (c<1) || (r>MAXORD) || (c>MAXORD) || (r>c) || (s<1) || (s>=c))
  { printf("Number of rows (r), columns (c) and size of sets (s) must satisfy 1<=r<=c<=%d, 1<=s<c<=%d.\n",MAXORD,MAXORD);
    exit(0);
  }

  if (mask & 1) printf("%d %d %d\n\n",r,c,s);
  
  /*  Define n,m (for nauty) */

  n = r+(s+1)*c+r*c;
  m = (n + WORDSIZE - 1) / WORDSIZE;

  /* Options for nauty */

  options.writemarkers = FALSE;
  if (mask & 2) options.writeautoms = TRUE;
  else options.writeautoms = FALSE;
  options.defaultptn = FALSE;
  options.getcanon = FALSE;
  options.invarproc = adjtriang;
  options.mininvarlevel = 1;
  options.maxinvarlevel = 2;
  options.invararg = 0;
  options.tc_level = 10;
  options.userautomproc = NILFUNCTION;
  labelorg = 1;

 
  /*************/
  /* Main loop */
  /*************/
 
  while (readmols(r,c,s))
  { ++count;

    /* Print matrix */
    
    if (mask & 1) writemols(r,c,s);
    
    /* Clear graph */
 
    for (i=0; i<n; ++i)
    { gv = GRAPHROW(g,i,m);
      EMPTYSET(gv,m);
    }

    /* Join rows */

    for (i=0; i<r; ++i)
    { gv = GRAPHROW(g,i,m);
      for (j=0; j<c; ++j) ADDELEMENT(gv,r+(s+1)*c+i*c+j);
      for (j=0; j<c; ++j)
      { gv = GRAPHROW(g,r+(s+1)*c+i*c+j,m);
        ADDELEMENT(gv,i);
      }
    }

    /* Join columns */

    for (i=0; i<c; ++i)
    {  gv = GRAPHROW(g,r+i,m);
       for (j=0; j<r; ++j) ADDELEMENT(gv,r+(s+1)*c+i+j*c);
       for (j=0; j<r; ++j)
       { gv = GRAPHROW(g,r+(s+1)*c+i+j*c,m);
         ADDELEMENT(gv,r+i);
       }
    }

    /* Join symbols */

    for (k=0; k<s; ++k) for (i=0; i<r; ++i) for (j=0; j<c; ++j)
    { gv = GRAPHROW(g,r+c+k*c+ls[k][i][j]-1,m);
      ADDELEMENT(gv,r+(s+1)*c+i*c+j);
      gv = GRAPHROW(g,r+(s+1)*c+i*c+j,m);
      ADDELEMENT(gv,r+c+k*c+ls[k][i][j]-1);
    }

    /* Restrict to isomorphisms */

    if (mask & 32)
    { for (i=0; i<r; ++i) 
      { gv = GRAPHROW(g,i,m);
        ADDELEMENT(gv,r+i);
        for (k=0; k<s; ++k) ADDELEMENT(gv,r+c+k*c+i);
        gv = GRAPHROW(g,r+i,m);
        ADDELEMENT(gv,i);
        for (k=0; k<s; ++k) 
        { gv = GRAPHROW(g,r+c+k*c+i,m);
          ADDELEMENT(gv,i);
	}
      }
      for (i=0; i<c; ++i)
      { gv = GRAPHROW(g,r+i,m);
        for (k=0; k<s; ++k) ADDELEMENT(gv,r+c+k*c+i);
        for (k=0; k<s; ++k)
	{ gv = GRAPHROW(g,r+c+k*c+i,m);
          ADDELEMENT(gv,r+i);
        }
      }
      for (i=0; i<c; ++i) for (j=0; j<s; ++j) for (k=j+1; k<s; ++k)
      { gv = GRAPHROW(g,r+c+j*c+i,m);
        ADDELEMENT(gv,r+c+k*c+i);
        gv = GRAPHROW(g,r+c+k*c+i,m);
        ADDELEMENT(gv,r+c+j*c+i);
      }
    }

    /* Define colouring */

    for (i=0; i<n; ++i) 
    { lab[i] = i; 
      ptn[i] = 1; 
    }
    ptn[r+(s+1)*c-1] = 0;
    ptn[n-1] = 0;
    if ((mask & 16)==0)  
    { ptn[r-1] = 0;
      for (k=0; k<s; ++k) ptn[r+c+k*c-1] = 0;
    }

    /* Call nauty */

    if (mask & 2) printf("g[%d]:=Group(",count);

    nauty(g,lab,ptn,NILSET,orbits,&options,&stats,workspace,50*MAXM,m,n,NULL);

    if (mask & 2) printf(");\n");

    if (mask & 8) printf("|Aut|=%.0f\n\n",stats.grpsize1);    

    if (mask & 4)
    { for (i=0; i<ngs && gs[i]!=stats.grpsize1; ++i) ;
      if (i==ngs)
      { ++ngs;
        if (ngs==MAXGS)
        { printf("Increase MAXGS!\n");
          exit(0);
        }
        gs[i] = stats.grpsize1;
        gsc[i] = 1;
      }
      else ++gsc[i];
    }

  } /* End of main loop */

  if (mask & 4)
  { for (i=0; i<ngs-1; ++i) for (j=i+1; j<ngs; ++j) if (gs[i]<gs[j])
    { tmp1 = gs[i]; tmp2 = gsc[i];
      gs[i] = gs[j]; gsc[i] = gsc[j];
      gs[j] = tmp1; gsc[j] = tmp2;
    } 
    printf("Distribution by group size:\n\n   |Aut|     #\n");
    for (i=0; i<ngs; ++i) printf("%7.0f%7d\n",gs[i],gsc[i]);
    printf("\n");
  }

}
