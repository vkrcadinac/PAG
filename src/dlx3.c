#define o mems++
#define oo mems+= 2
#define ooo mems+= 3
#define O "%"
#define mod % \

#define max_level 100000
#define DISCRETA_OUTPUT 1
#define RANDOMIZE 0 \

#define show_basics 1
#define show_choices 2
#define show_details 4
#define show_profile 128
#define show_full_state 256
#define show_tots 512
#define show_warnings 1024 \

#define len itm
#define aux color \

#define root 0 \

#define sanity_checking 0 \

#define panic(m) {fprintf(stderr,""O"s!\n"O"d: "O".99s\n",m,p,buf) ;exit(-666) ;} \

#define infty 0x7fffffff \

/*2:*/
#line 89 "dlx3.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <ctype.h> 
#line 27 "aw3.ch"
#if RANDOMIZE
#include "gb_flip.h"
#endif
#line 30 "aw3.ch"
#include "uthash.h"
#line 95 "dlx3.w"
typedef unsigned int uint;
typedef unsigned long long ullng;
/*8:*/
#line 289 "dlx3.w"

typedef struct node_struct{
int up,down;
int itm;
int color;
}node;

/*:8*//*9:*/
#line 322 "dlx3.w"

typedef struct itm_struct{
char name[8];
int prev,next;
int bound,slack;
}item;

/*:9*//*11:*/
#line 149 "aw3.ch"

typedef struct{
char*name;
int pos;
UT_hash_handle hh;
}item_hash;

item_hash*items_hash_table= NULL;

/*:11*/
#line 97 "dlx3.w"
;
/*3:*/
#line 164 "dlx3.w"

#line 68 "aw3.ch"
long max_cols= 1000000;
long max_nodes= 10000000;
#if RANDOMIZE
int random_seed= 0;
int randomizing;
#endif
#line 167 "dlx3.w"
 int vbose= show_basics+show_warnings;
#line 80 "aw3.ch"
int spacing;
int show_choices_max= 1000000;
#line 170 "dlx3.w"
int show_choices_gap= 1000000;

int show_levels_max= 1000000;
#line 88 "aw3.ch"
int maxl= 0;
int print_indices= 1;
#line 175 "dlx3.w"
ullng count;
ullng options;
ullng imems,mems;
ullng updates;
ullng cleansings;
ullng bytes;
ullng nodes;
ullng thresh= 0;
ullng delta= 0;
ullng maxcount= 0xffffffffffffffff;
ullng timeout= 0x1fffffffffffffff;
FILE*shape_file;
char*shape_name;

/*:3*//*10:*/
#line 329 "dlx3.w"

#line 142 "aw3.ch"
node*nd;
int last_node;
item*cl;
int second;
int bufsize;
char*buf;

/*:10*//*26:*/
#line 270 "aw3.ch"

#if DISCRETA_OUTPUT
int*solution_vector;
int*selectedcolumns;
int overallrows;
char dummy[16];
#endif
#line 277 "aw3.ch"

/*:26*//*34:*/
#line 667 "dlx3.w"

int level;
int choice[max_level];
ullng profile[max_level];
int first_tweak[max_level];
int scor[max_level];

/*:34*/
#line 98 "dlx3.w"
;
/*12:*/
#line 158 "aw3.ch"

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
#line 334 "dlx3.w"
int last_itm;

/*:12*//*14:*/
#line 347 "dlx3.w"

void print_option(int p,FILE*stream,int head,int score){
register int k,q;
if((p<last_itm&&p==head)||(head>=last_itm&&p==nd[head].itm))
fprintf(stream," null "O".8s",cl[p].name);
else{
if(p<last_itm||p>=last_node||nd[p].itm<=0){
fprintf(stderr,"Illegal option "O"d!\n",p);
return;
}
for(q= p;;){
fprintf(stream," "O".8s",cl[nd[q].itm].name);
if(nd[q].color)
fprintf(stream,":"O"c",nd[q].color> 0?nd[q].color:nd[nd[q].itm].color);
q++;
#line 182 "aw3.ch"
if(nd[q].itm<=0)fprintf(stream," _%d_ ",-nd[q].itm);
if(nd[q].itm<=0)q= nd[q].up;

#line 364 "dlx3.w"
if(q==p)break;
}
}
for(q= head,k= 1;q!=p;k++){
if(p>=last_itm&&q==nd[p].itm){
fprintf(stream," (?)\n");return;
}else q= nd[q].down;
}
fprintf(stream," ("O"d of "O"d)\n",k,score);
}

