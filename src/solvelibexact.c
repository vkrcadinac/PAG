/*
    SOLVELIBEXACT.C

    Calls libexact by Petteri Kaski and Olli Pottonen, see 
    https://pottonen.kapsi.fi/libexact.html

    Vedran Krcadinac (krcko@math.hr), 15.10.2024.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>
#include "exact.h"

int mask = 0;   /* An integer mask for options */
/* Meaning of the bits:
*/


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int m,n,i,j,ok,freq=1;
  long int count=0;
  int *row;
  exact_t *e;
  int soln_size;
  const int *soln;
  char *infilename=0, *outfilename;
  FILE *infile, *outfile;

  outfilename="solutions";

  /* Command line arguments */

  for(i=1; i<argc; ++i) if (argv[i][0] != '-') infilename = argv[i];
  else
  { j = 0;
    while (argv[i][j] != '\0')
    { if (argv[i][j] == 'r') mask |= 1;
      if (argv[i][j] == 'R') mask &= ~1;
      if (argv[i][j] == 'f') sscanf(argv[i]+j+1,"%d",&freq);
	     
      /* Help */
      if ((argv[i][j] == 'h') || (argv[i][j] == 'H') || (argv[i][j] == '?'))
      { printf("Usage: solvelibexact [options] input_file_name\n");
        printf("Options:\n");
	printf("-r, -R      Report found solutions (default no)\n"); 
        printf("-fN         Frequency of reporting (default N=%d).\n",freq);
        printf("-oFILENAME  Output file name (default: %s).\n",outfilename);
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

  ok=1;

  if (infilename==0)
  { printf("No input file!\n");
    ok=0;
  }

  /**********************/
  /* Read linear system */
  /**********************/

  infile = fopen(infilename,"r");

  if (infile==0)
  { printf("Cannot open input file '%s'!\n",infilename);
    ok=0;
  }

  /* Read dimensions */

  j=1;
  j&=(fscanf(infile,"%d",&m)==1);
  j&=(fscanf(infile,"%d",&n)==1);
  j&=(fscanf(infile,"%d",&i)==1);

  if (j==0)
  { printf("Dimensions of the system must be given first.\n");
    ok=0;
  }

  if (i!=1)
  { printf("Works only for single RHS.\n");
    ok=0;
  }

  if (ok==0) exit(0);

  /* Read coefficients */

  row = (int *)calloc(n,sizeof(int));
  e = exact_alloc();
    
  for (i=0; i<n; ++i) exact_declare_col(e, i, 1); 

  for (i=0; ok && i<m; ++i)
  { for (j=0; ok && j<=n; ++j) ok&=(fscanf(infile,"%d",row+j)==1);
    /* for (j=0; j<=n; ++j) printf("%d ",*(row+j));
    printf("\n"); */

    if (!ok) printf("Error reading coefficients.\n");
    else
    { exact_declare_row(e, i, *(row+n));  
      for (j=0; ok && j<n; ++j)
      { if (*(row+j)==1) exact_declare_entry(e, i, j); 
        else if (*(row+j)!=0)
        { printf("System matrix entries must be 0-1!\n");
          ok=0;
        }
      }
    }
  }

  fclose(infile);

  if (ok==0) exit(0);

  if (mask & 1) printf("Starting search...\n");

  outfile = fopen(outfilename,"w");

  if (outfile==0)
  { printf("Cannot open output file '%s'!\n",outfilename);
    exit(0);
  }
	     
  while((soln = exact_solve(e, &soln_size)) != NULL) 
  { ++count;
    if ((mask & 1) && (count%freq==0)) printf("Solution #%ld\n",count);
    for (i=0; i<n; ++i) *(row+i)=0;
    for (i=0; i<soln_size; ++i) *(row+soln[i])=1;
    for (i=0; i<n; ++i) fprintf(outfile,"%d",*(row+i));
    fprintf(outfile,"\n"); 
    fflush(outfile);
  }

  if (mask & 1) printf("Total number of solutions: %ld\n",count);
  fclose(outfile);

}

