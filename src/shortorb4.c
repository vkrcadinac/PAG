/*
    SHORTORB4.C

    A program for generating short orbit representatives
    of k-element subsets of a v-element set, with up to 
    four prescribed intersection numbers.

    Input:
	v k
	x y z w
	n (group order)
	list of group elements
	seeds

    Vedran Krcadinac (krcko@math.hr), 29.4.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/


#define MAXV	500     /* Maximal size of set */
#define MAXN	50000  /* Maximal order of group */

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Global stuff */
/****************/

short int g[MAXN][MAXV];    /* Group elements */
int v=0,k=0,n=0;            /* Parameters */
int x, y, z, w;                /* Intersection sizes */
int take[MAXV], orbsize[MAXV], norb;
int set[MAXV];
short int orb[MAXV][MAXV], tsize,fst=1;
int count=0;

int mask = 0;	/* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Symmertric designs (set intersections are x) -s, -S
   2  Quasi-symmetric designs (set intersections are x or y) -q, -Q
*/

int backtrack(int depth, int size)
{ int i,j,ok,is;

  /* printf("norb=%d, depth=%d, size=%d\n",norb,depth,size); */
  
  if (depth==norb)
  { if (size==0)
	{ for (i=0; i<v; ++i) set[i]=0;
	  for (i=0; i<norb; ++i) if (take[i])
		for (j=0; j<orbsize[i]; ++j) set[orb[i][j]]=1;
	  ok=1;
	  for (i=1; ok && i<n; ++i)
	  { is=0;
	    for (j=0; j<v; ++j) if (set[g[i][j]] && set[j]) ++is;
	    ok = is==x || is==y || is==z || is==w || is==k;
	  }
	  if (ok)
	  { ++count;
	    if (fst) fst=0;
	    else printf(",\n");
	    printf("[");
        j=0;
	    for (i=0; i<v; ++i) if (set[i]) 
		{ printf("%d",i+1);
	      ++j;
		  if (j<k) printf(",");
		}
	    printf("]");
	  }
	}
  }
  else
  { backtrack(depth+1,size);
    if (size-orbsize[depth]>=0)
	{ take[depth]=1;
	  backtrack(depth+1,size-orbsize[depth]);
	  take[depth]=0;
    }
  }
  return 1;
}


int backtrack0(int depth, int size)
{ int i,j;

  /* printf("norb=%d, depth=%d, size=%d\n",norb,depth,size); */
  
  if (depth==norb)
  { if (size==0)
	{ for (i=0; i<v; ++i) set[i]=0;
	  for (i=0; i<norb; ++i) if (take[i])
		for (j=0; j<orbsize[i]; ++j) set[orb[i][j]]=1;
	  ++count;
	  if (fst) fst=0;
	  else printf(",\n");
	  printf("[");
      j=0;
	  for (i=0; i<v; ++i) if (set[i]) 
	  { printf("%d",i+1);
	    ++j;
		if (j<k) printf(",");
	  }
	  printf("]");
	}
  }
  else
  { backtrack0(depth+1,size);
    if (size-orbsize[depth]>=0)
	{ take[depth]=1;
	  backtrack0(depth+1,size-orbsize[depth]);
	  take[depth]=0;
    }
  }
  return 1;
}



/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok;


  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 's') { mask |= 1; mask &= ~2; }
      if (argv[i][j] == 'S') mask &= ~1;
      if (argv[i][j] == 'q') { mask |= 2; mask &= ~1; }
      if (argv[i][j] == 'Q') mask &= ~2;
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H')
	  || (argv[i][j] == '?'))
      { printf("Usage: shortorb4 [options]\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
        /* printf("-s, -S   Orbit elements intersect in x points; for symmetric designs (default no)\n");
        printf("-q, -Q   Orbit elements intersect in x or y points; for quasi-symmetric designs (default no)\n"); */
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  /* Read parameters */

  scanf("%d",&v);
  if (v > MAXV)
  { fprintf(stderr,"\nIncrease MAXV!\n");
    exit(0);
  }
  scanf("%d",&k);
  if (k > v)
  { fprintf(stderr,"\nParameter k can be at most v.\n");
    exit(0);
  }
  scanf("%d",&x);
  scanf("%d",&y);
  scanf("%d",&z);
  scanf("%d",&w);
  scanf("%d",&n);
  if (n > MAXN)
  { fprintf(stderr,"\nIncrease MAXN!\n");
    exit(0);
  }

  /* Read group elements */

  for (i=0; i<n; ++i)
    for (j=0; j<v; ++j)
	{ scanf("%d",&g[i][j]);
	  --g[i][j];
	}

  /* for (i=0; i<n; ++i)
  { for (j=0; j<v; ++j) printf("%d ",g[i][j]);
    printf("\n");
  }
  exit(0); */

  /*************/
  /* Main loop */
  /*************/

  printf("PAGProcessResult:=[\n");

  norb=0;
  orbsize[0]=0;
  tsize=0;
  ok=0;
  for (i=0; i<v; ++i) take[i]=0;

  while (scanf("%d",&i)>=0) if (i==-1)
  { ok |= orbsize[norb]<=k;
	tsize+=orbsize[norb];
    ++norb;
    orbsize[norb]=0;
    if (tsize==v)
    { if (ok) 
		{ /* for (i=0; i<norb; ++i)
			{ for (j=0; j<orbsize[i]; ++j) printf("%d ",orb[i][j]+1);
			  printf("; ");
			}
		  printf("\n"); */
		  if (x==-1 || y==-1) backtrack0(0,k);
	      else backtrack(0,k);
	      /* printf("Zavrsio s backtrackingom\n"); */
		}
      norb=0;
      orbsize[0]=0;
      tsize=0;
	  ok = 0;
    }
  }
  else
  { orb[norb][orbsize[norb]]=i-1;
    ++orbsize[norb];
  }
  printf("\n];\n");

  /* printf("count=%d\n",count); */

}