#line 192 "aw3.ch"
void prow(int p){
print_option(p,stderr,nd[nd[p].itm].down,nd[nd[p].itm].len);
}

/*:14*//*15:*/
#line 197 "aw3.ch"

int get_option_number(int p){
register int q;
#if 0
if(p<last_itm||p>=last_node||nd[p].itm<=0){

fprintf(stderr,"Illegal option %d %d %d!\n",p,nd[p].itm,last_itm);
return-1;
}
#endif
for(q= p;;){
q++;
if(nd[q].itm<=0)return-nd[q].itm;
if(q==p)break;
}
return-1;
}
#line 378 "dlx3.w"

/*:15*//*16:*/
#line 381 "dlx3.w"

void print_itm(int c){
register int p;
if(c<root||c>=last_itm){
fprintf(stderr,"Illegal item "O"d!\n",c);
return;
}
fprintf(stderr,"Item "O".8s",cl[c].name);
if(c<second){
if(cl[c].slack||cl[c].bound!=1)
fprintf(stderr," ("O"d,"O"d)",cl[c].bound-cl[c].slack,cl[c].bound);
fprintf(stderr,", length "O"d, neighbors "O".8s and "O".8s:\n",
nd[c].len,cl[cl[c].prev].name,cl[cl[c].next].name);
}else fprintf(stderr,", length "O"d:\n",nd[c].len);
for(p= nd[c].down;p>=last_itm;p= nd[p].down)prow(p);
}

/*:16*//*17:*/
#line 403 "dlx3.w"

void sanity(void){
register int k,p,q,pp,qq,t;
for(q= root,p= cl[q].next;;q= p,p= cl[p].next){
if(cl[p].prev!=q)fprintf(stderr,"Bad prev field at itm "O".8s!\n",
cl[p].name);
if(p==root)break;
/*18:*/
#line 414 "dlx3.w"

for(qq= p,pp= nd[qq].down,k= 0;;qq= pp,pp= nd[pp].down,k++){
if(nd[pp].up!=qq)fprintf(stderr,"Bad up field at node "O"d!\n",pp);
if(pp==p)break;
if(nd[pp].itm!=p)fprintf(stderr,"Bad itm field at node "O"d!\n",pp);
}
if(nd[p].len!=k)fprintf(stderr,"Bad len field in item "O".8s!\n",
cl[p].name);

/*:18*/
#line 410 "dlx3.w"
;
}
}

/*:17*//*41:*/
#line 750 "dlx3.w"

void cover(int c,int deact){
register int cc,l,r,rr,nn,uu,dd,t;
if(deact){
o,l= cl[c].prev,r= cl[c].next;
oo,cl[l].next= r,cl[r].prev= l;
}
updates++;
for(o,rr= nd[c].down;rr>=last_itm;o,rr= nd[rr].down)
for(nn= rr+1;nn!=rr;){
if(o,nd[nn].color>=0){
o,uu= nd[nn].up,dd= nd[nn].down;
cc= nd[nn].itm;
if(cc<=0){
nn= uu;
continue;
}
oo,nd[uu].down= dd,nd[dd].up= uu;
updates++;
o,t= nd[cc].len-1;
o,nd[cc].len= t;
}
nn++;
}
}

/*:41*//*42:*/
#line 785 "dlx3.w"

void uncover(int c,int react){
register int cc,l,r,rr,nn,uu,dd,t;
for(o,rr= nd[c].down;rr>=last_itm;o,rr= nd[rr].down)
for(nn= rr+1;nn!=rr;){
if(o,nd[nn].color>=0){
o,uu= nd[nn].up,dd= nd[nn].down;
cc= nd[nn].itm;
if(cc<=0){
nn= uu;
continue;
}
oo,nd[uu].down= nd[dd].up= nn;
o,t= nd[cc].len+1;
o,nd[cc].len= t;
}
nn++;
}
if(react){
o,l= cl[c].prev,r= cl[c].next;
oo,cl[l].next= cl[r].prev= c;
}
}

/*:42*//*45:*/
#line 849 "dlx3.w"

void purify(int p){
register int cc,rr,nn,uu,dd,t,x;
o,cc= nd[p].itm,x= nd[p].color;
nd[cc].color= x;
cleansings++;
for(o,rr= nd[cc].down;rr>=last_itm;o,rr= nd[rr].down){
if(o,nd[rr].color!=x){
for(nn= rr+1;nn!=rr;){
o,uu= nd[nn].up,dd= nd[nn].down;
o,cc= nd[nn].itm;
if(cc<=0){
nn= uu;continue;
}
if(nd[nn].color>=0){
oo,nd[uu].down= dd,nd[dd].up= uu;
updates++;
o,t= nd[cc].len-1;
o,nd[cc].len= t;
}
nn++;
}
}else if(rr!=p)cleansings++,o,nd[rr].color= -1;
}
}

