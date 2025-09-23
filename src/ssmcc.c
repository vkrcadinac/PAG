#define o mems++
#define oo mems+= 2
#define ooo mems+= 3
#define subroutine_overhead mems+= 4
#define O "%"
#define mod % \

#define max_stage 500
#define max_level 32000
#define savesize 10000000
#define DISCRETA_OUTPUT 1
#define RANDOMIZE 0 \

#define show_basics 1
#define show_choices 2
#define show_details 4
#define show_record_weights 16
#define show_weight_bumps 32
#define show_final_weights 64
#define show_profile 128
#define show_full_state 256
#define show_tots 512
#define show_warnings 1024
#define show_max_deg 2048 \

#define size(x) set[(x) -1].i
#define pos(x) set[(x) -2].i
#define lname(x) set[(x) -4].i
#define rname(x) set[(x) -3].i
#define slack(x) set[(x) -5].i
#define bound(x) set[(x) -6].i
#define wt(x) set[(x) -7].f
#define primextra 7
#define secondextra 4
#define maxextra 7
#define ipropcount 6 \

#define sanity_checking 0 \

#define panic(m) {fprintf(stderr,""O"s!\n"O"d: "O".99s\n",m,p,buf) ;exit(-666) ;} \

#define dangerous 1e32f
#define wmin 1e-30f \

#define inf_size 0x7fffffff \

/*2:*/
#line 57 "ssmcc.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <ctype.h> 
#line 27 "aw_ssm.ch"
#if RANDOMIZE
#include "gb_flip.h"
#endif
#line 30 "aw_ssm.ch"
#include "uthash.h"
#line 63 "ssmcc.w"
typedef unsigned int uint;
typedef unsigned long long ullng;
/*9:*/
#line 332 "ssmcc.w"

typedef struct node_struct{
int itm;
int loc;
int clr;
int spr;
}node;
typedef union{
int i;
float f;
}tetrabyte;

/*:9*//*11:*/
#line 364 "ssmcc.w"

typedef struct{
int l,r;
}twoints;
typedef struct{
int l,s,b;
}threeints;
typedef union{
unsigned char str[8];
twoints lr;
}stringbuf;
#line 148 "aw_ssm.ch"
stringbuf namebuf;

typedef struct{
char*name;
int pos;
UT_hash_handle hh;
}item_hash;

item_hash*items_hash_table= NULL;

/*:11*/
#line 65 "ssmcc.w"
;
/*3:*/
#line 146 "ssmcc.w"

int random_seed= 0;
int randomizing;
int vbose= show_basics+show_warnings;
int spacing;
int show_choices_max= 1000000;
int show_choices_gap= 1000000;

int show_levels_max= 10;
int maxl;
int maxs;
#line 63 "aw_ssm.ch"
int maxsaveptr;
int bufsize;
int print_indices= 1;
long max_cols= 1000000;
long max_nodes= 10000000;
#line 159 "ssmcc.w"
ullng count;
ullng options;
ullng imems,mems,tmems,cmems;
ullng updates;
ullng bytes;
ullng nodes;
ullng thresh= 10000000000;
ullng delta= 10000000000;
ullng maxcount= 0xffffffffffffffff;
ullng timeout= 0x1fffffffffffffff;
float w0= 1.0,dw= 1.0,dwfactor= 1.0;
float maxwt= 1.0;
FILE*shape_file;
char*shape_name;
int maxdeg;

/*:3*//*10:*/
#line 344 "ssmcc.w"

#line 121 "aw_ssm.ch"
node*nd;
#line 346 "ssmcc.w"
int last_node;
#line 128 "aw_ssm.ch"
int*item;
int second;
#line 349 "ssmcc.w"
int last_itm;
#line 135 "aw_ssm.ch"
tetrabyte*set;
#line 351 "ssmcc.w"
int itemlength;
int setlength;
int active;
int oactive;
int baditem;
int osecond;
#line 141 "aw_ssm.ch"
int*force;
char*buf;
#line 358 "ssmcc.w"
int forced;

/*:10*//*27:*/
#line 247 "aw_ssm.ch"

#if DISCRETA_OUTPUT
int*solution_vector;
#endif
#line 251 "aw_ssm.ch"

/*:27*//*35:*/
#line 790 "ssmcc.w"

int stage;
int level;
int choice[max_level];
int deg[max_level];
int levelstage[max_stage];
int stagelevel[max_level];
ullng profile[max_stage];

/*:35*//*37:*/
#line 858 "ssmcc.w"

int level;
int choice[max_level];
int saved[max_level+1];
threeints savestack[savesize];
int saveptr;
int tough_itm;

/*:37*/
#line 66 "ssmcc.w"
;
/*7:*/
#line 212 "ssmcc.w"

void confusion(char*m){
fprintf(stderr,""O"s!\n",m);
}

