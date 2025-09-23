/*
    MAKEDLX.C

    Take t- and k-subset orbit representatives and compute DLX file.

    Input:
    v t k 
    n (group order)
    list of group elements
    nt (number of t-subset orbits)
    list of t-subset orbit representatives
    nk (number of k-subset orbits)
    list of k-subset orbit representatives

    Vedran Krcadinac (krcko@math.hr), 17.2.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/

#define MAXV    250    /* Maximal size of set */
#define NINTS   8      /* Number of ints for bitfield; NINTS*sizeof(int)*8 must be >= MAXV */
#define MAXK    30     /* Maximal k */
#define MAXN	6000   /* Maximal order of group */

#include <stdio.h>
#include <stdlib.h>
#include "exact.h"

/****************/
/* Global stuff */
/****************/

int bitsum[256];

int mask = 0;	/* An integer mask for options */
/* Meaning of the bits are:
   1  Repeat columns
   2  Add rows
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

void writedlx(exact_t *e)
{ int m,n,i,j;

  m=exact_num_rows(e);
  n=exact_num_cols(e);
  for (j=0; j<n; ++j)
  { for (i=0; i<m; ++i) if (exact_is_entry(e,i,j)) printf("%d ",i);
    printf("\n");
  }
}

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,ok,i1,j1,j2;
  unsigned char g[MAXN][MAXV];    /* Group elements */
  int v=0,t=0,k=0,n=0;            /* Parameters and group size */
  unsigned int orb[MAXN][NINTS], pot[MAXV][NINTS];
  int nt,nk,stab,is,e;
  unsigned int *tsub;
  int bad1=0,bad2=0,ee;
  char *cfilename, *rfilename;
  FILE *cfile, *rfile;
  exact_t *lei;
  int nc,nr,*dc,b;

  if (sizeof(i)*8*NINTS<MAXV)
  { printf("sizeof(int)=%d, NINTS=%d, MAXV=%d\n",sizeof(i),NINTS,MAXV); 
    printf("Increase NINTS!\n");
    exit(0);
  }

  /* Command line arguments */

  for(i=1; i<argc; ++i) 
  { /* if (argv[i][1] == 'x') mask |= 1;
    if (argv[i][1] == 'X') mask &= ~1; */
    if (argv[i][1] == 'c') 
    { cfilename=argv[i]+2;
      mask |= 1;
    }
    if (argv[i][1] == 'r') 
    { rfilename=argv[i]+2;
      mask |= 2;
    }
    /* Help */
    if ((argv[i][1] == 'h') || (argv[i][1] == 'H') || (argv[i][1] == '?'))
    { printf("Usage: makedlx [options]\n");
      printf("Options:\n");
      printf("-cFILENAME  Repeat columns, given in file, at the end of the matrix.\n");
      printf("            A row will also be added, ensuring that exactly one of the repeated columns must be chosen.\n");
      printf("-rFILENAME  Add more rows, given in file.\n");
      exit(0);
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

  /* Allocate libexact instance and create rows */

  /* Open files */

  if (mask & 1)
  { cfile = fopen(cfilename,"r");
    if (cfile==0)
    { printf("Cannot open file '%s'!\n",cfilename);
      exit(0);
    }
  }

  if (mask & 2)
  { rfile = fopen(rfilename,"r");
    if (rfile==0)
    { printf("Cannot open file '%s'!\n",rfilename);
      exit(0);
    }
  }

  lei = exact_alloc();
  for (i=0; i<nt; ++i) exact_declare_row(lei, i, 1);

  /* Read k-subset orbits and compute Kramer-Mesner matrix */

  scanf("%d",&nk);
  for (i=0; i<nk; ++i)
  { exact_declare_col(lei, i, 1);
    for (i1=0; i1<n; ++i1) for (j1=0; j1<NINTS; ++j1)  orb[i1][j1]=0;
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
    for (j=0; j<nt; ++j)
    { e=0;
      for (j2=0; j2<n; ++j2)
      { is=idot(orb[j2][0],*(tsub+j*NINTS));
        for (j1=1; j1<NINTS; ++j1) is += idot(orb[j2][j1],*(tsub+j*NINTS+j1));
	if (is==t) ++e;
      }
      ee=e/stab;
      if (e%stab) bad1=1;
      if (ee>1) bad2=1; 
      if (ee) exact_declare_entry(lei, j, i);
    } 
  }

  if (bad1)
  { printf("Error: entry was not divisible by stabilizer!\n");
  }

  if (bad2)
  { printf("Error: matrix contains entries that are not 0-1!\n");
  }

  if (bad1 || bad2) exit(0);

  /* Write first row of dlx file */

  for (i=0; i<nt; ++i) printf("%d ",i);

  /* Add rows */

  if (mask & 2)
  { ok=1;
    while (ok)
    { ok=fscanf(rfile,"%d",&b)==1;
      if (ok) 
      { exact_declare_row(lei, nt, b);
        if (b==1) printf("%d ",nt);
	else printf("%d|%d ",b,nt);
        fscanf(rfile,"%d",&nr);
	for (i=0; i<nr; ++i)
        { fscanf(rfile,"%d",&j);
          exact_declare_entry(lei, nt, j);
        }
        ++nt; 
      } 
    }
    fclose(rfile);
  }

  /* Duplicate columns */

  if (mask & 1)
  { fscanf(cfile,"%d",&nc);
    /* printf("No. duplicate columns: %d\nColumns: ",nc); */
    dc = (int *)calloc(nc,sizeof(int));
    exact_declare_row(lei, nt, 1);
    for (i=0; i<nc; ++i)
    { fscanf(cfile,"%d",dc+i);
      /* printf("%d ",dc[i]); */
      exact_declare_col(lei, nk+i, 1);
      exact_declare_entry(lei, nt, nk+i);
      for (j=0; j<nt; ++j) if (exact_is_entry(lei,j,dc[i]))
        exact_declare_entry(lei, j, nk+i);
    }
    fclose(cfile);
    printf("%d ",nt);
    ++nt;
    nk+=nc;
    /* printf("\n"); */
  }

  printf("\n");

  writedlx(lei);

}

