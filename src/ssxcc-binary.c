#define o mems++
#define oo mems+= 2
#define ooo mems+= 3
#define subroutine_overhead mems+= 4
#define O "%"
#define mod % \

#define max_stage 500
#define max_level 100000
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
#define wt(x) set[(x) -5].f
#define primextra 5
#define secondextra 4
#define maxextra 5 \

#define sanity_checking 0 \

#define panic(m) {fprintf(stderr,""O"s!\n"O"d: "O".99s\n",m,p,buf) ;exit(-666) ;} \

#define dangerous 1e32f
#define wmin 1e-30f \

#define inf_size 0x7fffffff \

/*2:*/
#line 62 "ssxcc-binary.w"

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <ctype.h> 
#line 27 "aw_ssxb.ch"
#if RANDOMIZE
#include "gb_flip.h"
#endif
#line 30 "aw_ssxb.ch"
#include "uthash.h"
#line 68 "ssxcc-binary.w"
typedef unsigned int uint;
typedef unsigned long long ullng;
/*9:*/
#line 330 "ssxcc-binary.w"

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
#line 361 "ssxcc-binary.w"

typedef struct{
int l,r;
}twoints;
typedef union{
unsigned char str[8];
twoints lr;
}stringbuf;
#line 154 "aw_ssxb.ch"
stringbuf namebuf;

typedef struct{
char*name;
int pos;
UT_hash_handle hh;
}item_hash;

item_hash*items_hash_table= NULL;

/*:11*/
#line 70 "ssxcc-binary.w"
;
/*3:*/
#line 151 "ssxcc-binary.w"

int random_seed= 0;
int randomizing;
int vbose= show_basics+show_warnings;
int spacing;
int show_choices_max= 1000000;
int show_choices_gap= 1000000;

int show_levels_max= 10;
int maxl;
int maxs;
#line 69 "aw_ssxb.ch"
int maxsaveptr;
int bufsize;
int print_indices= 1;
long max_cols= 1000000;
long max_nodes= 10000000;
#line 164 "ssxcc-binary.w"
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
#line 342 "ssxcc-binary.w"

#line 127 "aw_ssxb.ch"
node*nd;
#line 344 "ssxcc-binary.w"
int last_node;
#line 134 "aw_ssxb.ch"
int*item;
int second;
#line 347 "ssxcc-binary.w"
int last_itm;
#line 141 "aw_ssxb.ch"
tetrabyte*set;
#line 349 "ssxcc-binary.w"
int itemlength;
int setlength;
int active;
int baditem;
int osecond;
#line 147 "aw_ssxb.ch"
int*force;
char*buf;
#line 355 "ssxcc-binary.w"
int forced;

/*:10*//*25:*/
#line 249 "aw_ssxb.ch"

#if DISCRETA_OUTPUT
int*solution_vector;
#endif
#line 253 "aw_ssxb.ch"

/*:25*//*32:*/
#line 712 "ssxcc-binary.w"

int stage;
int level;
int choice[max_level];
int deg[max_level];
int levelstage[max_stage];
int stagelevel[max_level];
ullng profile[max_stage];

/*:32*//*34:*/
#line 778 "ssxcc-binary.w"

int level;
int choice[max_level];
int saved[max_level+1];
twoints savestack[savesize];
int saveptr;
int tough_itm;

/*:34*/
#line 71 "ssxcc-binary.w"
;
/*7:*/
#line 217 "ssxcc-binary.w"

void confusion(char*m){
fprintf(stderr,""O"s!\n",m);
}

/*:7*//*12:*/
#line 164 "aw_ssxb.ch"

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
#line 370 "ssxcc-binary.w"

/*:12*//*13:*/
#line 371 "ssxcc-binary.w"

void print_item_name(int k,FILE*stream){
namebuf.lr.l= lname(k),namebuf.lr.r= rname(k);
fprintf(stream," "O".8s",namebuf.str);
}

/*:13*//*14:*/
#line 381 "ssxcc-binary.w"