/*:7*//*12:*/
#line 158 "aw_ssm.ch"

void add_item(unsigned char*name,int pos){
item_hash*s;
s= malloc(sizeof*s);
s->pos= pos;
s->name= (char*)name;
HASH_ADD_KEYPTR(hh,items_hash_table,s->name,strlen(s->name),s);
}
int find_item(unsigned char*name){
item_hash*s;
s= malloc(sizeof*s);
HASH_FIND_STR(items_hash_table,(char*)name,s);
if(s==NULL){
fprintf(stderr,"find_item: unknown name %s\n",(char*)name);
return 0;
}
return s->pos;
}
#line 376 "ssmcc.w"

/*:12*//*13:*/
#line 377 "ssmcc.w"

void print_item_name(int k,FILE*stream){
namebuf.lr.l= lname(k),namebuf.lr.r= rname(k);
fprintf(stream," "O".8s",namebuf.str);
}

/*:13*//*14:*/
#line 387 "ssmcc.w"

#line 181 "aw_ssm.ch"
#if DISCRETA_OUTPUT
void print_option_discreta(int p,FILE*stream){
register int k,q,x;

x= nd[p].itm;
if(p>=last_node||x<=0){
fprintf(stderr,"Illegal option "O"d!\n",p);
return;
}
for(q= p;;){
q++;
if(nd[q].itm<0){
k= nd[q].spr-1;
if(print_indices){
fprintf(stream,"%d ",k);
}else{
solution_vector[k]= 1;
}
break;
}
x= nd[q].itm;
if(x<0)q+= x,x= nd[q].itm;
if(q==p)break;
}
}
#endif
#line 207 "aw_ssm.ch"
 void print_option(int p,FILE*stream,int showpos){
#line 389 "ssmcc.w"
register int k,q,x;
x= nd[p].itm;
if(p>=last_node||x<=0){
fprintf(stderr,"Illegal option "O"d!\n",p);
return;
}
for(q= p;;){
print_item_name(x,stream);
if(nd[q].clr)
fprintf(stream,":"O"c",nd[q].clr);
q++;
x= nd[q].itm;
if(x<0)q+= x,x= nd[q].itm;
if(q==p)break;
}
k= nd[q].loc;
if(showpos> 0)fprintf(stream," ("O"d of "O"d)\n",k-x+1,size(x));
else if(showpos==0)fprintf(stream,"\n");
}

void prow(int p){
print_option(p,stderr,1);
}

/*:14*//*15:*/
#line 415 "ssmcc.w"

void print_itm(int c){
register int p;
if(c<primextra||c>=setlength||
pos(c)<0||pos(c)>=itemlength||item[pos(c)]!=c){
fprintf(stderr,"Illegal item "O"d!\n",c);
return;
}
fprintf(stderr,"Item ("O"d)",c);
print_item_name(c,stderr);
if(c<second){
if(slack(c)||bound(c)!=1)
fprintf(stderr," ("O"d,"O"d)",bound(c)-slack(c),bound(c));
fprintf(stderr," ("O"d of "O"d), length "O"d, weight "O".1f:\n",
pos(c)+1,active,size(c),wt(c));
}
else if(pos(c)>=active)
fprintf(stderr," (secondary "O"d, purified), length "O"d:\n",
pos(c)+1,size(c));
else fprintf(stderr," (secondary "O"d), length "O"d:\n",
pos(c)+1,size(c));
for(p= c;p<c+size(c);p++)prow(set[p].i);
}

void print_items()
{
register int i;
for(i= 0;i<itemlength;i++)
print_itm(item[i]);
}

/*:15*//*16:*/
#line 451 "ssmcc.w"

void sanity(){
register int k,x,i,l,r,q,qq;
int ok= 1;
for(k= 0;k<itemlength;k++){
x= item[k];
if(pos(x)!=k){
fprintf(stderr,"Bad pos field of item");
print_item_name(x,stderr);
fprintf(stderr," ("O"d != "O"d, "O"d)!\n",k,pos(x),x);
ok= 0;
}
}
for(i= 0;i<last_node;i++){
l= nd[i].itm,r= nd[i].loc;
if(l<=0){
if(nd[i+r+1].itm!=-r)
{
fprintf(stderr,"Bad spacer in nodes "O"d, "O"d!\n",i,i+r+1);
ok= 0;
}
qq= 0;
}else{
if(l> r)fprintf(stderr,"itm>loc in node "O"d!\n",i);
else{
if(set[r].i!=i){
fprintf(stderr,"Bad loc field for option "O"d of item",r-l+1);
print_item_name(l,stderr);
fprintf(stderr," in node "O"d!, set[r].i="O"d\n",i,set[r].i);
ok= 0;
}
if(pos(l)<active){
if(r<l+size(l))q= +1;else q= -1;
if(q*qq<0){
fprintf(stderr,"Flipped status at option "O"d of item",r-l+1);
print_item_name(l,stderr);
fprintf(stderr," in node "O"d!, q,qq="O"d,"O"d\n",i,q,qq);
ok= 0;
}
qq= q;
}
}
}
}
}

