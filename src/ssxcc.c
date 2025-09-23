#define o mems++
#define oo mems+= 2
#define ooo mems+= 3
#define O "%"
#define mod % \

#define max_level 100000
#define savesize 10000000
#define DISCRETA_OUTPUT 1
#define RANDOMIZE 0 \

#define show_basics 1
#define show_choices 2
#define show_details 4
#define show_profile 128
#define show_full_state 256
#define show_tots 512
#define show_warnings 1024
#define show_max_deg 2048 \

#define size(x) set[(x) -1]
#define pos(x) set[(x) -2]
#define lname(x) set[(x) -4]
#define rname(x) set[(x) -3]
#define primextra 4
#define secondextra 4
#define maxextra 4 \

#define sanity_checking 0 \

#define panic(m) {fprintf(stderr,""O"s!\n"O"d: "O".99s\n",m,p,buf) ;exit(-666) ;} \

/*3:*/
#line 56 "ssxcc.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <ctype.h> 
#line 27 "aw_ssx.ch"
#if RANDOMIZE
#include "gb_flip.h"
#endif
#line 30 "aw_ssx.ch"
#include "uthash.h"
#line 62 "ssxcc.w"
typedef unsigned int uint;
typedef unsigned long long ullng;
/*9:*/
#line 302 "ssxcc.w"

typedef struct node_struct{
int itm;
int loc;
int clr;
int spr;
}node;

/*:9*//*11:*/
#line 330 "ssxcc.w"

typedef struct{
int l,r;
}twoints;
typedef union{
unsigned char str[8];
twoints lr;
}stringbuf;
#line 153 "aw_ssx.ch"
stringbuf namebuf;

typedef struct{
char*name;
int pos;
UT_hash_handle hh;
}item_hash;

item_hash*items_hash_table= NULL;

/*:11*/
#line 64 "ssxcc.w"
;
/*4:*/
#line 144 "ssxcc.w"

int random_seed= 0;
int randomizing;
int vbose= show_basics+show_warnings;
int spacing;
int show_choices_max= 1000000;
int show_choices_gap= 1000000;

int show_levels_max= 1000000;
int maxl;
#line 69 "aw_ssx.ch"
int maxsaveptr;
int bufsize;
int print_indices= 1;
long max_cols= 1000000;
long max_nodes= 10000000;
#line 156 "ssxcc.w"
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
FILE*shape_file;
char*shape_name;
int maxdeg;

/*:4*//*10:*/
#line 310 "ssxcc.w"

#line 126 "aw_ssx.ch"
node*nd;
#line 312 "ssxcc.w"
int last_node;
#line 133 "aw_ssx.ch"
int*item;
int second;
#line 315 "ssxcc.w"
int last_itm;
#line 140 "aw_ssx.ch"
int*set;
#line 317 "ssxcc.w"
int itemlength;
int setlength;
int active;
int oactive;
int baditem;
int osecond;
#line 146 "aw_ssx.ch"
int*force;
char*buf;
#line 324 "ssxcc.w"
int forced;

/*:10*//*25:*/
#line 248 "aw_ssx.ch"

#if DISCRETA_OUTPUT
int*solution_vector;
#endif
#line 252 "aw_ssx.ch"

/*:25*//*32:*/
#line 685 "ssxcc.w"

int level;
int choice[max_level];
int saved[max_level+1];
ullng profile[max_level];
twoints savestack[savesize];
int saveptr;

/*:32*/
#line 65 "ssxcc.w"
;
/*12:*/
#line 163 "aw_ssx.ch"

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
#line 339 "ssxcc.w"

/*:12*//*13:*/
#line 340 "ssxcc.w"

void print_item_name(int k,FILE*stream){
namebuf.lr.l= lname(k),namebuf.lr.r= rname(k);
fprintf(stream," "O".8s",namebuf.str);
}

/*:13*//*14:*/
#line 350 "ssxcc.w"

#line 186 "aw_ssx.ch"
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
#line 212 "aw_ssx.ch"
 void print_option(int p,FILE*stream){
#line 352 "ssxcc.w"
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
fprintf(stream," ("O"d of "O"d)\n",k-x+1,size(x));
}

void prow(int p){
print_option(p,stderr);
}

/*:14*//*15:*/
#line 377 "ssxcc.w"

