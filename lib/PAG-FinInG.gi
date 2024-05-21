#############################################################################
##
##
#W  PAG.gi        Prescribed Automorphism Groups (PAG)
#W                by Vedran Krcadinac 
##
##  Definition of functions in the PAG package depending
##  on the suggested package FinInG.
##


#############################################################################
#
#  AffineMosaic( <k>, <n>, <q> )  
#
#  Returns mosaic of designs with blocks being <A>k</A>-dimensional subspaces 
#  of the affine space <M>AG(</M><A>n</A><M>,</M><A>q</A><M>)</M>. 
#  Uses the <Package>FinInG</Package> package. If the package is not 
#  available, the function is not loaded. 
#
InstallGlobalFunction( AffineMosaic, function( k, n, q )
local a,p,b,D,r,v,L;

  a:=AG(n,q);
  p:=Points(a);
  v:=Size(p);
  b:=ElementsOfIncidenceStructure(a,k+1);
  b:=Concatenation(Set(b,x->Set(ParallelClass(x))));
  D:=List(p,x->List(b,y->IversonBracket(x in y)));
  r:=Sum(D[1]);
  L:=CayleyTableOfGroup(CyclicGroup(v/Sum(TransposedMat(D)[1]))); 
  return D*KroneckerProduct(IdentityMat(r),L);
end );

