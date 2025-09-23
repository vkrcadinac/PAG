/*
    SOLVELIBEXACT3.C

    Take t- and k-subset orbit representatives for Steiner designs, set
    up exact cover problem instance in memory and call libexact. 

    Input:
    v t k 
    n (group order)
    list of group elements
    nt (number of t-subset orbits)
    list of t-subset orbit representatives
    nk (number of k-subset orbits)
    list of k-subset orbit representatives

    Vedran Krcadinac (krcko@math.hr), 18.2.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/

#define MAXV    250    /* Maximal size of set */
#define NINTS   8      /* Number of ints for bitfield; NINTS*sizeof(int)*8 must be >= MAXV */
#define MAXK    30     /* Maximal k */
#define MAXN	6000   /* Maximal order of group */
#define MAXRHS	1000   /* Maximal number of added equations */

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
   4  Report solutions
   8  Iterate throgh fixed options 
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
  int v=0,t=0,k=0,n=0;            /* Parameters and group size */
  unsigned int orb[MAXN][NINTS], pot[MAXV][NINTS];
  int nt,nk,stab,is,e;
  unsigned int *tsub;
  int bad1=0,bad2=0,ee;
  char *cfilename, *rfilename, *outfilename;
  FILE *cfile, *rfile, *outfile;
  exact_t *lei, *lei2;
  int nc,nr,*dc,b,fix;
  int freq=1, *row;
  long int count;
  int soln_size;
  const int *soln;
  int iter, rhs[MAXRHS], nrhs;

  outfilename="solutions";

  if (sizeof(i)*8*NINTS<MAXV)
  { printf("sizeof(int)=%d, NINTS=%d, MAXV=%d\n",sizeof(i),NINTS,MAXV); 
    printf("Increase NINTS!\n");
    exit(0);
  }

  /* Command line arguments */

  for(i=1; i<argc; ++i) 
  { if (argv[i][1] == 's') mask |= 4;
    if (argv[i][1] == 'S') mask &= ~4; 
    if (argv[i][1] == 'i') mask |= 8;
    if (argv[i][1] == 'I') mask &= ~8; 
    if (argv[i][1] == 'c') 
    { cfilename=argv[i]+2;
      mask |= 1;
    }
    if (argv[i][1] == 'r') 
    { rfilename=argv[i]+2;
      mask |= 2;
    }
    if (argv[i][1] == 'o') outfilename=argv[i]+2;
    if (argv[i][1] == 'f') sscanf(argv[i]+2,"%d",&freq);
    /* Help */
    if ((argv[i][1] == 'h') || (argv[i][1] == 'H') || (argv[i][1] == '?'))
    { printf("Usage: solvelibexact3 [options]\n");
      printf("Options:\n");
      printf("-s, -S      Report found solutions (default no).\n"); 
      printf("-fN         Frequency of reporting (default N=%d).\n",freq);
      printf("-oFILENAME  Output file name (default: %s).\n",outfilename);
      printf("-rFILENAME  Add more rows, given in file.\n");
      printf("-cFILENAME  Repeat columns, given in file, at the end of the matrix. A row will also be\n"); 
      printf("            added, ensuring that exactly one of the repeated columns must be chosen.\n");
      printf("-i, -I      Instead of repeating columns, iterate through the options given in the -c file.\n");
      printf("            Each time a row with a single entry is added and the solver is restarted.\n");
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

  /* Add rows */

  nrhs=0;
  if (mask & 2)
  { ok=1;
    while (ok)
    { ok=fscanf(rfile,"%d",&b)==1;
      if (ok) 
      { rhs[nrhs]=b;
        ++nrhs;
	if (nrhs==MAXRHS)
        { printf("Increase MAXRHS!\n");
          exit(0);
        }
	exact_declare_row(lei, nt, b);
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

  /* Iterate */

  if (mask & 8)
  { 
    if (mask & 1) fscanf(cfile,"%d",&nc);
    else
    { printf("Cannot iterate; specify file with -c option!\n");
      exit(0);
    }

    /* Start search  */
    
    if (mask & 4) printf("Starting search...\n");
    outfile = fopen(outfilename,"w");
    if (outfile==0)
    { printf("Cannot open output file '%s'!\n",outfilename);
      exit(0);
    }
    row = (int *)calloc(nk,sizeof(int));
    count=0;

    for (iter=0; iter<nc; ++iter)
    { fscanf(cfile,"%d",&fix);
      if (mask & 4) 
      { printf("Iteration %d/%d: fixing %d\n",iter+1,nc,fix+1);
        fflush(stdout);
      }
      lei2 = exact_alloc();

      for (i=0; i<nt-nrhs; ++i) exact_declare_row(lei2, i, 1);
      for (i=0; i<nrhs; ++i) exact_declare_row(lei2, nt-nrhs+i, rhs[i]);
      for (j=0; j<nk; ++j) exact_declare_col(lei2, j, 1);
      for (i=0; i<nt; ++i) for (j=0; j<nk; ++j) if (exact_is_entry(lei,i,j)) exact_declare_entry(lei2,i,j);
      exact_declare_row(lei2, nt, 1);
      exact_declare_entry(lei2,nt,fix);

      while((soln = exact_solve(lei2, &soln_size)) != NULL) 
      { ++count;
        if ((mask & 4) && (count%freq==0)) 
        { printf("Solution #%ld\n",count);
          fflush(stdout);
        }
        for (i=0; i<nk; ++i) *(row+i)=0;
        for (i=0; i<soln_size; ++i) if (soln[i]<nk) *(row+soln[i])=1;
                                    else *(row+dc[soln[i]-nk])=1;
        for (i=0; i<nk; ++i) fprintf(outfile,"%d",*(row+i));
        fprintf(outfile,"\n"); 
        fflush(outfile);
      }

      exact_free(lei2);
    }

    if (mask & 4) 
    { printf("Total number of solutions: %ld\n",count);
    }

    fclose(outfile); 

  }

  /* Do not iterate */

  else
  { if (mask & 1)
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
      ++nt;
      /* printf("\n"); */
    }

    /*****************/
    /* Start search  */
    /*****************/

    if (mask & 4) 
    { printf("Starting search...\n");
      fflush(stdout);
    }

    outfile = fopen(outfilename,"w");
    if (outfile==0)
    { printf("Cannot open output file '%s'!\n",outfilename);
      exit(0);
    }

    row = (int *)calloc(nk,sizeof(int));

    count=0;

    while((soln = exact_solve(lei, &soln_size)) != NULL) 
    { ++count;
      if ((mask & 4) && (count%freq==0)) 
      { printf("Solution #%ld\n",count);
        fflush(stdout);
      }
      for (i=0; i<nk; ++i) *(row+i)=0;
      for (i=0; i<soln_size; ++i) if (soln[i]<nk) *(row+soln[i])=1;
                                  else *(row+dc[soln[i]-nk])=1;
      for (i=0; i<nk; ++i) fprintf(outfile,"%d",*(row+i));
      fprintf(outfile,"\n"); 
      fflush(outfile);
    }

    if (mask & 4) 
    { printf("Total number of solutions: %ld\n",count);
    }

    fclose(outfile); 
  }
}