void print_itm(int c){
register int p;
if(c<primextra||c>=setlength||
pos(c)<0||pos(c)>=itemlength||item[pos(c)]!=c){
fprintf(stderr,"Illegal item "O"d!\n",c);
return;
}
fprintf(stderr,"Item");
print_item_name(c,stderr);
if(c<second)fprintf(stderr," ("O"d of "O"d), length "O"d:\n",
pos(c)+1,active,size(c));
else if(pos(c)>=active)
fprintf(stderr," (secondary "O"d, purified), length "O"d:\n",
pos(c)+1,size(c));
else fprintf(stderr," (secondary "O"d), length "O"d:\n",
pos(c)+1,size(c));
for(p= c;p<c+size(c);p++)prow(set[p]);
}

/*:15*//*16:*/
#line 402 "ssxcc.w"

void sanity(void){
register int k,x,i,l,r,q,qq;
for(k= 0;k<itemlength;k++){
x= item[k];
if(pos(x)!=k){
fprintf(stderr,"Bad pos field of item");
print_item_name(x,stderr);
fprintf(stderr," ("O"d,"O"d)!\n",k,x);
}
}
for(i= 0;i<last_node;i++){
l= nd[i].itm,r= nd[i].loc;
if(l<=0){
if(nd[i+r+1].itm!=-r)
fprintf(stderr,"Bad spacer in nodes "O"d, "O"d!\n",i,i+r+1);
qq= 0;
}else{
if(l> r)fprintf(stderr,"itm>loc in node "O"d!\n",i);
else{
if(set[r]!=i){
fprintf(stderr,"Bad loc field for option "O"d of item",r-l+1);
print_item_name(l,stderr);
fprintf(stderr," in node "O"d!\n",i);
}
if(pos(l)<active){
if(r<l+size(l))q= +1;else q= -1;
if(q*qq<0){
fprintf(stderr,"Flipped status at option "O"d of item",r-l+1);
print_item_name(l,stderr);
fprintf(stderr," in node "O"d!\n",i);
}
qq= q;
}
}
}
}
}

/*:16*//*37:*/
#line 774 "ssxcc.w"

int hide(int c,int color,int check){
register int cc,s,rr,ss,nn,tt,uu,vv,nnp;
for(o,rr= c,s= c+size(c);rr<s;rr++){
o,tt= set[rr];
if(!color||(o,nd[tt].clr!=color))
/*38:*/
#line 785 "ssxcc.w"

{
for(nn= tt+1;nn!=tt;){
o,uu= nd[nn].itm,vv= nd[nn].loc;
if(uu<0){nn+= uu;continue;}
if(o,pos(uu)<oactive){
o,ss= size(uu)-1;
if(ss<=1&&check&&uu<second&&pos(uu)<active){
if(ss==0){
if((vbose&show_choices)&&level<show_choices_max){
fprintf(stderr," can't cover");
print_item_name(uu,stderr);
fprintf(stderr,"\n");
}
return 0;
}else o,force[forced++]= uu;
}
o,nnp= set[uu+ss];
o,size(uu)= ss;
oo,set[uu+ss]= nn,set[vv]= nnp;
oo,nd[nn].loc= uu+ss,nd[nnp].loc= vv;
updates++;
}
nn++;
}
}

/*:38*/
#line 780 "ssxcc.w"
;
}
return 1;
}

/*:37*//*45:*/
#line 918 "ssxcc.w"

void print_savestack(int start,int stop){
register int k;
for(k= start;k<=stop;k++){
print_item_name(savestack[k].l,stderr);
fprintf(stderr,"("O"d), "O"d\n",savestack[k].l,savestack[k].r);
}
}

/*:45*//*46:*/
#line 927 "ssxcc.w"

void print_state(void){
register int l;
fprintf(stderr,"Current state (level "O"d):\n",level);
for(l= 0;l<level;l++){
print_option(choice[l],stderr);
if(l>=show_levels_max){
fprintf(stderr," ...\n");
break;
}
}
fprintf(stderr," "O"lld solutions, "O"lld mems, and max level "O"d so far.\n",
count,mems,maxl);
}

/*:46*//*47:*/
#line 962 "ssxcc.w"