/*:16*//*41:*/
#line 901 "ssmcc.w"

int include_option(int opt){
register int c,optp,nn,nnp,ss,ii,iii,p,pp,s;
subroutine_overhead;
if(vbose&show_choices){
fprintf(stderr,"S"O"d:",stage);
print_option(opt,stderr,1);
}
for(;o,nd[opt-1].itm> 0;opt--);
for(;o,(ii= nd[opt].itm)> 0;opt++){
pp= nd[opt].loc;
o,p= pos(ii);
if(p>=active){
if(ii>=second)continue;
confusion("active");
}
/*42:*/
#line 925 "ssmcc.w"

{
if(ii<second)oo,bound(ii)--;
if(ii>=second||bound(ii)==0){
o,ss= size(ii);
if(ii<second)c= 0;else o,c= nd[opt].clr;
for(s= ii+ss-1;s>=ii;s--)if(s!=pp){
o,optp= set[s].i;
if(c==0||(o,nd[optp].clr!=c))
/*43:*/
#line 971 "ssmcc.w"

{
register int nn,ii,iii,p,pp,ss,nnp;
for(nn= optp;o,nd[nn-1].itm> 0;nn--);
for(;o,(ii= nd[nn].itm)> 0;nn++){
p= nd[nn].loc;
if(p>=second&&(o,pos(ii))>=active)continue;
o,ss= size(ii)-1;
if(p<second){
if(oo,ss<bound(ii)-slack(ii)){
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
fprintf(stderr,"Can't cover");
print_item_name(ii,stderr);
fprintf(stderr,", size="O"d, bound="O"d, slack="O"d, u="O"d\n",
ss,bound(ii),slack(ii),bound(ii)-slack(ii));
}
tough_itm= ii;
forced= 0;
return 0;
}
if(ss==0){
o,iii= item[--active];
o,pp= pos(ii);
if(vbose&show_details){
fprintf(stderr,"Empty option list, deactivating");
print_item_name(ii,stderr);
fprintf(stderr,"\n");
}
oo,item[active]= ii,item[pp]= iii;
oo,pos(ii)= active,pos(iii)= pp;
}
}
if(ss> 0){
o,nnp= set[ii+ss].i;
o,size(ii)= ss;
oo,set[ii+ss].i= nn,set[p].i= nnp;
oo,nd[nn].loc= ii+ss,nd[nnp].loc= p;
updates++;
}
}
}

/*:43*/
#line 934 "ssmcc.w"
;
}
o,p= pos(ii);
o,iii= item[--active];
oo,item[active]= ii,item[p]= iii;
oo,pos(ii)= active,pos(iii)= p;
}else{
o,ss= size(ii)-1;
if(oo,ss<bound(ii)-slack(ii)){
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
fprintf(stderr," can't cover");
print_item_name(item[ii],stderr);
fprintf(stderr,"\n");
}
tough_itm= ii;
forced= 0;
return 0;
}
if(ss==0){
o,iii= item[--active];
oo,item[active]= ii,item[p]= iii;
oo,pos(ii)= active,pos(iii)= p;
}else{
oo,nnp= set[ii+ss].i,size(ii)= ss;
oo,set[ii+ss].i= opt,set[pp].i= nnp;
oo,nd[opt].loc= ii+ss,nd[nnp].loc= pp;
updates++;
}
}
}

/*:42*/
#line 918 "ssmcc.w"
;
}
return 1;
}

/*:41*//*47:*/
#line 1108 "ssmcc.w"

void print_weights(void){
register int k;
for(k= 0;k<itemlength;k++)if(item[k]<second&&wt(item[k])!=w0){
print_item_name(item[k],stderr);
fprintf(stderr," wt "O".1f\n",wt(item[k]));
}
}

/*:47*//*53:*/
#line 1263 "ssmcc.w"

void print_savestack(int start,int stop){
int k;
for(k= start;k<stop;k++){
print_item_name(savestack[k].l,stderr);
fprintf(stderr,"("O"d), "O"d "O"d\n",
savestack[k].l,savestack[k].s,savestack[k].b);
}
}

/*:53*//*54:*/
#line 1273 "ssmcc.w"

void print_state(void){
register int l,s;
fprintf(stderr,"Current state (level "O"d):\n",level);
for(l= 0;l<level;l++){
if(levelstage[stagelevel[l]]!=l)fprintf(stderr,"~");
print_option(choice[l],stderr,-1);
fprintf(stderr," (of "O"d)\n",deg[l]);
if(l>=show_levels_max){
fprintf(stderr," ...\n");
break;
}
}
fprintf(stderr," "O"lld solutions, "O"lld mems, and max level "O"d so far.\n",
count,mems,maxl);
}

