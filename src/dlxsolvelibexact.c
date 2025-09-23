/*
    DLXSOLVELIBEXACT.C

    Calls libexact by Petteri Kaski and Olli Pottonen, see 
    https://pottonen.kapsi.fi/libexact.html
    Takes input file in DLX3 format, see
    https://www-cs-faculty.stanford.edu/~knuth/programs/dlx3.w

    Vedran Krcadinac (krcko@math.hr), 16.2.2025.
    Department of Mathematics, University of Zagreb, Croatia
*/

#include <stdio.h>
#include <stdlib.h>
#include "exact.h"

int mask = 0;   /* An integer mask for options */
/* Meaning of the bits:
   1  Report solutions 
   2  Fixed single options (bit not set) / pairs of options (bit set)
   4  Read equivalence information and add items to avoid multiple solutions
*/


/****************/
/* Main program */
/****************/

int main(int argc,char *argv[])
{ int m,n,i,j,ok,freq=1,rad,jn,first;
  char c,str[200];
  int *row;
  long int count=0;
  exact_t *e;
  int soln_size;
  const int *soln;
  char *infilename=0, *outfilename;
  FILE *infile, *outfile;
  int fon=0,fo[200],*fop,rn,j2,ie;
  char *fofilename=0;

  outfilename="solutions";

  /* Command line arguments */

  for(i=1; i<argc; ++i) if (argv[i][0] != '-') infilename = argv[i];
  else
  { if (argv[i][1] == 'r') mask |= 1;
    if (argv[i][1] == 'R') mask &= ~1;
    if (argv[i][1] == 'e') mask |= 4;
    if (argv[i][1] == 'E') mask &= ~4;
    if (argv[i][1] == 'f') sscanf(argv[i]+2,"%d",&freq);
    if (argv[i][1] == 'u') 
    { sscanf(argv[i]+2,"%d",&fo[fon]);
      ++fon;
    }
    if (argv[i][1] == 'v') 
    { fofilename=argv[i]+2;
      mask &= ~2;
    }
    /* if (argv[i][1] == 'w') 
    { fofilename=argv[i]+2;
      mask |= 2;
    } */
	     
    /* Help */
    if ((argv[i][1] == 'h') || (argv[i][1] == 'H') || (argv[i][1] == '?'))
    { printf("Usage: dlxsolvelibexact [options] input_file_name\n");
      printf("Options:\n");
      printf("-r, -R      Report found solutions (default no).\n"); 
      printf("-fN         Frequency of reporting (default N=%d).\n",freq);
      printf("-uN         Find only solutions using option N. Can be repeated to fix several options.\n");
      printf("-vFILENAME  Find only solutions using at least one of the option given in file.\n");
      printf("-e, -E      Read equivalence information from the file and add items to avoid multiple solutions (default no).\n"); 
      /* printf("-wFILENAME  Find only solutions using at least one of the pairs of option given in file.\n"); */
      printf("-oFILENAME  Output file name (default: %s).\n",outfilename);
      printf("\n");
      exit(0);
    }
    if (argv[i][1] == 'o') outfilename=argv[i]+2;
  }

  ok=1;

  /* printf("fon=%d\n",fon);
  for (i=0; i<fon; ++i) printf("%d ",fo[i]);
  printf("\n");
  exit(0); */

  if (infilename==0)
  { printf("No input file!\n");
    exit(0); 
  }

  /*****************/
  /* Read DLX file */
  /*****************/

  infile = fopen(infilename,"r");

  if (infile==0)
  { printf("Cannot open input file '%s'!\n",infilename);
    exit(0);
  }

  e = exact_alloc();

  /* Read row information */

  c=' '; 
  rad=1;
  m=0;
  while (rad)
  { while (c==' ') ok=fscanf(infile,"%c",&c);
    if ('0'<=c && c<='9')
    { i=0;
      while (ok==1 && '0'<=c && c<='9')
      { str[i]=c;
        ++i;
        ok=fscanf(infile,"%c",&c);
      }
      str[i]=0;
      sscanf(str,"%d",&j);
      jn=1;
      if (c=='|')
      { jn=j;
        ok=fscanf(infile,"%d",&j);
	ok&=fscanf(infile,"%c",&c);
	if (ok!=1)
        { printf("Error reading row information after | character.\n");
          exit(0);
        }
      }
      if (j!=m)
      { printf("Items should be numbered 0,1,...,m-1.\n");
        exit(0);
      }
      exact_declare_row(e, j, jn);  
      /* printf("%d|%d ",jn,j); */
      ++m;
    }
    else
    { if (c=='\n') 
      { rad=0;
      }
      else
      { printf("Unknown char %c reading row information.",c);
        exit(0);
      }
    }
  }

  n=0;

  while (ok==1)
  { c=' '; 
    first=1;
    rad=1;
    while (rad)
    { while (ok==1 && c==' ') ok=fscanf(infile,"%c",&c);
      if (ok==1 && '0'<=c && c<='9')
      { i=0;
        while (ok==1 && '0'<=c && c<='9')
        { str[i]=c;
          ++i;
          ok=fscanf(infile,"%c",&c);
        }
        str[i]=0;
        sscanf(str,"%d",&j);
        /* printf("%d(%d) ",j,first); */
	if (first) 
	{ exact_declare_col(e, n, 1); 
          /* printf("Dodajem stupac %d\n",n); */
        }
        exact_declare_entry(e, j, n); 
	/* printf("%d ",j); */
        first=0;
      }
      else
      { if (c=='\n') 
        { rad=0;
        }
        else if (ok==1)
        { printf("Unknown character %d reading column %d.",c,n);
          exit(0);
        }
      }
      if (ok!=1) rad=0;
    }
    if (ok==1) 
    { ++n;
      /* printf("\n"); */
    }
  }

  fclose(infile);

  /* Add rows and columns for fixed items */
  
  if (fofilename==0)
  { for (i=0; i<fon; ++i) 
    { exact_declare_row(e, m, 1);  
      exact_declare_entry(e, m, fo[i]); 
      ++m;
    }
  }

  /***************************/
  /* Read fixed options file */
  /***************************/

  else
  { infile = fopen(fofilename,"r");
    if (infile==0)
    { printf("Cannot open file '%s'!\n",fofilename);
      exit(0);
    }
    fscanf(infile,"%d",&fon);
    /* printf("No. fixed options: %d\nFixed: ",fon); */
    fop = (int *)calloc(fon,sizeof(int));
    exact_declare_row(e, m, 1);  
    for (i=0; i<fon; ++i)
    { fscanf(infile,"%d",fop+i);
      /* printf("%d ",fop[i]); */
      exact_declare_col(e, n+i, 1);  
      exact_declare_entry(e, m, n+i); 
      for (j=0; j<m; ++j) if (exact_is_entry(e,j,fop[i])) 
        exact_declare_entry(e, j, n+i); 
    }
    /* Read equivalence information and define additional items to avoid double solutions */
    if (mask & 4)
    { for (i=1; i<fon; ++i) exact_declare_row(e, m+i, 1);  
      for (i=1; i<fon; ++i)
      { fscanf(infile,"%d",&rn);
        for (j=0; j<rn; ++j)
        { fscanf(infile,"%d",&ie);
          for (j2=i; j2<fon; ++j2) exact_declare_entry(e, m+j2, ie); 
        }
	for (j=i; j<fon; ++j) exact_declare_entry(e, m+i, n+j); 
      }
    }
    fclose(infile);
    ++m;
    if (mask & 4) m+=fon-1;
    /* printf("\n");
    exit(0); */
  }

  /* printf("m=%d, n=%d\n",m,n); */

  /*****************/
  /* Start search  */
  /*****************/

  if (mask & 1) 
  { printf("Starting search...\n");
    fflush(stdout);
  }

  outfile = fopen(outfilename,"w");
  row = (int *)calloc(n,sizeof(int));

  if (outfile==0)
  { printf("Cannot open output file '%s'!\n",outfilename);
    exit(0);
  }

  while((soln = exact_solve(e, &soln_size)) != NULL) 
  { ++count;
    if ((mask & 1) && (count%freq==0)) 
    { printf("Solution #%ld\n",count);
      fflush(stdout);
    }
    for (i=0; i<n; ++i) *(row+i)=0;
    for (i=0; i<soln_size; ++i) if (soln[i]<n) *(row+soln[i])=1;
                                else *(row+fop[soln[i]-n])=1;
    for (i=0; i<n; ++i) fprintf(outfile,"%d",*(row+i));
    fprintf(outfile,"\n"); 
    fflush(outfile);
  }

  if (mask & 1) 
  { if (fon==0) printf("Total number of solutions: %ld\n",count);
    else printf("Number of solutions: %ld\n",count);
  }
  fclose(outfile); 

}