void print_progress(void){
register int l,k,d,c,p,ds= 0;
register double f,fd;
fprintf(stderr," after "O"lld mems: "O"lld sols,",mems,count);
for(f= 0.0,fd= 1.0,l= 0;l<level;l++){
c= nd[choice[l]].itm,d= size(c),k= nd[choice[l]].loc-c+1;
fd*= d,f+= (k-1)/fd;
if(l<show_levels_max)fprintf(stderr," "O"c"O"c",
k<10?'0'+k:k<36?'a'+k-10:k<62?'A'+k-36:'*',
d<10?'0'+d:d<36?'a'+d-10:d<62?'A'+d-36:'*');
else if(!ds)ds= 1,fprintf(stderr,"...");
}
#line 315 "aw_ssx.ch"
fprintf(stderr," "O".12lf\n",f+0.5/fd);
#line 976 "ssxcc.w"
}

/*:47*/
#line 66 "ssxcc.w"
;
#line 36 "aw_ssx.ch"
int main(int argc,char*argv[]){
#line 68 "ssxcc.w"
register int c,cc,i,j,k,p,pp,q,r,s,t,cur_choice,cur_node,best_itm;
#line 42 "aw_ssx.ch"
/*5:*/
#line 173 "ssxcc.w"

for(j= argc-1,k= 0;j;j--)switch(argv[j][0]){
#line 81 "aw_ssx.ch"
case'i':k|= (sscanf(argv[j]+1,""O"d",&print_indices)-1);break;
case'v':k|= (sscanf(argv[j]+1,""O"d",&vbose)-1);break;
case'm':k|= (sscanf(argv[j]+1,""O"d",&spacing)-1);break;
case'I':k|= (sscanf(argv[j]+1,""O"ld",&max_cols)-1);break;
case'M':k|= (sscanf(argv[j]+1,""O"ld",&max_nodes)-1);break;
case's':k|= (sscanf(argv[j]+1,""O"d",&random_seed)-1),randomizing= 1;break;
#line 178 "ssxcc.w"
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
#line 98 "aw_ssx.ch"
if(k){
fprintf(stderr,"Usage: "O"s [v<n>] [m<n>] [s<n>] [d<n>]"
" [c<n>] [C<n>] [l<n>] [t<n>] [T<n>] [S<bar>] [i<0|1>] [I<n>] [M<n>] < foo.dlx\n",
argv[0]);
exit(-1);
}
#if RANDOMIZE
if(randomizing)gb_init_rand(random_seed);
#endif
#line 107 "aw_ssx.ch"

/*:5*/
#line 42 "aw_ssx.ch"
;
/*6:*/
#line 109 "aw_ssx.ch"

if(max_nodes*sizeof(node)> 2147483647){
panic("Too much memory allocated, i.e. parameter M is too large");
}
nd= (node*)malloc(max_nodes*sizeof(node));
item= (int*)malloc(max_cols);
force= (int*)malloc(max_cols);
set= (int*)malloc(max_nodes+maxextra*max_cols);
second= max_cols;

bufsize= 9*max_cols+3;
buf= (char*)malloc(bufsize*sizeof(char));
#line 198 "ssxcc.w"

/*:6*/
#line 43 "aw_ssx.ch"
;
/*26:*/
#line 255 "aw_ssx.ch"

solution_vector= (int*)calloc(options,sizeof(int));

/*:26*/
#line 44 "aw_ssx.ch"

#line 70 "ssxcc.w"
/*17:*/
#line 448 "ssxcc.w"

while(1){
if(!fgets(buf,bufsize,stdin))break;
if(o,buf[p= strlen(buf)-1]!='\n')panic("Input line way too long");
for(p= 0;o,isspace(buf[p]);p++);
#line 218 "aw_ssx.ch"
if(buf[p]=='|'||buf[p]=='%'||!buf[p])continue;
#line 454 "ssxcc.w"
last_itm= 1;
break;
}
if(!last_itm)panic("No items");
for(;o,buf[p];){
o,namebuf.lr.l= namebuf.lr.r= 0;
for(j= 0;j<8&&(o,!isspace(buf[p+j]));j++){
if(buf[p+j]==':'||buf[p+j]=='|')
panic("Illegal character in item name");
o,namebuf.str[j]= buf[p+j];
}
if(j==8&&!isspace(buf[p+j]))panic("Item name too long");
#line 224 "aw_ssx.ch"
oo,lname(last_itm<<2)= namebuf.lr.l,rname(last_itm<<2)= namebuf.lr.r;
add_item(namebuf.str,last_itm<<2);
#line 467 "ssxcc.w"
/*18:*/
#line 478 "ssxcc.w"

for(k= last_itm-1;k;k--){
if(o,lname(k<<2)!=namebuf.lr.l)continue;
if(rname(k<<2)==namebuf.lr.r)break;
}
if(k)panic("Duplicate item name");

/*:18*/
#line 467 "ssxcc.w"
;
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
#line 70 "ssxcc.w"
;
/*19:*/
#line 489 "ssxcc.w"

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
/*20:*/
#line 241 "aw_ssx.ch"

k= find_item(namebuf.str);
#line 540 "ssxcc.w"
if(!k)panic("Unknown item name");
if(o,pos(k)> i)panic("Duplicate item name in this option");
last_node++;
if(last_node==max_nodes)panic("Too many nodes");
o,t= size(k);
o,nd[last_node].itm= k>>2,nd[last_node].loc= t;
if((k>>2)<second)pp= 1;
o,size(k)= t+1,pos(k)= last_node;

/*:20*/
#line 503 "ssxcc.w"
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
/*21:*/
#line 549 "ssxcc.w"

o,k= nd[last_node].itm<<2;
oo,size(k)--,pos(k)= i-1;

/*:21*/
#line 517 "ssxcc.w"
;
last_node--;
}
}else{
o,nd[i].loc= last_node-i;
last_node++;
#line 231 "aw_ssx.ch"
if(last_node==max_nodes)panic("Too many nodes. Count the number of options using 'counttokens.sh' and use the option 'M<n>'");
#line 524 "ssxcc.w"
options++;
o,nd[last_node].itm= i+1-last_node;
nd[last_node].spr= options;
}
}
/*22:*/
#line 553 "ssxcc.w"