/*:45*//*46:*/
#line 878 "dlx3.w"

void unpurify(int p){
register int cc,rr,nn,uu,dd,t,x;
o,cc= nd[p].itm,x= nd[p].color;
for(o,rr= nd[cc].up;rr>=last_itm;o,rr= nd[rr].up){
if(o,nd[rr].color<0)o,nd[rr].color= x;
else if(rr!=p){
for(nn= rr-1;nn!=rr;){
o,uu= nd[nn].up,dd= nd[nn].down;
o,cc= nd[nn].itm;
if(cc<=0){
nn= dd;continue;
}
if(nd[nn].color>=0){
oo,nd[uu].down= nd[dd].up= nn;
o,t= nd[cc].len+1;
o,nd[cc].len= t;
}
nn--;
}
}
}
}

/*:46*//*47:*/
#line 911 "dlx3.w"

void tweak(int n,int block){
register int cc,nn,uu,dd,t;
for(nn= (block?n+1:n);;){
if(o,nd[nn].color>=0){
o,uu= nd[nn].up,dd= nd[nn].down;
cc= nd[nn].itm;
if(cc<=0){
nn= uu;
continue;
}
oo,nd[uu].down= dd,nd[dd].up= uu;
updates++;
o,t= nd[cc].len-1;
o,nd[cc].len= t;
}
if(nn==n)break;
nn++;
}
}

/*:47*//*48:*/
#line 947 "dlx3.w"

void untweak(int c,int x,int unblock){
register int z,cc,nn,uu,dd,t,k,rr,qq;
oo,z= nd[c].down,nd[c].down= x;
for(rr= x,k= 0,qq= c;rr!=z;o,qq= rr,rr= nd[rr].down){
o,nd[rr].up= qq,k++;
if(unblock)for(nn= rr+1;nn!=rr;){
if(o,nd[nn].color>=0){
o,uu= nd[nn].up,dd= nd[nn].down;
cc= nd[nn].itm;
if(cc<=0){
nn= uu;
continue;
}
oo,nd[uu].down= nd[dd].up= nn;
o,t= nd[cc].len+1;
o,nd[cc].len= t;
}
nn++;
}
}
o,nd[rr].up= qq;
oo,nd[c].len+= k;
if(!unblock)uncover(c,0);
}

/*:48*//*54:*/
#line 1071 "dlx3.w"

void print_state(void){
register int l,p,c,q;
fprintf(stderr,"Current state (level "O"d):\n",level);
for(l= 0;l<level;l++){
p= choice[l];
c= (p<last_itm?p:nd[p].itm);
if(!first_tweak[l])print_option(p,stderr,nd[c].down,scor[l]);
else print_option(p,stderr,first_tweak[l],scor[l]);
if(l>=show_levels_max){
fprintf(stderr," ...\n");
break;
}
}
fprintf(stderr," "O"lld sols, "O"lld mems, and max level "O"d so far.\n",
count,mems,maxl);
}

/*:54*//*55:*/
#line 1109 "dlx3.w"

void print_progress(void){
register int l,k,d,c,p;
register double f,fd;
#line 501 "aw3.ch"
fprintf(stderr," after %llu updates and "O"lld mems: "O"lld sols,",updates,mems,count);
#line 1114 "dlx3.w"
for(f= 0.0,fd= 1.0,l= 0;l<level;l++){
p= choice[l],d= scor[l];
c= (p<last_itm?p:nd[p].itm);
if(!first_tweak[l])p= nd[c].down;
else p= first_tweak[l];
for(k= 1;p!=choice[l];k++,p= nd[p].down);
fd*= d,f+= (k-1)/fd;
fprintf(stderr," "O"c"O"c",
k<10?'0'+k:k<36?'a'+k-10:k<62?'A'+k-36:'*',
d<10?'0'+d:d<36?'a'+d-10:d<62?'A'+d-36:'*');
if(l>=show_levels_max){
fprintf(stderr,"...");
break;
}
}
#line 507 "aw3.ch"
fprintf(stderr," "O".12lf\n",f+0.5/fd);
#line 1130 "dlx3.w"
}