/*:54*//*55:*/
#line 1307 "ssmcc.w"

void print_progress(void){
register int l,ll,k,d,c,p,ds= 0;
register double f,fd;
fprintf(stderr," after "O"lld mems: "O"lld sols,",mems,count);
for(f= 0.0,fd= 1.0,l= 0;l<level;l++){
if(l<show_levels_max)
fprintf(stderr," "O"s"O"d",levelstage[stagelevel[l]]==l?"":"~",deg[l]);
if(levelstage[stagelevel[l]]==l){
for(k= 1,d= deg[l],ll= l-1;
ll>=0&&stagelevel[ll]==stagelevel[l];k++,d++,ll--);
fd*= d,f+= (k-1)/fd;
}
if(l>=show_levels_max&&!ds)ds= 1,fprintf(stderr,"...");
}
#line 314 "aw_ssm.ch"
fprintf(stderr," "O".12lf\n",f+0.5/fd);
#line 1323 "ssmcc.w"
}

/*:55*/
#line 67 "ssmcc.w"
;
int main(int argc,char*argv[]){
register int c,cc,i,j,k,p,pp,q,r,s,t,cur_choice,cur_node,best_itm,istage,score,best_s,best_l;
#line 36 "aw_ssm.ch"
/*4:*/
#line 178 "ssmcc.w"

for(j= argc-1,k= 0;j;j--)switch(argv[j][0]){
#line 75 "aw_ssm.ch"
case'i':k|= (sscanf(argv[j]+1,""O"d",&print_indices)-1);break;
case'v':k|= (sscanf(argv[j]+1,""O"d",&vbose)-1);break;
case'm':k|= (sscanf(argv[j]+1,""O"d",&spacing)-1);break;
case'I':k|= (sscanf(argv[j]+1,""O"ld",&max_cols)-1);break;
case'M':k|= (sscanf(argv[j]+1,""O"ld",&max_nodes)-1);break;
case's':k|= (sscanf(argv[j]+1,""O"d",&random_seed)-1),randomizing= 1;break;
#line 183 "ssmcc.w"
case'd':k|= (sscanf(argv[j]+1,""O"lld",&delta)-1),thresh= delta;break;
case'c':k|= (sscanf(argv[j]+1,""O"d",&show_choices_max)-1);break;
case'C':k|= (sscanf(argv[j]+1,""O"d",&show_levels_max)-1);break;
case'l':k|= (sscanf(argv[j]+1,""O"d",&show_choices_gap)-1);break;
case't':k|= (sscanf(argv[j]+1,""O"lld",&maxcount)-1);break;
case'T':k|= (sscanf(argv[j]+1,""O"lld",&timeout)-1);break;
case'w':k|= (sscanf(argv[j]+1,""O"f",&dw)-1);break;
case'W':k|= (sscanf(argv[j]+1,""O"f",&dwfactor)-1);break;
case'S':shape_name= argv[j]+1,shape_file= fopen(shape_name,"w");
if(!shape_file)
fprintf(stderr,"Sorry, I can't open file `"O"s' for writing!\n",
shape_name);
break;
default:k= 1;
}
#line 92 "aw_ssm.ch"
if(k){
fprintf(stderr,"Usage: "O"s [v<n>] [m<n>] [s<n>] [d<n>]"
" [c<n>] [C<n>] [l<n>] [t<n>] [T<n>] [w<f>] [W<f>] [S<bar>]"
" [i<0|1>] [I<n>] [M<n>] < foo.dlx\n",
argv[0]);
exit(-1);
}
#if RANDOMIZE
if(randomizing)gb_init_rand(random_seed);
#endif
#line 102 "aw_ssm.ch"

/*:4*/
#line 36 "aw_ssm.ch"
;
/*5:*/
#line 104 "aw_ssm.ch"

if(max_nodes*sizeof(node)> 2147483647){
panic("Too much memory allocated, i.e. parameter M is too large");
}
nd= (node*)malloc(max_nodes*sizeof(node));
item= (int*)malloc(max_cols);
force= (int*)malloc(max_cols);
set= (tetrabyte*)malloc((max_nodes+maxextra*max_cols)*sizeof(tetrabyte));
second= max_cols;

bufsize= 9*max_cols+3;
buf= (char*)malloc(bufsize*sizeof(char));
#line 205 "ssmcc.w"

/*:5*/
#line 37 "aw_ssm.ch"
;
/*28:*/
#line 254 "aw_ssm.ch"

solution_vector= (int*)calloc(options,sizeof(int));

/*:28*/
#line 38 "aw_ssm.ch"

#line 71 "ssmcc.w"
/*17:*/
#line 505 "ssmcc.w"

while(1){

if(!fgets(buf,bufsize,stdin))break;
if(o,buf[p= strlen(buf)-1]!='\n')panic("Input line way too long");
for(p= 0;o,isspace(buf[p]);p++);
#line 213 "aw_ssm.ch"
if(buf[p]=='|'||buf[p]=='%'||!buf[p])continue;
#line 512 "ssmcc.w"
last_itm= 1;
break;
}
if(!last_itm)panic("No items");
for(;o,buf[p];){
o,namebuf.lr.l= namebuf.lr.r= 0;
/*18:*/
#line 532 "ssmcc.w"

if(second==max_cols)istage= 0;else istage= 2;
start_name:for(j= 0;j<8&&(o,!isspace(buf[p+j]));j++){
if(buf[p+j]==':'){
if(istage)panic("Illegal `:' in item name");
/*19:*/
#line 560 "ssmcc.w"

for(q= 0,pp= p;pp<p+j;pp++){
if(buf[pp]<'0'||buf[pp]> '9')panic("Illegal digit in bound spec");
q= 10*q+buf[pp]-'0';
}
p= pp+1;
while(j)namebuf.str[--j]= 0;

/*:19*/
#line 537 "ssmcc.w"
;
r= q,istage= 1;
goto start_name;
}else if(buf[p+j]=='|'){
if(istage> 1)panic("Illegal `|' in item name");
/*19:*/
#line 560 "ssmcc.w"

for(q= 0,pp= p;pp<p+j;pp++){
if(buf[pp]<'0'||buf[pp]> '9')panic("Illegal digit in bound spec");
q= 10*q+buf[pp]-'0';
}
p= pp+1;
while(j)namebuf.str[--j]= 0;

/*:19*/
#line 542 "ssmcc.w"
;
if(q==0)panic("Upper bound is zero");
if(istage==0)r= q;
else if(r> q)panic("Lower bound exceeds upper bound");
istage= 2;
goto start_name;
}
o,namebuf.str[j]= buf[p+j];
}
switch(istage){
case 1:panic("Lower bound without upper bound");
case 0:q= r= 1;
case 2:break;
}
if(j==0)panic("Item name empty");
if(j==8&&!isspace(buf[p+j]))panic("Item name too long");
/*20:*/
#line 568 "ssmcc.w"

for(k= last_itm-1;k;k--){
if(o,lname(k*ipropcount)!=namebuf.lr.l)continue;
if(rname(k*ipropcount)==namebuf.lr.r)break;
}
if(k)panic("Duplicate item name");

/*:20*/
#line 558 "ssmcc.w"
;

/*:18*/
#line 518 "ssmcc.w"
;
#line 220 "aw_ssm.ch"
oo,lname(last_itm*ipropcount)= namebuf.lr.l,
rname(last_itm*ipropcount)= namebuf.lr.r;
add_item(namebuf.str,last_itm*ipropcount);
#line 521 "ssmcc.w"
o,slack(last_itm*ipropcount)= q-r,bound(last_itm*ipropcount)= q;
last_itm++;
if(last_itm> max_cols)panic("Too many items");
for(p+= j+1;o,isspace(buf[p]);p++);
if(buf[p]=='|'){
if(second!=max_cols)panic("Item name line contains | twice");
second= last_itm;
for(p++;o,isspace(buf[p]);p++);
}
}

/*:17*/
#line 71 "ssmcc.w"
;
/*21:*/
#line 579 "ssmcc.w"

while(1){
if(!fgets(buf,bufsize,stdin))break;
if(o,buf[p= strlen(buf)-1]!='\n')panic("Option line too long");
for(p= 0;o,isspace(buf[p]);p++);
if(buf[p]=='|'||!buf[p])continue;
i= last_node;
for(pp= 0;buf[p];){
o,namebuf.lr.l= namebuf.lr.r= 0;
for(j= 0;j<8&&(o,!isspace(buf[p+j]))&&buf[p+j]!=':';j++)
o,namebuf.str[j]= buf[p+j];
if(!j)panic("Empty item name");
if(j==8&&!isspace(buf[p+j])&&buf[p+j]!=':')
panic("Item name too long");
/*22:*/
#line 239 "aw_ssm.ch"

k= find_item(namebuf.str);
if(k<0)panic("Unknown item name");
#line 632 "ssmcc.w"
if(o,pos(k)> i)panic("Duplicate item name in this option");
last_node++;
if(last_node==max_nodes)panic("Too many nodes");
o,t= size(k);
o,nd[last_node].itm= k/ipropcount,nd[last_node].loc= t;
if((k/ipropcount)<second)pp= 1;
o,size(k)= t+1,pos(k)= last_node;

/*:22*/
#line 593 "ssmcc.w"
;
if(buf[p+j]!=':')o,nd[last_node].clr= 0;
else if(k>=second){
if((o,isspace(buf[p+j+1]))||(o,!isspace(buf[p+j+2])))
panic("Color must be a single character");
o,nd[last_node].clr= (unsigned char)buf[p+j+1];
p+= 2;
}else panic("Primary item must be uncolored");
for(p+= j+1;o,isspace(buf[p]);p++);
}
if(!pp){
if(vbose&show_warnings)
fprintf(stderr,"Option ignored (no primary items): "O"s",buf);
while(last_node> i){
/*23:*/
#line 640 "ssmcc.w"

o,k= nd[last_node].itm*ipropcount;
oo,size(k)--,pos(k)= i-1;

/*:23*/
#line 607 "ssmcc.w"
;
last_node--;
}
}else{
o,nd[i].loc= last_node-i;
last_node++;
#line 228 "aw_ssm.ch"
if(last_node==max_nodes)panic("Too many nodes. Count the number of options using 'counttokens.sh' and use the option 'M<n>'");
#line 614 "ssmcc.w"
options++;
o,nd[last_node].itm= i+1-last_node;
nd[last_node].spr= options;
}
}
/*24:*/
#line 644 "ssmcc.w"

active= itemlength= last_itm-1;
for(k= 0,j= primextra;k<itemlength;k++){
oo,item[k]= j,j+= (k+2<second?primextra:secondextra)+size((k+1)*ipropcount);
if(j<item[k]+ipropcount)j= item[k]+ipropcount;
}
setlength= j-ipropcount;
if(second==max_cols)osecond= active,second= j;
else osecond= second-1;

/*:24*/
#line 619 "ssmcc.w"
;
/*25:*/
#line 657 "ssmcc.w"

for(;k;k--){
o,j= item[k-1];
if(k==second)second= j;
oo,size(j)= size(k*ipropcount);
o,pos(j)= k-1;
oo,rname(j)= rname(k*ipropcount),lname(j)= lname(k*ipropcount);
oo,slack(j)= slack(k*ipropcount),bound(j)= bound(k*ipropcount);
if(k<=osecond){
o,wt(j)= w0;
if(size(j)<bound(j)-slack(j))baditem= k;
else if(size(j)==0)force[forced++]= j;
}else if(size(j)==0)force[forced++]= j;
}

/*:25*/
#line 620 "ssmcc.w"
;
/*26:*/
#line 672 "ssmcc.w"

for(k= 1;k<last_node;k++){
if(o,nd[k].itm<0)continue;
o,j= item[nd[k].itm-1];
i= j+nd[k].loc;
o,nd[k].itm= j,nd[k].loc= i;
o,set[i].i= k;
}

#line 247 "aw_ssm.ch"
/*:26*/
#line 621 "ssmcc.w"
;
/*30:*/
#line 691 "ssmcc.w"

while(forced){
o,j= force[--forced];
if(vbose&show_details){
fprintf(stderr,"Deactivating optionless item");
print_item_name(j,stderr);
fprintf(stderr,"\n");
}
oo,i= item[--active],pp= pos(j);
oo,item[active]= j,item[pp]= i;
oo,pos(j)= active,pos(i)= pp;
}

/*:30*/
#line 622 "ssmcc.w"
;

/*:21*/
#line 72 "ssmcc.w"
;
if(vbose&show_basics)
/*31:*/
#line 708 "ssmcc.w"

fprintf(stderr,
"("O"lld options, "O"d+"O"d items, "O"d entries successfully read)\n",
options,osecond,itemlength-osecond,last_node);

/*:31*/
#line 74 "ssmcc.w"
;
if(vbose&show_tots)
/*32:*/
#line 719 "ssmcc.w"

{
fprintf(stderr,"Item totals:");
for(k= 0;k<itemlength;k++){
if(k==second)fprintf(stderr," |");
fprintf(stderr," "O"d",size(item[k]));
}
fprintf(stderr,"\n");
}

#line 269 "aw_ssm.ch"
/*:32*/
#line 76 "ssmcc.w"
;
imems= mems,mems= 0;
if(baditem)/*29:*/
#line 257 "aw_ssm.ch"

#line 682 "ssmcc.w"
{
if(vbose&show_choices){
k= item[baditem-1];
fprintf(stderr,"Item");
print_item_name(k,stderr);
fprintf(stderr," has fewer than "O"d options!\n",bound(k)-slack(k));
}
}

/*:29*/
#line 78 "ssmcc.w"

else{
if(randomizing)/*33:*/
#line 269 "aw_ssm.ch"

#if RANDOMIZE
for(k= active;k> 1;){
mems+= 4,j= gb_unif_rand(k);
k--;
oo,oo,t= item[j],item[j]= item[k],item[k]= t;
oo,pos(t)= k,pos(item[j])= j;
}
#endif
#line 736 "ssmcc.w"

/*:33*/
#line 80 "ssmcc.w"
;
/*36:*/
#line 815 "ssmcc.w"

{
level= stage= 0;
forward:nodes++;
if(vbose&show_profile)profile[stage]++;
if(sanity_checking)sanity();
/*46:*/
#line 1101 "ssmcc.w"

while(forced){
o,best_itm= force[--forced];
if(o,pos(best_itm)>=active)continue;
/*52:*/
#line 1254 "ssmcc.w"

{
if((vbose&show_choices)&&level<show_choices_max)
fprintf(stderr,"(forcing)\n");
o,saved[stage]= saveptr;
score= 1;
goto advance;
}

/*:52*/
#line 1105 "ssmcc.w"
;
}

/*:46*/
#line 821 "ssmcc.w"
;
/*38:*/
#line 866 "ssmcc.w"

if(delta&&(mems>=thresh)){
thresh+= delta;
if(vbose&show_full_state)print_state();
else print_progress();
}
if(mems>=timeout){
fprintf(stderr,"TIMEOUT!\n");goto done;
}

/*:38*/
#line 822 "ssmcc.w"
;
/*48:*/
#line 1159 "ssmcc.w"

{
score= inf_size,tmems= mems;
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap)
fprintf(stderr,"Level "O"d:",level);
for(k= 0;k<active;k++)if(o,item[k]<second){
o,s= slack(item[k]);
if(o,s> bound(item[k]))s= bound(item[k]);
o,t= size(item[k])+s-bound(item[k])+1;
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
print_item_name(item[k],stderr);
if(bound(item[k])!=1||s!=0){
fprintf(stderr,"("O"d:"O"d,"O"d)",
bound(item[k])-s,bound(item[k]),t);
}else fprintf(stderr,"("O"d)",t);
}
if(t==1)
for(i= bound(item[k])-slack(item[k]);i> 0;i--)o,force[forced++]= item[k];
else if(t<=score&&(t<score||
(s<=best_s&&(s<best_s||
(size(item[k])>=best_l&&(size(item[k])> best_l||
(item[k]<best_itm)))))))
score= t,best_itm= item[k],best_s= s,best_l= size(item[k]);
}
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
if(score==inf_size)fprintf(stderr," solution\n");
else if(forced){
fprintf(stderr," found "O"d forced:",forced);
for(i= 0;i<forced;i++)print_item_name(force[i],stderr);
fprintf(stderr,"\n");
}else{
fprintf(stderr," branching on");
print_item_name(best_itm,stderr);
fprintf(stderr,"("O"d)\n",score);
}
}
if(score> maxdeg&&score<inf_size&&!forced)maxdeg= score;
if(shape_file){
if(score==inf_size)fprintf(shape_file,"sol\n");
else{
fprintf(shape_file,""O"d",score);
print_item_name(best_itm,shape_file);
fprintf(shape_file,"\n");
}
fflush(shape_file);
}
cmems+= mems-tmems;
}