active= itemlength= last_itm-1;
for(k= 0,j= primextra;k<itemlength;k++)
oo,item[k]= j,j+= (k+2<second?primextra:secondextra)+size((k+1)<<2);
setlength= j-4;
if(second==max_cols)osecond= active,second= j;
else osecond= second-1;

/*:22*/
#line 529 "ssxcc.w"
;
/*23:*/
#line 564 "ssxcc.w"

for(;k;k--){
o,j= item[k-1];
if(k==second)second= j;
oo,size(j)= size(k<<2);
if(size(j)==0&&k<=osecond)baditem= k;
o,pos(j)= k-1;
oo,rname(j)= rname(k<<2),lname(j)= lname(k<<2);
}

/*:23*/
#line 530 "ssxcc.w"
;
/*24:*/
#line 574 "ssxcc.w"

for(k= 1;k<last_node;k++){
if(o,nd[k].itm<0)continue;
o,j= item[nd[k].itm-1];
i= j+nd[k].loc;
o,nd[k].itm= j,nd[k].loc= i;
o,set[i]= k;
}

#line 248 "aw_ssx.ch"
/*:24*/
#line 531 "ssxcc.w"
;

/*:19*/
#line 71 "ssxcc.w"
;
if(vbose&show_basics)
/*28:*/
#line 596 "ssxcc.w"

fprintf(stderr,
"("O"lld options, "O"d+"O"d items, "O"d entries successfully read)\n",
options,osecond,itemlength-osecond,last_node);

/*:28*/
#line 73 "ssxcc.w"
;
if(vbose&show_tots)
/*29:*/
#line 607 "ssxcc.w"

{
fprintf(stderr,"Item totals:");
for(k= 0;k<itemlength;k++){
if(k==second)fprintf(stderr," |");
fprintf(stderr," "O"d",size(item[k]));
}
fprintf(stderr,"\n");
}

#line 270 "aw_ssx.ch"
/*:29*/
#line 75 "ssxcc.w"
;
imems= mems,mems= 0;
if(baditem)/*27:*/
#line 258 "aw_ssx.ch"

#line 584 "ssxcc.w"
{
if(vbose&show_choices){
fprintf(stderr,"Item");
print_item_name(item[baditem-1],stderr);
fprintf(stderr," has no options!\n");
}
}

/*:27*/
#line 77 "ssxcc.w"