#line 187 "aw_ssxb.ch"
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
#line 213 "aw_ssxb.ch"
 void print_option(int p,FILE*stream,int showpos){
#line 383 "ssxcc-binary.w"
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
#line 409 "ssxcc-binary.w"

void print_itm(int c){
register int p;
if(c<primextra||c>=setlength||
pos(c)<0||pos(c)>=itemlength||item[pos(c)]!=c){
fprintf(stderr,"Illegal item "O"d!\n",c);
return;
}
fprintf(stderr,"Item");
print_item_name(c,stderr);
if(c<second)
fprintf(stderr," ("O"d of "O"d), length "O"d, weight "O".1f:\n",
pos(c)+1,active,size(c),wt(c));
else if(pos(c)>=active)
fprintf(stderr," (secondary "O"d, purified), length "O"d:\n",
pos(c)+1,size(c));
else fprintf(stderr," (secondary "O"d), length "O"d:\n",
pos(c)+1,size(c));
for(p= c;p<c+size(c);p++)prow(set[p].i);
}

/*:15*//*16:*/
#line 435 "ssxcc-binary.w"

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
if(set[r].i!=i){
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

/*:16*//*38:*/
#line 821 "ssxcc-binary.w"

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
if(p<active)/*39:*/
#line 842 "ssxcc-binary.w"

{
o,ss= size(ii);
if(ii<second)c= 0;else o,c= nd[opt].clr;
for(s= ii+ss-1;s>=ii;s--)if(s!=pp){
o,optp= set[s].i;
if(c==0||(o,nd[optp].clr!=c))
/*40:*/
#line 862 "ssxcc-binary.w"

{
register int nn,ii,p,ss,nnp;
for(nn= optp;o,nd[nn-1].itm> 0;nn--);
for(;o,(ii= nd[nn].itm)> 0;nn++)if(nn!=optp){
p= nd[nn].loc;
if(p>=second&&(o,pos(ii)>=active))continue;
o,ss= size(ii)-1;
if(ss<=1&&p<second){
if(ss==0){
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
fprintf(stderr," can't cover");
print_item_name(ii,stderr);
fprintf(stderr,"\n");
}
tough_itm= ii;
forced= 0;
return 0;
}
else o,force[forced++]= ii;
}
o,nnp= set[ii+ss].i;
o,size(ii)= ss;
oo,set[ii+ss].i= nn,set[p].i= nnp;
oo,nd[nn].loc= ii+ss,nd[nnp].loc= p;
updates++;
}
}

/*:40*/
#line 849 "ssxcc-binary.w"
;
}
o,iii= item[--active];
oo,item[active]= ii,item[p]= iii;
oo,pos(ii)= active,pos(iii)= p;
}

/*:39*/
#line 833 "ssxcc-binary.w"
;
}
return 1;
}

/*:38*//*44:*/
#line 964 "ssxcc-binary.w"

void print_weights(void){
register int k;
for(k= 0;k<itemlength;k++)if(item[k]<second&&wt(item[k])!=w0){
print_item_name(item[k],stderr);
fprintf(stderr," wt "O".1f\n",wt(item[k]));
}
}

/*:44*//*50:*/
#line 1090 "ssxcc-binary.w"

void print_savestack(int start,int stop){
register int k;
for(k= start;k<stop;k++){
print_item_name(savestack[k].l,stderr);
fprintf(stderr,"("O"d), "O"d\n",savestack[k].l,savestack[k].r);
}
}

/*:50*//*51:*/
#line 1099 "ssxcc-binary.w"