/*:48*/
#line 824 "ssmcc.w"
;
if(forced){
o,best_itm= force[--forced];
/*52:*/
#line 1254 "ssmcc.w"

{
if((vbose&show_choices)&&level<show_choices_max)
fprintf(stderr,"(forcing)\n");
o,saved[stage]= saveptr;
score= 1;
goto advance;
}

/*:52*/
#line 827 "ssmcc.w"
;
}
if(score==inf_size)/*49:*/
#line 1211 "ssmcc.w"

{
count++;
#line 287 "aw_ssm.ch"
#if DISCRETA_OUTPUT
if(spacing&&(count mod spacing==0)){
if(!print_indices){
for(k= 0;k<options;k++){
solution_vector[k]= 0;
}
}
for(k= 0;k<stage;k++)print_option_discreta(choice[levelstage[k]],stdout);
if(!print_indices){
for(k= 0;k<options;k++){
fprintf(stdout,"%d",solution_vector[k]);
}
}
fprintf(stdout,"\n");
}
#else
#line 303 "aw_ssm.ch"
 if(spacing&&(count mod spacing==0)){
printf(""O"lld:\n",count);
for(k= 0;k<stage;k++)print_option(choice[levelstage[k]],stdout,0);
fflush(stdout);
}
#endif
#line 1219 "ssmcc.w"
 if(count>=maxcount)goto done;
goto backup;
}