/*:55*/
#line 99 "dlx3.w"
;
#line 36 "aw3.ch"
int main(int argc,char*argv[]){
#line 101 "dlx3.w"
register int cc,i,j,k,p,pp,q,r,s,t,
cur_node,best_itm,stage,score,best_s,best_l;
#line 42 "aw3.ch"
/*4:*/
#line 192 "dlx3.w"

for(j= argc-1,k= 0;j;j--)switch(argv[j][0]){
#line 97 "aw3.ch"
case'i':k|= (sscanf(argv[j]+1,""O"d",&print_indices)-1);break;
case'v':k|= (sscanf(argv[j]+1,""O"d",&vbose)-1);break;
case'm':k|= (sscanf(argv[j]+1,""O"d",&spacing)-1);break;
case'I':k|= (sscanf(argv[j]+1,""O"ld",&max_cols)-1);break;
case'M':k|= (sscanf(argv[j]+1,""O"ld",&max_nodes)-1);break;
#if RANDOMIZE
case's':k|= (sscanf(argv[j]+1,""O"d",&random_seed)-1),randomizing= 1;break;
#endif
#line 197 "dlx3.w"
 case'd':k|= (sscanf(argv[j]+1,""O"lld",&delta)-1),thresh= delta;break;
case'c':k|= (sscanf(argv[j]+1,""O"d",&show_choices_max)-1);break;
case'C':k|= (sscanf(argv[j]+1,""O"d",&show_levels_max)-1);break;
case'l':k|= (sscanf(argv[j]+1,""O"d",&show_choices_gap)-1);break;
case't':k|= (sscanf(argv[j]+1,""O"lld",&maxcount)-1);break;
case'T':k|= (sscanf(argv[j]+1,""O"lld",&timeout)-1);break;
case'S':shape_name= argv[j]+1,shape_file= fopen(shape_name,"w");
if(!shape_file)
fprintf(stderr,"Sorry, I can't open file `"O"s' for writing!\n",
shape_name);
break;
default:k= 1;
}
#line 116 "aw3.ch"
if(k){
fprintf(stderr,"Usage: "O"s [v<n>] [m<n>] [s<n>] [d<n>]"
" [c<n>] [C<n>] [l<n>] [t<n>] [T<n>] [S<bar>] [i<0|1>] [I<n>] [M<n>] < foo.dlx\n",
argv[0]);
exit(-1);
}
#if RANDOMIZE
if(randomizing)gb_init_rand(random_seed);
#endif
#line 125 "aw3.ch"

/*:4*/
#line 42 "aw3.ch"
;
/*5:*/
#line 127 "aw3.ch"

cl= (item*)malloc((max_cols+2)*sizeof(item));
second= max_cols;
max_nodes= (max_nodes<=2*max_cols)?2*max_cols+100000:max_nodes;
nd= (node*)malloc(max_nodes*sizeof(node));
bufsize= 9*max_cols+3;
buf= (char*)malloc(bufsize*sizeof(char));
#line 217 "dlx3.w"

/*:5*/
#line 43 "aw3.ch"
;
#line 104 "dlx3.w"
/*19:*/
#line 428 "dlx3.w"

if(max_nodes<=2*max_cols){
#line 219 "aw3.ch"
fprintf(stderr,"Restart me: max_nodes must exceed twice max_cols %ld!\n",max_cols);
#line 431 "dlx3.w"
exit(-999);
}
while(1){
if(!fgets(buf,bufsize,stdin))break;
if(o,buf[p= strlen(buf)-1]!='\n')panic("Input line way too long");
for(p= 0;o,isspace(buf[p]);p++);
if(buf[p]=='|'||!buf[p])continue;
last_itm= 1;
break;
}
if(!last_itm)panic("No items");
for(;o,buf[p];){
/*20:*/
#line 457 "dlx3.w"

if(second==max_cols)stage= 0;else stage= 2;
start_name:for(j= 0;j<8&&(o,!isspace(buf[p+j]));j++){
if(buf[p+j]==':'){
if(stage)panic("Illegal `:' in item name");
/*21:*/
#line 485 "dlx3.w"

for(q= 0,pp= p;pp<p+j;pp++){
if(buf[pp]<'0'||buf[pp]> '9')panic("Illegal digit in bound spec");
q= 10*q+buf[pp]-'0';
}
p= pp+1;
while(j)cl[last_itm].name[--j]= 0;

/*:21*/
#line 462 "dlx3.w"
;
r= q,stage= 1;
goto start_name;
}else if(buf[p+j]=='|'){
if(stage> 1)panic("Illegal `|' in item name");
/*21:*/
#line 485 "dlx3.w"

for(q= 0,pp= p;pp<p+j;pp++){
if(buf[pp]<'0'||buf[pp]> '9')panic("Illegal digit in bound spec");
q= 10*q+buf[pp]-'0';
}
p= pp+1;
while(j)cl[last_itm].name[--j]= 0;

/*:21*/
#line 467 "dlx3.w"
;
if(q==0)panic("Upper bound is zero");
if(stage==0)r= q;
else if(r> q)panic("Lower bound exceeds upper bound");
stage= 2;
goto start_name;
}
o,cl[last_itm].name[j]= buf[p+j];
}
#line 225 "aw3.ch"
add_item(cl[last_itm].name,last_itm);
switch(stage){
#line 477 "dlx3.w"
case 1:panic("Lower bound without upper bound");
case 0:q= r= 1;
case 2:break;
}
if(j==0)panic("Item name empty");
if(j==8&&!isspace(buf[p+j]))panic("Item name too long");
/*22:*/
#line 493 "dlx3.w"

for(k= 1;o,strncmp(cl[k].name,cl[last_itm].name,8);k++);
if(k<last_itm)panic("Duplicate item name");

/*:22*/
#line 483 "dlx3.w"
;

/*:20*/
#line 443 "dlx3.w"
;
/*23:*/
#line 497 "dlx3.w"

if(last_itm> max_cols)panic("Too many items");
if(second==max_cols)
oo,cl[last_itm-1].next= last_itm,cl[last_itm].prev= last_itm-1,
o,cl[last_itm].bound= q,cl[last_itm].slack= q-r;
else o,cl[last_itm].next= cl[last_itm].prev= last_itm;
o,nd[last_itm].up= nd[last_itm].down= last_itm;

last_itm++;

/*:23*/
#line 444 "dlx3.w"
;
for(p+= j+1;o,isspace(buf[p]);p++);
if(buf[p]=='|'){
if(second!=max_cols)panic("Item name line contains | twice");
second= last_itm;
for(p++;o,isspace(buf[p]);p++);
}
}
if(second==max_cols)second= last_itm;
o,cl[root].prev= second-1;
last_node= last_itm;
o,nd[last_node].itm= 0;

/*:19*/
#line 104 "dlx3.w"
;
/*24:*/
#line 510 "dlx3.w"

while(1){
#line 232 "aw3.ch"
if(!fgets(buf,bufsize,stdin)||strstr(buf,"SELECTEDCOLUMNS")!=NULL)break;
#line 513 "dlx3.w"
if(o,buf[p= strlen(buf)-1]!='\n')panic("Option line too long");
for(p= 0;o,isspace(buf[p]);p++);
if(buf[p]=='|'||!buf[p])continue;
i= last_node;
for(pp= 0;buf[p];){
for(j= 0;j<8&&(o,!isspace(buf[p+j]))&&buf[p+j]!=':';j++)
o,cl[last_itm].name[j]= buf[p+j];
if(!j)panic("Empty item name");
if(j==8&&!isspace(buf[p+j])&&buf[p+j]!=':')
panic("Item name too long");
if(j<8)o,cl[last_itm].name[j]= '\0';
/*28:*/
#line 281 "aw3.ch"

#line 287 "aw3.ch"
k= find_item(cl[last_itm].name);
#line 553 "dlx3.w"
if(k==last_itm)panic("Unknown item name");
if(o,nd[k].aux>=i)panic("Duplicate item name in this option");
last_node++;
if(last_node==max_nodes)panic("Too many nodes");
o,nd[last_node].itm= k;
if(k<second)pp= 1;
o,t= nd[k].len+1;
/*29:*/
#line 573 "dlx3.w"

o,nd[k].len= t;
nd[k].aux= last_node;
#line 302 "aw3.ch"
#if RANDOMIZE
if(!randomizing){
o,r= nd[k].up;
ooo,nd[r].down= nd[k].up= last_node,nd[last_node].up= r,nd[last_node].down= k;
}else{
mems+= 4,t= gb_unif_rand(t);
for(o,r= k;t;o,r= nd[r].down,t--);
ooo,q= nd[r].up,nd[q].down= nd[r].up= last_node;
o,nd[last_node].up= q,nd[last_node].down= r;
}
#else
#line 313 "aw3.ch"
 o,r= nd[k].up;
ooo,nd[r].down= nd[k].up= last_node,nd[last_node].up= r,nd[last_node].down= k;
#endif
#line 585 "dlx3.w"

/*:29*/
#line 560 "dlx3.w"
;

/*:28*/
#line 524 "dlx3.w"
;
if(buf[p+j]!=':')o,nd[last_node].color= 0;
else if(k>=second){
if((o,isspace(buf[p+j+1]))||(o,!isspace(buf[p+j+2])))
panic("Color must be a single character");
o,nd[last_node].color= buf[p+j+1];
p+= 2;
}else panic("Primary item must be uncolored");
for(p+= j+1;o,isspace(buf[p]);p++);
}
if(!pp){
if(vbose&show_warnings)
fprintf(stderr,"Option ignored (no primary items): "O"s",buf);
while(last_node> i){
/*30:*/
#line 586 "dlx3.w"

o,k= nd[last_node].itm;
oo,nd[k].len--,nd[k].aux= i-1;
o,q= nd[last_node].up,r= nd[last_node].down;
oo,nd[q].down= r,nd[r].up= q;

#line 324 "aw3.ch"
/*:30*/
#line 538 "dlx3.w"
;
last_node--;
}
}else{
o,nd[i].down= last_node;
last_node++;
#line 238 "aw3.ch"
if(last_node==max_nodes){
panic("Too many nodes. Count the number of options using 'counttokens.sh' and use the option 'M<n>'");
}
#line 545 "dlx3.w"
options++;
o,nd[last_node].up= i+1;
o,nd[last_node].itm= -options;
}
}

#line 246 "aw3.ch"
/*25:*/
#line 249 "aw3.ch"

#if DISCRETA_OUTPUT
if(strstr(buf,"SELECTEDCOLUMNS")!=NULL){
if(sscanf(buf,"%s %d",dummy,&overallrows)!=2){
panic("Input of size of selection vector failed");
}
}else{
overallrows= options;
}
selectedcolumns= (int*)calloc(overallrows,sizeof(int));
if(strstr(buf,"SELECTEDCOLUMNS")!=NULL){
for(i= 0;i<overallrows;i++)
if(scanf("%d\n",&(selectedcolumns[i]))!=1)
panic("Input of selection vector failed");
}else{
for(i= 0;i<overallrows;i++)selectedcolumns[i]= 1;
}

/*27:*/
#line 279 "aw3.ch"

solution_vector= (int*)calloc(options,sizeof(int));
/*:27*/
#line 267 "aw3.ch"
;
#endif
#line 269 "aw3.ch"

/*:25*/
#line 246 "aw3.ch"
;

/*:24*/
#line 105 "dlx3.w"
;
if(vbose&show_basics)
/*31:*/
#line 324 "aw3.ch"

fprintf(stderr,
"("O"lld options, "O"d+"O"d items, "O"d entries successfully read)\n",
options,second-1,last_itm-second,last_node-last_itm);
fflush(stderr);
#line 596 "dlx3.w"

/*:31*/
#line 107 "dlx3.w"
;
if(vbose&show_tots)
/*32:*/
#line 601 "dlx3.w"

{
fprintf(stderr,"Item totals:");
for(k= 1;k<last_itm;k++){
if(k==second)fprintf(stderr," |");
fprintf(stderr," "O"d",nd[k].len);
}
fprintf(stderr,"\n");
}

/*:32*/
#line 109 "dlx3.w"
;
imems= mems,mems= 0;
/*33:*/
#line 635 "dlx3.w"

level= 0;
forward:nodes++;
if(vbose&show_profile)profile[level]++;
if(sanity_checking)sanity();
/*35:*/
#line 674 "dlx3.w"

if(delta&&(mems>=thresh)){
thresh+= delta;
if(vbose&show_full_state)print_state();
else print_progress();
}
if(mems>=timeout){
fprintf(stderr,"TIMEOUT!\n");goto done;
}

/*:35*/
#line 640 "dlx3.w"
;
/*49:*/
#line 363 "aw3.ch"

score= infty;
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap)
fprintf(stderr,"Level "O"d:",level);
for(o,k= cl[root].next;k!=root;o,k= cl[k].next){
o,s= cl[k].slack;if(s> cl[k].bound)s= cl[k].bound;
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
if(cl[k].bound!=1||s!=0)fprintf(stderr," "O".8s("O"d:"O"d,"O"d)",
cl[k].name,cl[k].bound-s,cl[k].bound,
nd[k].len+s-cl[k].bound+1);
else fprintf(stderr," "O".8s("O"d)",cl[k].name,nd[k].len);
}
t= nd[k].len+s-cl[k].bound+1;

