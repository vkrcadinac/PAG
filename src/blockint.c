/*
    BLOCKINT.C

    Compute block intersection numbers of a design.

    Vedran Krcadinac (krcko@math.hr), 7.5.2022.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>

/****************/
/* Global stuff */
/****************/

int bitsum[256];

int mask=1;  /* An integer mask for options */
/* Meaning of the bits and options to put them on/off are:
   1  Output for GAP (-g, -G)
   2  Single block intersection vectors (-s, -S) 
*/


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int b=0,v=0; /* Design parameters */
  int vb; /* Number of bytes for storing blocks */
  unsigned char *d; /* The design */
  unsigned char *db1, *db2;  /* Pointers to blocks */
  int i,j,k,s,x,ok;
  char c;
  int *inum;

  /* Command line arguments */
  for(i=1; i<argc; ++i)
    if (('0' <= argv[i][0]) && (argv[i][0] <= '9'))
    {  if (k==0) sscanf(argv[i],"%d",&k);
       else if (b==0) sscanf(argv[i],"%d",&b);
    }
    else
    { j = 0;
      while (argv[i][j] != '\0')
      { if (argv[i][j] == 'g') mask |= 1;
	    if (argv[i][j] == 'G') mask &= ~1;
        if (argv[i][j] == 's') mask |= 2; 
		if (argv[i][j] == 'S') mask &= ~2;

        /* Help */
        if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
        { printf("Usage: blockint [options]\n");
  	  printf("The number of points v, the number of blocks b and the design will be taken from stdin.\n");
	  printf("Options:\n");
          /* printf("-g, -G  Output for GAP (default yes)\n");
	  printf("-s, -S  Single block intersection vectors (default no)\n"); */
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

  vb=(v/8)+(v%8!=0);

  d=(unsigned char *)calloc(b,vb);
  if (d == NULL) 
  { printf("Memory not allocated.\n");
    exit(0);
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

  /* Read design */

  c=0;
  while (ok==1 && c!='[') ok= scanf("%c",&c);
  if (ok!=1)
  { printf("Error reading design.\n");
    exit(0);
  }
	   
  i=0;
  db1=d;
  while (i<b)
  { /* printf("Block %d: ",i+1); */
    c=0;
    while (ok==1 && c!='[') ok= scanf("%c",&c);
    if (ok!=1)
    { printf("Error reading design.\n");
      exit(0);
    }
    c=',';
    for (j=0; j<vb; ++j) db1[j]=0;
    while (ok==1 && c==',')
    { ok=scanf("%d",&x);
      if (x<1 || x>v) 
      { printf("Error reading point of design.\n");
        exit(0);
      }
      /* printf("%d ",x); */
      --x;
      db1[x/8]|=1<<(x%8);
      c=0;
      while (ok==1 && c!=']' && c!=',') ok= scanf("%c",&c);
      if (ok!=1)
      { printf("Error reading design.\n");
        exit(0);
      }
    }
    /* printf("\n");
    for (j=0; j<vb; ++j) printf("%d ",db1[j]);
    printf("\n"); */
    ++i;
    db1+=vb;
  }

  inum=(int *)calloc(v+1,sizeof(int));
  if (inum == NULL) 
  { printf("Memory not allocated.\n");
    exit(0);
  }

  for (i=0; i<=v; ++i) inum[i]=0;

  /* Compute intersection numbers */

  db1=d;
  for (i=0; i<b-1; ++i) 
  { db2=db1+vb;
    for (j=i+1; j<b; ++j)
    { s=0;
      for (k=0; k<vb; ++k) s+=bitsum[db1[k] & db2[k]];
      ++inum[s];
      db2+=vb;
    }
    db1+=vb;
  }

  ok=0;
  printf("return [ ");
  for (i=0; i<=v; ++i) 
  { if(inum[i]) 
    { if (ok) printf(", ");
      ok=1;
      printf("[%d, %d]",i,inum[i]);
    }
  }
  printf(" ];\n");

}
