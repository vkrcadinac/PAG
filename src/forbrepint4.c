/*
    FORBREPINT4.C

    Fast program for generating orbit representatives of
    k-element subsets of a v-element set. Version that works
    with field of unsigned integers instead of double floats.
    Tests intersections at lower levels of search and does not
    find short orbits!

    Input:
    v k x y
    n (group order)
    list of group elements

    Vedran Krcadinac (krcko@math.hr), 9.2.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/


#define MAXV    250    /* Maximal size of set */
#define NINTS   8      /* Number of ints for bitfield; NINTS*sizeof(int)*8 must be >= MAXV */
#define MAXK    30     /* Maximal k */
#define MAXN	15000   /* Maximal order of group */

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Global stuff */
/****************/

unsigned char g[MAXN][MAXV];    /* Group elements */
int v=0,k=0,n=0;            /* Parameters */
int x, y;                   /* Intersection sizes */
double count=0.0,count2=0.0,ftree[MAXK+1];
unsigned int orb[MAXN][NINTS], pot[MAXV][NINTS];
int inc[MAXV], pinc[MAXV];
int bitsum[256];


int mask = 1;	/* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Print orbit representatives (-p, -P)
   2  Report number of orbits (-r, -R) 
   4  Flush output (-f, -F)
   8  Find orbits with intersection numbers <=y and ignore x (-t, -T)
*/

unsigned char set[MAXK];
int testxy;

int idot(unsigned int x, unsigned int y)
{ unsigned int and,sum;
  
  and = x & y;
  sum = bitsum[and & 255];
  and >>= 8;
  sum += bitsum[and & 255];
  and >>= 8;
  sum += bitsum[and & 255];
  and >>= 8;
  sum += bitsum[and];
  return sum;
}


void search(int e, int s)
{ int i,j,j1,ok,is;

  ftree[e]+=1.0;

  if (e==k) 
  { if (mask & 1)
    { if (count==0) printf("[");
      else printf(",\n["); 
      for (i=0; i<k-1; ++i) printf("%d,",set[i]+1);
      printf("%d]",set[k-1]+1);
      if (mask & 4) fflush(stdout);
    }
    count+=1.0;
  }
  else
  { for (i=s; i<=v-k+e; ++i)
    { set[e]=i;
      ok=1;
      for (j1=0; j1<NINTS; ++j1) orb[0][j1]+=pot[g[0][i]][j1];
      for (j=1; j<n; ++j)
      { for (j1=0; j1<NINTS; ++j1) orb[j][j1]+=pot[g[j][i]][j1];
        j1=NINTS-1;
        while (j1>0 && orb[0][j1]==orb[j][j1]) --j1;
        ok &= orb[0][j1]>=orb[j][j1];
        if (ok && e>y)
        { is=idot(orb[0][0],orb[j][0]);
          for (j1=1; j1<NINTS; ++j1) is+=idot(orb[0][j1],orb[j][j1]);
          ok &= is<=y;
          if ((e+1)==k && testxy)
          { ok &= is==x || is==y; 
          } 
        }
      }
      if (ok) search(e+1,i+1);
      for (j=0; j<n; ++j) for (j1=0; j1<NINTS; ++j1) orb[j][j1]-=pot[g[j][i]][j1];
    }
  }
} 

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,j1;

  if (sizeof(i)*8*NINTS<MAXV)
  { printf("sizeof(int)=%d, NINTS=%d, MAXV=%d\n",sizeof(i),NINTS,MAXV); 
    printf("Increase NINTS!\n");
    exit(0);
  }

  /* Command line arguments */

  for(i=1; i<argc; ++i) 
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'p') mask |= 1; 
      if (argv[i][j] == 'P') mask &= ~1;
      if (argv[i][j] == 'r') mask |= 2; 
      if (argv[i][j] == 'R') mask &= ~2;
      if (argv[i][j] == 'f') mask |= 4; 
      if (argv[i][j] == 'F') mask &= ~4;
      if (argv[i][j] == 't') mask |= 8; 
      if (argv[i][j] == 'T') mask &= ~8;
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H')
	  || (argv[i][j] == '?'))
      { printf("Usage: forbrepint4 [options]\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
        printf("-p, -P   Print good orbit representatives (default yes)\n");
        printf("-r, -R   Report number of orbits & tree (default no)\n");
        printf("-f, -F   Flush output (default no)\n");
        printf("-t, -T   Find orbits with intersections <=y and ignore x (default no)\n");
        printf("         This can be used for Steiner t-designs by setting y=t-1\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  } 

  testxy=1;
  if (mask & 8) testxy=0;

  /* Set up 'bitsum' */
 
  for (i=0; i<256; ++i)
  { bitsum[i] = 0;
    j = i;
    while (j != 0)
    { if (j & 1) ++bitsum[i];
      j >>= 1;
    }
  }

  /* Read parameters */

  scanf("%d",&v);
  if (v > MAXV)
  { printf("\nIncrease MAXV!\n");
    exit(0);
  }
  scanf("%d",&k);
  if (k > v)
  { printf("\nParameter k can be at most v.\n");
    exit(0);
  }
  if (k > MAXK)
  { printf("\nIncrease MAXK!\n");
    exit(0);
  }
  scanf("%d",&x);
  scanf("%d",&y);
  scanf("%d",&n);
  if (n > MAXN)
  { printf("\nIncrease MAXN!\n");
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

  /* Set up and start search */

  for (i=0; i<n; ++i) for (j=0; j<NINTS; ++j)  orb[i][j]=0;
  pot[v-1][0]=1;
  for (j=1; j<NINTS; ++j) pot[v-1][j]=0;
  j1=0;
  for (i=1; i<v; ++i)
  { for (j=0; j<NINTS; ++j) pot[v-1-i][j]=0;
    pot[v-1-i][j1]=pot[v-i][j1] << 1;
    if (pot[v-1-i][j1]==0)
    { ++j1;
      pot[v-1-i][j1]=1;
    }
  }

  /* for (i=0; i<v; ++i)
  { for (j=0; j<NINTS; ++j) printf("%u ",pot[i][j]);
    printf("\n");
  }
  exit(0); */

  for (i=0; i<k; ++i) ftree[i]=0.0;

  if (mask & 1) printf("PAGProcessResult:=[\n");

  search(0,0); 

  if (mask & 1) printf("\n];\n");

  if (mask & 2)
  { printf("Good orbits : %.0f\n",count);

    printf("tree: ");
    for (i=0; i<=k; ++i) printf("%.0f ",ftree[i]);
    printf("\n");
  }

}