#if 0
if(t<=score&&t> 1&&(o,cl[k].name[0]=='#'))t+= last_node;

#else
#line 383 "aw3.ch"
 if(t<=score&&t> 1&&(o,cl[k].name[0]!='#'))t+= last_node;

#endif
#line 386 "aw3.ch"

if(t<=score){
#if RANDOMIZE
if(t<score||s<best_s||(s==best_s&&nd[k].len> best_l))
score= t,best_itm= k,best_s= s,best_l= nd[k].len,p= 1;
else if(s==best_s&&nd[k].len==best_l){
p++;
if(randomizing&&(mems+= 4,!gb_unif_rand(p)))best_itm= k;
}
#else
#line 396 "aw3.ch"
 if(t<score||s<best_s||(s==best_s&&nd[k].len> best_l))
score= t,best_itm= k,best_s= s,best_l= nd[k].len;
#endif
#line 399 "aw3.ch"
}
}
#line 407 "aw3.ch"
if(score> last_node&&score<infty)score-= last_node;
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
#line 1037 "dlx3.w"
if(score<infty)
fprintf(stderr," branching on "O".8s("O"d)\n",cl[best_itm].name,score);
else fprintf(stderr," solution\n");
}
if(shape_file&&score<infty){
fprintf(shape_file,""O"d "O".8s\n",score>=0?score:0,cl[best_itm].name);
fflush(shape_file);
}

