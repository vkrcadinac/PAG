/*
    SOLVECM.C

    Backtracking solver for Kramer-Mesner systems with compatibility matrices.

    Vedran Krcadinac (krcko@math.hr), 8.5.2022.
    Department of Mathematics, University of Zagreb, Croatia
*/


#define MAXM		5000
#define MAXN		20000
#define UPDATEFREQ	10000

#include <stdio.h>
#include <stdlib.h>
#include <time.h>


/****************/
/* Global stuff */
/****************/

int A[MAXM][MAXN], b[MAXM];   /* The linear system */
char cm[MAXN][MAXN];          /* The compatibility matrix */
int m,n,x=-1;                 /* Dimensions */
int psum[MAXM],tree[MAXN],sol[MAXN],solvec[MAXN],maxdepth;
int count,update;
FILE *outfile;


int mask = 0;	/* An integer mask for options */
/* Meaning of the bits:
  0 - read compatibility matrix
*/

void writemat(int *mat, int m, int n)
{ int i,j;

  for (i=0; i<m; ++i)
  { for (j=0; j<n; ++j) printf("%d ",*(mat+MAXN*i+j));
    printf("\n");
  }
  /* printf("\n"); */
  fflush(stdout);
}


void search(int depth, int start, int remaining)
{ int i,j,ok;

  if (depth>maxdepth) maxdepth=depth;
  ++tree[depth];
  --update;
  if (update==0)
  { update=UPDATEFREQ;
    printf("tree: ");
    for (i=0; i<maxdepth; ++i) printf("%d ",tree[i]);
    printf("(%d solutions)\n",count);
    fflush(stdout);
  }
  if (remaining==0)
  { ok=1;
    if (x!=-1) for (j=0; ok && j<m-1; ++j) ok &= (psum[j]==b[j] || psum[j]==x);
    if (ok)
	{ ++count;
      for (i=0; i<n; ++i) solvec[i]=0;
	  for (i=0; i<depth; ++i) ++solvec[sol[i]];
	  for (i=0; i<n; ++i) fprintf(outfile,"%d",solvec[i]);
	  fprintf(outfile,"\n"); 
	  fflush(outfile);
	}
  }
  else for (i=start; i<n; ++i)
  { ok=remaining>=A[m-1][i];
    for (j=0; ok && j<m-1; ++j) ok &= (psum[j]+A[j][i])<=b[j];
	if (mask & 1) for (j=0; ok && j<depth; ++j) ok &= cm[sol[j]][i]; 

	if (ok)
	{ for (j=0; j<m-1; ++j) psum[j]+=A[j][i];
	  sol[depth]=i; 
	  search(depth+1,i+1,remaining-A[m-1][i]);
	  for (j=0; j<m-1; ++j) psum[j]-=A[j][i];
    }
  }

} 


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,k,ok;  
  char *infilename=0, *outfilename;
  FILE *infile;   
  time_t t;

  outfilename="solutions";

  /* Command line arguments */

  for(i=1; i<argc; ++i) if (argv[i][0] != '-') infilename = argv[i];
  else
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'c') mask |= 1;
      if (argv[i][j] == 'C') mask &= ~1;
      if (argv[i][j] == 'x') sscanf(argv[i]+j+1,"%d",&x);
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: solvecm [options] input_file_name\n");
	printf("Options:\n");
        printf("-oFILENAME  Output file name (default: %s).\n",outfilename);
	printf("-c          Read compatibility matrix (default no).\n");
	printf("-xN         Alternative RHS=N - for quasi-symmetric designs (default no).\n");
        printf("\n");
	exit(0);
      }
      if (argv[i][j] == 'o') 
      { outfilename=argv[i]+j+1;
	while (argv[i][j] != '\0') ++j;
	--j;
      }
      ++j;
    }
  }  

  if (infilename==0)
  { printf("No input file!\n");
    exit(0);
  }

  /**********************/
  /* Read linear system */
  /**********************/
  
  infile = fopen(infilename,"r");
  
  if (infile==0)
  { printf("Cannot open file '%s'!\n",infilename);
    exit(0);
  }

  /* Read dimensions */
  
  fscanf(infile,"%d",&m);
  fscanf(infile,"%d",&n);
  fscanf(infile,"%d",&i);
  if (m > MAXM)
  { printf("Increase MAXM!\n");
    exit(0);
  }
  if (n > MAXN)
  { printf("Increase MAXN!\n");
    exit(0);
  }
  if (i!=1)
  { printf("Works only for single RHS.\n");
    exit(0);
  }

  /* Read coefficients */

  for (i=0; i<m; ++i)
  { for (j=0; j<n; ++j) fscanf(infile,"%d",&A[i][j]);
    fscanf(infile,"%d",&b[i]);
  }

  /* writemat(A[0],m,n);
  writemat(b,1,m); */

  /* Read compatibility matrix */

  if (mask & 1)
  { for (i=0; i<n; ++i) for (j=0; j<n; ++j) fscanf(infile,"%d",&cm[i][j]);
    /* printf("CM:\n");
    for (i=0; i<n; ++i)
    { for (j=0; j<n; ++j) printf("%d",cm[i][j]);
      printf("\n");
    } */
  }

  fclose(infile);

  printf("Linear system: %d x %d\n",m,n);
  if (mask & 1) printf("Compatibility matrix: yes\n");
  else printf("Compatibility matrix: no\n");

  /*************************************/
  /* Search for inconsistent equations */
  /*************************************/

  ok=1;
  for (i=0; ok && i<m; ++i) if (b[i] && x!=0)
  { k=1;
    for (j=0; k && j<n; ++j) if (A[i][j]) k=0;
	ok = !k;
  }

  if (!ok)
  { printf("Equation #%d does not allow solutions\n",i);
    printf("Total number of solutions: 0\n");
    outfile = fopen(outfilename,"w");
	fclose(outfile);
    exit(0);
  }

  /**********************/
  /* Analyse the system */
  /**********************/

  i=0;
  while (A[m-1][i]!=0 && i<n) ++i;
  if (i<n || b[m-1]==0)
  { printf("Last row must contain orbit sizes.\n");
    exit(0);
  }

  /**************************/
  /* Start backtrack search */
  /**************************/

  for (i=0; i<m; ++i) psum[i]=0;
  t=time(&t);
  printf("Starting search: %s",ctime(&t));
  update=UPDATEFREQ;
  maxdepth=0;
  outfile = fopen(outfilename,"w");

  search(0,0,b[m-1]); 

  fclose(outfile);
  printf("tree: ");
  for (i=0; i<maxdepth; ++i) printf("%d ",tree[i]);
  printf("(%d solutions)\n",count);
  t=time(&t);
  printf("Finished search: %s",ctime(&t));
  printf("Total number of solutions: %d\n",count);

}
