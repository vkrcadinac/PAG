#define zlength 16000
/*5:*/
#line 104 "solvediophant.w"

/*6:*/
#line 133 "solvediophant.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/times.h>   
#include <unistd.h> 

#include "diophant.h"

/*:6*/
#line 105 "solvediophant.w"
;
/*7:*/
#line 147 "solvediophant.w"

int user_time,time_0,time_1;
char timestring[256];

/*8:*/
#line 158 "solvediophant.w"

int os_ticks()
{
struct tms tms_buffer;

if(-1==times(&tms_buffer))
return(-1);
return(tms_buffer.tms_utime);
}

int os_ticks_per_second()
{
int clk_tck= 1;

clk_tck= sysconf(_SC_CLK_TCK);
return(clk_tck);
}
/*:8*/
#line 151 "solvediophant.w"
;
/*9:*/
#line 177 "solvediophant.w"

int os_ticks_to_hms_tps(int ticks,int tps,int*h,int*m,int*s)
{
int l1;

l1= ticks/tps;
*s= l1%60;
l1-= *s;
l1/= 60;
*m= l1%60;
l1-= *m;
l1/= 60;
*h= l1;
return(1);
}

int os_ticks_to_hms(int ticks,int*h,int*m,int*s)
{
os_ticks_to_hms_tps(ticks,os_ticks_per_second(),h,m,s);
return(1);
}

/*:9*/
#line 152 "solvediophant.w"
;
/*10:*/
#line 199 "solvediophant.w"

void print_delta_time_tps(int l,int tps,char*str)
{
int h,m,s;

os_ticks_to_hms_tps(l,tps,&h,&m,&s);
sprintf(str,"%d:%02d:%02d",h,m,s);
}

void print_delta_time(int l,char*str)
{
print_delta_time_tps(l,os_ticks_per_second(),str);
}

/*:10*/
#line 153 "solvediophant.w"
;

/*:7*/
#line 106 "solvediophant.w"
;