/*:49*/
#line 642 "dlx3.w"
;
if(score<=0)goto backdown;
if(score==infty)/*50:*/
#line 1046 "dlx3.w"

{
if(shape_file){
fprintf(shape_file,"sol\n");fflush(shape_file);
}
#line 415 "aw3.ch"
#if DISCRETA_OUTPUT
/*51:*/
#line 425 "aw3.ch"

{
count++;
if(spacing&&(count mod spacing==0)){
/*52:*/
#line 460 "aw3.ch"

for(k= 0;k<options;k++)solution_vector[k]= 0;

for(k= 0;k<level;k++){
pp= choice[k];
cc= pp<last_itm?pp:nd[pp].itm;
{
int head;
register int q;
if(!first_tweak[k]){
head= nd[cc].down;
}else{
head= first_tweak[k];
}
if(!(pp<last_itm&&pp==head)&&!(head>=last_itm&&pp==nd[head].itm)){
if(pp!=nd[head].itm){
if(pp<last_itm||pp>=last_node||nd[pp].itm<=0){
fprintf(stderr,"Illegal option "O"d!\n",pp);
break;
}
for(q= pp;;){
q++;
if(nd[q].itm<=0){
solution_vector[-nd[q].itm-1]= 1;
q= nd[q].up;

break;
}
if(q==pp)break;
}
}
}
}
}

/*:52*/
#line 429 "aw3.ch"
;

if(print_indices){

k= 0;
for(i= 0;i<overallrows;i++){
if(selectedcolumns[i]!=0){
if(solution_vector[k]!=0){
fprintf(stdout,"%d ",k);
}
k++;
}
}
}else{

k= 0;
for(i= 0;i<overallrows;i++){
if(selectedcolumns[i]==0){
fprintf(stdout,"0");
}else{
fprintf(stdout,"%d",solution_vector[k]);
k++;
}
}
}
fprintf(stdout,"\n");
}
if(count>=maxcount)goto done;
goto backdown;
}

/*:51*/
#line 416 "aw3.ch"
;
#else
#line 418 "aw3.ch"
/*53:*/
#line 495 "aw3.ch"

#line 1055 "dlx3.w"
{
count++;
if(spacing&&(count mod spacing==0)){
printf(""O"lld:\n",count);
for(k= 0;k<level;k++){
pp= choice[k];
cc= pp<last_itm?pp:nd[pp].itm;
if(!first_tweak[k])print_option(pp,stdout,nd[cc].down,scor[k]);
else print_option(pp,stdout,first_tweak[k],scor[k]);
}
fflush(stdout);
}
if(count>=maxcount)goto done;
goto backdown;
}

/*:53*/
#line 418 "aw3.ch"
;
#endif
#line 1052 "dlx3.w"
}