else{
if(randomizing)/*30:*/
#line 270 "aw_ssx.ch"

#if RANDOMIZE
for(k= active;k> 1;){
mems+= 4,j= gb_unif_rand(k);
k--;
oo,oo,t= item[j],item[j]= item[k],item[k]= t;
oo,pos(t)= k,pos(item[j])= j;
}
#endif
#line 624 "ssxcc.w"

/*:30*/
#line 79 "ssxcc.w"
;
/*31:*/
#line 640 "ssxcc.w"

{
level= 0;
forward:nodes++;
if(vbose&show_profile)profile[level]++;
if(sanity_checking)sanity();
/*40:*/
#line 867 "ssxcc.w"

while(forced){
o,best_itm= force[--forced];
if(o,pos(best_itm)<active)/*44:*/
#line 907 "ssxcc.w"

{
if((vbose&show_choices)&&level<show_choices_max)
fprintf(stderr,"(forcing)\n");
/*34:*/
#line 703 "ssxcc.w"

p= active-1,active= p;
o,pp= pos(best_itm);
o,cc= item[p];
oo,item[p]= best_itm,item[pp]= cc;
oo,pos(cc)= pp,pos(best_itm)= p;
updates++;

/*:34*/
#line 911 "ssxcc.w"
;
oactive= active,hide(best_itm,0,0);
cur_choice= best_itm;
o,saved[level+1]= saveptr;
goto advance;
}

/*:44*/
#line 870 "ssxcc.w"
;
}

/*:40*/
#line 646 "ssxcc.w"
;
/*33:*/
#line 693 "ssxcc.w"

if(delta&&(mems>=thresh)){
thresh+= delta;
if(vbose&show_full_state)print_state();
else print_progress();
}
if(mems>=timeout){
fprintf(stderr,"TIMEOUT!\n");goto done;
}

/*:33*/
#line 647 "ssxcc.w"
;
/*39:*/
#line 825 "ssxcc.w"

t= max_nodes,tmems= mems;
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap)
fprintf(stderr,"Level "O"d:",level);
for(k= 0;k<active;k++)if(o,item[k]<second){
o,s= size(item[k]);
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
print_item_name(item[k],stderr);
fprintf(stderr,"("O"d)",s);
}
if(s<=1){
if(s==0)fprintf(stderr,"I'm confused.\n");
else o,force[forced++]= item[k];
}else if(s<=t){
if(s<t)best_itm= item[k],t= s;
else if(item[k]<best_itm)best_itm= item[k];
}
}
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
if(forced)fprintf(stderr," found "O"d forced\n",forced);
else if(t==max_nodes)fprintf(stderr," solution\n");
else{
fprintf(stderr," branching on");
print_item_name(best_itm,stderr);
fprintf(stderr,"("O"d)\n",t);
}
}
if(t> maxdeg&&t<max_nodes&&!forced)maxdeg= t;
if(shape_file){
if(t==max_nodes)fprintf(shape_file,"sol\n");
else{
fprintf(shape_file,""O"d",t);
print_item_name(best_itm,shape_file);
fprintf(shape_file,"\n");
}
fflush(shape_file);
}
cmems+= mems-tmems;

/*:39*/
#line 648 "ssxcc.w"
;
if(forced){
o,best_itm= force[--forced];
/*44:*/
#line 907 "ssxcc.w"

{
if((vbose&show_choices)&&level<show_choices_max)
fprintf(stderr,"(forcing)\n");
/*34:*/
#line 703 "ssxcc.w"

p= active-1,active= p;
o,pp= pos(best_itm);
o,cc= item[p];
oo,item[p]= best_itm,item[pp]= cc;
oo,pos(cc)= pp,pos(best_itm)= p;
updates++;

/*:34*/
#line 911 "ssxcc.w"
;
oactive= active,hide(best_itm,0,0);
cur_choice= best_itm;
o,saved[level+1]= saveptr;
goto advance;
}

/*:44*/
#line 651 "ssxcc.w"
;
}
if(t==max_nodes)/*41:*/
#line 873 "ssxcc.w"

{
count++;
#line 288 "aw_ssx.ch"
#if DISCRETA_OUTPUT
if(spacing&&(count mod spacing==0)){
if(!print_indices){
for(k= 0;k<options;k++){
solution_vector[k]= 0;
}
}
for(k= 0;k<level;k++)print_option_discreta(choice[k],stdout);
if(!print_indices){
for(k= 0;k<options;k++){
fprintf(stdout,"%d",solution_vector[k]);
}
}
fprintf(stdout,"\n");
}
#else
#line 304 "aw_ssx.ch"
 if(spacing&&(count mod spacing==0)){
printf(""O"lld:\n",count);
for(k= 0;k<level;k++)print_option(choice[k],stdout);
fflush(stdout);
}
#endif
#line 881 "ssxcc.w"
 if(count>=maxcount)goto done;
goto backup;
}

