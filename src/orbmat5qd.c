/*
    ORBMAT5QD.C

    Vedran Krcadinac (krcko@math.hr), 14.8.2007.
    Department of Mathematics, University of Zagreb, Croatia
                
*/

#define MAXM	20
#define MAXN	50
#define MAXT	10
#define MAXNOS	20
#define MAXCAND 10000
#define MAXMEM	1000
#define MAXOC	1000
 
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct { long int n,d; } frac;

/****************/
/* Global stuff */
/****************/

int A[MAXM][MAXN]; /* Orbit matrix */
int C[MAXM][MAXN]; /* Canonical orbit matrix */

int o[MAXM], O[MAXN]; /* Orbit sizes */
int m,n,m0,n0; /* Dimensions of the matrix */
int t,v,k,lambda[MAXT+1]; /* Parameters of the design */
int row,finalrow=0;
int lcm; /* Least common multiple of block-orbit sizes, squared */

int nos, os[MAXNOS], osf[MAXNOS], osl[MAXNOS], osn[MAXNOS]; /* Block-orbit sizes */
int ncomp, comp[MAXNOS]; /* Compositions */
int npart, part[MAXNOS][MAXN+1]; /* Partitions */
int ncand[MAXM], cand[MAXM][MAXCAND][MAXN+1], candf[MAXM][MAXCAND][MAXN+1], 
    candl[MAXM][MAXCAND][MAXN+1], scand[MAXCAND][MAXN]; /* Row candidates */

int mask = 0;	/* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
     1  Print information about row-entries and exit (-i)
     2  Read first part of matrix / start from scratch (-r, -R)
	 4  Create log file (-lFILENAME)
	 8  Write markers (-m, -M)
*/

int readmat(int mm, int nn)
{ int i,j,ok=1,x;
 
  for (i=m0; i<m; ++i) for (j=n0; j<n; ++j) A[i][j] = 0;

  for (i=0; ok && (i<mm); ++i)
    for (j=0; ok && (j<nn); ++j)
    { ok = scanf("%d",&x) == 1;
      A[i][j] = x;
    }
  
  return ok;
}

void writemat(int m, int n)
{ int i,j;

  for (i=0; i<m; ++i)
  { for (j=0; j<n; ++j) if (mask & 32) printf("%d ",o[i]*A[i][j]/O[j]);
                        else printf("%d ",A[i][j]);
    printf("\n");
  }
  printf("\n");
  fflush(stdout);
}

long int gcd(long int a, long int b)
{ long int tmp;

  if (a<b)
  { tmp = a;
    a = b;
    b = tmp;
  }

  while (b)
  { tmp = a % b;
    a = b;
    b = tmp;
  }

  return a;
}

frac reduce(frac q)
{ long int n;
  frac q2;
  
  n=gcd(q.d,q.n);
  q2.d=q.d/n;
  q2.n=q.n/n;
  return q2;
}

frac add(frac x, frac y)
{ frac r;

  r.n=x.n*y.d+y.n*x.d;
  r.d=x.d*y.d;
  return reduce(r);
}

int cmp(int *v1, int *v2, int n)
{ int i=0,c=0;

  while ((c==0) && (i<n))
  { c = *(v1+i)-*(v2+i);
    ++i;
  }
  
  return c;
} 



void makepart(int i, int n, int maxp, int maxl)
{ int j;
  
  if (n==0) ++npart;
  else if (i<maxl) for (j=maxp; j>0; --j) if (n-j>=0) makepart(i+1,n-j,j,maxl);
}