#line 425 "aw3.ch"
/*:50*/
#line 644 "dlx3.w"
;
scor[level]= score,first_tweak[level]= 0;

oo,cur_node= choice[level]= nd[best_itm].down;
o,cl[best_itm].bound--;
if(cl[best_itm].bound==0&&cl[best_itm].slack==0)cover(best_itm,1);
else{
o,first_tweak[level]= cur_node;
if(cl[best_itm].bound==0)cover(best_itm,1);
}
advance:/*39:*/
#line 725 "dlx3.w"

if((o,cl[best_itm].bound==0)&&(cl[best_itm].slack==0)){
if(cur_node==best_itm)goto backup;
}else if(oo,nd[best_itm].len<=cl[best_itm].bound-cl[best_itm].slack)
goto backup;
else if(cur_node!=best_itm)tweak(cur_node,cl[best_itm].bound);
else if(cl[best_itm].bound!=0){
o,p= cl[best_itm].prev,q= cl[best_itm].next;
oo,cl[p].next= q,cl[q].prev= p;
}

/*:39*/
#line 654 "dlx3.w"
;
if((vbose&show_choices)&&level<show_choices_max)/*37:*/
#line 694 "dlx3.w"

{
fprintf(stderr,"L"O"d:",level);
if(cl[best_itm].bound==0&&cl[best_itm].slack==0)
print_option(cur_node,stderr,nd[best_itm].down,score);
else print_option(cur_node,stderr,first_tweak[level],score);
}

