/*
    P16SOLVE.C

    Vedran Krcadinac (krcko@math.hr), 23.10.2024.

    Department of Mathematics, University of Zagreb, Croatia

*/

#define MAXSOL 1000
#define MAXORB 2000
#define ORBSIZE 96
#define MAXV 16

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int i,i2,j,ok,count,first,first2;
  char c,path[1000];
  int sol[MAXSOL],nsol;
  long int countsol=0,countgood=0;
  FILE *infile, *outfile;
  int x,orb[MAXORB][ORBSIZE][3], orbs[MAXORB], norb=0;
  int p1[MAXV][MAXV], p2[MAXV][MAXV], p3[MAXV][MAXV];
  int v=16,k=6,lambda=2,tst,sum1,sum2,sum3;

  /* Command line arguments */

  for(i=1; i<argc; ++i)
  { j = 0;
    while (argv[i][j] != '\0')
    { /* if (argv[i][j] == 'p') mask |= 1;
      if (argv[i][j] == 'P') mask &= ~1; */
    
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: p16solve path\n");
        printf("\n");
	exit(0);
      }
      ++j;
    }
  }

  strcpy(path,argv[1]);
  strcat(path,"orbits.in");
  /* printf("Filename: %s\n",path); */
  infile = fopen(path,"r");
  if (infile==0)
  { printf("Cannot open orbits.in!\n");
    exit(0);
  }
  ok=fscanf(infile,"%d",&x);
  norb=0;
  orbs[norb]=0;
  while (ok==1)
  { if (x<0)
    { ++norb;
      orbs[norb]=0;
      ok=fscanf(infile,"%d",&x);
    }
    else
    { orb[norb][orbs[norb]][0]=x-1;
      ok=fscanf(infile,"%d",&x);
      if ((ok!=1) || (x<=0))
      { printf("Error reading orbits!\n");
        exit(0);
      }
      orb[norb][orbs[norb]][1]=x-1;
      ok=fscanf(infile,"%d",&x);
      if ((ok!=1) || (x<=0))
      { printf("Error reading orbits!\n");
        exit(0);
      }
      orb[norb][orbs[norb]][2]=x-1;
      ++(orbs[norb]);
      if (orbs[norb]>ORBSIZE)
      { printf("Orbit size too large!\n");
        exit(0);
      }
      ok=fscanf(infile,"%d",&x);
    }
  }
  fclose(infile);

  printf("Number or orbits: %d\n",norb);
  /* printf("Orbit sizes:\n");
  for (i=0; i<norb; ++i) printf("%d ",orbs[i]);
  printf("\n"); 
  printf("Orbits:\n");
  for (i=0; i<norb; ++i)
  { for (j=0; j<orbs[i]; ++j) printf("%d %d %d\n",orb[i][j][0]+1,orb[i][j][1]+1,orb[i][j][2]+1);
    printf("-1\n");
  }
  exit(0); */

  strcpy(path,argv[1]);
  strcat(path,"solve.out");
  /* printf("Filename: %s\n",path); */
  infile = fopen(path,"r");
  if (infile==0)
  { printf("Cannot open solve.out!\n");
    exit(0);
  }

  strcpy(path,argv[1]);
  strcat(path,"p16solve.out");
  /* printf("Filename: %s\n",path); */
  outfile = fopen(path,"w");
  if (outfile==0)
  { printf("Cannot open p16solve.out!\n");
    exit(0);
  }
  fprintf(outfile,"return [\n");
  first=1;

  ok=1; 
  count=0;
  nsol=0;
  while (ok==1)
  { ok=fscanf(infile,"%c",&c);

    /* printf("%d *%c* %d\n",ok,c,c); */

    if (ok==1) 
    { if (c==49) 
      { sol[nsol]=count;
	++count; 
	++nsol;
	if (nsol==MAXSOL)
        { printf("Increase MAXSOL!\n");
          exit(0);
        }
      }

      if (c==48) ++count;

      if (c==10)
      { ++countsol;
        if (count!=norb)
        { printf("Error - solution vector of wrong lentgh!\n");
          exit(0);
        }

	/* Process solution */

        for (i=0; i<v; ++i) for (j=0; j<v; ++j)
	{ p1[i][j]=0;
          p2[i][j]=0;
	  p3[i][j]=0;
        }
	/* printf("Solution no. %ld:\n",countsol);
	for (i=0; i<nsol; ++i) printf("%d ",sol[i]);
	printf("\n"); */
	for (i=0; i<nsol; ++i) for (j=0; j<orbs[sol[i]]; ++j) 
        { /* printf("(%d,%d,%d)\n",orb[sol[i]][j][0],orb[sol[i]][j][1],orb[sol[i]][j][2]); */
	  p1[orb[sol[i]][j][0]][orb[sol[i]][j][1]]=1;
          p2[orb[sol[i]][j][0]][orb[sol[i]][j][2]]=1;
          p3[orb[sol[i]][j][1]][orb[sol[i]][j][2]]=1; 
        }
	tst=1;
        for (i=0; tst && i<v; ++i) for (j=i; tst && j<v; ++j)
        { sum1=0;
          sum2=0;
	  sum3=0;
          for (i2=0; i2<v; ++i2) 
	  { sum1+=p1[i][i2]*p1[j][i2];
	    sum2+=p2[i][i2]*p2[j][i2];
	    sum3+=p3[i][i2]*p3[j][i2];
          }
	  if (i==j) tst=(sum1==k && sum2==k && sum3==k);
	  else tst=(sum1==lambda && sum2==lambda && sum3==lambda);
        }

	if (tst) 
	{ ++countgood;
          if (first) first=0;
	  else fprintf(outfile,",\n");
	  first2=1;
	  fprintf(outfile,"[");
	  for (i=0; i<nsol; ++i) for (j=0; j<orbs[sol[i]]; ++j) 
          { if (first2) first2=0;
            else fprintf(outfile,",");
            fprintf(outfile,"[%d,%d,%d]",orb[sol[i]][j][0]+1,orb[sol[i]][j][1]+1,orb[sol[i]][j][2]+1);
          }
	  fprintf(outfile,"]");
        }

	/* End processing */

        count=0;
	nsol=0;
      }
    }

  }

  fprintf(outfile,"\n];\n");
  fclose(infile);
  fclose(outfile);

  printf("Number of solutions: %ld\n",countsol);
  printf("Number of good solutions: %ld\n",countgood);

}

