/*
    BDFILTERSP.C

    Filter out isomorphic copies of block designs.

    The program uses nauty/Traces 2.8 by B.D.McKay and A.Piperno. 
    This version calls nauty for sparse graphs. It needs to be linked 
    with nauty.c, nautil.c, naugraph.c, schreier.c, naurng.c, and 
    nausparse.c.

    Vedran Krcadinac (krcko@math.hr), 7.1.2023.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>

#include "nausparse.h" 

/****************/
/* Global stuff */
/****************/

int mask=1;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Print numbers: -n, -N 
   2  Print incidence matrices: -i, -I
   4  Print designs in GAP format: -d, -D 
   8  Print comments: -c, -C 
*/

void printinc(graph *g, int v, int b, int m)
{ int i,j;
  set *gv;

  for (i=0; i<v; ++i)
  { gv = GRAPHROW(g,i,m);
    for (j=0; j<b; ++j)  printf("%d",ISELEMENT(gv,v+j));
    printf("\n");
  }
  printf("\n");
}


void printdes(graph *g, int v, int b, int m)
{ int i,j,first;
  set *gv;

  printf("[ ");
  for (j=0; j<b; ++j)  
  { if (j==0) printf("[ ");
    else printf(",\n[ ");
    gv = GRAPHROW(g,v+j,m);
    first=1;
    for (i=0; i<v; ++i)  if (ISELEMENT(gv,i)) 
    { if (first) printf("%d",i+1);
      else printf(", %d",i+1);
      first=0;
    }
    printf(" ]");
  }
  printf(" ]");
}


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ 
  DYNALLSTAT(graph,g,g_sz);
  DYNALLSTAT(int,lab,lab_sz);
  DYNALLSTAT(int,ptn,ptn_sz);
  DYNALLSTAT(int,orbits,orbits_sz);
  static DEFAULTOPTIONS_SPARSEGRAPH(options);
  statsblk stats;
  sparsegraph *sgp;

  SG_DECL(cg);

  int n,m,mc;
  graph *cng;

  int b=0,v=0; /* Design parameters */
  int p=0;     /* Point class size for initial coloring */

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
      { if (argv[i][j] == 'n') mask |= 1;
	if (argv[i][j] == 'N') mask &= ~1; 
        if (argv[i][j] == 'i') mask |= 2;
	if (argv[i][j] == 'I') mask &= ~2; 
        if (argv[i][j] == 'd') mask |= 4;
	if (argv[i][j] == 'D') mask &= ~4; 
        if (argv[i][j] == 'c') mask |= 8;
	if (argv[i][j] == 'C') mask &= ~8; 
	if (argv[i][j] == 'p') sscanf(argv[i]+j+1,"%d",&p);

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: bdfiltersp [options]\n");
  	  printf("The number of points v, the number of blocks b and the designs are taken from stdin.\n");
	  printf("Options:\n");
          printf("-n, -N  Print numbers (default yes)\n"); 
          printf("-i, -I  Print incidence matrices (default no)\n"); 
          printf("-d, -D  Print designs in GAP format (default no)\n"); 
          printf("-pN     Color points in classes of size N (default no)\n");
	  exit(0);
        }
        ++j;
      }
    }

  ok=scanf("%d",&v)==1;
  ok=ok && scanf("%d",&b)==1;

  if ((v<=0) || (b<=0) || (!ok))
  { printf("Parameters v and b must be entered first!\n");
    exit(0);
  }

  options.writeautoms = FALSE;
  options.schreier = TRUE;
  options.defaultptn = FALSE;
  options.getcanon = TRUE;

  n=v+b;
  m = SETWORDSNEEDED(n);
  depth = v*m;

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
  ptn[v-1] = 0;
  ptn[n-1] = 0;
  if (p>0) for (i=0; i<v; ++i) if ((i+1)%p==0) ptn[i]=0;

  if (mask & 6) printf("%d %d\n",v,b);
  if (mask & 2) printf("\n");

  /* Read designs */

  c=0;
  ok=1;
  while (ok==1 && c!='[') ok=scanf("%c",&c);

  while (ok==1)
  { EMPTYGRAPH(g,m,n);

    c=0;
    while (ok==1 && c!='[') ok=scanf("%c",&c);

    if (ok==1) 
    { i=0;
      while (i<b)
      { /* printf("Block %d: ",i+1); */
        c=0;
        while (ok==1 && c!='[') ok=scanf("%c",&c);
        if (ok!=1)
        { printf("Error reading design.\n");
          exit(0);
        }
        c=',';
        while (ok==1 && c==',')
        { ok=scanf("%d",&x);
          if (x<1 || x>v) 
          { printf("Error reading point of design.\n");
            exit(0);
          }
          /* printf("%d ",x); */
          --x;
          ADDONEEDGE(g,v+i,x,m);
          c=0;
          while (ok==1 && c!=']' && c!=',') ok= scanf("%c",&c);
          if (ok!=1)
          { printf("Error reading design.\n");
            exit(0);
          }
        }

        ++i;
      }

      ++count;

      /* Convert to sparse graph */

      if (count==1) sgp=nauty_to_sg(g,NULL,m,n);
      else nauty_to_sg(g,sgp,m,n);

      /* Call nauty */

      sparsenauty(sgp,lab,ptn,orbits,&options,&stats,&cg);

      /* printf("Design #%ld. |Aut|=",count);
      writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
      printf("\n"); */
      
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
	{ printf("Design #%lu. |Aut|=",count); 
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

	if (mask & 1) printf("%ld\n",count);
        if (mask & 2) printinc(g,v,b,m);
        if (mask & 4)
        { printf("[ ");
          printdes(g,v,b,m);
        }
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
	  { printf("Design #%lu. |Aut|=",count); 
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

	  if (mask & 1) printf("%ld\n",count);
          if (mask & 2) printinc(g,v,b,m);
          if (mask & 4)
          { printf(",\n");
            printdes(g,v,b,m);
          }
	  fflush(stdout);

	}
	else
	{ if (mask & 8) 
	  { printf("Design #%lu. |Aut|=",count); 
            writegroupsize(stdout,stats.grpsize1,stats.grpsize2);
            printf(". Not new.\n");
          }
        }
      }

    }
  }

  if (mask & 4) printf(" ]\n"); 

}

