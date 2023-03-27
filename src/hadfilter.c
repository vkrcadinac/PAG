/*
    HADFILTER.C

    Filter out equivalent Hadamard matrices.

    The program uses nauty/Traces 2.8 by B.D.McKay and A.Piperno. 
    It needs to be linked with nauty.c, nautil.c, naugraph.c, schreier.c, 
    naurng.c, nausparse.c, gtools.c, and traces.c. 

    Vedran Krcadinac (krcko@math.hr), 12.3.2023.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>

#include "traces.h" 

/****************/
/* Global stuff */
/****************/

int mask=0;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Allow transpositions: -d, -D 
   8  Print comments: -c, -C 
*/

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ 
  DYNALLSTAT(graph,g,g_sz);
  DYNALLSTAT(int,lab,lab_sz);
  DYNALLSTAT(int,ptn,ptn_sz);
  DYNALLSTAT(int,orbits,orbits_sz);
  static DEFAULTOPTIONS_TRACES(options);
  TracesStats stats;
  sparsegraph *sgp;

  SG_DECL(cg);

  int n,m,mc;
  graph *cng;

  int v=0; /* Order of the Hadamard matrices */

  int i,j,k,x,ok;
  char c;
  long unsigned int count=0,countout=0;

  /* Tree of canonical representatives */

  int depth;
  typedef struct node {
     setword elem;
     struct node *right;
     struct node *down;
  } NODE;
  NODE *root, *work, *new;

  /* Command line arguments */
  for(i=1; i<argc; ++i)
    if (('0' <= argv[i][0]) && (argv[i][0] <= '9'))
    {  /* if (k==0) sscanf(argv[i],"%d",&k);
       else if (b==0) sscanf(argv[i],"%d",&b); */
    }
    else
    { j = 0;
      while (argv[i][j] != '\0')
      { if (argv[i][j] == 'd') mask |= 1;
	if (argv[i][j] == 'D') mask &= ~1; 
	if (argv[i][j] == 'c') mask |= 8;
	if (argv[i][j] == 'C') mask &= ~8;

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: hadfilter [options]\n");
  	  printf("The order and the Hadamard matrices are taken from stdin.\n");
	  printf("Options:\n");
	  printf("-d, -D  Allow transpositions (default no)\n");
	  printf("-c, -C  Print comments (default no)\n");
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&v)==1;

  if ((v<=0) || (!ok))
  { printf("Order of the matrices must be entered first!\n");
    exit(0);
  }

  options.writeautoms = FALSE;
  options.defaultptn = FALSE;
  options.getcanon = TRUE;

  n=4*v;
  m = SETWORDSNEEDED(n);
  depth = 2*v*m;

  nauty_check(WORDSIZE,m,n,NAUTYVERSIONID);

  DYNALLOC2(graph,g,g_sz,m,n,"malloc");
  DYNALLOC1(int,lab,lab_sz,n,"malloc");
  DYNALLOC1(int,ptn,ptn_sz,n,"malloc");
  DYNALLOC1(int,orbits,orbits_sz,n,"malloc");
  EMPTYGRAPH(g,m,n);

  for (i=0; i<n; ++i) 
  { lab[i] = i; 
    ptn[i] = 1; 
  }
  if (!(mask & 1)) ptn[2*v-1] = 0;
  ptn[n-1] = 0;

  /* Read Hadamard matrices */

  c=0;
  ok=1;
  while (ok==1 && c!='[') ok=scanf("%c",&c);

  while (ok==1)
  { EMPTYGRAPH(g,m,n);

    c=0;
    while (ok==1 && c!='[') ok=scanf("%c",&c);

    if (ok==1) 
    { i=0;
      while (i<v)
      { /* printf("Block %d: ",i+1); */
        c=0;
        while (ok==1 && c!='[') ok=scanf("%c",&c);
        if (ok!=1)
        { printf("Error reading Hadamard matrix.\n");
          exit(0);
        }
        c=',';
	j=-1;
        while (ok==1 && c==',')
        { ok=scanf("%d",&x);
          if (x!=1 && x!=-1) 
          { printf("Error reading entry of Hadamard matrix.\n");
            exit(0);
          }
	  ++j;
	  /* printf("(%d,%d)=%d ",i,j,x); */
	  if (x==1)
	  { ADDONEEDGE(g,i,2*v+j,m);
	    ADDONEEDGE(g,v+i,3*v+j,m);
	  }
	  else
	  { ADDONEEDGE(g,i,3*v+j,m);
	    ADDONEEDGE(g,v+i,2*v+j,m);
	  }
	  c=0;
          while (ok==1 && c!=']' && c!=',') ok= scanf("%c",&c);
          if (ok!=1)
          { printf("Error reading Hadamard matrix.\n");
            exit(0);
          }
        }

        ++i;
      }

      ++count;

      /* Convert to sparse graph */

      if (count==1) sgp=nauty_to_sg(g,NULL,m,n);
      else nauty_to_sg(g,sgp,m,n);

      /* Call Traces */

      Traces(sgp,lab,ptn,orbits,&options,&stats,&cg);

      if (count==1) cng=sg_to_nauty(&cg,NULL,m,&mc);
      else sg_to_nauty(&cg,cng,m,&mc);
      if (m!=mc)
      { printf("Error: canonical m different!\n");
	exit(0);
      }

      /* Memorise canonical representative, if necessary */

      /* First design */

      if (count==1)
      { ++countout;
	if (mask & 8) 
	{ printf("Matrix #%lu. |Aut|=",count); 
          writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
          printf(". New, memorised as #%lu.\n",countout);
        }
        root = (NODE *)malloc(sizeof(NODE));
        if (root==NULL)
        { printf("Out of memory!\n");
          exit(0);
        }
        work = root;
        work->elem = *cng;
        work->down = NULL;
        for (i=1; i<depth; ++i)
        { new = (NODE *)malloc(sizeof(NODE));
          if (new==NULL)
          { printf("Out of memory!\n");
            exit(0);
	  }
	  work->right = new;
	  work = new;
	  work->elem = *(cng+i);
          work->down = NULL;
        }
        work->right = NULL;

	printf("%ld\n",count);
	fflush(stdout);
      } 

      /* Not the first design */

      else
      { work = root;
        k = 0;
        while ((k<depth) && ((work->elem == *(cng + k)) || (work->down != NULL)))
          if (work->elem == *(cng + k))
          { work = work->right;
	    ++k;
	  }
	  else work = work->down;

        if (k<depth) /* Rest of cng needs to be memorised */
	{ ++countout;
	  if (mask & 8) 
	  { printf("Matrix #%lu. |Aut|=",count); 
            writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
            printf(". New, memorised as #%lu.\n",countout);
          }
          new = (NODE *)malloc(sizeof(NODE));
	  if (new==NULL)
	  { printf("Out of memory!\n");
	    exit(0);
	  }
          work->down = new;
          work = new;
          work->elem = *(cng + k);
          work->down = NULL;
          for (++k ; k<depth; ++k)
          { new = (NODE *)malloc(sizeof(NODE));
            if (new==NULL)
            { printf("Out of memory!\n");
	      exit(0);
	    }
            work->right = new;
	    work = new;
	    work->elem = *(cng + k);
            work->down = NULL;
          }
	  new = (NODE *)malloc(sizeof(NODE));
	  if (new==NULL)
	  { printf("Out of memory!\n");
	    exit(0);
	  }
	  work->right = new;
	  new->elem = countout;
	  new->right = NULL;
          new->down = NULL;

	  printf("%ld\n",count);
	  fflush(stdout);

	}
	else
	{ if (mask & 8) 
	  { printf("Matrix #%lu. |Aut|=",count); 
            writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
            printf(". Not new.\n");
          }
        }
      }

    }
  }

}

