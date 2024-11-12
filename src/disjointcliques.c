/*
    DISJOINTCLIQUES.C

    Input: n, k, and a list of n sets of k integers. The sets
    are assumed to be given in ascending order. Searches for 
    cliques of mutually disjoint k-sets from the list.
    
    Calls Cliquer by Sampo Niskanen and Patric Ostergard, see 
    https://users.aalto.fi/~pat/cliquer.html

    Vedran Krcadinac (krcko@math.hr), 11.9.2024.
    Department of Mathematics, University of Zagreb, Croatia

*/

#define NULL 0           /* The null pointer */

#include <stdio.h>
#include <stdlib.h> 
#include "cliquer.h"

int mask=3;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
     1  Report progress.
        -v for yes, -V for no (default yes)
     2  Find all cliques or a single clique.
        -a for all (default), -A for single 
*/

FILE *outfile; 
int first;

boolean printclique(set_t s,graph_t *gr,clique_options *opts)
{ int i,j;

  if (first) first=0;
  else fprintf(outfile,",\n");

  fprintf(outfile,"[");
  j=0;
  for (i=0; i<gr->n; ++i) if (SET_CONTAINS(s,i)) 
  { if (j) fprintf(outfile,",");
    else j=1;
    fprintf(outfile,"%d",i+1);
  }
  fprintf(outfile,"]");

  return 1;
}

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,j,k,ok;
  int ordering=0,cmin=0,cmax=0;
  char *filename=0;
  int n,ncl;
  long int e;
  graph_t *ig;
  set_t s;
  int *l;
  int i1, j1, x;

  /* Command line arguments */
  for(i=1; i<argc; ++i)
  if (i==1 && argv[i][0]!='-') filename=argv[i];
  else
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'v') mask |= 1;
      if (argv[i][j] == 'V') mask &= ~1; 
      if (argv[i][j] == 'a') mask |= 2;
      if (argv[i][j] == 'A') mask &= ~2; 
      if (argv[i][j] == 'o') sscanf(argv[i]+j+1,"%d",&ordering);
      if (argv[i][j] == 'l') sscanf(argv[i]+j+1,"%d",&cmin);
      if (argv[i][j] == 'u') sscanf(argv[i]+j+1,"%d",&cmax);

      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: disjointcliques outfilename [options]\n");
  	printf("The list of sets is taken from stdin.\n");
	printf("Options (lowercase for yes, uppercase for no):\n");
        printf("-v, -V   Report progress (default yes)\n");
        printf("-a, -A   Find all cliques (default) or a single clique\n");
	printf("-oN      Ordering of vertices: N=1 ident, N=2 reverse, N=3 degree, N=4 random, N=5 greedy\n");
	printf("-lN      Lower bound on clique size\n");
	printf("-uN      Upper bound on clique size\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  if (filename==0) filename="disjointcliques.out";
  outfile = fopen(filename,"w");

  /* Read n and k */

  ok=scanf("%d",&n);
  if (ok!=1 || n<1)
  { printf("The number of k-sets must be entered first!\n");
    exit(0);
  }
  ok=scanf("%d",&k);
  if (ok!=1 || k<1)
  { printf("The size of the sets k must be entered second!\n");
    exit(0);
  }

  /* Read list of k-sets */

  l=(int *)calloc(n*k,sizeof(int));
  if (l == NULL)
  { printf("Memory not allocated.\n");
    exit(0);
  }
  for (i=0; i<n; ++i) for (j=0; j<k; ++j) 
  { ok=scanf("%d",l+i*k+j);
    if (ok!=1)
    { printf("Error reading list of k-sets!\n");
      exit(0);
    }
  }

  /* for (i=0; i<n; ++i)
  { for (j=0; j<k; ++j) printf("%d ",*(l+i*k+j));
    printf("\n");
  }
  printf("\n");
  exit(0); */

  ig = graph_new(n);
  if ((mask & 1)==0) clique_default_options->time_function=NULL; 
  clique_default_options->clique_list=NULL;
  clique_default_options->user_function=printclique; 
  if (ordering==1) clique_default_options->reorder_function=reorder_by_ident;
  if (ordering==2) clique_default_options->reorder_function=reorder_by_reverse;
  if (ordering==3) clique_default_options->reorder_function=reorder_by_degree;
  if (ordering==4) clique_default_options->reorder_function=reorder_by_random;
  if (ordering==5) clique_default_options->reorder_function=reorder_by_unweighted_greedy_coloring; 

  /* Define graph */

  ig = graph_new(n);
  e=0;

  for (i=0; i<n; ++i) for (j=i+1; j<n; ++j)
  { i1=0;
    j1=0;
    ok=1;
    while (ok && i1<k && j1<k)
    { x=*(l+i*k+i1) - *(l+j*k+j1);
      ok=(x!=0);
      if (x>0) ++j1;
      else ++i1;
    }
    if (ok)
    { GRAPH_ADD_EDGE(ig,i,j);
      ++e;
    }
  }

  if (mask & 1) printf("Graph: %d vertices, %ld edges (density %g)\n",n,e,1.0*e/(n*(n-1)/2.0)); 

  fprintf(outfile,"return [\n");
  first=1;

  if (mask & 2) ncl=clique_find_all(ig,cmin,cmax,FALSE,NULL);
  else 
  { s=clique_find_single(ig,cmin,cmax,FALSE,NULL);
    ncl=1;
    fprintf(outfile,"[");
    j=0;
    for (i=0; i<n; ++i) if (SET_CONTAINS(s,i)) 
    { if (j) fprintf(outfile,",");
      else j=1;
      fprintf(outfile,"%d",i+1);
    }
    fprintf(outfile,"]");
  }
  fprintf(outfile,"\n];\n");

  fclose(outfile);

  if (mask & 1) printf("Cliques: %d\n",ncl);

  return 1;
}