/*:49*/
#line 829 "ssmcc.w"
;
/*50:*/
#line 1223 "ssmcc.w"

o,saved[stage]= saveptr;
if(saveptr+active> maxsaveptr){
if(saveptr+active>=savesize){
fprintf(stderr,"Stack overflow (savesize="O"d)!\n",savesize);
exit(-5);
}
maxsaveptr= saveptr+active;
}
for(p= 0;p<active;p++){
mems+= 4,savestack[saveptr+p].l= item[p],savestack[saveptr+p].s= size(item[p]);
if(item[p]<second)
o,savestack[saveptr+p].b= bound(item[p]);
}
saveptr+= active;

/*:50*/
#line 830 "ssmcc.w"
;
advance:oo,choice[level]= cur_choice= set[best_itm].i;
o,deg[level]= score;
if(!include_option(cur_choice))goto tryagain;
/*39:*/
#line 876 "ssmcc.w"

if(++stage> maxs){
if(stage>=max_stage){
fprintf(stderr,"Too many stages!\n");
exit(-40);
}
maxs= stage;
}

/*:39*/
#line 834 "ssmcc.w"
;/*40:*/
#line 885 "ssmcc.w"

if(++level> maxl){
if(level>=max_level){
fprintf(stderr,"Too many levels!\n");
exit(-4);
}
maxl= level;
}
oo,stagelevel[level]= stage,levelstage[stage]= level;