void makecand(int c, int i, int n, int maxp, int maxl)
{ int j,l,i1,ok;
  frac x,sum;
  
  if (c==nos) 
  { ++npart;
    /* printf("Partitions: ");
	for (j=0; j<nos; ++j)
	{ l=0;
	  if (part[j][l]==0) printf("0 ");
	  while (part[j][l]!=0)
	  { printf("%d ",part[j][l]);
	    ++l;
	  }
	  printf("| ");
	} 
	printf("\n"); */

	/* Test sum of squares */
	sum.n=lambda[1]+(o[row]-1)*lambda[2];
	sum.d=1;
	for (j=0; j<n0; ++j)
	{ x.n=-A[row][j]*A[row][j]*o[row];
	  x.d=O[j];
	  sum=add(sum,x);
	}
	/* printf("sum1=%d, ",sum.n); */
    for (j=0; j<nos; ++j)
	{ l=0;
	  while (part[j][l]!=0)
	  { x.n=-part[j][l]*part[j][l]*o[row];
	    x.d=os[j];
		sum=add(sum,x);
		++l;
	  }
    }
	/* printf("sum2=%d/%d ",sum.n,sum.d); */
	ok=sum.n==0;

	/* Test sum of cubes */
	if (t>=3)
	{ sum.n=lambda[1]+3*(o[row]-1)*lambda[2]+(o[row]-1)*(o[row]-2)*lambda[3];
	  sum.d=1;
 	  for (j=0; j<n0; ++j)
	  { x.n=-A[row][j]*A[row][j]*A[row][j]*o[row]*o[row];
	    x.d=O[j]*O[j];
	    sum=add(sum,x);
	  }
	  /* printf("sum1=%d, ",sum.n); */
      for (j=0; j<nos; ++j)
	  { l=0;
	    while (part[j][l]!=0)
		{ x.n=-part[j][l]*part[j][l]*part[j][l]*o[row]*o[row];
	      x.d=os[j]*os[j];
		  sum=add(sum,x);
		  ++l;
		}
	  }
	  /* printf("sum2=%d/%d ",sum.n,sum.d); */
	  ok&=sum.n==0;
	}
	/* printf("t=%d\n"); */

	/* printf("ok=%d\n",ok); */
	if (ok) 
	{ i1=0;
	  for (j=0; j<nos; ++j)
		{ l=0;
		  while (part[j][l]!=0)
		  { cand[row][ncand[row]][i1]=part[j][l];
  		    candf[row][ncand[row]][i1]=osf[j];
		    candl[row][ncand[row]][i1]=osl[j];
			++i1;
			++l;
		  }
		}
      cand[row][ncand[row]][i1]=0;
	  ++ncand[row];
	  if (ncand[row]==MAXCAND)
	  { printf("Increase MAXCAND!\n");
	    exit(0);
	  }
	}
  }
  else 
  { if (n==0) 
	{ part[c][i]=0;
      makecand(c+1,0,comp[c+1],os[c+1],osn[c+1]);
	}
    else if (i<maxl) for (j=maxp; j>0; --j) if (n-j>=0) 
	{ /* Alltop divisibility test */
	  if (!((o[row]*j) % os[c]))
      {	part[c][i]=j;
	    makecand(c,i+1,n-j,j,maxl);
	  }
	}
  }
}

void makecomp(int i, int sum)
{ int j;
  if (i==nos-1)
  { comp[i]=sum;
	++ncomp;
	makecand(0,0,comp[0],os[0],osn[0]);
  }
  else for (j=0; j<=sum; ++j)
  { comp[i]=j;
    makecomp(i+1,sum-j);
  }
}

int canon(int m, int n, int *A, int *C, int *nu, int *beta)
{ char K[MAXMEM][MAXN], K2[MAXMEM][MAXN];
  int nK,nK2;
  int d[MAXM],v[MAXN];
  int r,s,i,j,jj,k,c,ok,tmp;
  char rperm[MAXM], cperm[MAXN]; /* Row and column permutations */
  
 
  /* Compute C = canon(A) */

  nK = 1;
  
  for (r=0; r<m; ++r)
  { *(C+r*MAXN) = -1;
    for (s=0; s<nK; ++s)
    { 
      /* d = {1,..,m}\K[s] that preserve nu */

      for (i=0; i<m; ++i) d[i] = *(nu+r) == *(nu+i);
      for (i=0; i<r; ++i) d[K[s][i]] = 0; 
 
      for (j=0; j<m; ++j) if (d[j])
      { for (i=0; i<r; ++i) rperm[i] = K[s][i];
        rperm[r] = j;
        for (i=0; i<n; ++i) cperm[i] = i;

        /* Lexicographical sort */

        for (i=0; i<n-1; ++i)
          for (jj=i+1; jj<n; ++jj) if (*(beta+i)==*(beta+jj))
          { c=0;
            k=0;
            while ((c==0) && (k<r+1))
            { c = *(A+rperm[k]*MAXN+cperm[i]) - *(A+rperm[k]*MAXN+cperm[jj]);
              ++k;
            }
            if (c<0)
            { tmp = cperm[i];
              cperm[i] = cperm[jj];
              cperm[jj] = tmp;
            }
          }

        for (i=0; i<n; ++i) v[i] = *(A+rperm[r]*MAXN+cperm[i]);
        c = cmp(C+r*MAXN,v,n);
        if (c==0) 
        { for (i=0; i<=r; ++i) K2[nK2][i] = rperm[i];
          ++nK2;
          if (nK2==MAXMEM)
          { printf("\nIncrease MAXMEM!\n");
            exit(0);
          }
        }
        if (c<0)
        { for (i=0; i<n; ++i) *(C+r*MAXN+i)= v[i];
          for (i=0; i<=r; ++i) K2[0][i] = rperm[i];
          nK2=1;
        }
      }
    }
    nK = nK2;
    for (i=0; i<nK; ++i)
      for (j=0; j<=r; ++j) K[i][j] = K2[i][j];
  } 

  /* Is A == C ? */

  ok = 1;

  for (i=0; ok && (i<m); ++i)
    for (j=0; ok && (j<n); ++j) ok = *(A+i*MAXN+j) == *(C+i*MAXN+j);

  return ok;
}