/*:37*/
#line 655 "dlx3.w"
;
if(cur_node> last_itm)
/*43:*/
#line 809 "dlx3.w"

for(pp= cur_node+1;pp!=cur_node;){
o,cc= nd[pp].itm;
if(cc<=0)o,pp= nd[pp].up;
else{
if(cc<second){
oo,cl[cc].bound--;
if(cl[cc].bound==0)cover(cc,1);
}else{
if(!nd[pp].color)cover(cc,1);
else if(nd[pp].color> 0)purify(pp);
}
pp++;
}
}

/*:43*/
#line 657 "dlx3.w"
;
/*36:*/
#line 684 "dlx3.w"

if(++level> maxl){
if(level>=max_level){
fprintf(stderr,"Too many levels!\n");
exit(-4);
}
maxl= level;
}
goto forward;

/*:36*/
#line 658 "dlx3.w"
;
backup:/*40:*/
#line 736 "dlx3.w"

if((o,cl[best_itm].bound==0)&&(cl[best_itm].slack==0))uncover(best_itm,1);
else o,untweak(best_itm,first_tweak[level],cl[best_itm].bound);
oo,cl[best_itm].bound++;

/*:40*/
#line 659 "dlx3.w"
;
backdown:if(level==0)goto done;
level--;
oo,cur_node= choice[level],best_itm= nd[cur_node].itm,score= scor[level];
if(cur_node<last_itm)/*38:*/
#line 702 "dlx3.w"

{
best_itm= cur_node;
o,p= cl[best_itm].prev,q= cl[best_itm].next;
oo,cl[p].next= cl[q].prev= best_itm;
goto backup;
}

/*:38*/
#line 663 "dlx3.w"
;
/*44:*/
#line 828 "dlx3.w"

for(pp= cur_node-1;pp!=cur_node;){
o,cc= nd[pp].itm;
if(cc<=0)o,pp= nd[pp].down;
else{
if(cc<second){
if(o,cl[cc].bound==0)uncover(cc,1);
o,cl[cc].bound++;
}else{
if(!nd[pp].color)uncover(cc,1);
else if(nd[pp].color> 0)unpurify(pp);
}
pp--;
}
}

/*:44*/
#line 664 "dlx3.w"
;
oo,cur_node= choice[level]= nd[cur_node].down;goto advance;

/*:33*/
#line 111 "dlx3.w"
;
done:if(vbose&show_tots)
/*32:*/
#line 601 "dlx3.w"

{
fprintf(stderr,"Item totals:");
for(k= 1;k<last_itm;k++){
if(k==second)fprintf(stderr," |");
fprintf(stderr," "O"d",nd[k].len);
}
fprintf(stderr,"\n");
}

/*:32*/
#line 113 "dlx3.w"
;
if(vbose&show_profile)/*56:*/
#line 1132 "dlx3.w"

{
fprintf(stderr,"Profile:\n");
for(level= 0;level<=maxl;level++)
fprintf(stderr,""O"3d: "O"lld\n",
level,profile[level]);
}

/*:56*/
#line 114 "dlx3.w"
;
if(vbose&show_basics)/*6:*/
#line 218 "dlx3.w"

{
fprintf(stderr,"Altogether "O"llu solution"O"s",
count,count==1?"":"s");
fprintf(stderr,", "O"llu+"O"llu mems,",imems,mems);
fprintf(stderr," "O"llu updates, "O"llu cleansings,",
updates,cleansings);
bytes= last_itm*sizeof(item)+last_node*sizeof(node)+maxl*sizeof(int);
fprintf(stderr," "O"llu bytes, "O"llu nodes.\n",
bytes,nodes);
}

/*:6*/
#line 115 "dlx3.w"
;
/*7:*/
#line 230 "dlx3.w"

if(shape_file)fclose(shape_file);

/*:7*/
#line 116 "dlx3.w"
;
}

/*:2*/