/*:40*/
#line 834 "ssmcc.w"
;
goto forward;
tryagain:if(score==1)goto prebackup;
if(vbose&show_choices)
fprintf(stderr,"Backtracking in stage "O"d\n",stage);
goto purgeit;
prebackup:o,saveptr= saved[stage];
backup:if(--stage<0)goto done;
if(vbose&show_choices)
fprintf(stderr,"Backtracking to stage "O"d\n",stage);
o,level= levelstage[stage];
purgeit:if(o,deg[level]==1)goto prebackup;
/*51:*/
#line 1239 "ssmcc.w"

o,active= saveptr-saved[stage];
saveptr= saved[stage];
for(p= 0;p<active;p++)
{
ooo,size(savestack[saveptr+p].l)= savestack[saveptr+p].s;
if(savestack[saveptr+p].l<second)
o,bound(savestack[saveptr+p].l)= savestack[saveptr+p].b;
}

/*:51*/
#line 846 "ssmcc.w"
;
o,cur_choice= choice[level];
/*44:*/
#line 1014 "ssmcc.w"

{
register int ii,iii,ss,p,nnp;
for(;o,nd[cur_choice-1].itm> 0;cur_choice--);
for(;o,(ii= nd[cur_choice].itm)> 0;cur_choice++){
p= nd[cur_choice].loc;
if(p>=second&&(o,pos(ii))>=active)continue;
o,ss= size(ii)-1;
if(p<second){
if(oo,ss<bound(ii)-slack(ii)){
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
fprintf(stderr," can't cover");
print_item_name(item[ii],stderr);
fprintf(stderr,"\n");
}
goto prebackup;
}
if(ss==0){
o,iii= item[--active];
o,pp= pos(ii);
if(vbose&show_details){
fprintf(stderr,"Null move, deactivating");
print_item_name(ii,stderr);
fprintf(stderr,"\n");
}
oo,item[active]= ii,item[pp]= iii;
oo,pos(ii)= active,pos(iii)= pp;
}
}
if(ss> 0){
oo,nnp= set[ii+ss].i,size(ii)= ss;
oo,set[ii+ss].i= cur_choice,set[p].i= nnp;
oo,nd[cur_choice].loc= ii+ss,nd[nnp].loc= p;
updates++;
}
}
}

