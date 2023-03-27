/*
     MOLSFILTER.C

     A program that takes as its input a list of MOLS sets and 
     and returns representatives of isotopism / paratopism / 
     isomorphism classes.

     The program uses nauty 2.7 by B.D.McKay and A.Piperno. 
     It needs to be linked with nauty.c, nautil.c, naugraph.c, 
     schreier.c, naurng.c and nautinv.c.

     Vedran Krcadinac (krcko@math.hr), 1.10.2022.
     Department of Mathematics, University of Zagreb, Croatia
*/

#define MAXORD 50        /* Maximal order of Latin squares */
#define MAXDEPTH 1000    /* Maximal depth of the tree */
#define SLEVEL 10        /* Default level for short nodes */
#define MEMBLOCK 131072  /* Allocate memory in units of MEMBLOCK bytes */

#define MAXN 5100   /* Maximal number of vertices for the graph */
                    /* MAXN = 2*MAXORD*(MAXORD+1) */

#include "nautinv.h"
#include "naututil.h"

int ls[MAXORD-1][MAXORD][MAXORD];   /* Set of MOLS */
int canonls[MAXORD-1][MAXORD][MAXORD];   /* Canonically labeled Set of MOLS */

int mask=1;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
     1  Print inequivalent MOLS sets: -p for yes, -P for no (default yes)
     2  Print information about tree: -t for yes, -T for no (default no)
    16  Return paratopism classes: -c for yes, -C for no (default no)
    32  Return isomorphism classes: -i for yes, -I for no (default no)
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

void writecanonls(int r, int c, int s)
{ int i,j,k;

  for (k=0; k<s; ++k)
  { for (i=0; i<r; ++i)
    { for (j=0; j<c; ++j) printf("%d ",canonls[k][i][j]);
      printf("\n");
    }
    printf("\n");
  } 
  printf("\n");
}