/*:41*/
#line 653 "ssxcc.w"
;
/*34:*/
#line 703 "ssxcc.w"

p= active-1,active= p;
o,pp= pos(best_itm);
o,cc= item[p];
oo,item[p]= best_itm,item[pp]= cc;
oo,pos(cc)= pp,pos(best_itm)= p;
updates++;

/*:34*/
#line 654 "ssxcc.w"
;
oactive= active,hide(best_itm,0,0);
cur_choice= best_itm;
/*42:*/
#line 885 "ssxcc.w"

if(saveptr+active> maxsaveptr){
if(saveptr+active>=savesize){
fprintf(stderr,"Stack overflow (savesize="O"d)!\n",savesize);
exit(-5);
}
maxsaveptr= saveptr+active;
}
for(p= 0;p<active;p++)
ooo,savestack[saveptr+p].l= item[p],savestack[saveptr+p].r= size(item[p]);
o,saved[level+1]= saveptr= saveptr+active;

/*:42*/
#line 657 "ssxcc.w"
;
advance:oo,cur_node= choice[level]= set[cur_choice];
tryit:if((vbose&show_choices)&&level<show_choices_max){
fprintf(stderr,"L"O"d:",level);
print_option(cur_node,stderr);
}
/*35:*/
#line 715 "ssxcc.w"

p= oactive= active;
for(q= cur_node+1;q!=cur_node;){
o,c= nd[q].itm;
if(c<0)q+= c;
else{
o,pp= pos(c);
if(pp<p){
o,cc= item[--p];
oo,item[p]= c,item[pp]= cc;
oo,pos(cc)= pp,pos(c)= p;
updates++;
}
q++;
}
}
active= p;

/*:35*/
#line 663 "ssxcc.w"
;
/*36:*/
#line 736 "ssxcc.w"

for(q= cur_node+1;q!=cur_node;){
o,cc= nd[q].itm;
if(cc<0)q+= cc;
else{
if(cc<second){
if(hide(cc,0,1)==0){
forced= 0;
goto abort;
}
}else{
o,pp= pos(cc);
if(pp<oactive&&(o,hide(cc,nd[q].clr,1)==0)){
forced= 0;
goto abort;
}
}
q++;
}
}

/*:36*/
#line 664 "ssxcc.w"
;
if(++level> maxl){
if(level>=max_level){
fprintf(stderr,"Too many levels!\n");
exit(-4);
}
maxl= level;
}
goto forward;
backup:if(level==0)goto done;
level--;
oo,cur_node= choice[level],best_itm= nd[cur_node].itm,cur_choice= nd[cur_node].loc;
abort:if(o,cur_choice+1>=best_itm+size(best_itm))goto backup;
/*43:*/
#line 897 "ssxcc.w"

o,saveptr= saved[level+1];
o,active= saveptr-saved[level];
for(p= -active;p<0;p++)
oo,size(savestack[saveptr+p].l)= savestack[saveptr+p].r;

/*:43*/
#line 677 "ssxcc.w"
;
cur_choice++;goto advance;
}

/*:31*/
#line 80 "ssxcc.w"
;
}
done:if(vbose&show_profile)/*48:*/
#line 978 "ssxcc.w"

{
fprintf(stderr,"Profile:\n");
for(level= 0;level<=maxl;level++)
fprintf(stderr,""O"3d: "O"lld\n",
level,profile[level]);
}

/*:48*/
#line 82 "ssxcc.w"
;
if(vbose&show_max_deg)
fprintf(stderr,"The maximum branching degree was "O"d.\n",maxdeg);
if(vbose&show_basics){
fprintf(stderr,"Altogether "O"llu solution"O"s, "O"llu+"O"llu mems,",
count,count==1?"":"s",imems,mems);
bytes= (itemlength+setlength)*sizeof(int)+last_node*sizeof(node)
+2*maxl*sizeof(int)+maxsaveptr*sizeof(twoints);
fprintf(stderr," "O"llu updates, "O"llu bytes, "O"llu nodes,",
updates,bytes,nodes);
fprintf(stderr," ccost "O"lld%%.\n",
mems?(200*cmems+mems)/(2*mems):0);
}
if(sanity_checking)fprintf(stderr,"sanity_checking was on!\n");
/*7:*/
#line 199 "ssxcc.w"

if(shape_file)fclose(shape_file);

/*:7*/
#line 96 "ssxcc.w"
;
}

/*:3*/