/*:44*/
#line 848 "ssmcc.w"
;
/*40:*/
#line 885 "ssmcc.w"

if(++level> maxl){
if(level>=max_level){
fprintf(stderr,"Too many levels!\n");
exit(-4);
}
maxl= level;
}
oo,stagelevel[level]= stage,levelstage[stage]= level;

/*:40*/
#line 849 "ssmcc.w"
;
goto forward;
}

/*:36*/
#line 81 "ssmcc.w"
;
}
done:if(vbose&show_profile)/*56:*/
#line 1325 "ssmcc.w"

{
fprintf(stderr,"Profile:\n");
for(k= 0;k<=maxs;k++)
fprintf(stderr,""O"3d: "O"lld\n",
k,profile[k]);
}

/*:56*/
#line 83 "ssmcc.w"
;
if(vbose&show_final_weights){
fprintf(stderr,"Final weights:\n");
print_weights();
}
if(vbose&show_max_deg)
fprintf(stderr,"The maximum best_itm size was "O"d.\n",maxdeg);
if(vbose&show_basics){
fprintf(stderr,"Altogether "O"llu solution"O"s, "O"llu+"O"llu mems,",
count,count==1?"":"s",imems,mems);
bytes= (itemlength+setlength)*sizeof(int)+last_node*sizeof(node)
+2*maxl*sizeof(int)+maxsaveptr*sizeof(threeints);
fprintf(stderr," "O"llu updates, "O"llu bytes, "O"llu nodes,",
updates,bytes,nodes);
fprintf(stderr," ccost "O"lld%%.\n",
mems?(200*cmems+mems)/(2*mems):0);
}
if(sanity_checking)fprintf(stderr,"sanity_checking was on!\n");
/*6:*/
#line 206 "ssmcc.w"

if(shape_file)fclose(shape_file);

/*:6*/
#line 101 "ssmcc.w"
;
}

/*:2*/