void intersect(set *set1,set *set2,set *set3,int m)
{ int i;

  for (i=m; --i >= 0; )
    *set3++ = (*set1++) & (*set2++);
}


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{
  graph g[MAXN*MAXM];
  graph canong[MAXN*MAXM];
  nvector lab[MAXN],ptn[MAXN],orbits[MAXN];
  static DEFAULTOPTIONS_GRAPH(options);
  statsblk(stats);
  setword workspace[50*MAXM];
  set *gv, *gv2, *gv3;
  set inter[MAXM];

  int r=0,c=0,s=0,count=0;
  int n,m,i,j,k,e,ok;
  int cbits,nint,slevel=SLEVEL,depth,ii,jj;
  unsigned crep[MAXDEPTH];

  typedef struct node {
    unsigned elem;
    struct node *right;
    struct node *down;
  } NODE;
  NODE *start, *work; 
  char *free, *end;
  int blockcount, nodecount, snodecount;
  unsigned *elem;

 
  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1;
      if (argv[i][j] == 't') mask |= 2;
      if (argv[i][j] == 'T') mask &= ~2;
      if (argv[i][j] == 'c') mask |= 16;
      if (argv[i][j] == 'C') mask &= ~16;
      if (argv[i][j] == 'i') mask |= 32;
      if (argv[i][j] == 'I') mask &= ~32;
      if (argv[i][j] == 's') sscanf(argv[i]+j+1,"%d",&slevel);
        
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: molsfilter [options]\n");
	printf("Dimensions and size of MOLS sets are taken from stdin.\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
        printf("-p, -P   Print inequivalent MOLS sets (default yes)\n");
        printf("-t, -T   Print information about tree (default no)\n");
	printf("-c, -C   Return paratopism classes (default no)\n");
	printf("-i, -I   Return isomorphisms classes (default no)\n");
        printf("-sN      Set level for short nodes to N (default N=%d)\n",SLEVEL);
	exit(0);
      }

      ++j;
    }
  }

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

  printf("%d %d %d\n\n",r,c,s);

  /* Compute parameters for compact representation */

  cbits = 0;
  i = c-1;
  while (i!=0)
  { ++cbits;
    i >>= 1;
  }
  nint = (8*sizeof(unsigned)/cbits)+(8*sizeof(unsigned)%cbits!=0);
  if (slevel>=r*c*s) depth = r*c*s;
  else depth = ((r*c*s-slevel)/nint)+((r*c*s-slevel)%nint!=0)+slevel;
  if (depth >= MAXDEPTH)
  { printf("Increase MAXDEPTH!\n");
    exit(0);
  }

  start=0;
  
  /*  Define n,m (for nauty) */

  n = r+(s+1)*c+r*c;
  m = (n + WORDSIZE - 1) / WORDSIZE;

  /* Options for nauty */

  options.writemarkers = FALSE;
  options.writeautoms = FALSE;
  options.defaultptn = FALSE;
  options.getcanon = TRUE;
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

    /* Add complete subgraphs for paratopism */

    if (mask & 16) for (k=0; k<s+2; ++k) for (i=0; i<c; ++i)
    { gv = GRAPHROW(g,i+c*k,m);
      for (j=0; j<c; ++j) if (i!=j) ADDELEMENT(gv,j+c*k);
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

    nauty(g,lab,ptn,NILSET,orbits,&options,&stats,workspace,50*MAXM,m,n,canong);

    /* Transform canong to MOLS */

    for (i=0; i<r; ++i)
    { gv = GRAPHROW(canong,i,m);
      for (j=0; j<c; ++j)
      { gv2 = GRAPHROW(canong,r+j,m);
        intersect(gv,gv2,inter,m);
        gv3 = GRAPHROW(canong,nextelement(inter,m,-1),m);
        e = -1;
        while ((e = nextelement(gv3,m,e)) < r+c) ;
        canonls[0][i][j]=e-r-c;
	for (k=1; k<s; ++k)
	{ e=nextelement(gv3,m,e);
	  canonls[k][i][j]=e-r-(k+1)*c;
	}
      }
    }

    /* writecanonls(r,c,s); */

    /* Translate to compact representation */

    ii=0;
    jj=0;
    crep[0]=0;
    for (k=0; k<s; ++k) for (i=0; i<r; ++i) for (j=0; j<c; ++j) 
    { crep[ii] <<= cbits;
      crep[ii] += canonls[k][i][j];
      ++jj;
      if (k*r*c+i*c+j<slevel || jj==nint)
      { jj=0;
        ++ii;
        crep[ii]=0;
      }
    }

    /* for (i=0; i<depth; ++i) printf("%u ",crep[i]);
    printf("\n"); */

    /* Memorize canonical representative, if neccessary */

    /* First MOLS set */

    if (start==0)
    { if (mask & 1) writemols(r,c,s); 
      blockcount = 1;
      nodecount = 1;
      snodecount = slevel>0;
      free = (char *)malloc(MEMBLOCK);
      if (free==NULL)
      { printf("Out of memory on %d. malloc() call!\n",blockcount);
        exit(0);
      }
      start = (NODE *)free;
      end = free + MEMBLOCK-1-sizeof(NODE);
      free += sizeof(NODE);
      if (free>end)
      { printf("Increase MEMBLOCK!\n");
	exit(0);
      }
      elem = crep;
      work = start;
      work->elem = *elem;
      ++elem;
      work->down = 0;
      i=1;

      while (i<depth)
      { work->right = (NODE *)free;
	work=(NODE *)free;
  	free += sizeof(NODE);
	if (free>end)
	{ printf("Increase MEMBLOCK!\n");
	  exit(0);
	}
	work->elem = *elem;
	++elem;
	work->down = 0;
	if (i<slevel) ++snodecount;
	++i;
	++nodecount;
      }
      work->right = 0;
    }

    /* Not the first MOLS set */

    else
    { work = start;
      elem = crep;
      i = 0;
      
      while (((work->right!=0) && (work->elem==*elem)) || 
             ((work->down!=0) && (work->elem!=*elem)))
      { if (work->elem == *elem) 
        { work = work->right;
          ++elem;
          ++i;
        }
        else work = work->down; 
      }
  
      if (work->elem != *elem)  /* Rest of crep needs to be memorised */
      { if (mask & 1) writemols(r,c,s); 

	work->down = (NODE *)free;
	work=(NODE *)free;
	free += sizeof(NODE);
        if (free>end)
	{ ++blockcount;
          free = malloc(MEMBLOCK);
          if (free==NULL)
          { printf("\nOut of memory on %d. malloc() call!\n",blockcount);
            exit(0);
          }
	  end = free+MEMBLOCK-1-sizeof(NODE);
	}
	work->elem = *elem;
	++elem;
	work->down = 0;
	if (i<slevel) ++snodecount;
	++i;
	++nodecount;

        while (i<depth)
        { work->right = (NODE *)free;
	  work=(NODE *)free;
	  free += sizeof(NODE);
	  if (free>end)
	  { ++blockcount;
	    free = malloc(MEMBLOCK);
            if (free==NULL)
            { printf("\nOut of memory on %d. malloc() call!\n",blockcount);
              exit(0);
            }
	    end = free+MEMBLOCK-1-sizeof(NODE);
	  }
	  work->elem = *elem;
	  ++elem;
	  work->down = 0;
	  if (i<slevel) ++snodecount;
	  ++i;
	  ++nodecount;
        }
	work->right = 0;
      }		
    }    

  } /* End of main loop */

  if (mask & 2)
  { printf("Tree contains %d nodes of %d bytes (%d bytes)\n",nodecount,sizeof(NODE),nodecount*sizeof(NODE));
    printf("Number of short nodes: %d (slevel=%d, depth=%d)\n",snodecount,slevel,depth);
    printf("Allocated %d blocks of %d bytes (%d bytes)\n\n",blockcount,MEMBLOCK,blockcount*MEMBLOCK); 
  }

}
