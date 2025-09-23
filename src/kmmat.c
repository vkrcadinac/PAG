/*
    KMMAT.C

    Computes Kramer-Mesner matrix.

    Input:
    v t k 
    n (group order)
    list of group elements
    nt (number of t-subset orbits)
    list of t-subset orbit representatives
    nk (number of k-subset orbits)
    list of k-subset orbit representatives

    Vedran Krcadinac (krcko@math.hr), 3.2.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/


#define MAXV    250    /* Maximal size of set */
#define NINTS   8      /* Number of ints for bitfield; NINTS*sizeof(int)*8 must be >= MAXV */
#define MAXK    30     /* Maximal k */
#define MAXN	6000   /* Maximal order of group */

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Global stuff */
/****************/

int bitsum[256];


int mask = 1;	/* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Print orbit representatives (-p, -P)
   2  Report number of orbits (-r, -R) 
   4  Flush output (-f, -F)
*/

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


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,i1,j1,j2;
  unsigned char g[MAXN][MAXV];    /* Group elements */
  int v=0,t=0,k=0,n=0;            /* Parameters */
  unsigned int orb[MAXN][NINTS], pot[MAXV][NINTS];
  int nt,nk,stab,is,e;
  unsigned int *tsub;

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
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H')
	  || (argv[i][j] == '?'))
      { printf("Usage: kmmat [options]\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
        /* printf("-p, -P   Print good orbit representatives (default yes)\n");
        printf("-r, -R   Report number of orbits & tree (default no)\n");
        printf("-f, -F   Flush output (default no)\n");
        printf("\n"); */
	exit(0);
      }
      ++j;
    }
  }  

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
  scanf("%d",&t);
  if (t > v)
  { printf("\nParameter t can be at most v.\n");
    exit(0);
  }
  if (t > MAXK)
  { printf("\nIncrease MAXK!\n");
    exit(0);
  }
  scanf("%d",&k);
  if ((t>k) || (k > v))
  { printf("\nParameters must satisfy t<=k<=v.\n");
    exit(0);
  }
  if (k > MAXK)
  { printf("\nIncrease MAXK!\n");
    exit(0);
  }
  scanf("%d",&n);
  if (n > MAXN)
  { printf("\nIncrease MAXN!\n");
    exit(0);
  } 

  /* printf("v=%d, t=%d, k=%d, n=%d\n",v,t,k,n); */

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

  /* Set up pot */

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

  /* printf("v=%d\n",v);
  for (i=0; i<v; ++i)
  { for (j=0; j<NINTS; ++j) printf("%u ",pot[i][j]);
    printf("\n");
  }
  exit(0); */

  /* Read and memorize t-subset orbit representatives */

  scanf("%d",&nt);
  tsub = (int *)calloc(nt,NINTS*sizeof(unsigned int));
  if (tsub==NULL)
  { printf("Could not allocate memory.\n");
    exit(0);
  }

  for (i=0; i<nt; ++i) 
  { for (j=0; j<t; ++j) 
    { scanf("%d",&e);
      --e;
      /* printf("%d ",e); */
      for (j1=0; j1<NINTS; ++j1) *(tsub+i*NINTS+j1)+=pot[e][j1];
    }
    /* printf("\n");
    for (j1=0; j1<NINTS; ++j1) printf("%d ",*(tsub+i*NINTS+j1));
    printf("\n\n"); */
  }

  /* printf("Read %d representatives of %d-subset orbits.\n",nt,t); */

  /* Read k-subset orbits and compute Kramer-Mesner matrix */

  scanf("%d",&nk);
  printf("PAGProcessResult:=TransposedMat([\n");
  for (i=0; i<nk; ++i)
  { for (i1=0; i1<n; ++i1) for (j1=0; j1<NINTS; ++j1)  orb[i1][j1]=0;
    for (j=0; j<k; ++j) 
    { scanf("%d",&e);
      --e;
      for (j2=0; j2<n; ++j2) for (j1=0; j1<NINTS; ++j1) orb[j2][j1]+=pot[g[j2][e]][j1];
    }
    stab=1;
    for (j=1; j<n; ++j)
    { ok=1;
      for (j1=0; ok && j1<NINTS; ++j1) ok=orb[j][j1]==orb[0][j1];
      if (ok) ++stab;
    }
    printf("[%d,",n/stab);
    for (j=0; j<nt; ++j)
    { e=0;
      for (j2=0; j2<n; ++j2)
      { is=idot(orb[j2][0],*(tsub+j*NINTS));
        for (j1=1; j1<NINTS; ++j1) is += idot(orb[j2][j1],*(tsub+j*NINTS+j1));
	if (is==t) ++e;
      }
      printf("%d",e/stab);
      if (j<nt-1) printf(",");
    } 
    printf("]");
    if (i<nk-1) printf(",");
    printf("\n"); 
  }
  printf("]);\n");

}