void print_state(void){
register int l,s;
fprintf(stderr,"Current state (level "O"d, stage "O"d):\n",level,stage);
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

/*:51*//*52:*/
#line 1140 "ssxcc-binary.w"

void print_progress(void){
register int l,ll,k,d,c,p,ds= 0;
register double f,fd;
fprintf(stderr," after "O"lld mems: "O"lld sols,",mems,count);
for(f= 0.0,fd= 1.0,l= 0;l<level;l++){
if(l<show_levels_max)
fprintf(stderr," "O"s"O"d",levelstage[stagelevel[l]]==l?"":"~",deg[l]);
if(levelstage[stagelevel[l]]==l||l==level-1){
for(k= 1,d= deg[l],ll= l-1;
ll>=0&&stagelevel[ll]==stagelevel[l];k++,d++,ll--);
fd*= d,f+= (k-1)/fd;
}
if(l>=show_levels_max&&!ds)ds= 1,fprintf(stderr,"...");
}
#line 316 "aw_ssxb.ch"
fprintf(stderr," "O".12lf\n",f+0.5/fd);
#line 1156 "ssxcc-binary.w"
}

/*:52*/
#line 72 "ssxcc-binary.w"
;
#line 36 "aw_ssxb.ch"
int main(int argc,char*argv[]){
#line 74 "ssxcc-binary.w"
register int c,cc,i,j,k,p,pp,q,r,s,t,cur_choice,cur_node,best_itm;
#line 42 "aw_ssxb.ch"
/*4:*/
#line 183 "ssxcc-binary.w"

for(j= argc-1,k= 0;j;j--)switch(argv[j][0]){
#line 81 "aw_ssxb.ch"
case'i':k|= (sscanf(argv[j]+1,""O"d",&print_indices)-1);break;
case'v':k|= (sscanf(argv[j]+1,""O"d",&vbose)-1);break;
case'm':k|= (sscanf(argv[j]+1,""O"d",&spacing)-1);break;
case'I':k|= (sscanf(argv[j]+1,""O"ld",&max_cols)-1);break;
case'M':k|= (sscanf(argv[j]+1,""O"ld",&max_nodes)-1);break;
case's':k|= (sscanf(argv[j]+1,""O"d",&random_seed)-1),randomizing= 1;break;
#line 188 "ssxcc-binary.w"
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
#line 98 "aw_ssxb.ch"
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
#line 108 "aw_ssxb.ch"

/*:4*/
#line 42 "aw_ssxb.ch"
;
/*5:*/
#line 110 "aw_ssxb.ch"

if(max_nodes*sizeof(node)> 2147483647){
panic("Too much memory allocated, i.e. parameter M is too large");
}
nd= (node*)malloc(max_nodes*sizeof(node));
item= (int*)malloc(max_cols);
force= (int*)malloc(max_cols);
set= (tetrabyte*)malloc(max_nodes+maxextra*max_cols);
second= max_cols;

bufsize= 9*max_cols+3;
buf= (char*)malloc(bufsize*sizeof(char));
#line 210 "ssxcc-binary.w"

/*:5*/
#line 43 "aw_ssxb.ch"
;
/*26:*/
#line 256 "aw_ssxb.ch"

solution_vector= (int*)calloc(options,sizeof(int));

/*:26*/
#line 44 "aw_ssxb.ch"

#line 76 "ssxcc-binary.w"
/*17:*/
#line 481 "ssxcc-binary.w"

while(1){
if(!fgets(buf,bufsize,stdin))break;
if(o,buf[p= strlen(buf)-1]!='\n')panic("Input line way too long");
for(p= 0;o,isspace(buf[p]);p++);
#line 219 "aw_ssxb.ch"
if(buf[p]=='|'||buf[p]=='%'||!buf[p])continue;
#line 487 "ssxcc-binary.w"
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
#line 225 "aw_ssxb.ch"
oo,lname(last_itm<<2)= namebuf.lr.l,rname(last_itm<<2)= namebuf.lr.r;
add_item(namebuf.str,last_itm<<2);
#line 500 "ssxcc-binary.w"
/*18:*/
#line 511 "ssxcc-binary.w"

for(k= last_itm-1;k;k--){
if(o,lname(k<<2)!=namebuf.lr.l)continue;
if(rname(k<<2)==namebuf.lr.r)break;
}
if(k)panic("Duplicate item name");

/*:18*/
#line 500 "ssxcc-binary.w"
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
#line 76 "ssxcc-binary.w"
;
/*19:*/
#line 522 "ssxcc-binary.w"

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
#line 242 "aw_ssxb.ch"

k= find_item(namebuf.str);
#line 573 "ssxcc-binary.w"
if(!k)panic("Unknown item name");
if(o,pos(k)> i)panic("Duplicate item name in this option");
last_node++;
if(last_node==max_nodes)panic("Too many nodes");
o,t= size(k);
o,nd[last_node].itm= k>>2,nd[last_node].loc= t;
if((k>>2)<second)pp= 1;
o,size(k)= t+1,pos(k)= last_node;

/*:20*/
#line 536 "ssxcc-binary.w"
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
#line 582 "ssxcc-binary.w"

o,k= nd[last_node].itm<<2;
oo,size(k)--,pos(k)= i-1;

/*:21*/
#line 550 "ssxcc-binary.w"
;
last_node--;
}
}else{
o,nd[i].loc= last_node-i;
last_node++;
#line 232 "aw_ssxb.ch"
if(last_node==max_nodes)panic("Too many nodes. Count the number of options using 'counttokens.sh' and use the option 'M<n>'");
#line 557 "ssxcc-binary.w"
options++;
o,nd[last_node].itm= i+1-last_node;
nd[last_node].spr= options;
}
}
/*22:*/
#line 586 "ssxcc-binary.w"

active= itemlength= last_itm-1;
for(k= 0,j= primextra;k<itemlength;k++)
oo,item[k]= j,j+= (k+2<second?primextra:secondextra)+size((k+1)<<2);
setlength= j-4;
if(second==max_cols)osecond= active,second= j;
else osecond= second-1;

/*:22*/
#line 562 "ssxcc-binary.w"
;
/*23:*/
#line 597 "ssxcc-binary.w"

for(;k;k--){
o,j= item[k-1];
if(k==second)second= j;
oo,size(j)= size(k<<2);
if(size(j)==0&&k<=osecond)baditem= k;
o,pos(j)= k-1;
oo,rname(j)= rname(k<<2),lname(j)= lname(k<<2);
if(k<=osecond)o,wt(j)= w0;
}

/*:23*/
#line 563 "ssxcc-binary.w"
;
/*24:*/
#line 608 "ssxcc-binary.w"

for(k= 1;k<last_node;k++){
if(o,nd[k].itm<0)continue;
o,j= item[nd[k].itm-1];
i= j+nd[k].loc;
o,nd[k].itm= j,nd[k].loc= i;
o,set[i].i= k;
}

#line 249 "aw_ssxb.ch"
/*:24*/
#line 564 "ssxcc-binary.w"
;

/*:19*/
#line 77 "ssxcc-binary.w"
;
if(vbose&show_basics)
/*28:*/
#line 630 "ssxcc-binary.w"

fprintf(stderr,
"("O"lld options, "O"d+"O"d items, "O"d entries successfully read)\n",
options,osecond,itemlength-osecond,last_node);

/*:28*/
#line 79 "ssxcc-binary.w"
;
if(vbose&show_tots)
/*29:*/
#line 641 "ssxcc-binary.w"

{
fprintf(stderr,"Item totals:");
for(k= 0;k<itemlength;k++){
if(k==second)fprintf(stderr," |");
fprintf(stderr," "O"d",size(item[k]));
}
fprintf(stderr,"\n");
}

#line 271 "aw_ssxb.ch"
/*:29*/
#line 81 "ssxcc-binary.w"
;
imems= mems,mems= 0;
if(baditem)/*27:*/
#line 259 "aw_ssxb.ch"

#line 618 "ssxcc-binary.w"
{
if(vbose&show_choices){
fprintf(stderr,"Item");
print_item_name(item[baditem-1],stderr);
fprintf(stderr," has no options!\n");
}
}

/*:27*/
#line 83 "ssxcc-binary.w"

else{
if(randomizing)/*30:*/
#line 271 "aw_ssxb.ch"

#if RANDOMIZE
for(k= active;k> 1;){
mems+= 4,j= gb_unif_rand(k);
k--;
oo,oo,t= item[j],item[j]= item[k],item[k]= t;
oo,pos(t)= k,pos(item[j])= j;
}
#endif
#line 658 "ssxcc-binary.w"

/*:30*/
#line 85 "ssxcc-binary.w"
;
/*33:*/
#line 737 "ssxcc-binary.w"

{
level= stage= 0;
forward:nodes++;
if(vbose&show_profile)profile[stage]++;
if(sanity_checking)sanity();
/*43:*/
#line 956 "ssxcc-binary.w"

while(forced){
o,best_itm= force[--forced];
if(o,pos(best_itm)<active){
/*49:*/
#line 1081 "ssxcc-binary.w"

{
if((vbose&show_choices)&&level<show_choices_max)
fprintf(stderr,"(forcing)\n");
o,saved[stage]= saveptr;
t= 1;
goto advance;
}

/*:49*/
#line 960 "ssxcc-binary.w"
;
}
}

/*:43*/
#line 743 "ssxcc-binary.w"
;
/*35:*/
#line 786 "ssxcc-binary.w"

if(delta&&(mems>=thresh)){
thresh+= delta;
if(vbose&show_full_state)print_state();
else print_progress();
}
if(mems>=timeout){
fprintf(stderr,"TIMEOUT!\n");goto done;
}

/*:35*/
#line 744 "ssxcc-binary.w"
;
/*45:*/
#line 1001 "ssxcc-binary.w"

{
t= inf_size,tmems= mems;
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
if(s==0)
fprintf(stderr,"I'm confused.\n");
else o,force[forced++]= item[k];
}else if(s<=t){
if(s<t)best_itm= item[k],t= s;
else if(item[k]<best_itm)best_itm= item[k];
}
}
if((vbose&show_details)&&
level<show_choices_max&&level>=maxl-show_choices_gap){
if(forced)fprintf(stderr," found "O"d forced\n",forced);
else if(t==inf_size)fprintf(stderr," solution\n");
else{
fprintf(stderr," branching on");
print_item_name(best_itm,stderr);
fprintf(stderr,"("O"d)\n",t);
}
}
if(t> maxdeg&&t<inf_size&&!forced)maxdeg= t;
if(shape_file){
if(t==inf_size)fprintf(shape_file,"sol\n");
else{
fprintf(shape_file,""O"d",t);
print_item_name(best_itm,shape_file);
fprintf(shape_file,"\n");
}
fflush(shape_file);
}
cmems+= mems-tmems;
}

/*:45*/
#line 745 "ssxcc-binary.w"
;
if(forced){
o,best_itm= force[--forced];
/*49:*/
#line 1081 "ssxcc-binary.w"

{
if((vbose&show_choices)&&level<show_choices_max)
fprintf(stderr,"(forcing)\n");
o,saved[stage]= saveptr;
t= 1;
goto advance;
}

/*:49*/
#line 748 "ssxcc-binary.w"
;
}
if(t==inf_size)/*46:*/
#line 1046 "ssxcc-binary.w"

{
count++;
#line 289 "aw_ssxb.ch"
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
#line 305 "aw_ssxb.ch"
 if(spacing&&(count mod spacing==0)){
printf(""O"lld:\n",count);
for(k= 0;k<stage;k++)print_option(choice[levelstage[k]],stdout,0);
fflush(stdout);
}
#endif
#line 1054 "ssxcc-binary.w"
 if(count>=maxcount)goto done;
goto backup;
}

/*:46*/
#line 750 "ssxcc-binary.w"
;
/*47:*/
#line 1058 "ssxcc-binary.w"

o,saved[stage]= saveptr;
if(saveptr+active> maxsaveptr){
if(saveptr+active>=savesize){
fprintf(stderr,"Stack overflow (savesize="O"d)!\n",savesize);
exit(-5);
}
maxsaveptr= saveptr+active;
}
for(p= 0;p<active;p++)
ooo,savestack[saveptr+p].l= item[p],savestack[saveptr+p].r= size(item[p]);
saveptr+= active;

/*:47*/
#line 751 "ssxcc-binary.w"
;
advance:oo,choice[level]= cur_choice= set[best_itm].i;
o,deg[level]= t;
if(!include_option(cur_choice))goto tryagain;
/*36:*/
#line 796 "ssxcc-binary.w"

if(++stage> maxs){
if(stage>=max_stage){
fprintf(stderr,"Too many stages!\n");
exit(-40);
}
maxs= stage;
}

/*:36*/
#line 755 "ssxcc-binary.w"
;/*37:*/
#line 805 "ssxcc-binary.w"

if(++level> maxl){
if(level>=max_level){
fprintf(stderr,"Too many levels!\n");
exit(-4);
}
maxl= level;
}
oo,stagelevel[level]= stage,levelstage[stage]= level;

/*:37*/
#line 755 "ssxcc-binary.w"
;
goto forward;
tryagain:if(t==1)goto prebackup;
if(vbose&show_choices)
fprintf(stderr,"Backtracking in stage "O"d\n",stage);
goto purgeit;
prebackup:o,saveptr= saved[stage];
backup:if(--stage<0)goto done;
if(vbose&show_choices)
fprintf(stderr,"Backtracking to stage "O"d\n",stage);
o,level= levelstage[stage];
purgeit:if(o,deg[level]==1)goto prebackup;
/*48:*/
#line 1071 "ssxcc-binary.w"

o,active= saveptr-saved[stage];
saveptr= saved[stage];
for(p= 0;p<active;p++)
oo,size(savestack[saveptr+p].l)= savestack[saveptr+p].r;

/*:48*/
#line 767 "ssxcc-binary.w"
;
o,cur_choice= choice[level];
/*41:*/
#line 896 "ssxcc-binary.w"

{
register int ii,ss,p,nnp;
for(;o,nd[cur_choice-1].itm> 0;cur_choice--);
for(;o,(ii= nd[cur_choice].itm)> 0;cur_choice++){
p= nd[cur_choice].loc;
if(p>=second&&(o,pos(ii)>=active))continue;
o,ss= size(ii)-1;
oo,nnp= set[ii+ss].i,size(ii)= ss;
oo,set[ii+ss].i= cur_choice,set[p].i= nnp;
oo,nd[cur_choice].loc= ii+ss,nd[nnp].loc= p;
updates++;
}
}

/*:41*/
#line 769 "ssxcc-binary.w"
;
/*37:*/
#line 805 "ssxcc-binary.w"

if(++level> maxl){
if(level>=max_level){
fprintf(stderr,"Too many levels!\n");
exit(-4);
}
maxl= level;
}
oo,stagelevel[level]= stage,levelstage[stage]= level;

/*:37*/
#line 770 "ssxcc-binary.w"
;
goto forward;
}

/*:33*/
#line 86 "ssxcc-binary.w"
;
}
done:if(vbose&show_profile)/*53:*/
#line 1158 "ssxcc-binary.w"

{
fprintf(stderr,"Profile:\n");
for(k= 0;k<=maxs;k++)
fprintf(stderr,""O"3d: "O"lld\n",
k,profile[k]);
}

/*:53*/
#line 88 "ssxcc-binary.w"
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
+2*maxl*sizeof(int)+maxsaveptr*sizeof(twoints);
fprintf(stderr," "O"llu updates, "O"llu bytes, "O"llu nodes,",
updates,bytes,nodes);
fprintf(stderr," ccost "O"lld%%.\n",
mems?(200*cmems+mems)/(2*mems):0);
}
if(sanity_checking)fprintf(stderr,"sanity_checking was on!\n");
/*6:*/
#line 211 "ssxcc-binary.w"

if(shape_file)fclose(shape_file);

/*:6*/
#line 106 "ssxcc-binary.w"
;
}

/*:2*/
