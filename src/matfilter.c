/*
    MATFILTER.C

    Filter out matrices equivalent under rearrangements of rows, columns
    and symbols.

    The program uses nauty/Traces 2.8 by B.D.McKay and A.Piperno. 
    It needs to be linked with nauty.c, nautil.c, naugraph.c, schreier.c, 
    naurng.c, nausparse.c, gtools.c, and traces.c. 

    Vedran Krcadinac (krcko@math.hr), 7.1.2024.
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

  int vr=0, vc=0, vs=0; /* Number of rows, columns, and distinct entries of the matrix */

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
        { printf("Usage: matfilter [options]\n");
	  printf("The number of rows, columns, symbols and the matrices are taken from stdin.\n");
	  printf("Options:\n");
	  printf("-c, -C  Print comments (default no)\n");
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&vr)==1;
  ok&=scanf("%d",&vc)==1;
  ok&=scanf("%d",&vs)==1;

  if ((vr<=0) || (vc<=0) || (vs<=0) || (!ok))
  { printf("The number of rows, columns, and distinct entries of the matrices must be given first!\n");
    exit(0);
  }

  options.writeautoms = FALSE;
  options.defaultptn = FALSE;
  options.getcanon = TRUE;

  n=vr+vc+vs+vr*vc;
  m = SETWORDSNEEDED(n);
  depth = (vr+vc+vs)*m;

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
  ptn[vr-1] = 0;
  ptn[vr+vc-1] = 0;
  ptn[vr+vc+vs-1] = 0;
  ptn[n-1] = 0;

  /* Read matrices */

  c=0;
  ok=1;
  while (ok==1 && c!='[') ok=scanf("%c",&c);

  while (ok==1)
  { EMPTYGRAPH(g,m,n);
    for (i=0; i<vr; ++i) for (j=0; j<vc; ++j)
    { ADDONEEDGE(g,i,vr+vc+vs+i*vc+j,m); 
      ADDONEEDGE(g,vr+j,vr+vc+vs+i*vc+j,m); 
    }

    c=0;
    while (ok==1 && c!='[') ok=scanf("%c",&c);

    if (ok==1) 
    { i=0;
      while (i<vr)
      { /* printf("Block %d: ",i+1); */
        c=0;
        while (ok==1 && c!='[') ok=scanf("%c",&c);
        if (ok!=1)
        { printf("Error reading matrix.\n");
          exit(0);
        }
        c=',';
	j=-1;
        while (ok==1 && c==',')
        { ok=scanf("%d",&x);
          if (x<0 && x>=vs) 
	  { printf("Error reading entry of matrix.\n");
	    exit(0);
	  }
	  ++j;
	  /* printf("(%d,%d)=%d ",i,j,x); */
	  ADDONEEDGE(g,vr+vc+x,vr+vc+vs+i*vc+j,m); 
	  c=0;
          while (ok==1 && c!=']' && c!=',') ok= scanf("%c",&c);
          if (ok!=1)
          { printf("Error reading matrix.\n");
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
	if (mask & 1) 
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
	  if (mask & 1) 
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
	{ if (mask & 1) 
	  { printf("Matrix #%lu. |Aut|=",count); 
            writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
            printf(". Not new.\n");
          }
        }
      }

    }
  }

}

