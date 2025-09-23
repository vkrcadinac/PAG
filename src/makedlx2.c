/*
    MAKEDLX2.C

    Take t- and k-subset orbit representatives and create DLX file.

    Input:
    v t k 
    n (group order)
    list of group elements
    nt (number of t-subset orbits)
    list of t-subset orbit representatives
    nk (number of k-subset orbits)
    list of k-subset orbit representatives

    Vedran Krcadinac (krcko@math.hr), 22.3.2025.
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

int bitsum[256];

int mask = 0;	/* An integer mask for options */
/* Meaning of the bits are:
   1  Repeated columns
   2  Add rows
   4  Secondary items and colors
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
{ int i,j,ok,i1,j1,j2,jj;
  unsigned char g[MAXN][MAXV];    /* Group elements */
  int v=0,t=0,k=0,n=0;            /* Parameters and group size */
  unsigned int orb[MAXN][NINTS], pot[MAXV][NINTS];
  int nt,nk,stab,is,e;
  unsigned int *tsub;
  int bad1=0,bad2=0,ee;
  char *cfilename, *rfilename, *mfilename=0, *pfilename;
  FILE *cfile, *rfile, *mfile, *pfile;
  int nc,nr,*dc,b,**memcol,*nmemcol,mc,M=0,*vec,np,*rhs,ne; 
  char **rows;

  if (sizeof(i)*8*NINTS<MAXV)
  { fprintf(stderr,"sizeof(int)=%d, NINTS=%d, MAXV=%d\n",sizeof(i),NINTS,MAXV); 
    fprintf(stderr,"Increase NINTS!\n");
    exit(0);
  }

  /* Command line arguments */

  for(i=1; i<argc; ++i) if (argv[i][0]='-') 
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
    if (argv[i][1] == 'p') 
    { pfilename=argv[i]+2;
      mask |= 5;
    }
    if (argv[i][1] == 'm') mfilename=argv[i]+2;
    if (argv[i][1] == 'm') mfilename=argv[i]+2;
    /* Help */
    if ((argv[i][1] == 'h') || (argv[i][1] == 'H') || (argv[i][1] == '?'))
    { printf("Usage: makedlx2 [options]\n");
      printf("Options:\n");
      printf("-rFILENAME  Add more rows, given in file.\n");
      printf("-cFILENAME  Repeat columns given in file at the end of the matrix. A row will also be\n");
      printf("            added, ensuring that exactly one of the repeated columns must be chosen.\n");
      printf("-pFILENAME  Read a partition of the columns from file. Expand matrix and add secondary\n");
      printf("            items and colors to avoid solutions equivalent under the normalizer.\n"); 
      printf("-mFILENAME  Write the number of 1-entries in the matrix to file.\n");
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
  { fprintf(stderr,"\nIncrease MAXV!\n");
    exit(0);
  }
  scanf("%d",&t);
  if (t > v)
  { fprintf(stderr,"\nParameter t can be at most v.\n");
    exit(0);
  }
  if (t > MAXK)
  { fprintf(stderr,"\nIncrease MAXK!\n");
    exit(0);
  }
  scanf("%d",&k);
  if ((t>k) || (k > v))
  { fprintf(stderr,"\nParameters must satisfy t<=k<=v.\n");
    exit(0);
  }
  if (k > MAXK)
  { fprintf(stderr,"\nIncrease MAXK!\n");
    exit(0);
  }
  scanf("%d",&n);
  if (n > MAXN)
  { fprintf(stderr,"\nIncrease MAXN!\n");
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
  { fprintf(stderr,"Could not allocate memory.\n");
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
  
  /* Read number of k-subset orbits */

  scanf("%d",&nk);

  /* Read and memorize added rows */

  nr=0;
  if (mask & 2)
  { rfile = fopen(rfilename,"r");
    if (rfile==0)
    { fprintf(stderr,"Cannot open file '%s'!\n",rfilename);
      exit(0);
    }
    ok=fscanf(rfile,"%d",&nr)==1;
    rhs = (int *)calloc(nr,sizeof(int));
    rows = (char **)calloc(nr,sizeof(char *));
    for (i=0; ok && i<nr; ++i)
    { rows[i] = (char *)calloc(nk,sizeof(char));
      ok=fscanf(rfile,"%d",rhs+i)==1;
      ok=fscanf(rfile,"%d",&ne)==1;
      for (j=0; ok && j<ne; ++j)
      { ok=fscanf(rfile,"%d",&i1)==1;
        *(rows[i]+i1)=1;
      }
    }
    fclose(rfile);
    if (!ok)
    { fprintf(stderr,"Error reading file with additional rows!\n");
      exit(0);
    }
    /* for (i=0; i<nr; ++i) printf("%d ",rhs[i]);
    printf("\n\n");
    for (i=0; i<nr; ++i) 
    { for (j=0; j<nk; ++j) printf("%d",*(rows[i]+j));
      printf("\n\n");
    }
    exit(0); */
  }

  /* Read duplicate columns */

  if ((mask & 1) && !(mask & 4))
  { cfile = fopen(cfilename,"r");
    if (cfile==0)
    { fprintf(stderr,"Cannot open file '%s'!\n",cfilename);
      exit(0);
    }
    fscanf(cfile,"%d",&nc);
    /* printf("No. duplicate columns: %d\nColumns: ",nc); */
    dc = (int *)calloc(nc,sizeof(int));
    for (i=0; i<nc; ++i)
    { fscanf(cfile,"%d",dc+i);
      /* printf("%d ",dc[i]); */
    }
    fclose(cfile);
    memcol = (int **)calloc(nc,sizeof(int *));
    nmemcol = (int *)calloc(nc,sizeof(int));
  }

  /* Read partition vector */

  if (mask & 4)
  { pfile = fopen(pfilename,"r");
    if (pfile==0)
    { fprintf(stderr,"Cannot open file '%s'!\n",pfilename);
      exit(0);
    }
    fscanf(pfile,"%d",&np);
    if (nk<np)
    { fprintf(stderr,"Number of orbits smaller than partition vector length!\n");
      exit(0);
    }
    vec = (int *)calloc(np,sizeof(int));
    nc=0;
    for (i=0; i<np; ++i)
    { fscanf(pfile,"%d",vec+i);
      if (vec[i]>nc) nc=vec[i];
    }
    fclose(pfile);
    dc = (int *)calloc(nc,sizeof(int));
    for (i=0; i<nc; ++i)
    { for (j=0; j<np && vec[j]!=(i+1); ++j) ;
      if (j==np)
      { fprintf(stderr,"Partition vector does not contain consecutive integers!\n");
        exit(0);
      }
      dc[i]=j;
    }
    memcol = (int **)calloc(nc,sizeof(int *));
    nmemcol = (int *)calloc(nc,sizeof(int));
  }

  /* printf("%d\n",np);
  for (i=0; i<np; ++i) printf("%d ",vec[i]);
  printf("\n");
  printf("%d\n",nc);
  for (i=0; i<nc; ++i) printf("%d ",dc[i]);
  printf("\n");
  exit(0); */

  /* Write first row of dlx file */

  for (i=0; i<nt; ++i) printf("%d ",i);
  if (mask & 1) printf("d ");
  if (mask & 2)
  { for (i=0; i<nr; ++i)
    { if (rhs[i]>1) printf("%d|",rhs[i]);
      printf("r%d ",i);
    }
  }
  if (mask & 4)
  { printf("| ");
    for (i=1; i<nc; ++i) printf("c%d ",i);
  }
  printf("\n");

  /* Read k-subset orbits and compute Kramer-Mesner matrix */

  mc=0;
  for (i=0; i<nk; ++i)
  { if (mask & 1)
    { for (j=0; j<nc && dc[j]!=i; ++j) ;
      mc=j<nc;
      if (mc) 
      { *(memcol+j) = (int *)calloc(nt,sizeof(int));
        *(nmemcol+j) = 0;
	jj=j;
      }
    }
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
      if (ee) 
      { ++M; 
	printf("%d ",j);
        if (mc) 
        { *(*(memcol+jj)+*(nmemcol+jj))=j;
          *(nmemcol+jj)+=1;
        }
      }
    }
    if (mask & 2)
    { for (i1=0; i1<nr; ++i1) if (*(rows[i1]+i)) printf("r%d ",i1);
    }
    if ((mask & 4) && (i<np))
    { if (vec[i]<nc) printf("c%d:1 ",vec[i]);
    }
    printf("\n");
  }

  if (bad1)
  { fprintf(stderr,"Error: entry was not divisible by stabilizer!\n");
  }

  if (bad2)
  { fprintf(stderr,"Error: matrix contains entries that are not 0-1!\n");
  }

  if (bad1 || bad2) exit(0);

  if (mask & 1)
  { for (i=0; i<nc; ++i)
    { for (j=0; j<*(nmemcol+i); ++j)
      { ++M; 
	printf("%d ",*(*(memcol+i)+j));
      }
      if (mask & 2)
      { for (i1=0; i1<nr; ++i1) if (*(rows[i1]+dc[i])) printf("r%d ",i1);
      }
      printf("d ");
      if (mask & 4)
      { for (j=1; j<=i; ++j) printf("c%d:0 ",j);
      }
      printf("\n");
    }
  }

  if (mfilename!=0)
  { mfile = fopen(mfilename,"w");
    fprintf(mfile,"return %d;\n",M);
    fclose(mfile);
  }

}

