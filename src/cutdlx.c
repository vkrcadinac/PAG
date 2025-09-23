/*
    CUTDLX.C

    Takes input file in DLX3 format, see
    https://www-cs-faculty.stanford.edu/~knuth/programs/dlx3.w

    Vedran Krcadinac (krcko@math.hr), 23.3.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>

#define MAXLINE 600000  

int mask = 0;   /* An integer mask for options */
/* Meaning of the bits:
*/


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ char line[MAXLINE]; 
  char *pfilename=0;
  int fixed=-1;
  FILE *pfile;
  int nk, *pvec, ok, nt, first;

  int i,j;

  /* Command line arguments */

  for(i=1; i<argc; ++i) if (argv[i][0]=='-') 
  { /* if (argv[i][1] == 'r') mask |= 1;
    if (argv[i][1] == 'R') mask &= ~1; */
    if (argv[i][1] == 'p') pfilename=argv[i]+2;
    if (argv[i][1] == 'f') sscanf(argv[i]+2,"%d",&fixed);
    /* Help */
    if ((argv[i][1] == 'h') || (argv[i][1] == 'H') || (argv[i][1] == '?'))
    { printf("Usage: cutdlx [options]\n");
      printf("Options:\n");
      printf("-pFILENAME  Read partition vector from file.\n");
      printf("-fN         Fix first option in N-th block of partition.\n"); 
      printf("            Discard options in blocks preceeding the N-th.\n");
      printf("\n");
      exit(0);
    }
  }

  if (pfilename==0)
  { fprintf(stderr,"Name of partition file not given!\n");
    exit(0); 
  } 
  if (fixed<0)
  { fprintf(stderr,"Block containing fixed option not given!\n");
    exit(0); 
  } 

  /* Read partition vector */

  pfile = fopen(pfilename,"r");
  if (pfile==NULL)
  { fprintf(stderr,"Cannot open file '%s'!\n",pfilename);
    exit(0);
  }
  ok=fscanf(pfile,"%d",&nk)==1;
  if (ok) 
  { pvec = (int *)calloc(nk,sizeof(int));
    if (pvec==NULL)
    { fprintf(stderr,"Error allocating memory!\n");
      exit(0);
    }
  }
  for (i=0; ok && i<nk; ++i) ok=fscanf(pfile,"%d",pvec+i)==1;
  fclose(pfile);
  if (!ok)
  { fprintf(stderr,"Error reading partition file!\n");
    exit(0);
  }

  /* printf("%d\n",nk);
  for (i=0; i<nk; ++i) printf("%d ",*(pvec+i));
  printf("\n"); */

  ok=fgets(line,MAXLINE,stdin)==line;
  if (ok)
  { j=0;
    while (j<MAXLINE && line[j]!='\n') ++j;
    if (j==MAXLINE)
    { fprintf(stderr,"Reached MAXLINE!\n");
      exit(0);
    }
    if (line[j-1]==' ') line[j]=0;
    else 
    { line[j]=' ';
      line[j+1]=0;
    }
  }
  printf("%s",line);
  printf("f \n");

  first=1;

  for (i=0; ok && i<nk; ++i)
  { ok=fgets(line,MAXLINE,stdin)==line;
    if (first && pvec[i]==fixed)
    { j=0;
      while (j<MAXLINE && line[j]!='\n') ++j;
      if (j==MAXLINE)
      { fprintf(stderr,"Reached MAXLINE!\n");
        exit(0);
      }
      if (line[j-1]==' ') line[j]=0;
      else 
      { line[j]=' ';
        line[j+1]=0;
      }
      printf("%s",line);
      printf("f \n");
      first=0;
    }
    else if (pvec[i]>=fixed) printf("%s",line);
  }

  if (!ok) 
  { fprintf(stderr,"Error reading DLX file!\n");
    exit(0);
  }

  ok=fgets(line,MAXLINE,stdin)==line;
  while (ok)
  { printf("%s",line);
    ok=fgets(line,MAXLINE,stdin)==line;
  }
  
}
