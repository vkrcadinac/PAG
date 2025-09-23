/*
    GRDEFILTER.C
    Isomorphism filter for graph decompositions. 

    Vedran Krcadinac (krcko@math.hr), 9.5.2025.
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
   1  Print comments: -c, -C 
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

  int gv=0, ge=0; /* Number of vertices and edges of the decomposed graph */
  int b=0, he; /* Number of blocks and edges in a block */
  int *edg;

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
      { if (argv[i][j] == 'c') mask |= 1;
	if (argv[i][j] == 'C') mask &= ~1;

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: grdefilter [options]\n");
	  printf("Options:\n");
	  printf("-c, -C  Print comments (default no)\n");
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&gv)==1;
  ok&=scanf("%d",&ge)==1;
  ok&=scanf("%d",&b)==1;

  if ((gv<=0) || (ge<=0) || (b<=0) || (!ok))
  { fprintf(stderr,"The number of vertices and edges of the decomposed graph must be given first,\n");
    fprintf(stderr,"then the number of blocks\n");
    exit(0);
  }

  if ((ge%b)!=0)
  { fprintf(stderr,"Number of edges not divisible by number of blocks!\n");
    exit(0);
  }
  he=ge/b;

  options.writeautoms = FALSE;
  options.defaultptn = FALSE;
  options.getcanon = TRUE;

  n=gv+ge+b;
  m = SETWORDSNEEDED(n);
  depth = n*m;

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
  ptn[gv-1]=0;
  ptn[gv+ge-1]=0; 
  ptn[n-1] = 0;

  /* for (i=0; i<n; ++i) printf("%d ",ptn[i]);
  printf("\n");
  exit(0); */

  /* Read edges of the decomposed graph */

  edg=(int *)calloc(2*ge,sizeof(int));
  for (i=0; ok && i<ge; ++i)
  { ok&=scanf("%d",edg+2*i)==1;
    ok&=scanf("%d",edg+2*i+1)==1;
    --(*(edg+2*i));
    --(*(edg+2*i+1));
  }

  /* Read decompositions */

  while (ok)
  { EMPTYGRAPH(g,m,n);

    for (i=0; i<ge; ++i)
    { ADDONEEDGE(g,*(edg+2*i),gv+i,m); 
      ADDONEEDGE(g,*(edg+2*i+1),gv+i,m); 
    }

    for (i=0; ok && i<b; ++i) for (j=0; ok && j<he; ++j)
    { ok=scanf("%d",&x)==1;
      if (ok)
      { ADDONEEDGE(g,gv+x-1,gv+ge+i,m); 
      }
    }

    if (ok) 
    { ++count;

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
	if (mask & 1) 
	{ printf("Graph #%lu. |Aut|=",count); 
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
	  if (mask & 1) 
	  { printf("Graph #%lu. |Aut|=",count); 
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
	{ if (mask & 1) 
	  { printf("Graph #%lu. |Aut|=",count); 
            writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
            printf(". Not new.\n");
          }
        }
      }

    }
  }

}