void search(int row)
{ int i,j,l,work,ok;
  int ce,ci;
  int pos[MAXN];
  int y[MAXM],y1[MAXM],y2[MAXM],z[MAXM][MAXM];
  int pgame2[MAXM],pgame31[MAXM], pgame32[MAXM],pgame33[MAXM][MAXM];
	
  if (row==finalrow)
  { /* if (canon(row,n,A[0],C[0],o,O)) */ writemat(row,n);            
  }
  else
  { /* Permute candidates */
	for (ci=0; ci<ncand[row]; ++ci)
	{ /* printf("#%d\n",ci); */
	  for (i=0; i<n; ++i) pos[i]=0;
	  for (i=n0; i<n; ++i) A[row][i]=0;
	  /* Set up partial game products */
	  for (i=0; i<row; ++i)
	  { pgame2[i]=o[row]*lambda[2]*lcm;
	    for (j=0; j<n0; ++j) pgame2[i]-=o[row]*A[i][j]*A[row][j]*lcm/O[j];
		if (t>=3)
		{ pgame31[i]=(o[row]*lambda[2]+o[row]*(o[row]-1)*lambda[3])*lcm;
		  pgame32[i]=(o[row]*lambda[2]+o[row]*(o[i]-1)*lambda[3])*lcm;
          for (j=0; j<n0; ++j)
		  { pgame31[i]-=o[row]*o[row]*A[i][j]*A[row][j]*A[row][j]*lcm/O[j]/O[j];
		    pgame32[i]-=o[i]*o[row]*A[i][j]*A[i][j]*A[row][j]*lcm/O[j]/O[j];
		  }
		  for (j=i+1; j<row; ++j)
		  { pgame33[i][j]=o[i]*o[j]*lambda[3]*lcm;
		    for (l=0; l<n0; ++l)
			  pgame33[i][j]-=o[i]*o[j]*A[i][l]*A[j][l]*A[row][l]*lcm/O[l]/O[l];
		  }
		}
      }
      ce=0;
	  pos[0]=candf[row][ci][0];
	  work=1;
	  while (work)
	  { ok=A[row][pos[ce]]==0;
	    if (ok)
		{ for (i=0; i<row; ++i)
			{ y[i]=pgame2[i]-o[row]*cand[row][ci][ce]*A[i][pos[ce]]*lcm/O[pos[ce]];
		      ok &= y[i]>=0;
			  if (t>=3)
			  { y1[i]=pgame31[i]-o[row]*o[row]*cand[row][ci][ce]*cand[row][ci][ce]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
			    ok &= y1[i]>=0;
				y2[i]=pgame32[i]-o[i]*o[row]*cand[row][ci][ce]*A[i][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
			    ok &= y2[i]>=0;
				for (j=i+1; j<row; ++j)
				{ z[i][j]=pgame33[i][j]-o[i]*o[j]*cand[row][ci][ce]*A[i][pos[ce]]*A[j][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
			      ok &= z[i][j]>=0;
				}
			  }
			}
		  if (ok) for (i=0; i<row; ++i) 
		  { pgame2[i]=y[i];
		    if (t>=3)
			{ pgame31[i]=y1[i];
			  pgame32[i]=y2[i];
			  for (j=i+1; j<row; ++j) pgame33[i][j]=z[i][j];
			}
		  }		  
		}
	    /* printf("ci=%d, ce=%d, entry=%d, pos=%d, ok=%d\n",ci,ce,cand[row][ci][ce],pos[ce],ok); */
		if (ok) 
		{ A[row][pos[ce]]=cand[row][ci][ce];
		  /* writemat(row+1,n); */
		  ++ce;
		  if (cand[row][ci][ce])
		  { if (candf[row][ci][ce]==candf[row][ci][ce-1] && cand[row][ci][ce]==cand[row][ci][ce-1]) 
			{ pos[ce]=pos[ce-1]+1;
		      if (pos[ce]>candl[row][ci][ce])
			  { --ce;
			    for (i=0; i<row; ++i)
				{ pgame2[i]+=o[row]*A[row][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]];
				  if (t>=3)
				  { pgame31[i]+=o[row]*o[row]*A[row][pos[ce]]*A[row][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
                    pgame32[i]+=o[i]*o[row]*A[row][pos[ce]]*A[i][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
					for (j=i+1; j<row; ++j)
					  pgame33[i][j]+=o[i]*o[j]*A[i][pos[ce]]*A[j][pos[ce]]*A[row][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
				  }
				}
				A[row][pos[ce]]=0;
			    ok=0;
			  }
			}
		    else pos[ce]=candf[row][ci][ce];
		  }
		  else 
		  { for (i=0; i<row; ++i) ok&=pgame2[i]==0;
		    if (ok && t>=3) for (i=0; i<row; ++i) 
			{ ok&=(pgame31[i]==0) && (pgame32[i]==0);
			  for (j=i+1; j<row; ++j) ok&=pgame33[i][j]==0;
			}
		    if (ok) ok=canon(row+1,n,A[0],C[0],o,O);
			if (ok) search(row+1);
		    --ce;
			for (i=0; i<row; ++i)
			{ pgame2[i]+=o[row]*A[row][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]];
			  if (t>=3)
			  { pgame31[i]+=o[row]*o[row]*A[row][pos[ce]]*A[row][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
                pgame32[i]+=o[i]*o[row]*A[row][pos[ce]]*A[i][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
				for (j=i+1; j<row; ++j)
				  pgame33[i][j]+=o[i]*o[j]*A[i][pos[ce]]*A[j][pos[ce]]*A[row][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
			  }
			}
			A[row][pos[ce]]=0;
			ok=0;
		  }
		}
		
		if (!ok)
		{ ++pos[ce];
          while (work && pos[ce]>candl[row][ci][ce])
		  { --ce;
		    work = ce>=0;
 		    if (work) 
			{ for (i=0; i<row; ++i)
				{ pgame2[i]+=o[row]*A[row][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]];
				  if (t>=3)
				  { pgame31[i]+=o[row]*o[row]*A[row][pos[ce]]*A[row][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
                    pgame32[i]+=o[i]*o[row]*A[row][pos[ce]]*A[i][pos[ce]]*A[i][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
					for (j=i+1; j<row; ++j)
					  pgame33[i][j]+=o[i]*o[j]*A[i][pos[ce]]*A[j][pos[ce]]*A[row][pos[ce]]*lcm/O[pos[ce]]/O[pos[ce]];
				  }
				}
			  A[row][pos[ce]]=0;
			  ++pos[ce];
			}
		  }
		}
	  }
	  
	}
  }
}


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,l,l1,m1,ok,bo;
  int sum,tmp,rowok;
  frac x,y,z;
  int good[MAXCAND], goodc[MAXCAND][MAXN+1], goodcf[MAXCAND][MAXN+1], goodcl[MAXCAND][MAXN+1];
  /* int prod; */
  char instring[256],*filename=0,*logname;
  char *form, *line, *mark, *spce;
  FILE *parfile;   /* File containing parameters etc. */
  int nOcand,Ocand[MAXOC][MAXN],On[MAXOC];
  int nOgood=0, Ogood[MAXOC];
  int incount;

  /* Command line arguments */

  for(i=1; i<argc; ++i) if (argv[i][0] != '-') filename = argv[i];
  else
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'i') mask |= 1;
      if (argv[i][j] == 'I') mask &= ~1;
      if (argv[i][j] == 'r') mask |= 2;
      if (argv[i][j] == 'R') mask &= ~2;
      /* if (argv[i][j] == 'l') mask |= 4;
      if (argv[i][j] == 'L') mask &= ~4; */
      if (argv[i][j] == 'm') mask |= 8;
      if (argv[i][j] == 'M') mask &= ~8; 
      if (argv[i][j] == 'p') mask |= 16;
      if (argv[i][j] == 'P') mask &= ~16;
      if (argv[i][j] == 'd') mask |= 32;
      if (argv[i][j] == 'D') mask &= ~32;
      if (argv[i][j] == 'b') mask |= 64;
      if (argv[i][j] == 'B') mask &= ~64;
      if (argv[i][j] == 'e') sscanf(argv[i]+j+1,"%d",&finalrow);
      /*if (argv[i][j] == 'c') sscanf(argv[i]+j+1,"%d",&crow);
      if (argv[i][j] == 'f') sscanf(argv[i]+j+1,"%d",&stop);
      if (argv[i][j] == 's') sscanf(argv[i]+j+1,"%d",&skip); */
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H')
	  || (argv[i][j] == '?'))
      { printf("Usage: orbmat5qd <name of parameter file> [options]\n");
	    printf("Options:\n");
        printf("-i   Print information about row entries and exit.\n"); 
        printf("-r   Read partial matrices.\n");
        printf("-eN  Expand matrices to row N.\n"); 
		printf("-d   Print dual orbit matrices.\n");
		printf("-b   Read more than one block-orbit distribution from parameter file.\n");
        /*printf("-cN     Apply canonical rejection only to rows 1,..,N.\n"); 
        printf("-fN     Stop after N matrices have been found.\n"); 
        printf("-sN     Skip first N-1 partial matrices on input.\n");
        printf("-lFILENAME  Create log file.\n"); */
	    printf("-m      Write markers.\n"); 
        printf("\n");
	    exit(0);
      }
	  if (argv[i][j] == 'l') 
	  { mask |= 4;
	    logname=argv[i]+j+1;
	    while (argv[i][j] != '\0') ++j;
	    --j;
	  }
      ++j;
    }
  }  

  if (filename==0)
  { printf("\nNo parameter file!\n");
    exit(0);
  }

  /*********************************/
  /* Read data from parameter file */
  /*********************************/
  
  parfile = fopen(filename,"r");
  
  if (parfile==0)
  { printf("Cannot open file '%s'!\n",filename);
    exit(0);
  }

  /* Read parameters */
 
  fscanf(parfile,"%d",&t);
  if (t>=MAXT)
  { printf("Increase MAXT!\n");
    exit(0);
  }
  if (t>5)
  { printf("Works only for t<=5.\n");
    exit(0);
  }
  fscanf(parfile,"%d",&v);
  fscanf(parfile,"%d",&k);
  fscanf(parfile,"%d",&lambda[t]);

  for (i=t-1; i>=0; --i)
  { if (lambda[i+1]*(v-i) % (k-i))
	{ printf("Parameters not admissible.\n");
      exit(0);
	}
    lambda[i]=(lambda[i+1]*(v-i))/(k-i);
  }

  if (mask & 16) t=2;

  /* for (i=0; i<=t; ++i) printf("%d ",lambda[i]);
  printf("\n"); 
  exit(0); */

  /* Read dimensions */

  fscanf(parfile,"%d",&m);
  if (m > MAXM)
  { printf("Increase MAXM!\n");
    exit(0);
  }
  if (!(mask & 64))
  { fscanf(parfile,"%d",&n);
    if (n > MAXN)
	{ printf("Increase MAXN!\n");
      exit(0);
	}
  }

  if (finalrow>m || finalrow<0) 
  { printf("Error: finalrow must be between 0 and %d.\n\n",m);
    exit(0);
  }

  if (finalrow==0) finalrow=m; 

  /* Read orbit sizes */

  for (i=0; i<m; ++i) fscanf(parfile,"%d",o+i);
  j=0;
  for (i=0; i<m; ++i) j += o[i];
  if (j!=v)
  { printf("Point-orbit sizes do not agree with parameters!\n");
    exit(0);
  }
  
  if (mask & 64)
  { fscanf(parfile,"%d",&nOcand);
    if (nOcand > MAXOC)
	{ printf("Increase MAXOC.\n");
	  exit(0);
	}
  }
  else nOcand=1;

  for (l=0; l<nOcand; ++l)
  { /* pritnf("l=%d\n",l); */
	if (mask & 64)
	{ fscanf(parfile,"%d",On+l);
	  if (On[l]>MAXN)
	  { printf("Increase MAXN!\n");
        exit(0);
	  }
	}
    else On[l]=n;

    for (i=0; i<On[l]; ++i) fscanf(parfile,"%d",&(Ocand[l][i]));
    j=0;
    for (i=0; i<On[l]; ++i) j += Ocand[l][i];
    if (j!=lambda[0])
	{ printf("Block-orbit sizes no. %d do not agree with parameters!\n",l+1);
      exit(0);
	}
	ok = 1;
    for (j=1; j<On[l]; ++j) ok &= Ocand[l][j-1]<=Ocand[l][j];
    if (!ok)
	{ printf("Please write block-orbit sizes no. %d in increasing order!\n",l+1);
      exit(0);
	}
  }

  /* for (i=0; i<n; ++i) fscanf(parfile,"%d",O+i);
  j=0;
  for (i=0; i<n; ++i) j += O[i];
  ok &= j==lambda[0];
  if (!ok)
  { printf("Orbit sizes do not agree with parameters!\n");
    exit(0);
  }

  ok = 1;
  for (j=1; j<m; ++j) ok &= O[j-1]<=O[j];

  if (!ok)
  { printf("Please write block-orbit sizes in increasing order!\n");
    exit(0);
  }
  */

  /* Read known part of orbit matrix */

  for (i=0; i<m; ++i)
    for (j=0; j<n; ++j) A[i][j] = 0;

  if (mask & 64)
  { m0=0;
    n0=0;
  }
  else
  {
  m0 = -1;
  for (i=0; (m0==-1) && (i<m); ++i)
  { for (j=0; (m0==-1) && (j<n); ++j)
    { fscanf(parfile,"%s",instring);
      if (instring[0]=='?') 
      { m0 = i;
        n0 = j;
      }
      else
      { sscanf(instring,"%d",&l); 
        A[i][j] = l;
      }
    }
  }

  for (i=m0+1; i<m; ++i)
  { for (j=0; j<n0; ++j)
    { fscanf(parfile,"%d",&l);
      A[i][j] = l;
    }
  }
  }
  
  fclose(parfile);

  /* printf("Param. file closed.\n"); */

  /* writemat(m,n);
  printf("m0=%d, n0=%d\n",m0,n0); */

  /* Loop over block-orbit size candidates */

  for (bo=0; bo<nOcand; ++bo)
  {
	n=On[bo];
	for (i=0; i<n; ++i) O[i]=Ocand[bo][i];

  /* Compute least common multiple of block-orbit sizes, squared */

  lcm = 1;
  for (i=0; i<n; ++i) lcm=lcm*O[i]/gcd(lcm,O[i]);
  lcm=lcm*lcm;
  /* printf("lcm=%d\n",lcm); */

  /* Compute inormation about different block-orbit sizes */

  nos=0;
  os[0]=O[n0];
  osf[0]=n0;
  osl[0]=n0;
  for (i=n0+1; i<n; ++i) if (O[i]==O[i-1]) ++osl[nos];
  else 
  { ++nos;
    if (nos==MAXNOS)
	{ printf("Increase MAXNOS!\n");
	  exit(0);
	}
    os[nos]=O[i];
	osf[nos]=i;
	osl[nos]=i;
  }
  ++nos;
  for (i=0; i<nos; ++i) osn[i]=osl[i]-osf[i]+1;

  /* for (i=0; i<nos; ++i) printf("O=%d, first=%d, last=%d, number=%d\n",os[i],osf[i],osl[i],osn[i]); */

  Ogood[bo]=1;

  /* Compute row candidates */

  for (row=m0; row<m; ++row) 
  { ok = row>m0 && o[row-1]==o[row];
    for (i=0; ok && i<n0; ++i) ok &= A[row][i]==A[row-1][i];
    if (ok)
	{ ncand[row]=ncand[row-1];
      for (i=0; i<ncand[row]; ++i) for (j=0; j<=MAXN; ++j)
	  { cand[row][i][j] = cand[row-1][i][j];
	    candf[row][i][j] = candf[row-1][i][j];
	    candl[row][i][j] = candl[row-1][i][j];
	  }
	}
    else if (Ogood[bo])
	{ ncand[row]=0;
	  sum=lambda[1];
      for (i=0; i<n0; ++i) sum-=A[row][i];
      /* printf("row=%d, sum=%d\n",row,sum); */
	  ncomp=0;
	  npart=0;
      makecomp(0,sum);
      /* printf("Number of compositions: %d\n",ncomp); 
	  printf("Number of candidates for row %d: %d\n",row,ncand[row]); */

	  /* Elliminate some row candidates */

	  for (i=0; i<ncand[row]; ++i) good[i]=1;

	  /* Alltop test for candidates */

      /* Not necessary - built into the generator for row candidates */

	  /* for (i=0; i<ncand[row]; ++i) if (good[i])
	  { printf("Row %d cand %d alltop: ",row,i); 
	    j=0;
	    while (cand[row][i][j]!=0)
	    { x.n=o[row]*cand[row][i][j];
	      x.d=O[candf[row][i][j]];
		  printf("%d/%d ",x.n,x.d); 
		  x=reduce(x);
		  good[i]&=x.d==1;
		  ++j;
	    }
	    printf("%d\n",ok);
	  } */

	  /* Test candidates for t-designs, t>=4 */

	  if (t>=4)
	  { for (i=0; i<ncand[row]; ++i) if (good[i])
		{ x.n=0;
		  x.d=1;
		  j=0;
		  while (cand[row][i][j]!=0)
		  { z.n=o[row];
		    z.d=O[candf[row][i][j]];
			z=reduce(z);
			y.n=z.n*z.n*z.n*cand[row][i][j]*cand[row][i][j]*cand[row][i][j]*cand[row][i][j];
		    y.d=z.d*z.d*z.d;
			y=reduce(y);
            x=add(x,y);
			++j;
		  }
		  if ((x.d<1) || (x.n<0)) printf("Warning: overflow while checking equation for 4-designs.\n");
		  /* printf("Test4, row %d, cand %d: %d/%d==%d\n",row,i,x.n,x.d,lambda[1]+7*(o[row]-1)*lambda[2]+6*(o[row]-1)*(o[row]-2)*lambda[3]+(o[row]-1)*(o[row]-2)*(o[row]-3)*lambda[4]); */
		  good[i]&=(x.d==1) && (x.n==(lambda[1]+7*(o[row]-1)*lambda[2]+6*(o[row]-1)*(o[row]-2)*lambda[3]+(o[row]-1)*(o[row]-2)*(o[row]-3)*lambda[4]));
		}
	  }

	  if (t>=5)
	  { for (i=0; i<ncand[row]; ++i) if (good[i])
		{ x.n=0;
		  x.d=1;
		  j=0;
		  while (cand[row][i][j]!=0)
		  { z.n=o[row];
		    z.d=O[candf[row][i][j]];
			z=reduce(z);
			y.n=z.n*z.n*z.n*z.n*cand[row][i][j]*cand[row][i][j]*cand[row][i][j]*cand[row][i][j]*cand[row][i][j];
		    y.d=z.d*z.d*z.d*z.d;
			y=reduce(y);
            x=add(x,y);
			++j;
		  }
		  if ((x.d<1) || (x.n<0)) printf("Warning: overflow while checking equation for 5-designs.\n");
		  /* printf("Test5, row %d, cand %d: %d/%d==%d\n",row,i,x.n,x.d,lambda[1]+15*(o[row]-1)*lambda[2]+25*(o[row]-1)*(o[row]-2)*lambda[3]+10*(o[row]-1)*(o[row]-2)*(o[row]-3)*lambda[4]+(o[row]-1)*(o[row]-2)*(o[row]-3)*(o[row]-4)*lambda[5]); */
		  good[i]&=(x.d==1) && (x.n==(lambda[1]+15*(o[row]-1)*lambda[2]+25*(o[row]-1)*(o[row]-2)*lambda[3]+10*(o[row]-1)*(o[row]-2)*(o[row]-3)*lambda[4]+(o[row]-1)*(o[row]-2)*(o[row]-3)*(o[row]-4)*lambda[5]));
		}
	  } 

	  l=0;
	  for (i=0; i<ncand[row]; ++i) if (good[i])
	  { for (j=0; j<=MAXN; ++j) 
		{ goodc[l][j]=cand[row][i][j];
          goodcf[l][j]=candf[row][i][j];
          goodcl[l][j]=candl[row][i][j];
		}
	    ++l;
	  }
	  ncand[row]=l;
	  for (i=0; i<ncand[row]; ++i) 
	  { for (j=0; j<=MAXN; ++j) 
		{ cand[row][i][j]=goodc[i][j];
          candf[row][i][j]=goodcf[i][j];
          candl[row][i][j]=goodcl[i][j];
		}
	    ++l;
	  }

	  /* Sort row candidates lexicographically */

      for (i=0; i<ncand[row]; ++i)
	  { for (j=0; j<n; ++j) scand[i][j]=0;
	    l=0;
	    j=0;
	    while (cand[row][i][j]!=0)
		{ scand[i][candf[row][i][j]+l]=cand[row][i][j];
	      if (candf[row][i][j]==candf[row][i][j+1]) ++l;
		  else l=0;
	      ++j;
		}
	    /* printf("#%d\n",i);
	    for (j=0; j<n; ++j) printf("%d ",scand[i][j]);
	    printf("\n"); */
	  }
	  for (i=0; i<ncand[row]; ++i)
	    for (j=i+1; j<ncand[row]; ++j) if (cmp(scand[i],scand[j],n)<0)
		{ for (l=0; l<MAXN; ++l)
			{ tmp=cand[row][i][l];
		      cand[row][i][l]=cand[row][j][l];
		      cand[row][j][l]=tmp;
		      tmp=candf[row][i][l];
		      candf[row][i][l]=candf[row][j][l];
		      candf[row][j][l]=tmp;
		      tmp=candl[row][i][l];
		      candl[row][i][l]=candl[row][j][l];
		      candl[row][j][l]=tmp;
              tmp=scand[i][l];
		      scand[i][l]=scand[j][l];
		      scand[j][l]=tmp;
			}
		}
	  /* for (i=0; i<ncand[row]; ++i)
	  { for (j=0; j<n; ++j) printf("%d ",scand[i][j]);
	    printf("\n");
	  }
	  printf("\n"); */

	  if ((mask & 64) && (mask & 1) && ncand[row]==0) Ogood[bo]=0;
    }

  }	/* End generating row candidates */

  if (Ogood[bo]) ++nOgood;
  else
  { for (i=0; ncand[i]>0 && i<m; ++i) ;
    for ( ; i<m; ++i) ncand[i]=0;
  }

  if ((mask & 1) && (bo==0)) printf("%d-(%d,%d,%d), b=%d, r=%d\n\n",t,v,k,lambda[t],lambda[0],lambda[1]);

  if (mask & 64) printf("Block-orbit sizes no. %d:\n\n",bo+1);

  /* Print row candidates */

  if (mask & 1)
  { if (O[n-1]<=9) 
    { form = "%2d";
      line = "--";
      mark = " .";
      spce = "  ";
    }
    else 
    { form = "%3d";
      line = "---";
      mark = "  .";
      spce = "   ";
    }
    printf("  |");
    for (i=0; i<n; ++i) printf(form,O[i]);
    printf("\n");
    printf("---");
    for (i=0; i<n; ++i) printf(line);
    printf("\n");
    for (i=0; i<m0; ++i)
    { printf("%2d|",o[i]);
      for (j=0; j<n; ++j) printf(form,A[i][j]);
      printf("\n");
    }

    rowok=1;
	for (i=m0; i<m; ++i)
	{ /* printf("nos=%d; osf=",nos);
	  for (j=0; j<nos; ++j) printf("%d ",osf[j]);
	  printf("\n"); */
	  printf("%2d|",o[i]);
	  for (j=0; j<n; ++j) if (j<n0) printf(form,A[i][j]);
	  else printf(mark);
	  printf(": ");
	  if (ncand[i]==0) 
	  { if (rowok) 
		{ printf("row impossible!\n");
	      if (mask & 64) rowok=0;
		}
	    else printf("?\n");
	  }
	  else 
	  { j=0;
	    l=0;
		while (osf[l]!=candf[i][0][0])
		{ printf("0 | ");
		  ++l;
		  if (l>=nos) 
		  { printf("Error!\n");
			exit(0);
		  }
		}
		while (cand[i][0][j]!=0) 
		{ printf("%d ",cand[i][0][j]);
	      if ((cand[i][0][j+1]!=0) && (candf[i][0][j+1]!=osf[l])) 
		  { printf("| ");
		    ++l;
  		    while (osf[l]!=candf[i][0][j+1])
			{ printf("0 | ");
		      ++l;
			  if (l>=nos) 
			  { printf("Error!\n");
			    exit(0);
			  }
			}
		  }
		  ++j;
		}
	    printf("\n");
	  }
	  for (j=1; j<ncand[i]; ++j)
	  { printf("   ");
        for (l=0; l<n; ++l) printf(spce);
        printf(": ");
		l=0;
		l1=0;
		while (osf[l1]!=candf[i][j][0])
		{ printf("0 | ");
		  ++l1;
		  if (l1>=nos) 
		  { printf("Error!\n");
			exit(0);
		  }
		}
		while (cand[i][j][l]!=0)
		{ printf("%d ",cand[i][j][l]);
	      if ((cand[i][j][l+1]!=0) && (candf[i][j][l+1]!=osf[l1])) 
		  { printf("| ");
		    ++l1;
  		    while (osf[l1]!=candf[i][j][l+1])
			{ printf("0 | ");
		      ++l1;
			  if (l1>=nos) 
			  { printf("Error!\n");
			    exit(0);
			  }
			}
		  }
		  ++l;		  
		}
		printf("\n");
	  }
	}
	printf("\n");
  }

  /* Search for orbit matrices */

  if (!(mask &1))
  { 
  
  /* Print dimensions and orbit sizes */

  printf("%d %d\n\n",finalrow,n);
  for (i=0; i<finalrow; ++i) printf("%d ",o[i]);
  printf("\n");
  for (i=0; i<n; ++i) printf("%d ",O[i]);
  printf("\n\n");

  ok=1;
  for (i=m0; i<m; ++i) ok &= ncand[i]>0;
  if (!ok)
  { if (!(mask & 1)) fprintf(stderr,"Some rows impossible! For more details use -i option.\n\n");
  }

  else
  {

  if (finalrow<=m0)
  { writemat(finalrow,n);
    exit(0);
  }

  if (mask & 2) /* Read partial matrices */
  { 
    scanf("%d",&m1);
    scanf("%d",&i);
    if ((m1<0) || (m1>=finalrow) || (i!=n))
    { printf("Error: dimensions at stdin (%d,%d) do not agree with parameter file.\n",m1,i);
      exit(0);
    }

    for (i=0; i<m1; ++i)
    { scanf("%d",&j);
      if (o[i]!=j)
      { printf("Error: orbit sizes at stdin do not agree with parameter file.\n");
        exit(0);
      }
    }

    for (i=0; i<n; ++i)
    { scanf("%d",&j);
      if (O[i]!=j)
      { printf("Error: orbit sizes at stdin do not agree with parameter file.\n");
        exit(0);
      }
    }

	incount=0;
    while (readmat(m1,n))
    { ++incount;
	  if (mask & 8) 
	  { printf("m%d\n",incount);
	    fflush(stdout);
	  }
	  search(m1);
    }
  }

  else /* Start from scratch */
  { if (m0==0) for (i=0; i<ncand[0]; ++i)
	{ for (j=n0; j<n; ++j) A[0][j]=0;
	  l=0;
	  j=0;
	  while (cand[0][i][j]!=0)
	  { A[0][candf[0][i][j]+l]=cand[0][i][j];
	    if (candf[0][i][j]==candf[0][i][j+1]) ++l;
		else l=0;
	    ++j;
	  }      
      search(1);
	}
    else
	{ search(m0);
	}
  }

  }

  } /* Search for orbit matrices */

  fflush(stdout);

  } /* Loop over block-orbit size candidates */

  if ((mask & 64) && (mask & 1))
  { printf("Good block-orbit sizes:\n\n");
    printf("%d\n",nOgood);
	for (i=0; i<nOcand; ++i) if (Ogood[i])
	{ printf("%d\n",On[i]);
	  for (j=0; j<On[i]; ++j) printf("%d ",Ocand[i][j]);
	  printf("\n");
	}
  }

}