int main(int argc,char*argv[]){
int i,j,flag;
/*12:*/
#line 222 "solvediophant.w"

#if defined(MPREC)
verylong factor_input= 0;
verylong norm_input= 0;
verylong*upperb;
verylong**A,*rhs;
#else
long factor_input;
long norm_input;
long*upperb;
long**A,*rhs;
#endif

int bkz_beta_input= 0;
int bkz_p_input= 0;
int iterate= 0;
int iterate_no= 0;
int silent;
int maxruntime= 0;

int no_rows,no_columns;

long stop_after_solutions;
long stop_after_loops;
int cut_after;
int free_RHS;
FILE*txt;
char*inputfile_name,*rowp;

char zeile[zlength];
char detectstring[100];

int*original_columns;
int no_original_columns;
int res= 1;

int nboundedvars;

FILE*solfile;
char solfilename[1024];

/*:12*//*14:*/
#line 277 "solvediophant.w"

char suffix[1024];

/*:14*//*24:*/
#line 568 "solvediophant.w"

int k,l;

/*:24*/
#line 110 "solvediophant.w"
;


/*13:*/
#line 263 "solvediophant.w"

strcpy(solfilename,"solutions");
iterate= -1;
bkz_beta_input= bkz_p_input= -1;
factor_input= norm_input= 0;
silent= 0;
for(i= 1;i<argc;i++){
/*15:*/
#line 280 "solvediophant.w"

if(strcmp(argv[i],"-silent")==0){
silent= 1;
fprintf(stderr,"No output of solutions, just counting.\n");
}else if(strncmp(argv[i],"-iterate",8)==0){
strcpy(suffix,argv[i]+8);
iterate_no= atoi(suffix);
iterate= 1;
}else if(strncmp(argv[i],"-bkz",4)==0){
iterate= 0;
}else if(strncmp(argv[i],"-beta",5)==0){
strcpy(suffix,argv[i]+5);
bkz_beta_input= atoi(suffix);
}else if(strncmp(argv[i],"-p",2)==0){
strcpy(suffix,argv[i]+2);
bkz_p_input= atoi(suffix);
}else if(strncmp(argv[i],"-time",5)==0){
strcpy(suffix,argv[i]+5);
maxruntime= atoi(suffix);
}else if(strncmp(argv[i],"-c",2)==0){
strcpy(suffix,argv[i]+2);
#if defined(MPREC)
zstrtoz(suffix,&factor_input);
#else
factor_input= atol(suffix);
#endif
}else if(strncmp(argv[i],"-maxnorm",8)==0){
strcpy(suffix,argv[i]+8);
#if defined(MPREC)
zstrtoz(suffix,&norm_input);
#else
norm_input= atol(suffix);
#endif
}else if(strncmp(argv[i],"-i",2)==0){
strcpy(suffix,argv[i]+2);
}else if(strncmp(argv[i],"-o",2)==0){
strcpy(solfilename,argv[i]+2);
}else if(strcmp(argv[i],"-?")==0||strcmp(argv[i],"-h")==0){
fprintf(stderr,"\nsolvediophant");
fprintf(stderr," -iterate*|(-bkz -beta* -p*) [-c*] [-maxnorm*] [-time*] [-silent] [-o*]");
fprintf(stderr," inputfile\n\n");
exit(1);
}

/*:15*/
#line 270 "solvediophant.w"
;
}
/*16:*/
#line 324 "solvediophant.w"

if(argc<2||strncmp(argv[argc-1],"-",1)==0){
fprintf(stderr,"The last parameter on the command line\n");
fprintf(stderr,"has to be the input file name.\n");
exit(1);
}
if(iterate==-1){
fprintf(stderr,"No reduction was chosen.\n");
fprintf(stderr,"It is set to iterate=1.\n");
iterate= 1;
iterate_no= 1;
}
if(iterate==0&&(bkz_beta_input==-1||bkz_p_input==-1)){
fprintf(stderr,"You have chosen bkz reduction. You also have to specify the parameters");
fprintf(stderr," -beta* -p*\n");
exit(1);
}
if(factor_input<=0){
fprintf(stderr,"You did not supply the options -c*. ");
fprintf(stderr,"It is set to 10000.\n");
#if defined(MPREC)
zstrtoz("100000",&factor_input);
#else
factor_input= 10000;
#endif
}
if(norm_input<=0){
fprintf(stderr,"You did not supply the options -maxnorm*. ");
fprintf(stderr,"It is set to 1.\n");
#if defined(MPREC)
zstrtoz("1",&norm_input);
#else
norm_input= 1;
#endif
}
/*:16*/
#line 272 "solvediophant.w"
;

inputfile_name= argv[argc-1];
/*17:*/
#line 359 "solvediophant.w"

if(maxruntime> 0)alarm(maxruntime);

/*:17*/
#line 275 "solvediophant.w"
;

/*:13*/
#line 113 "solvediophant.w"
;
/*18:*/
#line 364 "solvediophant.w"

txt= fopen(inputfile_name,"r");
if(txt==NULL){
printf("Could not open file '%s'!\n",inputfile_name);
fflush(stdout);
exit(1);
}
flag= 0;
free_RHS= 0;
stop_after_loops= 0;
stop_after_solutions= 0;
cut_after= -1;
do{
fgets(zeile,zlength,txt);
if(strstr(zeile,"% stopafter")!=NULL){
sscanf(zeile,"%% stopafter %ld",&stop_after_solutions);
}
if(strstr(zeile,"% stoploops")!=NULL){
sscanf(zeile,"%% stoploops %ld",&stop_after_loops);
}
if(strstr(zeile,"% cutafter")!=NULL){
sscanf(zeile,"%% cutafter %d",&cut_after);
}
if(strstr(zeile,"% FREERHS")!=NULL){
free_RHS= 1;
}
}
while(zeile[0]=='%');
sscanf(zeile,"%d%d%d",&no_rows,&no_columns,&flag);

/*:18*/
#line 114 "solvediophant.w"
;
/*19:*/
#line 394 "solvediophant.w"

#if defined(MPREC)
A= (verylong**)calloc(no_rows,sizeof(verylong*));
for(j= 0;j<no_rows;j++){
A[j]= (verylong*)calloc(no_columns,sizeof(verylong));
for(i= 0;i<no_columns;i++)A[j][i]= 0;
for(i= 0;i<no_columns;i++)zzero(&(A[j][i]));
}
rhs= (verylong*)calloc(no_rows,sizeof(verylong));
for(i= 0;i<no_rows;i++)rhs[i]= 0;
for(i= 0;i<no_rows;i++)zzero(&(rhs[i]));
#else
A= (long**)calloc(no_rows,sizeof(long*));
for(j= 0;j<no_rows;j++){
A[j]= (long*)calloc(no_columns,sizeof(long));
for(i= 0;i<no_columns;i++)A[j][i]= 0;
}
rhs= (long*)calloc(no_rows,sizeof(long));
for(i= 0;i<no_rows;i++)rhs[i]= 0;
#endif  

/*:19*/
#line 115 "solvediophant.w"
;
/*20:*/
#line 415 "solvediophant.w"

#if defined(MPREC)
for(j= 0;j<no_rows;j++){
for(i= 0;i<no_columns;i++){
res= zfread(txt,&(A[j][i]));
if(res==0){
/*25:*/
#line 572 "solvediophant.w"

fprintf(stderr,"Incomplete input file -> exit\n");
fflush(stderr);
exit(1);

/*:25*/
#line 421 "solvediophant.w"
;
}
}
res= zfread(txt,&(rhs[j]));
if(res==0){
/*25:*/
#line 572 "solvediophant.w"

fprintf(stderr,"Incomplete input file -> exit\n");
fflush(stderr);
exit(1);

/*:25*/
#line 426 "solvediophant.w"
;
}
}
#else
for(j= 0;j<no_rows;j++){
for(i= 0;i<no_columns;i++){
res= fscanf(txt,"%ld",&(A[j][i]));
if(res==(int)NULL||res==(int)EOF){
/*25:*/
#line 572 "solvediophant.w"

fprintf(stderr,"Incomplete input file -> exit\n");
fflush(stderr);
exit(1);

/*:25*/
#line 434 "solvediophant.w"
;
}
}
res= fscanf(txt,"%ld",&(rhs[j]));
if(res==(int)NULL||res==(int)EOF){
/*25:*/
#line 572 "solvediophant.w"

fprintf(stderr,"Incomplete input file -> exit\n");
fflush(stderr);
exit(1);

/*:25*/
#line 439 "solvediophant.w"
;
}
}
#endif
/*:20*/
#line 116 "solvediophant.w"
;
/*21:*/
#line 445 "solvediophant.w"

upperb= NULL;
fclose(txt);
txt= fopen(inputfile_name,"r");
if(txt==NULL){
printf("Could not open file %s !\n",inputfile_name);
fflush(stdout);
exit(1);
}
zeile[0]= '\0';
sprintf(detectstring,"BOUNDS");
do{
rowp= fgets(zeile,zlength,txt);
}while((rowp!=NULL)&&(strstr(zeile,detectstring)==NULL));

if(rowp==NULL){
upperb= NULL;
printf("No %s \n",detectstring);fflush(stdout);
nboundedvars= no_columns;
}else{
nboundedvars= no_columns;
sscanf(zeile,"BOUNDS %d",&nboundedvars);
if(nboundedvars> 0){
printf("Nr. bounded variables=%d\n",nboundedvars);
}else{
nboundedvars= 0;
}

#if defined(MPREC)
upperb= (verylong*)calloc(no_columns,sizeof(verylong));
for(i= 0;i<nboundedvars;i++){
upperb[i]= 0;
zfread(txt,&(upperb[i]));
}
#else
upperb= (long*)calloc(no_columns,sizeof(long));
for(i= 0;i<nboundedvars;i++)
fscanf(txt,"%ld",&(upperb[i]));
#endif
}
fclose(txt);
txt= fopen(inputfile_name,"r");
if(txt==NULL){
printf("Could not open file %s !\n",inputfile_name);
fflush(stdout);
exit(1);
}

/*:21*/
#line 117 "solvediophant.w"
;
/*22:*/
#line 494 "solvediophant.w"

sprintf(detectstring,"SELECTEDCOLUMNS");
do{
rowp= fgets(zeile,zlength,txt);
}while((rowp!=NULL)&&(strstr(zeile,detectstring)==NULL));

if(rowp!=NULL){
printf("SELECTEDCOLUMNS detected\n");fflush(stdout);
res= fscanf(txt,"%d",&(no_original_columns));
if(res==(int)NULL||res==(int)EOF){
/*25:*/
#line 572 "solvediophant.w"

fprintf(stderr,"Incomplete input file -> exit\n");
fflush(stderr);
exit(1);

/*:25*/
#line 504 "solvediophant.w"
;
}
}else no_original_columns= no_columns;

original_columns= (int*)calloc(no_original_columns,sizeof(int));

if(rowp!=NULL){
for(i= 0;i<no_original_columns;i++){
res= fscanf(txt,"%d",&(original_columns[i]));
if(res==(int)NULL||res==(int)EOF){
/*25:*/
#line 572 "solvediophant.w"

fprintf(stderr,"Incomplete input file -> exit\n");
fflush(stderr);
exit(1);

/*:25*/
#line 514 "solvediophant.w"
;
}
}
}else{
for(i= 0;i<no_original_columns;i++)original_columns[i]= 1;
}
fclose(txt);

/*:22*/
#line 118 "solvediophant.w"
;
/*23:*/
#line 523 "solvediophant.w"

if(upperb!=NULL){
for(i= nboundedvars-1;i>=1;i--){
#if defined(MPREC)
if(ziszero(upperb[i])){
for(j= i+1;j<no_columns;j++){
for(k= 0;k<no_rows;k++){
zcopy(A[k][j],&(A[k][j]));
}
zcopy(upperb[j],&(upperb[j-1]));
}
if(i<nboundedvars)nboundedvars--;
no_columns--;
k= l= 0;
while(k<i){
if(original_columns[l]==1){
k++;
}
l++;
}
original_columns[l]= 0;
}
#else
if(upperb[i]==0){
for(j= i+1;j<no_columns;j++){
for(k= 0;k<no_rows;k++){
A[k][j-1]= A[k][j];
}
upperb[j-1]= upperb[j];
}
if(i<nboundedvars)nboundedvars--;
no_columns--;
k= l= 0;
while(k<i){
if(original_columns[l]==1){
k++;
}
l++;
}
original_columns[l]= 0;
}
#endif   
}
fprintf(stderr,"cols=%d\n",nboundedvars);
}
/*:23*/
#line 119 "solvediophant.w"
;

solfile= fopen(solfilename,"w");
time_0= os_ticks();
diophant(A,rhs,upperb,no_columns,no_rows,
factor_input,norm_input,silent,iterate,iterate_no,bkz_beta_input,bkz_p_input,
stop_after_solutions,stop_after_loops,
free_RHS,original_columns,no_original_columns,cut_after,nboundedvars,solfile);
time_1= os_ticks();
fclose(solfile);

/*11:*/
#line 213 "solvediophant.w"

user_time= time_1-time_0;
timestring[0]= 0;
print_delta_time(user_time,timestring);
printf("total enumeration time: %s\n",timestring);
fflush(stdout);

/*:11*/
#line 130 "solvediophant.w"
;
return 0;
}
/*:5*/
