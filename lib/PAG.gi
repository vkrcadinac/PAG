#############################################################################
##
##
#W  PAG.gi        Prescribed Automorphism Groups (PAG)
#W                by Vedran Krcadinac 
##
##  Definition of functions in the PAG package.
##
##


#############################################################################
#
#  PrimitiveGroupsOfDegree( <v> ) 
#
#  Returns a list of all primitive permutation groups on v points.
#
InstallGlobalFunction( PrimitiveGroupsOfDegree, function( v )

    return List([1..NrPrimitiveGroups(v)],x->PrimitiveGroup(v,x));
end );


#############################################################################
#
#  TransitiveGroupsOfDegree( <v> ) 
#
#  Returns a list of all transitive permutation groups on v points.
#
InstallGlobalFunction( TransitiveGroupsOfDegree, function( v )

    return AllTransitiveGroups(NrMovedPoints,v);
end );


#############################################################################
#
#  ConjugationFilter( <v>, <gl>[, <opt>] ) 
#
#  Given a list of permutation groups <A>gl</A>, returns a set 
#  of representatives up to conjugation in the symmetric group 
#  of degree <A>v</A>, i.e. up to permutation isomorphism. If 
#  <A>gl</A> is partitioned into blocks, it is assumed that the 
#  groups from different blocks are not equivalent and the function 
#  is applied to each block. This reduces the number of ccnjugation
#  tests and makes the computation faster. The list <A>gl</A> can 
#  be partitioned using invariants given in the record <A>opt</A>.
#  If the record has a component <A>Invariant</A>, the list is 
#  partitioned accordingly and no conjugation tests are performed.
#  Here are the values that <A>Invariant</A> can take: 
#  <List>
#  <Item><A>Invariant</A>:="OrbitSizes"  The orbit sizes of 
#  <C>g</C> on <C>[1..</C><A>v</A><C>]</C> are used to partition
#  <A>gl</A>.</Item> 
#  <Item><A>Invariant</A>:="CycleLengths"  The cycle lengths of 
#  all elements of <C>g</C> on <C>[1..</C><A>v</A><C>]</C> are 
#  used to partition <A>gl</A>.</Item> 
#  <Item><A>Invariant</A>:=<C>function</C>  Any function that 
#  is an invariant of permutation isomorphism can also be
#  given and is then used to partition <A>gl</A>.</Item> 
#  </List>
#
InstallGlobalFunction( ConjugationFilter, function( v, gl, opt... )
local s,rez,g,inv,val,sval;

  if Size(opt)>0 then 
    opt:=opt[1];
  else
    opt:=rec();
  fi;
  if IsBound(opt.Invariant) then
    if NestingDepthA(gl)=2 then
      return Concatenation(List(gl,x->ConjugationFilter(v,x,opt)));
    else
      inv:=opt.Invariant;
      if not IsFunction(inv) then
        if inv="OrbitSizes" then
          inv:=g->AsSortedList(List(Orbits(g,[1..v]),Size)); 
        else 
          if inv="CycleLengths" then
            inv:=g->Collected(List(Elements(g),e->AsSortedList(CycleLengths(e,[1..v]))));
          else
            Print("Unknown invariant!\n");
            return fail;
          fi;
        fi;
      fi; 
      val:=List(gl,inv);
      sval:=AsSet(val);
      return List(sval,x->gl{Positions(val,x)});
    fi;
  else 
    if NestingDepthA(gl)=2 then
      return List(gl,x->ConjugationFilter(v,x));
    else
      if Size(gl)<=1 then
        return gl;
      else
        s:=SymmetricGroup(v);
        rez:=[];
        while gl<>[] do
          g:=gl[1];
          rez:=Concatenation(rez,[g]);
          gl:=Filtered(gl,x->not IsConjugate(s,g,x));
        od;
        return rez;
      fi;
    fi;
  fi;
end );


#############################################################################
#
#  ConjugationFilter2( <v>, <gl>[, <opt>] ) 
#
#  Given a list of permutation groups <A>gl</A>, returns a set 
#  of representatives up to conjugation in the symmetric group 
#  of degree <A>v</A>, i.e. up to permutation isomorphism. Uses 
#  <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno 
#  <Cite Key='MP14'/>. The last argument <A>opt</A> is a record 
#  for options. The possible components of <A>opt</A> are:
#  <List>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files 
#  in the named directory. By default, 
#  <C>PAGGlobalOptions.TempDir</C> is used.</Item>
#  </List>
#
InstallGlobalFunction( ConjugationFilter2, function( v, gl, opt... )
local tempdir,input,output,command,str,l;

  if Size(opt)>0 then
    opt:=opt[1];
  else
    opt:=rec();
  fi;

  tempdir:=PAGGlobalOptions.TempDir;
  if IsBound(opt.TempDir) then
    tempdir:=Directory(opt.TempDir);
  fi;

  if Size(gl)<=1 then return gl;
  else
    PrintTo( Filename( tempdir, "conjfilter.gin" ), 
      [v,Size(gl[1]),List(gl,g->List(Elements(g),x->List([1..v],y->y^x)))]
    );

    input:=InputTextFile( Filename( tempdir, "conjfilter.gin" ) );
    output:=OutputTextFile( Filename( tempdir, "conjfilter.in" ), false );
    command:=Filename( DirectoriesPackagePrograms( "PAG" ), "gap2raw" );
    Process( tempdir, command, input, output, [  ] );
    CloseStream(input);
    CloseStream(output);

    input:=InputTextFile( Filename( tempdir, "conjfilter.in" ) );
    output:=OutputTextFile( Filename( tempdir, "conjfilter.out" ), false );
    command:=Filename( DirectoriesPackagePrograms( "PAG" ), "conjfilter" );
    Process( tempdir, command, input, output, [  ] );
    CloseStream(input);
    CloseStream(output);

    input:=InputTextFile( Filename(tempdir,"conjfilter.out") );
    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      l:=[];
    else
      NormalizeWhitespace(str);
      l:=List(SplitString(str," "),EvalString);
    fi;
    return gl{l};
  fi;
end );


#############################################################################
#
#  Homogeneity( <G> ) 
#
#  Returns the degree of homogeneity of the permutation group <A>G</A>, i.e. the largest
#  integer <M>k</M> such that <A>G</A> is <M>k</M>-homogeneous. This means that every
#  <M>k</M>-subset of points can be mapped to every other. Kantor <Cite Key='WK72'/>
#  classified all groups that are <M>k</M>-homogenous but not <M>k</M>-transitive.
#
InstallGlobalFunction( Homogeneity, function( g )
local o,i;

  o:=Orbits(g);
  if Size(o)>1 then 
    return 0;
  else
    i:=Transitivity(g);
    o:=Union(o);
    while Size(OrbitsDomain(g,Combinations(o,i+1),OnSets))=1 do
      i:=i+1;
    od;
    return i;
  fi;
end );


#############################################################################
#
#  CyclicPerm( <n> ) 
#
#  Returns the cyclic permutation (1,...,<A>n</A>).
#
InstallGlobalFunction( CyclicPerm, function( n )
local  l;

    l := [ 2 .. n ];
    Append( l, [ 1 ] );
    return PermList( l );
end );


#############################################################################
#
#  MovePerm( <p>, <from>, <to> ) 
#
#  Moves permutation <A>p</A> acting on the set <A>from</A> to a
#  permutation acting on the set <A>to</A>. The arguments <A>from</A>
#  and <A>to</A> should be lists of integers of the same size. 
#  Alternatively, if instead of <A>from</A> and <A>to</A> just
#  one integer argument <A>by</A> is given, the permutation is 
#  moved from <C>MovedPoints(</C><A>p</A><C>)</C> to
#  <C>MovedPoints(</C><A>p</A><C>)+</C><A>by</A>.
#
InstallGlobalFunction( MovePerm, function( arg )
local c,i,from,to,dis,by,p;

    if Size(arg)=3 then

      p:=arg[1];
      from:=arg[2];
      to:=arg[3];
      if Intersection(from,to)=[] then
        c:=();
        for i in [1..Length(from)] do
          c:=c*(from[i],to[i]);
        od;
        return c*p*c;
      else
        i:=Maximum(Union(from,to)); 
        dis:=[i+1..i+Size(from)];
        return MovePerm(MovePerm(p,from,dis),dis,to);
      fi;

   else

      p:=arg[1];
      by:=arg[2];
      return MovePerm(p,MovedPoints(p),MovedPoints(p)+by);

   fi;
end );


#############################################################################
#
#  ToGroup( <G>, <f> ) 
#
#  Apply function <A>f</A> to each generator of the group <A>G</A>.
#
InstallGlobalFunction( ToGroup, function( g, f )
   return Group(List(GeneratorsOfGroup(g),f));
end );


#############################################################################
#
#  MultiPerm( <G>, <set>, <m> ) 
#
#  Repeat the action of a permutation <A>m</A> times. The new 
#  permutation acts on <A>m</A> disjoint copies of <A>set</A>.
#
InstallGlobalFunction( MultiPerm, function( p, set, m )
local np,i;
   np:=p;
   for i in [1..m-1] do
     np:=np*MovePerm(p,set,set+i*Maximum(set));
   od;
   return np;
end );


#############################################################################
#
#  MoveGroup( <G>, <from>, <to> ) 
#
#  Apply <C>MovePerm</C> to each generator of the group <A>G</A>.
#
InstallGlobalFunction( MoveGroup, function( arg )
   if Size(arg)=3 then
     return ToGroup(arg[1],x->MovePerm(x,arg[2],arg[3]));
   else
     return ToGroup(arg[1],x->MovePerm(x,arg[2]));
   fi;
end );


#############################################################################
#
#  MultiGroup( <G>, <set>, <m> ) 
#
#  Apply <C>MultiPerm</C> to each generator of the group <A>G</A>.
#
InstallGlobalFunction( MultiGroup, function( g, set, m )
   return ToGroup(g,x->MultiPerm(x,set,m));
end );


#############################################################################
#
#  RestrictedGroup( <G>, <set> ) 
#
#  Apply <Ref Func="RestrictedPerm" BookName="ref"/> to each generator of the group <A>G</A>.
#
InstallGlobalFunction( RestrictedGroup, function( g, set )
   return ToGroup(g,x->RestrictedPerm(x,set));
end );


#############################################################################
#
#  TidyGroup( <G>, <set>[, <opt>] ) 
#
#  Given a permutation group <A>G</A> and a set, returns a 
#  permutationally isomorphic group such that its orbits 
#  contain consecutive integers and are sorted by size. The 
#  optional argument <A>opt</A> is a record with component 
#  <List>
#  <Item><A>MinimalGeneratingSet</A>:=<C>true</C>/<C>false</C>  
#  Use a minimal generating set of <A>G</A>. The default is 
#  <C>true</C>.</Item>
#  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C>  
#  Put orbits that are equivalent under the normalizer in
#  consecutive places. It is assumed that <A>set</A> is
#  of the form <C>[1..v]</C> and the normalizer of <A>G</A>
#  in <C>SymmetricGroup(v)</C> is computed. The default is 
#  <C>true</C>.</Item>
#  </List>
#
InstallGlobalFunction( TidyGroup, function(g,set,opt...)
local min,gen,orb,s0,s1,s2,s3,norm,n;

  min:=true;
  norm:=true;
  if Size(opt)>0 then
    if IsBound(opt[1].MinimalGeneratingSet) then
      min:=opt[1].MinimalGeneratingSet;
    fi;
    if IsBound(opt[1].Normalizer) then
      norm:=opt[1].Normalizer;
    fi;
  fi;

  if min then
    gen:=MinimalGeneratingSet(g);
  else
    gen:=GeneratorsOfGroup(g);
  fi;

  orb:=List(Orbits(g,set),AsSet);
  if norm then
    n:=Normalizer(SymmetricGroup(Size(set)),g);
    orb:=Orbits(n,orb,OnSets);
    orb:=Concatenation(List(AsSortedList(List(orb,x->[Size(x[1]),x])),y->y[2]));
  else
    orb:=Permuted(orb,Sortex(List(orb,Size)));
  fi;
  s0:=List(orb,Size);
  s1:=List(orb,x->[1..Size(x)]);
  s2:=List([1..Size(orb)],i->Sum(s0{[1..i-1]}));
  s3:=List(TransposedMat([s1,s2]),Sum);
  return Group(List(TransposedMat(List([1..Size(orb)],i->List(gen,y->MovePerm(Sortex(List(orb[i],x->x^y)),s1[i],s3[i])))),Product));
end );


#############################################################################
#
#  AllSubgroupsConjugation( <G> ) 
#
#  Returns a list of all subgroups of <A>G</A> up to conjugation. 
#
InstallGlobalFunction( AllSubgroupsConjugation, function( g )

    return List(ConjugacyClassesSubgroups(g),Representative);
end );


#############################################################################
#
#  PermRepresentationRight( <G> ) 
#
# Returns the regular permutation representation of a group <A>G</A>
# by right multiplication. 
#
InstallGlobalFunction( PermRepresentationRight, function( g )
local l;

  l:=SortedList(Elements(g));
  return Group(List(GeneratorsOfGroup(g),x->Sortex(List(l,y->y*x))));

end );


#############################################################################
#
#  PermRepresentationLeft( <G> ) 
#
# Returns the regular permutation representation of a group <A>G</A>
# by left multiplication. 
#
InstallGlobalFunction( PermRepresentationLeft, function( g )
local l;

  l:=SortedList(Elements(g));
  return Group(List(GeneratorsOfGroup(g),x->Sortex(List(l,y->x*y))));

end );


#############################################################################
#
#  ExtendedPermRepresentation( <G> ) 
#
#  Returns the extended permutation representation of a group <A>G</A>,
#  that includes right multiplication, left multiplication, and group
#  automorphisms. 
#
#
InstallGlobalFunction( ExtendedPermRepresentation, function( g )
local l;

  l:=SortedList(Elements(g));
  return Group(Concatenation(List(GeneratorsOfGroup(AutomorphismGroup(g)),x->Sortex(List(l,y->y^x))),GeneratorsOfGroup(PermRepresentationRight(g))));

end );


#############################################################################
#
#  AllPermRepresentations( <G>, <nu> ) 
#
#  Returns all permutation representations of a group <A>G</A>
#  on orbits of size given in a list of integers <A>nu</A>.
#  The integers should be divisors of the order of <A>G</A>.
#
InstallGlobalFunction( AllPermRepresentations, function( g, nu )
local trans,gen,moveperms,mgen,pg,n;

  trans:=List(AllSubgroupsConjugation(g),x->[Size(g)/Size(x),GeneratorsOfGroup(Action(g,RightCosets(g,x),OnRight))]);
  gen:=List(nu,x->List(Filtered(trans,y->y[1]=x),y->y[2]));
  moveperms:=function(l,s,m)
    return List(l,x->MovePerm(x,[1..s],[1..s]+m));
  end;
  mgen:=List([1..Size(nu)],i->List(gen[i],x->moveperms(x,nu[i],Sum(nu{[1..i-1]}))));
  n:=Size(g);
  pg:=Filtered(List(Cartesian(mgen),x->Group(List(TransposedMat(x),Product))),y->Size(y)=n);
  return pg;
end );


#############################################################################
#
#  OrbitFilter1( <G>, <obj>, <action> )  
#
#  Takes a list of objects <A>obj</A> and returns one representative
#  from each orbit of the group <A>G</A> acting by <A>action</A>.
#  Uses the GAP function Orbits. 
#
InstallGlobalFunction( OrbitFilter1, function( G, obj, action )
local rep;

  rep:=[];
  while obj<>[] do
    Add(rep,obj[1]);
    obj:=Difference(obj,Orbit(G,obj[1],action));
  od;
  return rep;

end );


#############################################################################
#
#  OrbitFilter2( <G>, <obj>, <action> )  
#
#  Takes a list of objects <A>obj</A> and returns one representative
#  from each orbit of the group <A>G</A> acting by <A>action</A>.
#  Uses the function CanonicalImage from the package Images. 
#
InstallGlobalFunction( OrbitFilter2, function( G, obj, action )

  return AsSet(List(obj,x->CanonicalImage(G,x,action)));

end );


#############################################################################
#
#  InequivalentSubsetOrbits( <N>, <ksub>[, <opt>] ) 
#
#  Takes a list of subset orbit representatives <A>ksub</A> and returns 
#  indices of the ones that cannot be mapped onto each other by the 
#  permutation group <A>N</A> (typically the normalizer of the group
#  generating the orbits). Uses the 
#  <Ref Func="CanonicalImage" BookName="Images"/> function from the 
#  <Package>Images</Package> package. The optional argument <A>opt</A> 
#  is a record for options. Possible components are:
#  <List>
#  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Returns a partition 
#  of <A>ksub</A> into <A>N</A>-equivalent subsets, not just one 
#  representative from each block. The partition is also given by 
#  indices.</Item> 
#  </List>
#
InstallGlobalFunction( InequivalentSubsetOrbits, function( n, ksub, opt... )
local ksubcan,pos,part,rez;

    part:=false; 
    if Size(opt)>0 then 
      if IsBound(opt[1].Partition) then
        part:=opt[1].Partition;
      fi;
    fi;
    ksubcan:=List(ksub,x->CanonicalImage(n,x,OnSets));
    pos:=AsSet(List(AsSet(ksubcan),x->Position(ksubcan,x)));
    if part then
      rez:=List(pos,x->Positions(ksubcan,ksubcan[x]));
      return Reversed(Permuted(rez,Sortex(List(rez,Size))));
    else
      return pos;
    fi;
end );


#############################################################################
#
#  InequivalentSubsetOrbitPairs( <N>, <G>, <ksub>[, <opt>] ) 
#
#  Takes a list of subset orbit representatives <A>ksub</A> and returns 
#  indices of the pairs that cannot be mapped onto each other by the 
#  permutation group <A>N</A> (typically the normalizer of the group
#  <A>G</A> generating the orbits). Uses the 
#  <Ref Func="CanonicalImage" BookName="Images"/> function from the 
#  <Package>Images</Package> package. The optional argument <A>opt</A> 
#  is a record for options. Possible components are:
#  <List>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  <Item><A>IntersectionNumbers</A>:=<A>lin</A>  If defined, only
#  pairs of compatible orbits are returned. This means that each
#  element from one orbit intersects each element from the other 
#  in a subset of size given in the list of integers <A>lin</A>.</Item>
#  </List>
#
InstallGlobalFunction( InequivalentSubsetOrbitPairs, function( n, g, ksub, opt... )
local verb,ins,i,j,stab,rez,rez1,lin,o,ksub1;

    verb := false;
    lin:=[];
    if Size(opt)>0 then 
      if IsBound(opt[1].Verbose) then
        verb:=opt[1].Verbose;
      fi;
      if IsBound(opt[1].IntersectionNumbers) then
        lin:=opt[1].IntersectionNumbers;
      fi;
    fi;

    if verb then
      Print("Calculating inequivalent subsets...\n");
    fi;
    ins:=InequivalentSubsetOrbits(n,ksub);
    if verb then
      Print(Size(ins),"\n");
    fi;

    rez:=[];
    j:=0;
    if verb then
      Print("Calculating pairs...\n");
    fi;
    for i in ins do
      j:=j+1;
      if verb then
        Print(j,"\n");
      fi;
      stab:=Stabiliser(n,ksub[i],OnSets);
      if lin=[] then
        ksub1:=ksub; 
      else
        o:=Orbit(g,ksub[i],OnSets);
        ksub1:=Filtered(ksub,y->IsSubset(lin,AsSet(List(o,x->Size(Intersection(x,y))))));
      fi;
      rez1:=List(Cartesian([i],Difference(InequivalentSubsetOrbits(stab,ksub1),[i])),AsSet);
      rez:=Union(rez,rez1);
   od;
   return rez;
end );


#############################################################################
#
#  SubsetOrbitRep( <G>, <v>, <k>[, <opt>] ) 
#
#  Computes orbit representatives of k-subsets of [1..v] under the 
#  action of the permutation group G. Options: 
#  -SizeLE:=<n>  Returns orbits of size less or equal to n.  
#  -IntersectionNumbers:=<lin>  Returns "good" orbits, with 
#   intersection numbers in the list of integers lin.
#
InstallGlobalFunction( SubsetOrbitRep, function( g, v, k, opt... )
local rep,gen,size,i,orbs2seeds,subsize,allsub,l,lin;

    size:=0;
    lin:=[];

    if Size(opt)>=1 then
      if IsBound(opt[1].SizeLE) then
         size := opt[1].SizeLE;
      fi;
      if IsBound(opt[1].IntersectionNumbers) then
         lin := opt[1].IntersectionNumbers;
      fi;
    fi;

    rep:=[];

    gen:=function(g,v,k,U,s)
    local e,U1,m;
 
      if k=s then
        Add(rep,U); 
      else
        if U=[] then
          m:=0;
        else
          m:=Maximum(U);
        fi; 
        for e in [m+1..v] do
          U1:=Concatenation(U,[e]);
          if IsMinimalImage(g,U1,OnSets) then
             gen(g,v,k,U1,s+1);
          fi;
        od;
      fi;
    end;

    orbs2seeds:=function(orbs,k)
    local sizes,sorb,i;

      sizes:=AsSet(List(orbs,Size));
      sorb:=List([1..Maximum(sizes)],x->[]);
      for i in sizes do
        sorb[i]:=Filtered(orbs,x->Size(x)=i);
      od;
      return List(Concatenation(List(RestrictedPartitions(k,sizes),
         p->List(Cartesian(List(sizes,y->List(Combinations(sorb[y],Number(p,x->x=y)),
         Concatenation))),Concatenation))),AsSet);
    end;

    if size<>0 and size<Size(g) then
#
# Algorithm from [KV16]
#
      subsize:=Size(g)/size; 
      allsub:=AllSubgroupsConjugation(g);
      allsub:=Filtered(allsub,x->Size(x)>=subsize);
      l:=List(allsub,x->Orbits(x,[1..v]));
      l:=List(l,x->orbs2seeds(x,k));
      rep:=OrbitFilter1(g,Union(l),OnSets);
    else
#
# Algorithm from [KVK21]
#
      gen(g,v,k,[],0);
    fi;
    
    if lin<>[] then
      rep:=Filtered(rep,x->IsGoodSubsetOrbit(g,x,lin));
    fi;
    return rep;
end );


#############################################################################
#
#  SubsetOrbitRepShort1( <G>, <v>, <k>, <size> ) 
#
#  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
#  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
#  than the order of the group <A>G</A>. The algorithm is described in 
#  <Cite Key='KV16'/>. The implementation uses <Ref Func="OrbitFilter1"/>.
#
InstallGlobalFunction( SubsetOrbitRepShort1, function( g, v, k, size )
local rep,i,orbs2seeds,subsize,allsub,l,lin;

    rep:=[];

    orbs2seeds:=function(orbs,k)
    local sizes,sorb,i;

      sizes:=AsSet(List(orbs,Size));
      sorb:=List([1..Maximum(sizes)],x->[]);
      for i in sizes do
        sorb[i]:=Filtered(orbs,x->Size(x)=i);
      od;
      return List(Concatenation(List(RestrictedPartitions(k,sizes),
         p->List(Cartesian(List(sizes,y->List(Combinations(sorb[y],Number(p,x->x=y)),
         Concatenation))),Concatenation))),AsSet);
    end;

    if size<Size(g) then
      subsize:=Size(g)/size; 
      allsub:=AllSubgroupsConjugation(g);
      allsub:=Filtered(allsub,x->Size(x)>=subsize);
      l:=List(allsub,x->Orbits(x,[1..v]));
      l:=List(l,x->orbs2seeds(x,k));
      rep:=OrbitFilter1(g,Union(l),OnSets);
      return rep;
    else
      Print("Last argument 'size' must be less than the order of the group G.\n");
      return ;
    fi; 
end );


#############################################################################
#
#  SubsetOrbitRepShort2( <G>, <v>, <k>, <size> ) 
#
#  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
#  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
#  than the order of the group <A>G</A>. The algorithm is described in 
#  <Cite Key='KV16'/>. The implementation uses <Ref Func="OrbitFilter2"/>.
#
InstallGlobalFunction( SubsetOrbitRepShort2, function( g, v, k, size )
local rep,i,orbs2seeds,subsize,allsub,l,lin;

    rep:=[];

    orbs2seeds:=function(orbs,k)
    local sizes,sorb,i;

      sizes:=AsSet(List(orbs,Size));
      sorb:=List([1..Maximum(sizes)],x->[]);
      for i in sizes do
        sorb[i]:=Filtered(orbs,x->Size(x)=i);
      od;
      return List(Concatenation(List(RestrictedPartitions(k,sizes),
         p->List(Cartesian(List(sizes,y->List(Combinations(sorb[y],Number(p,x->x=y)),
         Concatenation))),Concatenation))),AsSet);
    end;

    if size<Size(g) then
      subsize:=Size(g)/size; 
      allsub:=AllSubgroupsConjugation(g);
      allsub:=Filtered(allsub,x->Size(x)>=subsize);
      l:=List(allsub,x->Orbits(x,[1..v]));
      l:=List(l,x->orbs2seeds(x,k));
      rep:=OrbitFilter2(g,Union(l),OnSets);
      return rep;
    else
      Print("Last argument 'size' must be less than the order of the group G.\n");
      return ;
    fi; 
end );


#############################################################################
#
#  SubsetOrbitRepShort3( <G>, <v>, <k>, <size>[, <opt>] ) 
#
#  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
#  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
#  than the order of the group <A>G</A>. The algorithm is described in 
#  <Cite Key='KV16'/>. This implementation calls a C program and allows 
#  specifying intersection numbers in a record <A>opt</A>. Possible 
#  components are:
#  <List>
#  <Item><A>IntersectionNumbers</A>:=<C>lin</C>  A set <C>lin</C> of up
#  to four intersection numbers can be given.</Item> 
#  <Item><A>SteinerT</A>:=<C>t</C>  Computes short orbits for Steiner 
#  <C>t</C>-designs. An integer <C>t</C> in [2,3,4] can be given;
#  this means that the intersection numbers are [0..<C>t</C>-1].
#  </Item> 
#  </List>
#
InstallGlobalFunction( SubsetOrbitRepShort3, function( g, v, k, size, opt... )
local cmpsize,subsize,l,o,allsub,input,output,command,x,y,z,w,dsub,h,t,lin,tempdir;

  cmpsize:=function(x,y)
    return Size(x)<Size(y);
  end;

  if Size(opt)>0 then
    opt:=opt[1];
  else
    opt:=rec();
  fi;
  t:=0;
  if IsBound(opt.SteinerT) then
    t:=opt.SteinerT;
  fi;
  lin:=[];
  if IsBound(opt.IntersectionNumbers) then
    lin:=opt.IntersectionNumbers;
  fi;

  tempdir := PAGGlobalOptions.TempDir;

  if t<>0 and lin<>[] then
    Print("Only one of the options SteinerT and IntersectionNumbers may be used.\n");
    return fail;
  fi;

  if t=0 and lin=[] then
    x:=-1;
    y:=-1;
    z:=-1;
    w:=-1;
  fi;

  if t<>0 then
    if not t in [2,3,4] then
      Print("SteinerT should be in [2,3,4].\n");
      return fail;
    fi;
    if t=2 then x:=0; y:=0; z:=0; w:=1; fi;
    if t=3 then x:=0; y:=0; z:=1; w:=2; fi;
    if t=4 then x:=0; y:=1; z:=2; w:=3; fi;
  fi;
  
  if lin<>[] then
    if not Size(lin) in [1,2,3,4] then
      Print("IntersectionNumbers should be a list of 1 to 4 integers.\n");
      return fail;
    fi;
    if Size(lin)=1 then x:=lin[1]; y:=lin[1]; z:=lin[1]; w:=lin[1]; fi;
    if Size(lin)=2 then x:=lin[1]; y:=lin[1]; z:=lin[1]; w:=lin[2]; fi;
    if Size(lin)=3 then x:=lin[1]; y:=lin[1]; z:=lin[2]; w:=lin[3]; fi;
    if Size(lin)=4 then x:=lin[1]; y:=lin[2]; z:=lin[3]; w:=lin[4]; fi;
  fi;

  output:=OutputTextFile( Filename( tempdir, "shortorb.gin" ), false );
  WriteLine(output,String([v,k]));
  WriteLine(output,String([x,y,z,w]));
  WriteLine(output,String(Size(g)));
  List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
  subsize:=Size(g)/size;
  allsub:=List(ConjugacyClassesSubgroups(g),Representative);
  allsub:=Filtered(allsub,x->Size(x)>=subsize);
#  Print( "allsub: ", Size( allsub ) );
  Sort( allsub, cmpsize );
  dsub := [  ];
  while allsub <> [  ]  do
      h := allsub[1];
      Append( dsub, [ h ] );
      allsub := Filtered( allsub, function ( x )
              return not IsSubgroup( x, h );
          end );
  od;
#  Print( ", dsub: ", Size( dsub ), "\n" );
  allsub := dsub;
  l:=List(allsub,x->Orbits(x,[1..v]));
  List(l,x->List(x,y->WriteLine(output,Concatenation(String(y)," -1"))));
  CloseStream(output);

  input:=InputTextFile( Filename( tempdir, "shortorb.gin" ) );
  output:=OutputTextFile( Filename( tempdir, "shortorb.in" ), false );
  command:=Filename( DirectoriesPackagePrograms( "PAG" ), "gap2raw" );
  Process( tempdir, command, input, output, [  ] );
  CloseStream(input);
  CloseStream(output);

  input:=InputTextFile( Filename( tempdir, "shortorb.in" ) );
  output:=OutputTextFile( Filename( tempdir, "shortorb.out" ), false );
  command:=Filename( DirectoriesPackagePrograms( "PAG" ), "shortorb4" );
  Process( tempdir, command, input, output, [  ] );
  CloseStream(input);
  CloseStream(output);

  Read( Filename( tempdir, "shortorb.out" ) );
  return OrbitFilter1(g,AsSet(PAGProcessResult),OnSets);
end );


#############################################################################
#
#  SubsetOrbitRepIN( <G>, <v>, <k>, <lin>[, <opt>] ) 
#
#  Computes orbit representatives of k-subsets of [1..v] under the 
#  action of the permutation group G with specified intersection
#  numbers. 
#
InstallGlobalFunction( SubsetOrbitRepIN, function( g, v, k, lin, opt... )
local rep,gen,maxin,flevel,srep,verb;

    maxin := Maximum(lin);
    verb := false;
    flevel:=k;
    if Size(opt)>0 then 
      if IsBound(opt[1].FilteringLevel) then
        flevel:=opt[1].FilteringLevel;
      fi;
      if IsBound(opt[1].Verbose) then
        verb:=opt[1].Verbose;
      fi;
    fi;

    gen:=function(g,v,k,U,s)
    local e,U1,m,o,so,ok,i,j;
 
      if k=s then
        if IsGoodSubsetOrbit(g,U,lin) then
          Add(rep,U); 
        fi;
      else
        if U=[] then
          m:=0;
        else
          m:=Maximum(U);
        fi; 
        for e in [m+1..v] do
          U1:=Concatenation(U,[e]);
          if IsMinimalImage(g,U1,OnSets) then
             if s>maxin and s<flevel then
                o:=Orbit(g,U1,OnSets);
                so:=Size(o);
                ok := true;
                i := 1;
                while ok and i < so  do
                  j := i + 1;
                  while ok and j <= so  do
                    ok := Size( Intersection( o[i], o[j] ) ) <= maxin;
                    j := j + 1;
                  od;
                  i := i + 1;
                od;
                if ok then
                  gen(g,v,k,U1,s+1);
                fi;
             else
               gen(g,v,k,U1,s+1);
             fi;
          fi;
        od;
      fi;
    end;

    if verb then
      Print("Computing long orbits...\n");    
    fi;

    rep := [];
    gen(g,v,k,[],0);

    if verb then
      Print(Size(rep),"\n");    
      Print("Computing short orbits...\n");    
    fi;

    srep:=Filtered(SubsetOrbitRepShort1(g,v,k,Size(g)/2),x->IsGoodSubsetOrbit(g,x,lin));
    
    if verb then
      Print(Size(srep),"\n");    
      Print("Joininig long and short orbits...\n");    
    fi;

    rep:=OrbitFilter1(g,Union(rep,srep),OnSets);

    if verb then
      Print(Size(rep),"\n");    
    fi;

    return rep;
end );


#############################################################################
#
#  SubsetOrbitRepIN2( <G>, <v>, <k>, <x>, <y>[, <opt>] ) 
#
#  Computes orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
#  under the action of the permutation group <A>G</A> with intersection 
#  numbers <A>x</A> and <A>y</A>. Calls a <C>C</C>-subroutine for the 
#  time-critical part of the computation and should be faster than
#  <Ref Func="SubsetOrbitRepIN"/>. The algorithm is described in 
#  <Cite Key='KVK21'/>. The last (optional) argument <A>opt</A> is 
#  a record for options. Possible components are:
#  <List>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  </List>
#
InstallGlobalFunction( SubsetOrbitRepIN2, function( g, v, k, x, y, opt... )
local verb,input,output,command,srep,rep,long,short;

    long:=true;
    short:=true;
    verb := false;
    if Size(opt)>0 then 
      if IsBound(opt[1].Verbose) then
        verb:=opt[1].Verbose;
      fi;
      if IsBound(opt[1].Long) then
        long:=opt[1].Long;
      fi;
      if IsBound(opt[1].Short) then
        short:=opt[1].Short;
      fi;
    fi;

    if long then
      if verb then
        Print("Computing long orbits...\n");    
      fi;
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.gin"), false );
      WriteLine(output,String([v,k]));
      WriteLine(output,String([x,y]));
      WriteLine(output,String(Size(g)));
      List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
      CloseStream(output);
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.gin") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.in"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "gap2raw");
      Process(PAGGlobalOptions.TempDir, command, input, output,[]); 
      CloseStream(input);
      CloseStream(output);
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.in") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.out"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "forbrepint4");
      Process(PAGGlobalOptions.TempDir, command, input, output,[]); 
      CloseStream(input);
      CloseStream(output);
      Read( Filename(PAGGlobalOptions.TempDir,"forbrepint4.out") );
      if verb then
        Print(Size(PAGProcessResult),"\n");    
      fi;
    else
      PAGProcessResult:=[];
    fi;

    if short then
      if verb then
        Print("Computing short orbits...\n");    
      fi;
      srep:=Filtered(SubsetOrbitRepShort1(g,v,k,Size(g)/2),z->IsGoodSubsetOrbit(g,z,[x,y]));
      if verb then
        Print(Size(srep),"\n");    
      fi;
    else
      srep:=[];
    fi;
    
    if verb and long and short then
      Print("Joininig long and short orbits...\n");    
    fi;

    rep:=Union(srep,PAGProcessResult);

    if verb and long and short then
      Print(Size(rep),"\n");    
    fi;

    return rep;
end );


#############################################################################
#
#  SubsetOrbitRepSteiner( <G>, <t>, <v>, <k>[, <opt>] ) 
#
#  Computes orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
#  under the action of the permutation group <A>G</A> with intersection 
#  numbers strictly less than <A>t</A>. Calls <C>C</C>-subroutines 
#  for the time-critical parts of the computation. The algorithm is 
#  described in <Cite Key='KVK21'/>. The last (optional) argument 
#  <A>opt</A> is a record for options. Possible components are:
#  <List>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  <Item><A>Long</A>:=<C>true</C>/<C>false</C>  Compute and return
#  the long orbits (of size equal to <M>|G|</M>).</Item>
#  <Item><A>Short</A>:=<C>true</C>/<C>false</C>  Compute and return
#  the short orbits (of size less than <M>|G|</M>).</Item>
#  </List>
#
InstallGlobalFunction( SubsetOrbitRepSteiner, function( g, t, v, k, opt... )
local verb,input,output,command,srep,lrep,rep,long,short,x,y;

    long:=true;
    short:=true;
    verb:=false;
    x:=0;
    y:=t-1;
    if Size(opt)>0 then 
      if IsBound(opt[1].Verbose) then
        verb:=opt[1].Verbose;
      fi;
      if IsBound(opt[1].Long) then
        long:=opt[1].Long;
      fi;
      if IsBound(opt[1].Short) then
        short:=opt[1].Short;
      fi;
    fi;

    if long then
      if verb then
        Print("Computing long orbits...\n");    
      fi;
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.gin"), false );
      WriteLine(output,String([v,k]));
      WriteLine(output,String([x,y]));
      WriteLine(output,String(Size(g)));
      List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
      CloseStream(output);
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.gin") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.in"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "gap2raw");
      Process(PAGGlobalOptions.TempDir, command, input, output,[]); 
      CloseStream(input);
      CloseStream(output);
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.in") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"forbrepint4.out"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "forbrepint4");
      Process(PAGGlobalOptions.TempDir, command, input, output,[ "-t" ]); 
      CloseStream(input);
      CloseStream(output);
      Read( Filename(PAGGlobalOptions.TempDir,"forbrepint4.out") );
      lrep:=PAGProcessResult;
      if verb then
        Print(Size(lrep),"\n");    
      fi;
    else
      lrep:=[];
    fi;

    if short then
      if verb then
        Print("Computing short orbits...\n");    
      fi;
      if t<=4 then
        srep:=SubsetOrbitRepShort3(g,v,k,Size(g)/2,rec(SteinerT:=t)); 
      else
        srep:=Filtered(SubsetOrbitRepShort1(g,v,k,Size(g)/2),z->IsGoodSubsetOrbit(g,z,[0..y]));
      fi;
      if verb then
        Print(Size(srep),"\n");    
      fi;
    else
      srep:=[];
    fi;
    
    if verb and long and short then
      Print("Joininig long and short orbits...\n");    
    fi;

    rep:=Union(srep,lrep);

    if verb and long and short then
      Print(Size(rep),"\n");    
    fi;

    return rep;
end );


#############################################################################
#
#  SubsetOrbitRepOM( <G>, <t>, <v>, <k>, <beta>, <OM>[, <opt>] ) 
#
#  Computes subset orbit representatives compatible with an orbit
#  matrix or list of orbit matrices <A>OM</A> with block orbit sizes
#  <A>beta</A>. For each orbit matrix, the result is returned as a 
#  list of two components. The first component is a list of sets of 
#  orbit representatives compatible with a column of the orbit matrix. 
#  The second component is a list of numbers indicating how many 
#  orbits have to be taken from each set. Calls 
#  <Ref Func="SubsetOrbitRepSteiner"/> to generate the subset orbits.
#  The last (optional) argument <A>opt</A> is a record for options. 
#  Possible components are:
#  <List>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  </List>
#
InstallGlobalFunction( SubsetOrbitRepOM, function( g, t, v, k, beta, om, opt... )
local verb,po,tm,r1,rs1,r2,rs2,r,rs,reptype,rt,takerep,rr,rez,i,single;
   
    verb:=false; 
    if Size(opt)>0 then 
      if IsBound(opt[1].Verbose) then
        verb:=opt[1].Verbose;
      fi;
    fi;

    if verb then
      Print("Computing orbits...\n");
    fi;
    r1:=SubsetOrbitRepSteiner(g,t,v,k,rec(Long:=false));
    rs1:=List(r1,x->Size(Orbit(g,x,OnSets)));
    r2:=SubsetOrbitRepSteiner(g,t,v,k,rec(Short:=false));
    rs2:=[1..Size(r2)]*0+Size(g);
    r:=Concatenation(r1,r2);
    rs:=Concatenation(rs1,rs2);
    if verb then
      Print(Size(r1)," (short) + ",Size(r2)," (long) = ",Size(r),"\n");
      Print("Computing orbit types...\n");
    fi;
    po:=Orbits(g,[1..v]);
    reptype:=rep->List(po,x->Size(Intersection(x,rep)));
    rt:=List(r,reptype);
    if verb then
      Print(Size(rt),"\n");
    fi;
  
    single:=false; 
    if NestingDepthA(om)=2 then
      om:=[om]; 
      single:=true;
    fi;
    rez:=[];

    for i in [1..Size(om)] do
      if verb then 
        if Size(om)>1 then
          Print("Orbit matrix no. ",i,"...\n");
        else
          Print("Computing compatible orbits...\n");
        fi;
      fi;
      tm:=Collected(TransposedMat([beta,TransposedMat(om[i])]));
      takerep:=x->Intersection(Positions(rs,x[1]),Positions(rt,x[2]));
      rr:=List(tm,x->r{takerep(x[1])});
      if verb then
        Print(Sum(List(rr,Size)),"\n");
      fi;
      rez:=Concatenation(rez,[[rr,List(tm,x->x[2])]]);
    od;

    if single then
      return rez[1];
    else
      return rez;
    fi;
end );


#############################################################################
#
#  IsGoodSubsetOrbit( <G>, <rep>, <lin> ) 
#
#  Check if the subset orbit generated by the permutation group <A>G</A>
#  and the representative <A>rep</A> is a good orbit with respect
#  to the list of intersection numbers <A>lin</A>. This means that the
#  intersection size of any pair of sets from the orbit is an integer
#  in <A>lin</A>. 
#
InstallGlobalFunction( IsGoodSubsetOrbit, function( g, rep, lin )
local o,s,ok,i,j;

    o:=Orbit(g,rep,OnSets);
    s:=Size(o);
    ok := true;
    i := 1;
    while ok and i < s  do
        j := i + 1;
        while ok and j <= s  do
            ok := Size( Intersection( o[i], o[j] ) ) in lin;
            j := j + 1;
        od;
        i := i + 1;
    od;
    return ok;
end );


#############################################################################
#
#  AreCompatibleSubsetOrbits( <G>, <rep1>, <rep2>, <lin> ) 
#
#  Check if the subset orbits generated by the permutation group <A>G</A>
#  and the representatives <A>rep1</A> and <A>rep2</A> are compatible with 
#  respect to the list of intersection numbers <A>lin</A>. This means that 
#  the intersection size of any pair of subsets from the two orbits is an 
#  integer in <A>lin</A>. 
#
InstallGlobalFunction( AreCompatibleSubsetOrbits, function( g, rep1, rep2, lin )
local o,s,ok,i,j;

    o:=Orbit(g,rep1,OnSets);
    s:=Size(o);
    ok := true;
    i := 1;
    while ok and i < s  do
      ok := Size( Intersection( o[i], rep2 ) ) in lin;
      i := i + 1;
    od;
    return ok;
end );


#############################################################################
#
#  SmallLambdaFilter( <G>, <tsub>, <ksub>, <lambda> ) 
#
#  Remove k-subset representatives from <A>ksub</A> such that the 
#  corresponding <A>G</A>-orbit covers some of the t-subset 
#  representatives in <A>tsub</A> more than <A>lambda</A> times. 
#
InstallGlobalFunction( SmallLambdaFilter, function( g, tsub, ksub, lambda )
local o,ok;

    o:=List(ksub,x->Orbit(g,x,OnSets));
    ok:=Positions(List(o,z->not false in List(tsub,x->Size(Filtered(z,y->IsSubset(y,x)))<=lambda)),true);
    return ksub{ok};
end );


#############################################################################
#
#  KramerMesnerMat( <G>, <tsub>, <ksub>[, <lambda>, <b>] )  
#
#  Returns the Kramer-Mesner matrix for a group <A>G</A>. The rows
#  are labelled by t-subset orbits represented by <A>tsub</A>, and
#  the columns by k-subset orbits represented by <A>ksub</A>. A column
#  of constants <A>lambda</A> is added if the optional argument <A>lambda</A>
#  is given. Another row is added if the optional argument <A>b</A> is
#  given, repesenting the constraint that sizes of the chosen k-subset
#  orbits must sum up to the number of blocks <A>b</A>.
#
InstallGlobalFunction( KramerMesnerMat, function( g, tsub, ksub, arg... )
local o,mat,a;

    o:=List(ksub,x->Orbit(g,x,OnSets));
    mat:=List(tsub,z->List(o,x->Size(Filtered(x,y->IsSubset(y,z)))));
    if Size(arg)>=1 then
      mat:=ExpandMatRHS(mat,arg[1]);
    fi;
    if Size(arg)>=2 then
      a:=Concatenation(List(o,Size),[arg[2]]);
      mat:=Concatenation(mat,[a]);
    fi;
    return mat;
end );


#############################################################################
#
#  KramerMesnerMat2( <G>, <tsub>, <ksub>[, <lambda>, <b>] )  
#
#  Returns the Kramer-Mesner matrix for a permutation group <A>G</A>. The 
#  rows are labelled by <M>t</M>-subset orbits represented by <A>tsub</A>, and
#  the columns by <M>k</M>-subset orbits represented by <A>ksub</A>. A column
#  of constants <A>lambda</A> is added if the optional argument <A>lambda</A>
#  is given. Another row is added if the optional argument <A>b</A> is
#  given, repesenting the constraint that sizes of the chosen <M>k</M>-subset
#  orbits must sum up to the number of blocks <A>b</A>. This function calls
#  a <C>C</C>-subroutine for the time-critical part of the computation and 
#  should be faster than <Ref Func="KramerMesnerMat"/>. 
#
InstallGlobalFunction( KramerMesnerMat2, function( g, tsub, ksub, arg... )
local os,mat,a,po,output,v,t,k,input,command;

    po:=Union(List(List(tsub,x->Orbit(g,x,OnSets)),Union));
    v:=Size(po);
    if po<>[1..v] then
      Print("Error: orbits do not span [1..v].\n");
    else
      t:=Size(tsub[1]);
      k:=Size(ksub[1]);
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "kmmat.gin" ), false );
      WriteLine( output, String( [ v, t, k ] ) );
      WriteLine( output, String( Size( g ) ) );
      List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
      WriteLine( output, String( Size( tsub ) ) );
      WriteLine( output, String( tsub ) );
      WriteLine( output, String( Size( ksub ) ) );
      WriteLine( output, String( ksub ) );
      CloseStream( output );
      input := InputTextFile( Filename( PAGGlobalOptions.TempDir, "kmmat.gin" ) );
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "kmmat.in" ), false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "gap2raw" );
      Process( PAGGlobalOptions.TempDir, command, input, output, [  ] );
      CloseStream( input );
      CloseStream( output );
      input := InputTextFile( Filename( PAGGlobalOptions.TempDir, "kmmat.in" ) );
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "kmmat.out" ), false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "kmmat" );
      Process( PAGGlobalOptions.TempDir, command, input, output, [  ] );
      CloseStream( input );
      CloseStream( output );
      Read( Filename(PAGGlobalOptions.TempDir,"kmmat.out") );
      os:=PAGProcessResult[1];
      mat:=PAGProcessResult{[2..Size(PAGProcessResult)]};
      if Size(arg)>=1 then
        mat:=ExpandMatRHS(mat,arg[1]);
      fi;
      if Size(arg)>=2 then
        a:=Concatenation(os,[arg[2]]);
        mat:=Concatenation(mat,[a]);
      fi;
      return mat;
    fi;
end );


#############################################################################
#
#  MakeDLX( <filename>, <G>, <tsub>, <ksub>[, <opt>] ) 
#
#  Creates a DLX file <A>filename</A> for the permutation group <A>G</A>, 
#  <M>t</M>-subset and <M>k</M>-subset orbits representatives <A>tsub</A> 
#  and <A>ksub</A>. The orbits must be such that the corresponding 
#  Kramer-Mesner matrix has only <M>0</M>-<M>1</M> entries. The <A>ksub</A>
#  argument may be given as returned by <Ref Func="SubsetOrbitRepOM"/>.
#  In that case additional equations will be added to make the solutions
#  compatible with the orbit matrix. For the DLX file format, see
#  <Cite Key='DK17'/>. The optional argument <A>opt</A> is a record for 
#  options. Possible components are:
#  <List>
#  <Item><A>UseOrbits</A>:=<C>list</C> Add equations and variables (in 
#  Knuth's terms: items and options) so that at least one of the orbits 
#  given in <C>list</C> must be chosen. This can be used to prune parts 
#  of the search tree leading to isomorphic designs, by using the 
#  normalizer.</Item>
#  </List>
#
InstallGlobalFunction( MakeDLX, function( filename, g, tsub, ksub, opt... )
local ol,om,po,output,v,t,k,input,command,cfilename,popt,omrhs,omsize,omsets,ompart,rfilename, i;

    ol:=[];
    if Size(opt)>=1 then
      if IsBound(opt[1].UseOrbits) then
         ol:=opt[1].UseOrbits;
      fi;
    fi;

    if ol<>[] then
      cfilename := Filename( PAGGlobalOptions.TempDir, "makedlx.col" );
      output := OutputTextFile( cfilename, false );
      WriteLine( output, String( Size(ol) ) );
      WriteLine( output, Concatenation(List(ol-1,x->Concatenation(String(x)," "))) );
      CloseStream( output );
    fi;

    om:=false;
    if Size(ksub)=2 and NestingDepthA(ksub[1])=3 and NestingDepthA(ksub[2])=1 then
      om:=true;
      omrhs:=ksub[2];
      omsize:=List(ksub[1],Size);
      omsets:=List(omsize,x->[1..x]);
      ompart:=List([1..Size(omsize)],i->Sum(omsize{[1..i-1]})+omsets[i]);
      rfilename := Filename( PAGGlobalOptions.TempDir, "makedlx.row" );
      output := OutputTextFile( rfilename, false );
      for i in [1..Size(omrhs)] do
        WriteLine( output, String( omrhs[i] ) );
        WriteLine( output, String( omsize[i] ) );
        WriteLine( output, Concatenation(List(ompart[i]-1,x->Concatenation(String(x)," "))) );
      od;
      CloseStream( output );
      ksub:=Concatenation(ksub[1]);
    fi;

    po:=Union(List(List(tsub,x->Orbit(g,x,OnSets)),Union));
    v:=Size(po);
    if po<>[1..v] then
      Print("Error: orbits do not span [1..v].\n");
    else
      t:=Size(tsub[1]);
      k:=Size(ksub[1]);
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "makedlx.gin" ), false );
      WriteLine( output, String( [ v, t, k ] ) );
      WriteLine( output, String( Size( g ) ) );
      List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
      WriteLine( output, String( Size( tsub ) ) );
      WriteLine( output, String( tsub ) );
      WriteLine( output, String( Size( ksub ) ) );
      WriteLine( output, String( ksub ) );
      CloseStream( output );
      input := InputTextFile( Filename( PAGGlobalOptions.TempDir, "makedlx.gin" ) );
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "makedlx.in" ), false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "gap2raw" );
      Process( PAGGlobalOptions.TempDir, command, input, output, [  ] );
      CloseStream( input );
      CloseStream( output );
      input := InputTextFile( Filename( PAGGlobalOptions.TempDir, "makedlx.in" ) );
      output := OutputTextFile( filename, false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "makedlx" );
      popt:=[];
      if ol<>[] then
        popt:=Concatenation(popt,[Concatenation("-c",cfilename)]);
      fi;
      if om then
        popt:=Concatenation(popt,[Concatenation("-r",rfilename)]);
      fi;
      Process( PAGGlobalOptions.TempDir, command, input, output, popt );
      CloseStream( input );
      CloseStream( output );
    fi;
end );


#############################################################################
#
#  MakeDLX2( <filename>, <G>, <tsub>, <ksub>[, <opt>] ) 
#
#  Creates a DLX file <A>filename</A> for the permutation group <A>G</A>, 
#  <M>t</M>-subset and <M>k</M>-subset orbits representatives <A>tsub</A> 
#  and <A>ksub</A>. The orbits must be such that the corresponding 
#  Kramer-Mesner matrix has only <M>0</M>-<M>1</M> entries. The <A>ksub</A>
#  argument may be given as returned by <Ref Func="SubsetOrbitRepOM"/>.
#  In that case additional equations will be added to make the solutions
#  compatible with the orbit matrix. For the DLX file format, see
#  <Cite Key='DK17'/>. The optional argument <A>opt</A> is a record for 
#  options. Possible components are:
#  <List>
#  <Item><A>UseOrbits</A>:=<C>list</C> Add equations and variables (in 
#  Knuth's terms: items and options) so that at least one of the orbits 
#  given in <C>list</C> must be chosen. This can be used to prune parts 
#  of the search tree leading to isomorphic designs, by using the 
#  normalizer. If <C>list</C> is a partition such that the blocks contain
#  mutually equivalent options, secondary items and colors will be used 
#  to avoid duplicate solutions.</Item>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
#  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
#  is used.</Item>
#  </List>
#
InstallGlobalFunction( MakeDLX2, function( filename, g, tsub, ksub, opt... )
local ol,po,output,v,t,k,input,command,cfilename,popt,
      om,omrhs,omsize,omsets,ompart,rfilename,
      i,mfilename,pfilename,PartitionToVector,pvec,
      tempdir;

    PartitionToVector:=function(part)
      local vec,i,j;
      vec:=[1..Sum(List(part,Size))];
      for j in [1..Size(part)] do for i in part[j] do vec[i]:=j; od; od;
      return vec;
    end;

    ol:=[];
    tempdir:=PAGGlobalOptions.TempDir;
    if Size(opt)>=1 then
      if IsBound(opt[1].UseOrbits) then
         ol:=opt[1].UseOrbits;
      fi;
      if IsBound(opt[1].TempDir) then
        tempdir:=Directory(opt[1].TempDir);
      fi;
    fi;

    if ol<>[] then
      if NestingDepthA(ol)=1 then
        cfilename := Filename( tempdir, "makedlx.col" );
        output := OutputTextFile( cfilename, false );
        WriteLine( output, String( Size(ol) ) );
        WriteLine( output, Concatenation(List(ol-1,x->Concatenation(String(x)," "))) );
        CloseStream( output );
      else
        pfilename := Filename( tempdir, "makedlx.pvec" );
        pvec:=PartitionToVector(ol);
        output := OutputTextFile( pfilename, false );
        WriteLine( output, String( Size(pvec) ) );
        WriteLine( output, Concatenation(List(pvec,x->Concatenation(String(x)," "))) );
        CloseStream( output );
      fi;
    fi;

    om:=false;
    if Size(ksub)=2 and NestingDepthA(ksub[1])=3 and NestingDepthA(ksub[2])=1 then
      om:=true;
      omrhs:=ksub[2];
      omsize:=List(ksub[1],Size);
      omsets:=List(omsize,x->[1..x]);
      ompart:=List([1..Size(omsize)],i->Sum(omsize{[1..i-1]})+omsets[i]);
      rfilename := Filename( tempdir, "makedlx.row" );
      output := OutputTextFile( rfilename, false );
      WriteLine( output, String( Size(omrhs) ) );
      for i in [1..Size(omrhs)] do
        WriteLine( output, String( omrhs[i] ) );
        WriteLine( output, String( omsize[i] ) );
        WriteLine( output, Concatenation(List(ompart[i]-1,x->Concatenation(String(x)," "))) );
      od;
      CloseStream( output );
      ksub:=Concatenation(ksub[1]);
    fi;

    po:=Union(List(List(tsub,x->Orbit(g,x,OnSets)),Union));
    v:=Size(po);
    if po<>[1..v] then
      Print("Error: orbits do not span [1..v].\n");
    else
      t:=Size(tsub[1]);
      k:=Size(ksub[1]);
      output := OutputTextFile( Filename( tempdir, "makedlx.gin" ), false );
      WriteLine( output, String( [ v, t, k ] ) );
      WriteLine( output, String( Size( g ) ) );
      List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
      WriteLine( output, String( Size( tsub ) ) );
      WriteLine( output, String( tsub ) );
      WriteLine( output, String( Size( ksub ) ) );
      WriteLine( output, String( ksub ) );
      CloseStream( output );
      input := InputTextFile( Filename( tempdir, "makedlx.gin" ) );
      output := OutputTextFile( Filename( tempdir, "makedlx.in" ), false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "gap2raw" );
      Process( tempdir, command, input, output, [  ] );
      CloseStream( input );
      CloseStream( output );
      input := InputTextFile( Filename( tempdir, "makedlx.in" ) );
      output := OutputTextFile( filename, false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "makedlx2" );
      mfilename:=Filename(tempdir,"makedlx.m");
      popt:=[ Concatenation("-m", mfilename) ];
      if ol<>[] then
        if NestingDepthA(ol)=1 then
          popt:=Concatenation(popt,[Concatenation("-c",cfilename)]);
        else
          popt:=Concatenation(popt,[Concatenation("-p",pfilename)]);
        fi;
      fi;
      if om then
        popt:=Concatenation(popt,[Concatenation("-r",rfilename)]);
      fi;
      Process( tempdir, command, input, output, popt );
      CloseStream( input );
      CloseStream( output );
    fi;
    return ReadAsFunction(mfilename)();
end );


#############################################################################
#
#  RectifySolutions( <norb>, <list>, <sol> ) 
#
#  Make solution(s) of a DLX file produced by <Ref Func="MakeDLX"/>
#  with the <A>UseOrbits</A>:=<C>list</C> option compatible with 
#  <A>norb</A> orbits. 
#
InstallGlobalFunction( RectifySolutions, function( norb, list, sol )
local rect;

    rect:=function(x)
       if x <= norb then return x;
       else return list[x-norb];
       fi;
    end;
    if NestingDepthA(sol)=1 then
      return AsSet(List(sol,rect));
    else
      return List(sol,x->AsSet(List(x,rect)));
    fi;
end );


#############################################################################
#
#  KramerMesnerMatOM( <G>, <tsub>, <ksub>, <lambda> ) 
#
#  Returns the Kramer-Mesner matrix for a permutation group <A>G</A> 
#  compatible with an orbit matrix. Rows are labeled by <M>t</M>-subset 
#  orbits <A>tsub</A>. The <M>k</M>-subset orbits <A>ksub</A> labeling 
#  the columns should be given as returned by the function
#  <Ref Func="SubsetOrbitRepOM"/>. 
#
InstallGlobalFunction( KramerMesnerMatOM, function( g, tsub, ksub, lambda )
local ksub1, ksubs, rhs2, km1, km2, tovec, eq; 

    ksub1:=Concatenation(ksub[1]);
    ksubs:=List(ksub[1],Size);
    rhs2:=ksub[2];
    km1:=KramerMesnerMat2(g,tsub,ksub1,lambda);
    tovec:=function ( vs, j )
      return Concatenation(List([1..Size(vs)],i->[1..vs[i]]*0+IversonBracket(i=j)));
    end;
    eq:=i->Concatenation(tovec(ksubs,i),[rhs2[i]]);
    km2:=List([1..Size(ksubs)],eq);
    return Concatenation(km1,km2);
end );


#############################################################################
#
#  WriteDLX( <filename>, <KM> ) 
#
#  Write a Kramer-Mesner matrix <A>KM</A> to a file in format suitable
#  for Donald Knuth's DLX3 program <Cite Key='DK17'/>. The matrix must
#  contain only <M>0</M>-<M>1</M> entries, except in the last column.
#
InstallGlobalFunction( WriteDLX, function( filename, km )
local file,n,a,b,i,s,x;

    file:=OutputTextFile( filename, false );

    n:=DimensionsMat(km)[2];
    km:=TransposedMat(km);
    a:=km{[1..n-1]};
    b:=km[n];
    s:="";
    for i in [1..Size(b)] do
      if b[i]=1 then
        s:=Concatenation(s,String(i-1)," ");
      else
        s:=Concatenation(s,String(b[i]),"|",String(i-1)," ");
      fi;
    od;
    WriteLine(file,s);

    for x in a do
      WriteLine(file,Concatenation(List(Positions(x,1)-1,y->Concatenation(String(y)," "))));  
    od;

    CloseStream( file );
end );


#############################################################################
#
#  CompatibilityMat( <G>, <ksub>, <lin> ) 
#
#  Returns the compatibility matrix of the <M>k</M>-subset representatives
#  <A>ksub</A> with respect to the group <A>G</A> and list of intersection 
#  numbers <A>lin</A>. Entries are <M>1</M> if intersection sizes of subsets 
#  in the corresponding <A>G</A>-orbits are all integers in <A>lin</A>, and
#  <M>0</M> otherwise.
#
InstallGlobalFunction( CompatibilityMat, function( g, ksub, lin )
local n,o,ctest,cm;

    n:=Size(ksub);
    o:=List(ksub,x->Orbit(g,x,OnSets));
    ctest:=function ( i, j )
    local s1, s2, k, l, ok;

        if i<j then
           ok := true;
           k := 1;
           s1 := Size( o[i] );
           s2 := Size( o[j] );
           while ok and k <= s1 do
              l := 1;
              while ok and l <= s2 do
                 ok := Size( Intersection( o[i][k], o[j][l] ) ) in lin;
                 l := l + 1;
              od;
              k := k + 1;
           od;
           if ok then return 1; else return 0; fi;
        else
          return 0;
        fi;
    end;
    cm:=List([1..n],i->List([1..n],j->ctest(i,j)));
    return cm+TransposedMat(cm);
end );


#############################################################################
#
#  ExpandMatRHS( <mat>, <lambda> )  
#
#  Add a column of <A>lambda</A>'s to the right of the matrix <A>mat</A>.
#
InstallGlobalFunction( ExpandMatRHS, function( mat, lambda )

    return TransposedMat(Concatenation(TransposedMat(mat),[List([1..DimensionsMat(mat)[1]],x->lambda)]));
end );


#############################################################################
#
#  SolveKramerMesner( <mat>[, <cm>][, <opt>] ) 
#
#  Solve a system of linear equations determined by the matrix <A>mat</A>
#  over <M>\{0,1\}</M>. By default, A.Wassermann's LLL solver <C>solvediophant2</C>
#  <Cite Key='AW21'/> is used. If the second argument is a compatibility
#  matrix <A>cm</A>, the backtracking program <C>solvecm</C> from the papers 
#  <Cite Key='KNP11'/> and <Cite Key='KV16'/> is used. The solver can also
#  be chosen explicitly in the record <A>opt</A>. Possible components are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
#  <C>solvediophant2</C>. Without <A>cm</A>, this is the default.</Item>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>.</Item>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> Use <C>solvecm</C>. This is
#  the default if <A>cm</A> is given.</Item>
#  <Item><A>Solver</A>:=<C>"libexact"</C> Use <C>libexact</C>.
#  This is P. Kaski and  O. Pottonen's implementation of the Dancing Links
#  algorithm, see <Cite Key='KP08'/>. The coefficients of <A>mat</A> must 
#  be in <M>\{0,1\}</M>. Other options are passed to the function 
#  <Ref Func="SolveDLX"/>; see its documentation.</Item>
#  <Item><A>Solver</A>:=<C>"dlx3"</C> / <C>"ssxcc"</C> / <C>"ssxcc-binary"</C> / 
#  <C>"ssmcc"</C>  Use one of D. E. Knuth's implementations of the Dancing 
#  Links or Dancing Cells algorithms; see <Cite Key='DK00'/> and
#  <Cite Key='DK25'/>. The coefficients of <A>mat</A> must be in <M>\{0,1\}</M>.
#  Other options are passed to the function <Ref Func="SolveDLX"/>; see 
#  its documentation.</Item>
#  </List>
#
InstallGlobalFunction( SolveKramerMesner, function( mat, arg... )
local input,output,row,el,command,cm,opt,sol,filename;

    cm:=[];
    opt:=rec();
    sol:=4;
    if Size(arg)=1 then
      if IsList(arg[1]) then
        cm:=arg[1];
        sol:=2;
      fi;
      if IsRecord(arg[1]) then
        opt:=arg[1];
      fi;
    fi;
    if Size(arg)=2 then
      if IsList(arg[1]) then
        cm:=arg[1];
        sol:=2;
      fi;
      if IsRecord(arg[2]) then
        opt:=arg[2];
      fi;
    fi;
    if IsBound(opt.Solver) then
      if opt.Solver="solvediophant" then
        sol:=1;
      fi;
      if opt.Solver="solvecm" then
        sol:=2;
      fi;
      if opt.Solver in ["libexact", "dlx3", "ssxcc", "ssxcc-binary", "ssmcc"]  then
        sol:=3;
      fi;
      if opt.Solver in ["solvediophant2","sd2"] then 
        sol:=4; 
      fi;
    fi;

    if sol=3 then
      filename:=Filename(PAGGlobalOptions.TempDir,"solvekm.dlx");
      WriteDLX(filename,mat);
      return SolveDLX(filename,opt);
    else
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.in"), false );
      PrintTo(output, DimensionsMat(mat)[1]," ",DimensionsMat(mat)[2]-1," 1\n\n");
      for row in mat do
        for el in row do
          AppendTo(output,el," ");
        od;
        AppendTo(output,"\n");
      od;
      if cm<>[] then
        AppendTo(output,"\n");
        for row in cm do
          for el in row do
            AppendTo(output,el," ");
          od;
          AppendTo(output,"\n");
        od;
      fi;
      CloseStream(output);

      input:=InputTextUser();
      if PAGGlobalOptions.Silent then
        output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.log"), false );
      else
        if sol=4 then
          output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.log1"), false );
        else
          output:=OutputTextUser();
        fi;
      fi;
      if sol=4 then
        command:=Filename(DirectoriesPackagePrograms("PAG"), "sd2");
        Process(PAGGlobalOptions.TempDir, command, input, output, 
              ["-c10000","-bkz","-beta80","-maxnorm1","-osolve.out", "solve.in"] );
      fi;
      if sol=1 then
        command:=Filename(DirectoriesPackagePrograms("PAG"), "solvediophant");
        Process(PAGGlobalOptions.TempDir, command, input, output, 
            ["-c10000","-bkz","-beta80","-p18","-maxnorm1","-osolve.out", "solve.in"] );
      fi;
      if sol=2 then
        command:=Filename(DirectoriesPackagePrograms("PAG"), "solvecm");
        if cm=[] then
          Process(PAGGlobalOptions.TempDir, command, input, output, ["-osolve.out", "solve.in"] );
        else
          Process(PAGGlobalOptions.TempDir, command, input, output, ["-c","-osolve.out", "solve.in"] );
        fi;
      fi;
      if sol=3 then
        command:=Filename(DirectoriesPackagePrograms("PAG"), "solvelibexact");
        if PAGGlobalOptions.Silent then
          Process(PAGGlobalOptions.TempDir, command, input, output, ["-osolve.out", "solve.in"] );
        else
          Process(PAGGlobalOptions.TempDir, command, input, output, ["-r","-osolve.out", "solve.in"] );
        fi;
      fi;
      CloseStream(output);

      command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.out") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.g"), false);
      Process(PAGGlobalOptions.TempDir, command, input, output, []);
      CloseStream(input);
      CloseStream(output);

      return ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"solve.g") )();
    fi;
end );


#############################################################################
#
#  SolveDLX( <filename>[, <opt>] ) 
#
#  Solve an exact cover problem given in the file <A>filename</A>. 
#  The file must be in Donald Knuth's DLX3 format <Cite Key='DK17'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible 
#  components are:
#  <List>
#  <Item><A>Solver</A>:=<C>"dlx3"</C> / <C>"ssxcc"</C> / <C>"ssxcc-binary"</C> / 
#  <C>"ssmcc"</C>  If defined, one of D. E. Knuth's implementations of the Dancing 
#  Links or Dancing Cells algorithms is used; see <Cite Key='DK00'/> and
#  <Cite Key='DK25'/>. The default is <C>dlx3</C>.</Item> 
#  <Item><A>M</A>:=<A>n</A>  Set memory option for Knuth's solvers to <C>n</C>.
#  The default is <M>130000000</M>.</Item>
#  <Item><A>Solver</A>:=<C>"libexact"</C> If defined, <C>libexact</C> is used.
#  This is P. Kaski and  O. Pottonen's implementation of the Dancing Links
#  algorithm; see <Cite Key='KP08'/>.</Item>
#  <Item><A>UseOrbits</A>:=<C>list</C> Return only solutions using at least 
#  one of the orbits (or sets of orbits) given in <C>list</C>. This can be 
#  used to prune parts of the search tree leading to isomorphic designs, 
#  using the normalizer.</Item>
#  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Restart solver for eached 
#  of the fixed orbits given in <A>UseOrbits</A>. By default, this is done 
#  only if sets of more than one orbit are fixed. Otherwise the solver is 
#  started once with additional rows and columns for the fixed orbits.</Item>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
#  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
#  is used.</Item>
#  </List>
#
InstallGlobalFunction( SolveDLX, function( filename, arg... )
local input,output,command,opt,sol,ol,rez,x,y,makelist,i,optfilename,iter,
      opts,M,tempdir;
    
    opt:=rec();
    sol:=7;
    ol:=[];
    M:=130000000;
    if Size(arg)=1 then
      opt:=arg[1];
    fi;
    if IsBound(opt.Solver) then
      if opt.Solver="libexact" then
        sol:=3;
      fi;
      if opt.Solver="ssxcc" then
        sol:=4;
      fi;
      if opt.Solver="ssxcc-binary" then
        sol:=5;
      fi;
      if opt.Solver="ssmcc" then
        sol:=6;
      fi;
      if opt.Solver="dlx3" then
        sol:=7;
      fi;
    fi;
    if IsBound(opt.M) then
      M:=opt.M; 
    fi;
    if IsBound(opt.UseOrbits) then
      ol:=opt.UseOrbits; 
    fi;
    tempdir:=PAGGlobalOptions.TempDir;
    if IsBound(opt.TempDir) then
       tempdir:=Directory(opt.TempDir);
    fi;

    if ol=[] then
      iter:=false;
    else
      makelist:=function(x)
        if IsList(x) then
          return x;
        else
          return [x];
        fi;
      end;
      ol:=List(ol,makelist)-1;
      iter:=AsSet(List(ol,Size))<>[1];
      if Size(ol)=1 then
        iter:=false;
      fi;
      if IsBound(opt.Iterate) then
        iter:=opt.Iterate; 
      fi;
    fi;

    if not iter then

      opts:=[];

      if Size(ol)>1 then
        optfilename:=Filename(tempdir,"solve.fo");
        output:=OutputTextFile( optfilename, false );
        WriteLine( output, String(Size(ol)) );
        ol:=Concatenation(List(Flat(ol),x->Concatenation(String(x)," ")));
        WriteLine( output, ol );
        CloseStream(output);
        opts:=[Concatenation("-v",optfilename)];
      else 
        if Size(ol)=1 then
          opts:=List(ol[1],x->Concatenation("-u",String(x)));
        fi;
      fi;  

      if sol in [4..7] then
        input:=InputTextFile( filename );
        if sol=4 then
          command:=Filename(DirectoriesPackagePrograms("PAG"), "ssxcc");
        fi;
        if sol=5 then
          command:=Filename(DirectoriesPackagePrograms("PAG"), "ssxcc-binary");
        fi;
        if sol=6 then
          command:=Filename(DirectoriesPackagePrograms("PAG"), "ssmcc");
        fi;
        if sol=7 then
          command:=Filename(DirectoriesPackagePrograms("PAG"), "dlx3");
        fi;
        output:=OutputTextFile( Filename(tempdir,"solve.out"), false );
        Process(tempdir, command, input, output, ["m1","d10000000000",Concatenation("M",String(M))] );
        CloseStream(output);
        CloseStream(input);
      fi;

      if sol=3 then
        input:=InputTextUser();
        if PAGGlobalOptions.Silent then
          output:=OutputTextFile( Filename(tempdir,"solve.log"), false );
        else
          output:=OutputTextUser();
        fi;
        command:=Filename(DirectoriesPackagePrograms("PAG"), "dlxsolvelibexact");
        if PAGGlobalOptions.Silent then
          Process(tempdir, command, input, output, Concatenation(opts,["-osolve.out",filename]) );
        else
          Process(tempdir, command, input, output, Concatenation(opts,["-r","-osolve.out",filename]) );
        fi;
        CloseStream(output);
      fi;

      command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
      input:=InputTextFile( Filename(tempdir,"solve.out") );
      output:=OutputTextFile( Filename(tempdir,"solve.g"), false);
      if sol in [4..7] then
        Process(tempdir, command, input, output, ["-v","-i"]);
      else
        Process(tempdir, command, input, output, ["-v"]);
      fi;
      CloseStream(input);
      CloseStream(output);

      Read( Filename(tempdir,"solve.g") );
      if sol in [4..7] then
        return PAGProcessResult+1;
      else
        return PAGProcessResult;
      fi;

    else
      
      ol:=List(ol,y->List(y,x->Concatenation("-u",String(x))));
      rez:=[];
      i:=0;
      for x in ol do
        i:=i+1;
        if not PAGGlobalOptions.Silent then
          Print(i,"\n");
        fi;
        input:=InputTextUser();
        if PAGGlobalOptions.Silent then
          output:=OutputTextFile( Filename(tempdir,"solve.log"), false );
        else
          output:=OutputTextUser();
        fi;
        command:=Filename(DirectoriesPackagePrograms("PAG"), "dlxsolvelibexact");
        if PAGGlobalOptions.Silent then
          Process(tempdir, command, input, output, Concatenation(x,["-osolve.out",filename]) );
        else
          Process(tempdir, command, input, output, Concatenation(x,["-r","-osolve.out",filename]) );
        fi;
        CloseStream(output);
        command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
        input:=InputTextFile( Filename(tempdir,"solve.out") );
        output:=OutputTextFile( Filename(tempdir,"solve.g"), false);
        Process(tempdir, command, input, output, []);
        CloseStream(input);
        CloseStream(output);

        rez:=Concatenation(rez,ReadAsFunction( Filename(tempdir,"solve.g") )());
      od;
      return rez; 

    fi;
end );


#############################################################################
#
#  SolveSteiner( <G>, <tsub>, <ksub>[, <opt>] ) 
#
#  Set up and solve exact cover problem for the permutation group <A>G</A>, 
#  <M>t</M>-subset and <M>k</M>-subset orbits representatives <A>tsub</A> 
#  and <A>ksub</A>. The orbits must be such that the corresponding 
#  Kramer-Mesner matrix has only <M>0</M>-<M>1</M> entries. The <A>ksub</A>
#  argument may be given as returned by <Ref Func="SubsetOrbitRepOM"/>.
#  In that case additional equations will be added to make the solutions
#  compatible with the orbit matrix. The optional argument <A>opt</A> is 
#  a record for options. Possible components are:
#  <List>
#  <Item><A>Solver</A>:=<C>"libexact"</C> If defined, <C>libexact</C> is 
#  used. This is P. Kaski and  O. Pottonen's implementation of the Dancing 
#  Links algorithm, see <Cite Key='KP08'/>.</Item>
#  <Item><A>UseOrbits</A>:=<C>list</C> Add equations and variables (in 
#  Knuth's terms: items and options) so that at least one of the orbits 
#  given in <C>list</C> must be chosen. This can be used to prune parts 
#  of the search tree leading to isomorphic designs, by using the 
#  normalizer. A partition of orbits can also be given in <C>list</C> to
#  avoid multiple solutions and reduce the search tree further.</Item>
#  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Re-create exact cover
#  problem and restart solver for eached of the fixed orbits given in 
#  <A>UseOrbits</A>. By default, the fixed orbits are modelled by adding
#  a single equation (item), duplicatng variables (options) and starting 
#  the solver once. If a partition is given in <A>UseOrbits</A>, iterating
#  is the default.</Item>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C> Report fixing of orbits
#  when iterating and restarting the solver.</Item> 
#  </List>
#
InstallGlobalFunction( SolveSteiner, function( g, tsub, ksub, opt... )
local ol,om,po,output,v,t,k,input,command,cfilename,popt,omrhs,omsize,omsets,ompart,rfilename,i,iter,verb,oli,part;

    ol:=[];
    iter:=false;
    verb:=false;
    if Size(opt)>=1 then
      if IsBound(opt[1].UseOrbits) then
         ol:=opt[1].UseOrbits;
      fi;
      if IsBound(opt[1].Iterate) then
         iter:=opt[1].Iterate;
      fi;
      if IsBound(opt[1].Verbose) then
         verb:=opt[1].Verbose;
      fi;
    fi;

    part:=false;
    if ol<>[] then
      if NestingDepthA(ol)=1 then
        cfilename := Filename( PAGGlobalOptions.TempDir, "solvesteiner.col" );
        output := OutputTextFile( cfilename, false );
        WriteLine( output, String( Size(ol) ) );
        WriteLine( output, Concatenation(List(ol-1,x->Concatenation(String(x)," "))) );
        CloseStream( output );
      else
        part:=true;
        cfilename := Filename( PAGGlobalOptions.TempDir, "solvesteiner.part" );
        output := OutputTextFile( cfilename, false );
        for oli in ol do
          WriteLine( output, String( Size(oli) ) );
          WriteLine( output, Concatenation(List(oli-1,x->Concatenation(String(x)," "))) );
        od;
        CloseStream( output );
      fi;
    fi;

    om:=false;
    if Size(ksub)=2 and NestingDepthA(ksub[1])=3 and NestingDepthA(ksub[2])=1 then
      om:=true;
      omrhs:=ksub[2];
      omsize:=List(ksub[1],Size);
      omsets:=List(omsize,x->[1..x]);
      ompart:=List([1..Size(omsize)],i->Sum(omsize{[1..i-1]})+omsets[i]);
      rfilename := Filename( PAGGlobalOptions.TempDir, "solvesteiner.row" );
      output := OutputTextFile( rfilename, false );
      for i in [1..Size(omrhs)] do
        WriteLine( output, String( omrhs[i] ) );
        WriteLine( output, String( omsize[i] ) );
        WriteLine( output, Concatenation(List(ompart[i]-1,x->Concatenation(String(x)," "))) );
      od;
      CloseStream( output );
      ksub:=Concatenation(ksub[1]);
    fi;

    po:=Union(List(List(tsub,x->Orbit(g,x,OnSets)),Union));
    v:=Size(po);
    if po<>[1..v] then
      Print("Error: orbits do not span [1..v].\n");
    else
      t:=Size(tsub[1]);
      k:=Size(ksub[1]);
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "solvesteiner.gin" ), false );
      WriteLine( output, String( [ v, t, k ] ) );
      WriteLine( output, String( Size( g ) ) );
      List(Elements(g),x->WriteLine(output,String(Permuted([1..v],x))));
      WriteLine( output, String( Size( tsub ) ) );
      WriteLine( output, String( tsub ) );
      WriteLine( output, String( Size( ksub ) ) );
      WriteLine( output, String( ksub ) );
      CloseStream( output );
      input := InputTextFile( Filename( PAGGlobalOptions.TempDir, "solvesteiner.gin" ) );
      output := OutputTextFile( Filename( PAGGlobalOptions.TempDir, "solvesteiner.in" ), false );
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "gap2raw" );
      Process( PAGGlobalOptions.TempDir, command, input, output, [  ] );
      CloseStream( input );
      CloseStream( output );

      input := InputTextFile( Filename( PAGGlobalOptions.TempDir, "solvesteiner.in" ) );
      if PAGGlobalOptions.Silent then
        output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solvesteiner.log"), false );
      else
        output:=OutputTextUser();
      fi;
      command := Filename( DirectoriesPackagePrograms( "PAG" ), "solvelibexact4" );
      popt:=["-osolve.out"];
      if ol<>[] then
        if part then
          popt:=Concatenation(popt,[Concatenation("-p",cfilename)]);
        else
          popt:=Concatenation(popt,[Concatenation("-c",cfilename)]);
        fi;
      fi;
      if om then
        popt:=Concatenation(popt,[Concatenation("-r",rfilename)]);
      fi;
      if not PAGGlobalOptions.Silent then
        popt:=Concatenation(popt,["-s"]);
      fi;
      if iter then
        popt:=Concatenation(popt,["-i"]);
      fi;
      if verb then
        popt:=Concatenation(popt,["-v"]);
      fi;
      Process( PAGGlobalOptions.TempDir, command, input, output, popt );
      CloseStream( input );
      CloseStream( output );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.out") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.g"), false);
      Process(PAGGlobalOptions.TempDir, command, input, output, ["-v"]);
      CloseStream(input);
      CloseStream(output);

      Read( Filename(PAGGlobalOptions.TempDir,"solve.g") );
      return PAGProcessResult;

    fi;
end );


#############################################################################
#
#  BaseBlocks( <ksub>, <sol> )
#
#  Returns base blocks of design(s) from solution(s) <A>sol</A> by picking
#  them from k-subset orbit representatives <A>ksub</A>
#
InstallGlobalFunction( BaseBlocks, function(ksub, sol)

    if NestingDepthA(sol)=1 then
      return ksub{sol};
    else
      return List(sol,x->ksub{x});
    fi;
end );


#############################################################################
#
#  OrbitMats( <t>, <v>, <k>, <lambda>, <nu>, <beta> )
#
#  Returns orbit matrices for <M>t</M>-<M>(v,k,lambda)</M> designs
#  with point and block orbit size vectors <A>nu</A> and <A>beta</A>.
#
InstallGlobalFunction( OrbitMats, function( t, v, k, lambda, nu, beta )
local b,i,output,input,command,rez;
  b:=TDesignB(t,v,k,lambda);
  if Sum(nu)<>v or Sum(beta)<>b then
    Print("Vectors nu, beta not compatible with parameters.\n");
  else
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"orbitmats.par"), false );
    WriteAll(output,Concatenation(String(t)," ",String(v)," ",String(k)," ",String(lambda),"\n"));
    WriteLine(output,Concatenation(String(Size(nu))," ",String(Size(beta))));
    for i in nu do WriteAll(output,Concatenation(String(i)," ")); od;
    WriteAll(output,"\n");
    for i in beta do WriteAll(output,Concatenation(String(i)," ")); od;
    WriteAll(output,"\n");
    WriteLine(output,"?");
    CloseStream(output);
    command:=Filename(DirectoriesPackagePrograms("PAG"), "orbmat5qd");
    input:=InputTextUser();
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"orbitmats.om"), false );
    Process(PAGGlobalOptions.TempDir, command, input, output, [Filename(PAGGlobalOptions.TempDir,"orbitmats.par"),"-d"]);
    CloseStream(input);
    CloseStream(output);
    rez:=ReadMat( Filename(PAGGlobalOptions.TempDir,"orbitmats.om"), rec(Format:="om") );
    if Size(rez)=3 then 
      rez:=rez[3];
    fi;
    return rez;
  fi;
end );


#############################################################################
#
#  OrbitMatsWide( <t>, <v>, <k>, <lambda>, <nu>, <beta>[, <opt>] )
#
#  Returns orbit matrices for <M>t</M>-<M>(v,k,lambda)</M> designs
#  with point and block orbit size vectors <A>nu</A> and <A>beta</A>.
#  Uses an algorithm suited for matrices with few rows and many 
#  columns, i.e. short <A>nu</A> and long <A>beta</A>. A.Wassermann's 
#  LLL solver <C>solvediophant2</C> is called. The function 
#  <Ref Func="OrbitMats" Style="Text"/> returns matrices in canonical 
#  form, therefore inequivalent. In contrast, this function may
#  return equivalent matrices multiple times. This can be changed 
#  by setting options. Possible components of the record <A>opt</A> 
#  are:
#  <List>
#  <Item><A>Inequivalent</A>:=<C>true</C>/<C>false</C> If set to <C>true</C>, 
#  equivalent copies of the orbit matrices are eliminated.</Item>
#  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
#  canonical forms of the orbit matrices are returned.</Item>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
#  <C>solvediophant2</C>. This is the default.</Item>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>. 
#  </Item>
#  </List>
#
InstallGlobalFunction( OrbitMatsWide, function( t, v, k, lambda, nu, beta, opt... )
local lambdas,m,n,cols,dcols,cbeta,colcand,ccs,eqn0,eqn1,colcandkapa,ccr,cck,eqn2a,
      eqn2b,output,mat,row,str,input,command,sol,canon,om,verb,eqn3a,eqn3b,eqn3c,
      eqn3d,bds,A,b,quo,bds2,pos,bds3,solver,filt;

    canon:=false;
    verb:=false;
    solver:=2;
    filt:=false;
    if Size(opt)>=1 then
      if IsBound(opt[1].Inequivalent) then
         filt:=opt[1].Inequivalent;
      fi;
      if IsBound(opt[1].Canonical) then
         canon:=opt[1].Canonical;
         if canon then filt:=true; fi;
      fi;
      if IsBound(opt[1].Verbose) then
         verb:=opt[1].Verbose;
      fi;
      if IsBound(opt[1].Solver) then
         if opt[1].Solver="solvediophant" then solver:=1; fi;
         if opt[1].Solver in ["solvediophant2","sd2"] then solver:=2; fi;
      fi;
    fi;

    if Sum(nu)<>v or Sum(beta)<>TDesignB(t,v,k,lambda) then
      Print("Vectors nu, beta not compatible with design parameters!\n");
    else
    m:=Size(nu);
    lambdas:=TDesignLambdas(t,v,k,lambda){[2..t+1]};
    cols:=OrderedPartitions(k+m,m)-1;
    dcols:=List(cols,x->List([1..m],i->x[i]/nu[i]));
    cbeta:=Collected(beta);
    colcand:=List(List(cbeta,First),y->Filtered(dcols*y,x->AsSet(List(x,IsInt))=[true]));
    ccs:=List(colcand,Size);
    eqn0:=List([1..Size(cbeta)],j->Concatenation(Concatenation(List([1..Size(cbeta)],i->[1..ccs[i]]*0+IversonBracket(i=j))),[cbeta[j][2]]));
    eqn1:=List([1..m],i->Concatenation(List(Concatenation(colcand),x->x[i]),[lambdas[1]]));
    colcandkapa:=List([1..Size(cbeta)],j->List(colcand[j],x->List([1..m],i->x[i]*nu[i]))/cbeta[j][1]);
    ccr:=Concatenation(colcand);
    cck:=Concatenation(colcandkapa);
    n:=Size(ccr);
    eqn2a:=List([1..m],i->Concatenation(List([1..n],j->ccr[j][i]*cck[j][i]),[lambdas[1]+lambdas[2]*(nu[i]-1)]));
    eqn2b:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]]));
    eqn3a:=[];
    eqn3b:=[];
    eqn3c:=[];
    eqn3d:=[];
    if t>=3 then
      eqn3a:=List([1..m],i->Concatenation(List([1..n],j->ccr[j][i]*cck[j][i]*cck[j][i]),[lambdas[1]+3*lambdas[2]*(nu[i]-1)+lambdas[3]*(nu[i]-1)*(nu[i]-2)]));
      eqn3b:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[1]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]+lambdas[3]*(nu[s[1]]-1)*nu[s[2]]]));
      eqn3c:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]+lambdas[3]*(nu[s[2]]-1)*nu[s[2]]]));
      eqn3d:=List(Combinations([1..m],3),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]*cck[j][s[3]]),[lambdas[3]*nu[s[2]]*nu[s[3]]]));
    fi;
    mat:=Concatenation(eqn0,eqn1,eqn2a,eqn2b,eqn3a,eqn3b,eqn3c,eqn3d);

    bds:=Concatenation(List([1..Size(cbeta)],i->[1..ccs[i]]*0+cbeta[i][2]));
    A:=TransposedMat(mat){[1..n]};
    b:=TransposedMat(mat)[n+1];
    quo:=function(x,y,z)
      if y=0 then return z;
      else return Int(x/y);
      fi;
    end;
    bds2:=List([1..Size(bds)],i->Minimum(List(TransposedMat([b,A[i]]),x->quo(x[1],x[2],bds[i])))); 
    pos:=Positions(List(bds2,x->x>0),true);
    bds3:=bds2{pos};
    mat:=TransposedMat(Concatenation(A{pos},[b]));
    n:=Size(pos);
    cck:=cck{pos};

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"orbmatswide.in"), false );
    WriteLine(output,Concatenation(String(Size(mat))," ",String(n)," 1"));
    for row in mat do
      str:=Concatenation(List(row,x->Concatenation(String(x)," ")));
      WriteLine(output,str);
    od;
    WriteLine(output,Concatenation("BOUNDS ",String(n)));
    str:=Concatenation(List(bds3,x->Concatenation(String(x)," ")));
    WriteLine(output,str);
    CloseStream(output);

    input:=InputTextUser();
    if solver=1 then
      if verb then
        output:=OutputTextUser();
      else
        output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.log"), false );
      fi;
      command:=Filename(DirectoriesPackagePrograms("PAG"), "solvediophant");
      Process(PAGGlobalOptions.TempDir, command, input, output, 
              ["-c10000","-bkz","-beta80","-p18","-maxnorm1","-oorbmatswide.out", "orbmatswide.in"] );
    else
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.log1"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "sd2");
      Process(PAGGlobalOptions.TempDir, command, input, output, 
              ["-c10000","-bkz","-beta80","-maxnorm1","-oorbmatswide.out", "orbmatswide.in"] );
    fi;
    CloseStream(input);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"orbmatswide.out") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"orbmatswide.g"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, ["-i"]);
    CloseStream(input);
    CloseStream(output);

    sol:=AsSet(ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"orbmatswide.g") )());
    om:=List(sol,y->TransposedMat(Concatenation(List([1..n],j->List([1..y[j]],x->cck[j])))));;

    if filt and om<>[] then
      if verb then
        Print("Eliminating equivalent copies...\n");
      fi;
      om:=OrbitMatFilter(nu,beta,om,rec(Canonical:=canon)); 
    fi;

    return om;
    fi;
end );


#############################################################################
#
#  OrbitMatsWide2( <t>, <v>, <k>, <lambda>, <nu>, <bo>[, <opt>] )  
#
#  Returns orbit matrices for <M>t</M>-<M>(v,k,lambda)</M> designs
#  with point size vector <A>nu</A> and block orbit sizes from a
#  set of integers <A>bo</A>. Typically, <A>bo</A> contains divisors 
#  of the group order. Uses an algorithm suited for matrices with 
#  few rows (i.e. short <A>nu</A>-vector) and many columns. 
#  A.Wassermann's LLL solver <C>solvediophant2</C> is called. The 
#  function <Ref Func="OrbitMats" Style="Text"/> returns matrices in 
#  canonical form, therefore inequivalent. By default, this function 
#  may return equivalent matrices. This can be changed by setting 
#  options. Possible components of the record <A>opt</A> are:
#  <List>
#  <Item><A>Inequivalent</A>:=<C>true</C>/<C>false</C> If set to <C>true</C>, 
#  equivalent copies of the orbit matrices are eliminated.</Item>
#  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
#  canonical forms of the orbit matrices are returned.</Item>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>. 
#  </Item>
#  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
#  <C>solvediophant2</C>. This is the default.</Item>
#  <Item><A>StopAfter</A>:=<M>n</M> Stop search after <M>n</M> solutions 
#  have been found. By default, the search goes on until all solutions 
#  are found.</Item>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
#  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
#  is used.</Item>
#  </List>
#
InstallGlobalFunction( OrbitMatsWide2, function( t, v, k, lambda, nu, bo, opt... )
local lambdas,m,n,cols,dcols,cbeta,colcand,ccs,eqn0,eqn1,colcandkapa,ccr,cck,
      eqn2a,eqn2b,output,mat,row,str,input,command,sol,canon,om,verb,eqn3a,eqn3b,
      eqn3c,eqn3d,bds,A,b,quo,bds2,pos,bds3,solver,betas,stopafter,tempdir,filt;

    canon:=false;
    filt:=false;
    verb:=false;
    solver:=2;
    stopafter:=0;
    tempdir:=PAGGlobalOptions.TempDir;
    if Size(opt)>=1 then
      if IsBound(opt[1].Inequivalent) then
         filt:=opt[1].Inequivalent;
      fi;
      if IsBound(opt[1].Canonical) then
         canon:=opt[1].Canonical;
         if canon then filt:=true; fi;
      fi;
      if IsBound(opt[1].Verbose) then
         verb:=opt[1].Verbose;
      fi;
      if IsBound(opt[1].Solver) then
         if opt[1].Solver="solvediophant" then solver:=1; fi;
         if opt[1].Solver in ["sd2","solvediophant2"] then solver:=2; fi;
      fi;
      if IsBound(opt[1].StopAfter) then
         stopafter:=opt[1].StopAfter;
      fi;
      if IsBound(opt[1].TempDir) then
         tempdir:=Directory(opt[1].TempDir);
      fi;
    fi;

    if Sum(nu)<>v then
      Print("Vector nu not compatible with design parameters!\n");
      return fail;
    else
    m:=Size(nu);
    lambdas:=TDesignLambdas(t,v,k,lambda){[2..t+1]};
    cols:=OrderedPartitions(k+m,m)-1;
    dcols:=List(cols,x->List([1..m],i->x[i]/nu[i]));
    colcand:=List(bo,y->Filtered(dcols*y,x->AsSet(List(x,IsInt))=[true]));
    ccs:=List(colcand,Size);
    eqn1:=List([1..m],i->Concatenation(List(Concatenation(colcand),x->x[i]),[lambdas[1]]));
    colcandkapa:=List([1..Size(bo)],j->List(colcand[j],x->List([1..m],i->x[i]*nu[i]))/bo[j]);
    ccr:=Concatenation(colcand);
    cck:=Concatenation(colcandkapa);
    n:=Size(ccr);
    eqn0:=[Concatenation(Concatenation(List(TransposedMat([List(List(colcand,Size),x->[1..x]*0),bo]),Sum)),[TDesignB(t,v,k,lambda)])];
    eqn2a:=List([1..m],i->Concatenation(List([1..n],j->ccr[j][i]*cck[j][i]),[lambdas[1]+lambdas[2]*(nu[i]-1)]));
    eqn2b:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]]));
    eqn3a:=[];
    eqn3b:=[];
    eqn3c:=[];
    eqn3d:=[];
    if t>=3 then
      eqn3a:=List([1..m],i->Concatenation(List([1..n],j->ccr[j][i]*cck[j][i]*cck[j][i]),[lambdas[1]+3*lambdas[2]*(nu[i]-1)+lambdas[3]*(nu[i]-1)*(nu[i]-2)]));
      eqn3b:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[1]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]+lambdas[3]*(nu[s[1]]-1)*nu[s[2]]]));
      eqn3c:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]+lambdas[3]*(nu[s[2]]-1)*nu[s[2]]]));
      eqn3d:=List(Combinations([1..m],3),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]*cck[j][s[3]]),[lambdas[3]*nu[s[2]]*nu[s[3]]]));
    fi;
    mat:=Concatenation(eqn0,eqn1,eqn2a,eqn2b,eqn3a,eqn3b,eqn3c,eqn3d);

    bds:=Concatenation(List([1..Size(bo)],i->[1..ccs[i]]*0+Int(TDesignB(t,v,k,lambda)/bo[i])));
    A:=TransposedMat(mat){[1..n]};
    b:=TransposedMat(mat)[n+1];
    quo:=function(x,y,z)
      if y=0 then return z;
      else return Int(x/y);
      fi;
    end;
    bds2:=List([1..Size(bds)],i->Minimum(List(TransposedMat([b,A[i]]),x->quo(x[1],x[2],bds[i]))));
    pos:=Positions(List(bds2,x->x>0),true);
    bds3:=bds2{pos};
    mat:=TransposedMat(Concatenation(A{pos},[b]));
    n:=Size(pos);
    cck:=cck{pos};

    output:=OutputTextFile( Filename(tempdir,"orbmatswide.in"), false );
    if stopafter>0 then
      WriteLine(output,Concatenation("% stopafter ",String(stopafter)));
    fi;
    WriteLine(output,Concatenation(String(Size(mat))," ",String(n)," 1"));
    for row in mat do
      str:=Concatenation(List(row,x->Concatenation(String(x)," ")));
      WriteLine(output,str);
    od;
    WriteLine(output,Concatenation("BOUNDS ",String(n)));
    str:=Concatenation(List(bds3,x->Concatenation(String(x)," ")));
    WriteLine(output,str);
    CloseStream(output);

    input:=InputTextUser();
    if solver=1 then
      if verb then
        output:=OutputTextUser();
      else
        output:=OutputTextFile( Filename(tempdir,"solve.log"), false );
      fi;
      command:=Filename(DirectoriesPackagePrograms("PAG"), "solvediophant");
      Process(tempdir, command, input, output,
              ["-c10000","-bkz","-beta80","-p18","-maxnorm1","-oorbmatswide.out", "orbmatswide.in"] );
    else
      output:=OutputTextFile( Filename(tempdir,"solve.log1"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "sd2");
      Process(tempdir, command, input, output,
              ["-c10000","-bkz","-beta80","-maxnorm1","-oorbmatswide.out", "orbmatswide.in"] );
    fi;
    CloseStream(input);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
    input:=InputTextFile( Filename(tempdir,"orbmatswide.out") );
    output:=OutputTextFile( Filename(tempdir,"orbmatswide.g"), false);
    Process(tempdir, command, input, output, ["-i"]);
    CloseStream(input);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
    input:=InputTextFile( Filename(tempdir,"orbmatswide.out") );
    output:=OutputTextFile( Filename(tempdir,"orbmatswide.g"), false);
    Process(tempdir, command, input, output, ["-i"]);
    CloseStream(input);
    CloseStream(output);

    sol:=AsSet(ReadAsFunction( Filename(tempdir,"orbmatswide.g") )());
    eqn0:=mat[1]{[1..Size(mat[1])-1]};
    om:=List(sol,y->[Concatenation(List(TransposedMat([List(y,i->[1..i]*0),eqn0]),Sum)),
      TransposedMat(Concatenation(List([1..n],j->List([1..y[j]],x->cck[j]))))]);;
    betas:=AsSet(List(om,First));
    om:=List(betas,z->[z,List(Filtered(om,x->x[1]=z),y->y[2])]);

    if filt and om<>[] then
      if verb then
        Print("Eliminating equivalent copies...\n");
      fi;
      om:=List(om,x->[x[1],OrbitMatFilter(nu,x[1],x[2],rec(Canonical:=canon))]); 
    fi;

    return om;
    fi;
end );


#############################################################################
#
#  ColumnsOM( <g>, <t>, <v>, <k>[, <opt>] )  
#  
#  Returns candidates for columns of orbit matrices corresponding to
#  Steiner <M>t</M>-<M>(v,k,1)</M> designs with <A>g</A> as group of
#  automorphisms. The optional argument <A>opt</A> is a record for 
#  options with possible components:
#  <List>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  <Item><A>Bounds</A>:=<C>true</C>/<C>false</C>  With each column 
#  also return an upper bound on how many times it may be used in 
#  the orbit matrix.</Item>
#  </List>
#
InstallGlobalFunction( ColumnsOM, function( g, t, v, k, opt... )
local po,ksub,clong,cshort,verb,bds;

  verb:=false;
  bds:=false;
  if Size(opt)>=1 then
    if IsBound(opt[1].Verbose) then
      verb:=opt[1].Verbose;
    fi;
    if IsBound(opt[1].Bounds) then
      bds:=opt[1].Bounds;
    fi;
  fi;
  po:=List(Orbits(g,[1..v]),AsSet);
  ksub:=SubsetOrbitRepSteiner(g,t,v,k,rec(Short:=false,Verbose:=verb));
  clong:=List(List(ksub,y->List(po,x->Size(Intersection(x,y)))),x->[Size(g),x]);
  ksub:=SubsetOrbitRepSteiner(g,t,v,k,rec(Long:=false,Verbose:=verb));
  cshort:=List(ksub,y->[Size(Orbit(g,y,OnSets)),List(po,x->Size(Intersection(x,y)))]);
  if bds then
    clong:=Collected(clong);
    cshort:=Collected(cshort);
  else
    clong:=AsSet(clong);
    cshort:=AsSet(cshort);
  fi;
  return Concatenation(cshort,clong);
end );


#############################################################################
#
#  OrbitMatsWide3( <t>, <v>, <k>, <g>[, <opt>] )  
#  
#  Returns orbit matrices for Steiner <M>t</M>-<M>(v,k,1)</M> designs
#  with <A>g</A> as group of automorphisms. This version computes the
#  point and block orbit sizes, the column candidates and upper bounds
#  on how many times they may be used from the group <A>g</A>. Uses
#  an algorithm suited for matrices with few rows and many columns. 
#  A.Wassermann's LLL solver <C>solvediophant2</C> is called. The 
#  function <Ref Func="OrbitMats" Style="Text"/> returns matrices in 
#  canonical form, therefore inequivalent. By default, this function 
#  may return equivalent matrices. This can be changed by setting 
#  options. Possible components of the record <A>opt</A> are:
#  <List>
#  <Item><A>Inequivalent</A>:=<C>true</C>/<C>false</C> If set to <C>true</C>, 
#  equivalent copies of the orbit matrices are eliminated.</Item>
#  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
#  canonical forms of the orbit matrices are returned.</Item>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
#  reporting the progress of the calculation.</Item>
#  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
#  <C>solvediophant2</C>. This is the default.</Item>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>. 
#  </Item>
#  <Item><A>StopAfter</A>:=<M>n</M> Stop search after <M>n</M> solutions 
#  have been found. By default, the search goes on until all solutions 
#  are found.</Item>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
#  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
#  is used.</Item>
#  </List>
#
InstallGlobalFunction( OrbitMatsWide3, function( t, v, k, g, opt... )
local lambdas,m,n,cols,dcols,cbeta,colcand,ccs,eqn0,eqn1,colcandkapa,ccr,cck,
      eqn2a,eqn2b,output,mat,row,str,input,command,sol,canon,om,verb,eqn3a,eqn3b,
      eqn3c,eqn3d,bds,A,b,quo,bds2,pos,bds3,solver,betas,stopafter,tempdir,
      po,nu,bo,lambda,com,bds0,bds1,optfilt,filt,norm,npo,unpo,v1,v2,i;

    canon:=false;
    filt:=false;
    verb:=false;
    solver:=2;
    stopafter:=0;
    optfilt:=rec();
    tempdir:=PAGGlobalOptions.TempDir;
    if Size(opt)>=1 then
      if IsBound(opt[1].Inequivalent) then
         filt:=opt[1].Inequivalent;
      fi;
      if IsBound(opt[1].Canonical) then
         canon:=opt[1].Canonical;
         if canon then filt:=true; fi;
      fi;
      if IsBound(opt[1].Verbose) then
         verb:=opt[1].Verbose;
      fi;
      if IsBound(opt[1].Solver) then
         if opt[1].Solver="solvediophant" then solver:=1; fi;
         if opt[1].Solver in ["sd2","solvediophant2"] then solver:=2; fi;
      fi;
      if IsBound(opt[1].StopAfter) then
         stopafter:=opt[1].StopAfter;
      fi;
      if IsBound(opt[1].TempDir) then
         tempdir:=Directory(opt[1].TempDir);
         optfilt.TempDir:=opt[1].TempDir;
      fi;
    fi;

    po:=List(Orbits(g,[1..v]),AsSet);
    nu:=List(po,Size);
    if nu<>AsSortedList(nu) then
      Print("The point orbit vector is not sorted! Apply 'TidyGroup' to get correct results.\n");
      return fail;   
    fi;
    m:=Size(nu);
    bo:=AsSet(List(AllSubgroupsConjugation(g),x->Size(g)/Size(x)));
    lambda:=1;
    lambdas:=TDesignLambdas(t,v,k,lambda){[2..t+1]};

    if verb then
      Print("Computing column candidates...\n");
    fi;
    com:=ColumnsOM(g,t,v,k,rec(Verbose:=verb,Bounds:=true));
    if verb then
      Print("Column candidates: ",Size(com),"\n");
    fi;
    bo:=AsSet(List(com,x->x[1][1]));
    colcandkapa:=List(bo,i->Filtered(com,x->x[1][1]=i));
    bds0:=List(Concatenation(colcandkapa),x->x[2]);
    colcandkapa:=List(colcandkapa,x->List(x,y->y[1][2]));
    colcand:=List([1..Size(bo)],j->List(colcandkapa[j],x->List([1..m],i->bo[j]*x[i]/nu[i])));

    ccs:=List(colcand,Size);
    eqn1:=List([1..m],i->Concatenation(List(Concatenation(colcand),x->x[i]),[lambdas[1]]));
    ccr:=Concatenation(colcand);
    cck:=Concatenation(colcandkapa);
    n:=Size(ccr);
    eqn0:=[Concatenation(Concatenation(List(TransposedMat([List(List(colcand,Size),x->[1..x]*0),bo]),Sum)),[TDesignB(t,v,k,lambda)])];
    eqn2a:=List([1..m],i->Concatenation(List([1..n],j->ccr[j][i]*cck[j][i]),[lambdas[1]+lambdas[2]*(nu[i]-1)]));
    eqn2b:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]]));
    eqn3a:=[];
    eqn3b:=[];
    eqn3c:=[];
    eqn3d:=[];
    if t>=3 then
      eqn3a:=List([1..m],i->Concatenation(List([1..n],j->ccr[j][i]*cck[j][i]*cck[j][i]),[lambdas[1]+3*lambdas[2]*(nu[i]-1)+lambdas[3]*(nu[i]-1)*(nu[i]-2)]));
      eqn3b:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[1]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]+lambdas[3]*(nu[s[1]]-1)*nu[s[2]]]));
      eqn3c:=List(Combinations([1..m],2),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]*cck[j][s[2]]),[lambdas[2]*nu[s[2]]+lambdas[3]*(nu[s[2]]-1)*nu[s[2]]]));
      eqn3d:=List(Combinations([1..m],3),s->Concatenation(List([1..n],j->ccr[j][s[1]]*cck[j][s[2]]*cck[j][s[3]]),[lambdas[3]*nu[s[2]]*nu[s[3]]]));
    fi;
    mat:=Concatenation(eqn0,eqn1,eqn2a,eqn2b,eqn3a,eqn3b,eqn3c,eqn3d);

    bds1:=Concatenation(List([1..Size(bo)],i->[1..ccs[i]]*0+Int(TDesignB(t,v,k,lambda)/bo[i])));
    bds:=List([1..Size(bds0)],i->Minimum(bds0[i],bds1[i]));
    A:=TransposedMat(mat){[1..n]};
    b:=TransposedMat(mat)[n+1];
    quo:=function(x,y,z)
      if y=0 then return z;
      else return Int(x/y);
      fi;
    end;
    bds2:=List([1..Size(bds)],i->Minimum(List(TransposedMat([b,A[i]]),x->quo(x[1],x[2],bds[i]))));
    pos:=Positions(List(bds2,x->x>0),true);
    bds3:=bds2{pos};
    mat:=TransposedMat(Concatenation(A{pos},[b]));
    n:=Size(pos);
    cck:=cck{pos};

    output:=OutputTextFile( Filename(tempdir,"orbmatswide.in"), false );
    if stopafter>0 then
      WriteLine(output,Concatenation("% stopafter ",String(stopafter)));
    fi;
    WriteLine(output,Concatenation(String(Size(mat))," ",String(n)," 1"));
    for row in mat do
      str:=Concatenation(List(row,x->Concatenation(String(x)," ")));
      WriteLine(output,str);
    od;
    WriteLine(output,Concatenation("BOUNDS ",String(n)));
    str:=Concatenation(List(bds3,x->Concatenation(String(x)," ")));
    WriteLine(output,str);
    CloseStream(output);

    input:=InputTextUser();
    if solver=1 then
      if verb then
        output:=OutputTextUser();
      else
        output:=OutputTextFile( Filename(tempdir,"solve.log"), false );
      fi;
      command:=Filename(DirectoriesPackagePrograms("PAG"), "solvediophant");
      Process(tempdir, command, input, output,
              ["-c10000","-bkz","-beta80","-p18","-maxnorm1","-oorbmatswide.out", "orbmatswide.in"] );
    else
      output:=OutputTextFile( Filename(tempdir,"solve.log1"), false );
      command:=Filename(DirectoriesPackagePrograms("PAG"), "sd2");
      Process(tempdir, command, input, output,
              ["-c10000","-bkz","-beta80","-maxnorm1","-oorbmatswide.out", "orbmatswide.in"] );
    fi;
    CloseStream(input);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
    input:=InputTextFile( Filename(tempdir,"orbmatswide.out") );
    output:=OutputTextFile( Filename(tempdir,"orbmatswide.g"), false);
    Process(tempdir, command, input, output, ["-i"]);
    CloseStream(input);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
    input:=InputTextFile( Filename(tempdir,"orbmatswide.out") );
    output:=OutputTextFile( Filename(tempdir,"orbmatswide.g"), false);
    Process(tempdir, command, input, output, ["-i","-v"]);
    CloseStream(input);
    CloseStream(output);

    Read( Filename(tempdir,"orbmatswide.g") );
    sol:=AsSet( PAGProcessResult );
    eqn0:=mat[1]{[1..Size(mat[1])-1]};
    om:=List(sol,y->[Concatenation(List(TransposedMat([List(y,i->[1..i]*0),eqn0]),Sum)),
      TransposedMat(Concatenation(List([1..n],j->List([1..y[j]],x->cck[j]))))]);;
    betas:=AsSet(List(om,First));
    om:=List(betas,z->[z,List(Filtered(om,x->x[1]=z),y->y[2])]);

    if filt and om<>[] then
      if verb then
        Print("Eliminating equivalent copies...\n");
      fi;
      norm:=Normalizer(SymmetricGroup(v),g);
      npo:=Orbits(norm,po,OnSets);
      unpo:=List(npo,Union);
      v1:=List(unpo{[1..Size(unpo)-1]},x->First(Reversed(x)));
      v2:=List(unpo{[2..Size(unpo)]},First);
      if v1+1<>v2 then
        Print("Equivalent orbits are not consecutive! Apply 'TidyGroup' to get correct result.\n");
        return fail;   
      fi;
      v1:=List(npo,x->List(x,Size));
      v2:=[1..Size(v1)]*0;
      for i in [2..Size(v1)] do
        if v1[i][1]=v1[i-1][1] then v2[i]:=v2[i-1]+Size(g); fi;
      od;
      nu:=Concatenation(List([1..Size(v1)],i->v1[i]+v2[i]));
      optfilt.Canonical:=canon;
      om:=List(om,x->[x[1],OrbitMatFilter(nu,x[1],x[2],optfilt)]); 
    fi;

    return om;
end );


#############################################################################
#
#  SubsetOrbitTypes( <g>, <v>, <ksub>, <i> )  
#  
#  Computes the types of index <A>i</A> for the subset orbit
#  representatives <A>ksub</A>. A permutation group <A>g</A>
#  and its degree <A>v</A> must also be given as arguments. 
#  The type information is returned in a record, together 
#  with the supplied arguments.
#
InstallGlobalFunction( SubsetOrbitTypes, function( g, v, ksub, tind )
local res,iorb,reptype,otype,ctype,types;

  res:=rec();
  res.OrbitRepresentatives:=ksub;
  res.TypeIndex:=tind;
  res.SetSize:=v; 
  res.Group:=g;
  iorb:=AsSet(List(Orbits(g,Combinations([1..v],tind),OnSets),AsSet));
  res.IndexOrbits:=iorb;
  reptype:=function(r)
    local ri;
    ri:=Combinations(r,tind);
    return List(iorb,x->Size(Intersection(x,ri)));
  end;
  otype:=List(ksub,reptype);
  ctype:=Collected(otype);
  types:=List(ctype,First);
  res.Types:=types;
  res.TypeBounds:=List(ctype,Last);
  res.OrbitTypes:=List(otype,x->Position(types,x));
  return res;
end );


#############################################################################
#
#  OrbitMatFilter( <nu>, <beta>, <om>[, <opt>] )  
#  
#  Eliminates equivalent copies from a list of orbit matrices <A>om</A>. 
#  It is assumed that all of the matrices have the same orbit size
#  vectors <A>nu</A> and <A>beta</A>. Two matrices are equivalent if 
#  one can be transformed into the other by row and column permutations 
#  respecting these vectors. Uses <C>nauty/Traces 2.8</C> by B.D.McKay 
#  and A.Piperno <Cite Key='MP14'/>. The optional argument <A>opt</A> 
#  is a record for options. Possible components of <A>opt</A> are:
#  <List>
#  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C> Puts the matrices in
#  canonical form.</Item>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
#  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
#  is used.</Item>
#  </List>
#
InstallGlobalFunction( OrbitMatFilter, function( nu, beta, om, opt... )
local input,output,str,mat,row,command,canon,tempdir,l,checkvec;

  checkvec:=function(vec)
  local i,c;
    c:=1;
    for i in [2..Size(vec)] do
      if vec[i]<>vec[i-1] then c:=c+1; fi;
    od;
    return Size(AsSet(vec))=c;
  end;

  if ((not checkvec(nu)) or (not checkvec(beta))) then
    Print("Warning! Orbit size vectors have equal entries in non-consecutive places!\n");
    Print("Apply 'TidyGroup' to make sure the orbit matrix computation is correct.\n");
  fi;

  tempdir:=PAGGlobalOptions.TempDir;
  canon:=false;
  if Size(opt)>=1 then
    if IsBound(opt[1].TempDir) then
      tempdir:=Directory(opt[1].TempDir);
    fi;
    if IsBound(opt[1].Canonical) then
      canon:=opt[1].Canonical;
    fi;
  fi;

  output:=OutputTextFile( Filename(tempdir,"omfilter.in"), false );
  str:=Concatenation(List(DimensionsMat(om[1]),x->Concatenation(String(x)," ")));
  WriteLine(output,str);
  str:=Concatenation(List(nu,x->Concatenation(String(x)," ")));
  WriteLine(output,str);
  str:=Concatenation(List(beta,x->Concatenation(String(x)," ")));
  WriteLine(output,str);
  for mat in om do
    for row in mat do
      str:=Concatenation(List(row,x->Concatenation(String(x)," ")));
        WriteLine(output,str);
      od;
      WriteLine(output,"");
    od;
  CloseStream(output);

  input:=InputTextFile( Filename(tempdir,"omfilter.in") );
  output:=OutputTextFile( Filename(tempdir,"omfilter.out"), false);
  if canon then
    command:=Filename(DirectoriesPackagePrograms("PAG"), "canonf");
    Process(tempdir, command, input, output, ["-t","-c"]);
  else
    command:=Filename(DirectoriesPackagePrograms("PAG"), "omfilter");
    Process(tempdir, command, input, output, []);
  fi;
  CloseStream(input);
  CloseStream(output);
  if canon then
    return ReadMat( Filename(tempdir,"omfilter.out"),rec(Format:="om"))[3];
  else
    input:=InputTextFile( Filename(tempdir,"omfilter.out") );
    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      l:=[]; 
    else
      NormalizeWhitespace(str);
      l:=List(SplitString(str," "),EvalString);
    fi;
    return om{l};
  fi;
end );


#############################################################################
#
#  TDesignB( <t>, <v>, <k>, <lambda> )  
#
#  The number of blocks of a <A>t</A>-(<A>v</A>,<A>k</A>,<A>lambda</A>) design. 
#
InstallGlobalFunction( TDesignB, function( t, v, k, lambda )

    return lambda*Binomial(v,t)/Binomial(k,t);
end );


#############################################################################
#
#  OrbitMatDual( <nu>, <beta>, <om> )  
#
#  Returns the dual of the orbit matrix <A>om</A>. 
#
InstallGlobalFunction( OrbitMatDual, function( nu, beta, om )
local i,j;

    return List([1..DimensionsMat(om)[1]],i->List([1..DimensionsMat(om)[2]],j->nu[i]*om[i][j]/beta[j]));
end );


#############################################################################
#
#  OrbitMatRowTest( <v>, <k>, <lambda>, <nu>, <beta>, <om> )  
#
#  Computes row products of <A>om</A> and tests if it is an
#  orbit matrix for a <M>2</M>-<M>(v,k,lambda)</M> design. 
#
InstallGlobalFunction( OrbitMatRowTest, function( v, k, lambda, nu, beta, om )
local rgame, rgames, samereturn, rtestmat;

    rgame:=function(nu,beta,om,i1,i2)
      return Sum([1..Size(beta)],j->beta[j]*om[i1][j]*om[i2][j]/nu[i1]);
    end;

    rgames:=function(nu,beta,om)
      return List([1..Size(nu)],i1->List([1..Size(nu)],i2->rgame(nu,beta,om,i1,i2)));
    end;

    samereturn:=function(x,y,same,different)
      if x=y then return same;
      else return different;
      fi;
    end;

    rtestmat:=function(v,k,lambda,nu,beta)
      local r;
      r:=TDesignLambdas(2,v,k,lambda)[2];
      return List([1..Size(nu)],i1->List([1..Size(nu)],i2->samereturn(i1,i2,lambda*(nu[i2]-1)+r,lambda*nu[i2])));
    end;

    return rgames(nu,beta,om)=rtestmat(v,k,lambda,nu,beta);
end );


#############################################################################
#
#  OrbitMatColumnTest( <v>, <k>, <lambda>, <x>, <y>, <nu>, <beta>, <om> )  
#
#  Computes column products of <A>om</A> and tests if it is an orbit 
#  matrix for a quasi-symmetric <M>2</M>-<M>(v,k,lambda)</M> design 
#  with intersection numbers <A>x</A> and <A>y</A>.
#
InstallGlobalFunction( OrbitMatColumnTest, function( v, k, lambda, x, y, nu, beta, om )
local cgame, cgames, tm1, possible, samereturn, ctestmat, tm2;

    cgame:=function(nu,beta,om,j1,j2)
      return Sum([1..Size(nu)],i->beta[j1]*om[i][j1]*om[i][j2]/nu[i]);
    end;

    cgames:=function(nu,beta,om)
      return List([1..Size(beta)],j1->List([1..Size(beta)],j2->cgame(nu,beta,om,j1,j2)));
    end;

    tm1:=cgames(nu,beta,om);

    possible:=function(x,y,size)
      return List([0..size],i->(size-i)*x+i*y);
    end;

    samereturn:=function(x,y,same,different)
      if x=y then return same;
      else return different;
      fi;
    end;

    ctestmat:=function(v,k,x,y,nu,beta)
      return List([1..Size(beta)],j1->List([1..Size(beta)],j2->samereturn(j1,j2,possible(x,y,beta[j1]-1)+k,possible(x,y,beta[j1]))));
    end;

    tm2:=ctestmat(v,k,x,y,nu,beta);

    return Union(List([1..Size(beta)],i->List([1..Size(beta)],j->tm1[i][j] in tm2[i][j])))=[true];
end );


#############################################################################
#
#  IntersectionNumbers( <d>[, <opt>] )  
#
#  Returns the list of intersection numbers of the block design <A>d</A>. 
#  The optional argument <A>opt</A> is a record for options. The possible 
#  components of <A>opt</A> are:
#  <List>
#  <Item><C>Frequencies:=true</C>/<C>false</C>  If set to <C>true</C>, 
#  frequencies of the intersection numbers are also returned.</Item>
#  </List>
#
InstallGlobalFunction( IntersectionNumbers, function( d, opt... )
local input,output,command,freq,lin;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"blockint.in"), false );
    PrintTo(output, NrBlockDesignPoints(d), " ", NrBlockDesignBlocks(d),"\n");
    PrintTo(output, BlockDesignBlocks(d));
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "blockint");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"blockint.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"blockint.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []); 
    CloseStream(output);
    CloseStream(input);

    lin:=ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"blockint.out") )();
    freq:=false;

    if Size(opt)>=1 then
      if IsBound(opt[1].Frequencies) then
         freq:=opt[1].Frequencies;
      fi;
    fi;

    if not freq then
      lin := List(lin,First);
    fi;

    return lin;
end );


#############################################################################
#
#  BlockDesignAut( <d>[, <opt>] )  
#
#  Computes the full automorphism group of a block design <A>d</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  This is an alternative for the <C>AutGroupBlockDesign</C> function from 
#  the <Package>Design</Package> package <Ref Chap="Design" BookName="DESIGN"/>. 
#  The optional argument <A>opt</A> is a record for options. Possible components 
#  of <A>opt</A> are:
#  <List>
#  <Item><A>Traces</A>:=<C>true</C>/<C>false</C>  Use <C>Traces</C>. 
#  This is the default.</Item>
#  <Item><A>SparseNauty</A>:=<C>true</C>/<C>false</C>  Use <C>nauty</C>
#  for sparse graphs.</Item>
#  <Item><A>DenseNauty</A>:=<C>true</C>/<C>false</C>  Use <C>nauty</C>
#  for dense graphs. This is usually the slowest program, but it allows
#  vertex invariants. Vertex invariants are ignored by the other programs.</Item>
#  <Item><A>BlockAction</A>:=<C>true</C>/<C>false</C>  If set to 
#  <C>true</C>, the action of the automorphisms on blocks is also 
#  given. In this case automorphisms are permutations of degree
#  <M>v+b</M>. By default, only the action on points is given,
#  i.e. automorphisms are permutations of degree <M>v</M>.</Item>
#  <Item><A>Dual</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
#  dual automorphisms (correlations) are also included. They will 
#  appear only for self-dual symmetric designs (with the same number
#  of points and blocks). The default is <C>false</C>.</Item>
#  <Item><A>PointClasses</A>:=<A>s</A>   Color the points into classes 
#  of size <A>s</A> that cannot be mapped onto each other (for autotopy). 
#  By default, all points are in the same class.</Item>
#  <Item><A>ParatopyClasses</A>:=<A>s</A>   Make point classes of size 
#  <A>s</A> that can be exchanged (for autoparatopy).</Item>
#  <Item><A>VertexInvariant</A>:=<A>n</A>   Use vertex invariant number 
#  <A>n</A>. The numbering is the same as in <C>dreadnaut</C>, e.g. 
#  <A>n</A>=1: <C>twopaths</C>, <A>n</A>=2: <C>adjtriang</C>, etc. The 
#  default is <C>twopaths</C>. Vertex invariants only work with dense
#  <C>nauty</C>. They are ignored by sparse <C>nauty</C> and 
#  <C>Traces</C>.</Item>
#  <Item><A>Mininvarlevel</A>:=<A>n</A>   Set <C>mininvarlevel</C>
#  to <A>n</A>. The default is <A>n</A>=0.</Item>
#  <Item><A>Maxinvarlevel</A>:=<A>n</A>   Set <C>maxinvarlevel</C>
#  to <A>n</A>. The default is <A>n</A>=2.</Item>
#  <Item><A>Invararg</A>:=<A>n</A>   Set <C>invararg</C> to <A>n</A>. 
#  The default is <A>n</A>=0.</Item>
#  </List>
#
InstallGlobalFunction( BlockDesignAut, function( d, opt... )
local input,output,command,str,n,l1,l2,ng,clo,g,abl,cmd,para;

  para:=0;
  if IsBound(d.autGroup) and Size(opt)=0 then
    return d.autGroup;
  else
    clo:=[];
    abl:=false;
    cmd:=3;
    if Size(opt)>=1 then
      if IsBound(opt[1].BlockAction) then
         abl:=opt[1].BlockAction; 
      fi;
      if IsBound(opt[1].Dual) then
         if opt[1].Dual then
           Add(clo,"-d");
           abl:=true;
         fi;
      fi;
      if IsBound(opt[1].DenseNauty) then
         if opt[1].DenseNauty then
           cmd:=2;
         fi;
      fi;
      if IsBound(opt[1].Traces) then
         if opt[1].Traces then
           cmd:=3;
         fi;
      fi;
      if IsBound(opt[1].SparseNauty) then
         if opt[1].SparseNauty then
           cmd:=1;
         fi;
      fi;
      if IsBound(opt[1].PointClasses) then
         Add(clo,Concatenation("-p",String(opt[1].PointClasses)));
      fi;
      if IsBound(opt[1].ParatopyClasses) then
         Add(clo,Concatenation("-t",String(opt[1].ParatopyClasses)));
         para:=opt[1].ParatopyClasses;
      fi;
      if cmd=2 then
        if IsBound(opt[1].VertexInvariant) then
          Add(clo,Concatenation("-i",String(opt[1].VertexInvariant)));
        fi;
        if IsBound(opt[1].Mininvarlevel) then
          Add(clo,Concatenation("-m",String(opt[1].Mininvarlevel)));
        fi;
        if IsBound(opt[1].Maxinvarlevel) then
          Add(clo,Concatenation("-x",String(opt[1].Maxinvarlevel)));
        fi;
        if IsBound(opt[1].Invararg) then
          Add(clo,Concatenation("-a",String(opt[1].Invararg)));
        fi;
      fi;
    fi;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.in"), false );
    PrintTo(output, NrBlockDesignPoints(d), " ", NrBlockDesignBlocks(d),"\n");
    PrintTo(output, BlockDesignBlocks(d));
    CloseStream(output);

    if cmd=2 then
      command:=Filename(DirectoriesPackagePrograms("PAG"), "bdaut");
    else if cmd=1 then
           command:=Filename(DirectoriesPackagePrograms("PAG"), "bdautsp");
         else
           command:=Filename(DirectoriesPackagePrograms("PAG"), "bdauttr");
         fi;
    fi;
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, clo); 
    CloseStream(output);
    CloseStream(input);

    if cmd=3 then
      command:=Filename(DirectoriesPackagePrograms("PAG"), "delgen");
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.out") );
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.out2"), false);
      Process(PAGGlobalOptions.TempDir, command, input, output, []); 
      CloseStream(output);
      CloseStream(input);
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.out2") );
    else
      input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"bdaut.out") );
    fi;

    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      g:=Group(());
    else
      NormalizeWhitespace(str);
      l1:=List(SplitString(str," "),EvalString)+1;
      n:=NrBlockDesignPoints(d)+NrBlockDesignBlocks(d)+para;
      ng:=Size(l1)/n-1;
      l2:=List([0..ng],i->l1{[n*i+1..n*(i+1)]});
      g:=Group(List(l2,PermList));
    fi;

    if not abl then
      g:=RestrictedGroup(g,[1..NrBlockDesignPoints(d)]);
    fi;
    if Size(opt)=0 then
      d.autGroup:=g;
    fi;
    return g;
  fi; 
end );


#############################################################################
#
#  HadamardMatAut( <H>[, <opt>] )  
#
#  Computes the full automorphism group of a Hadamard matrix <A>H</A>.
#  Represents the matrix by a colored graph (see <Cite Key='BM79'/>) and
#  uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible components 
#  of <A>opt</A> are:
#  <List>
#  <Item><A>Dual</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
#  dual automorphisms (transpositions) are also allowed. The default is 
#  <C>false</C>.</Item>
#  </List>
#
InstallGlobalFunction( HadamardMatAut, function( h, opt... )
local input,output,command,str,n,l1,l2,ng,clo,g;

    clo:=[];
    if Size(opt)>=1 then
      if IsBound(opt[1].Dual) then
         if opt[1].Dual then
           Add(clo,"-d");
         fi;
      fi;
    fi;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"hadaut.in"), false );
    PrintTo(output, Size(h),"\n");
    PrintTo(output, h);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "hadaut");
    
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"hadaut.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"hadaut.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, clo); 
    CloseStream(output);
    CloseStream(input);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "delgen");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"hadaut.out") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"hadaut.out2"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []); 
    CloseStream(output);
    CloseStream(input);
    
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"hadaut.out2") );
    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      g:=Group(());
    else
      NormalizeWhitespace(str);
      l1:=List(SplitString(str," "),EvalString)+1;
      n:=4*Size(h);
      ng:=Size(l1)/n-1;
      l2:=List([0..ng],i->l1{[n*i+1..n*(i+1)]});
      g:=Group(List(l2,PermList));
   fi;

   return g;
end );


#############################################################################
#
#  MatAut( <M> )  
#
#  Computes the full automorphism group of a matrix <A>M</A>. It is
#  assumed that the entries of <A>M</A> are consecutive integers. 
#  Permutations of rows, columns and symbols are allowed.
#  Represents the matrix by a colored graph and uses 
#  <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#
InstallGlobalFunction( MatAut, function( m )
local input,output,command,str,n,l1,l2,ng,g,e;

    e:=Union(m);
    m:=m-Minimum(e);
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"mataut.in"), false );
    PrintTo(output, Size(m), " ", Size(m[1]), " ", Size(e), "\n");
    PrintTo(output, m);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "mataut");
    
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"mataut.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"mataut.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, [] ); 
    CloseStream(output);
    CloseStream(input);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "delgen");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"mataut.out") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"mataut.out2"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []); 
    CloseStream(output);
    CloseStream(input);
    
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"mataut.out2") );
    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      g:=Group(());
    else
      NormalizeWhitespace(str);
      l1:=List(SplitString(str," "),EvalString)+1;
      n:=Size(m)+Size(m[1])+Size(e)+Size(m)*Size(m[1]);
      ng:=Size(l1)/n-1;
      l2:=List([0..ng],i->l1{[n*i+1..n*(i+1)]});
      g:=Group(List(l2,PermList));
   fi;

   return RestrictedGroup(g,[1..Size(m)+Size(m[1])+Size(e)]);
end );


#############################################################################
#
#  BlockDesignFilter( <dl>[, <opt>] )  
#
#  Eliminates isomorphic copies from a list of block designs <A>dl</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  This is an alternative for the <C>BlockDesignIsomorphismClassRepresentatives</C> 
#  function from the <Package>Design</Package> package <Ref Chap="Design" BookName="DESIGN"/>. 
#  The optional argument <A>opt</A> is a record for options. Possible components 
#  of <A>opt</A> are:
#  <List>
#  <Item><A>Traces</A>:=<C>true</C>/<C>false</C>  Use <C>Traces</C>. 
#  This is the default.</Item>
#  <Item><A>SparseNauty</A>:=<C>true</C>/<C>false</C>  Use <C>nauty</C>
#  for sparse graphs.</Item>
#  <Item><A>PointClasses</A>:=<A>s</A>   Color the points into classes 
#  of size <A>s</A> that cannot be mapped onto each other (for isotopy). 
#  By default, all points are in the same class.</Item>
#  <Item><A>ParatopyClasses</A>:=<A>s</A>   Make point classes of size 
#  <A>s</A> that can be exchanged (for paratopy).</Item>
#  <Item><A>Positions</A>:=<C>true</C>/<C>false</C> Return positions 
#  of nonisomorphic designs instead of the designs themselves.</Item>
#  </List>
#
InstallGlobalFunction( BlockDesignFilter, function( dl, opt... )
local input,output,command,str,l,clo,cmd,pos;

  if dl=[] then return dl;
  else
    clo:=[];
    cmd:=3;
    pos:=false;
    if Size(opt)>=1 then
      if IsBound(opt[1].Traces) then
         if opt[1].Traces then
           cmd:=3;
         fi;
      fi;
      if IsBound(opt[1].SparseNauty) then
         if opt[1].SparseNauty then
           cmd:=1;
         fi;
      fi;
      if IsBound(opt[1].PointClasses) then
         Add(clo,Concatenation("-p",String(opt[1].PointClasses)));
      fi;
      if IsBound(opt[1].ParatopyClasses) then
         Add(clo,Concatenation("-t",String(opt[1].ParatopyClasses)));
      fi;
      if IsBound(opt[1].Positions) then
         if opt[1].Positions then
           pos:=true;
         fi;
      fi;
    fi;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"bdfilter.in"), false );
    PrintTo(output, NrBlockDesignPoints(dl[1]), " ", NrBlockDesignBlocks(dl[1]),"\n");
    PrintTo(output, List(dl,BlockDesignBlocks));
    CloseStream(output);

    if cmd=1 then
       command:=Filename(DirectoriesPackagePrograms("PAG"), "bdfiltersp");
    else
       command:=Filename(DirectoriesPackagePrograms("PAG"), "bdfiltertr");
    fi;
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"bdfilter.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"bdfilter.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, clo); 
    CloseStream(output);
    CloseStream(input);

    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"bdfilter.out") );

    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      l:=[]; 
    else
      NormalizeWhitespace(str);
      l:=List(SplitString(str," "),EvalString);
   fi;

   if pos then return l;
   else return dl{l};
   fi;
 fi;
end );


#############################################################################
#
#  HadamardMatFilter( <hl>[, <opt>] )  
#
#  Eliminates equivalent copies from a list of Hadamard matrices <A>hl</A>. 
#  Represents the matrices by colored graphs (see <Cite Key='BM79'/>) and
#  uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible components 
#  of <A>opt</A> are:
#  <List>
#  <Item><A>Dual</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
#  dual equivalence is allowed (i.e. the matrices can be transposed). The 
#  default is <C>false</C>.</Item>
#  <Item><A>Positions</A>:=<C>true</C>/<C>false</C> Return positions 
#  of inequivalent Hadamard matrices instead of the matrices themselves.</Item>
#  </List>
#
InstallGlobalFunction( HadamardMatFilter, function( hl, opt... )
local input,output,command,str,l,clo,pos;

  if hl=[] then return hl;
  else
    clo:=[];
    pos:=false;
    if Size(opt)>=1 then
      if IsBound(opt[1].Dual) then
         if opt[1].Dual then
           Add(clo,"-d");
         fi;
      fi;
      if IsBound(opt[1].Positions) then
         if opt[1].Positions then
           pos:=true;
         fi;
      fi;
    fi;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"hadfilter.in"), false );
    PrintTo(output, Size(hl[1]), "\n");
    PrintTo(output, hl);
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "hadfilter");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"hadfilter.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"hadfilter.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, clo); 
    CloseStream(output);
    CloseStream(input);

    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"hadfilter.out") );
    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      l:=[]; 
    else
      NormalizeWhitespace(str);
      l:=List(SplitString(str," "),EvalString);
   fi;

   if pos then return l;
   else return hl{l};
   fi;
 fi;
end );


#############################################################################
#
#  MatFilter( <ml>[, <opt>] )  
#
#  Eliminates equivalent copies from a list of matrices <A>ml</A>. 
#  It is assumed that all of the matrices have the same set of consecutive 
#  integers as entries. Two matrices are equivalent if one can be transformed 
#  into the other by permutating rows, columns and symbols. Represents the 
#  matrices by colored graphs and uses <C>nauty/Traces 2.8</C> by B.D.McKay 
#  and A.Piperno <Cite Key='MP14'/>. The optional argument <A>opt</A> is a 
#  record for options. Possible components of <A>opt</A> are:
#  <List>
#  <Item><A>Positions</A>:=<C>true</C>/<C>false</C> Return positions 
#  of inequivalent matrices instead of the matrices themselves.</Item>
#  </List>
#
InstallGlobalFunction( MatFilter, function( ml, opt... )
local input,output,command,str,l,pos,e;

  if ml=[] then return ml;
  else
    pos:=false;
    if Size(opt)>=1 then
      if IsBound(opt[1].Positions) then
         if opt[1].Positions then
           pos:=true;
         fi;
      fi;
    fi;

    e:=Union(ml[1]);
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"matfilter.in"), false );
    PrintTo(output, Size(ml[1]), " ", Size(ml[1][1]), " ", Size(e), "\n");
    PrintTo(output, ml-Minimum(e));
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "matfilter");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"matfilter.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"matfilter.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []); 
    CloseStream(output);
    CloseStream(input);

    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"matfilter.out") );
    str:=ReadAll(input);
    CloseStream(input);
    if str=fail then
      l:=[]; 
    else
      NormalizeWhitespace(str);
      l:=List(SplitString(str," "),EvalString);
   fi;

   if pos then return l;
   else return ml{l};
   fi;
 fi;
end );


#############################################################################
#
#  Paley1Mat( <q> )  
#    
#  Returns a Paley type I Hadamard matrix of order <M><A>q</A>+1</M> constructed 
#  from the squares in <M>GF(<A>q</A>)</M>. The argument should be a prime power 
#  <M><A>q</A>\equiv 3 \pmod{4}</M>.
#
InstallGlobalFunction( Paley1Mat, function( q )
local pg1,qr,mat,chi;

    pg1:=Union([infinity],Elements(GF(q)));
    qr:=AsSet(List(Elements(GF(q)),x->x^2));
    chi:=function(x)
       if x in qr then return 1;
       else return -1; fi;
    end;
    mat:=function(x,y)
       if x=infinity and y=infinity then return -1;
       else if x=infinity or y=infinity or x=y then return 1;
       else return chi(y-x); fi; fi; 
    end;
    return List(pg1,x->List(pg1,y->mat(x,y)));
end );


#############################################################################
#
#  Paley2Mat( <q> )  
#    
#  Returns a Paley type II Hadamard matrix of order <M>2(<A>q</A>+1)</M> 
#  constructed from the squares in <M>GF(<A>q</A>)</M>. The argument should 
#  be a prime power <M><A>q</A>\equiv 1 \pmod{4}</M>.
#
InstallGlobalFunction( Paley2Mat, function( q )
local gf,qr,chi,mat,joinmat,S;

    gf:=Elements(GF(q));
    qr:=AsSet(List(gf,x->x^2));
    chi:=function(x)
       if x in qr then return 1;
       else return -1; fi;
    end;
    mat:=function(i,j)
       if i=j then return 0;
          else if i=1 or j=1 then return 1;
          else return chi(gf[i-1]-gf[j-1]);
       fi; fi;
    end;
    S:=List([1..q+1],i->List([1..q+1],j->mat(i,j)));
    joinmat:=function(a,b)
       return List([1..Size(a)],i->Concatenation(a[i],b[i]));
    end;
    return Concatenation(joinmat(S+IdentityMat(q+1),S-IdentityMat(q+1)),joinmat(S-IdentityMat(q+1),-S-IdentityMat(q+1)));
end );


#############################################################################
#
#  Paley3DMat( <v> )  
#    
#  Returns a three-dimensional Hadamard matrix of order <A>v</A> obtained by 
#  the Paley-like construction introduced in <Cite Key='KPT23b'/>. The argument 
#  should be an even number <A>v</A> such that <M><A>v</A>-1</M> is a prime 
#  power.
#
InstallGlobalFunction( Paley3DMat, function( v )
local pg1,qr,mat,chi;

    pg1:=Union([infinity],Elements(GF(v-1)));
    qr:=AsSet(List(Elements(GF(v-1)),x->x^2));
    chi:=function(x)
       if x in qr then return 1;
       else return -1; fi;
    end;
    mat:=function(x,y,z)
       if x=y and y=z then return -1;
       else if x=y or x=z or y=z then return 1;
       else if x=infinity then return chi(z-y);
       else if y=infinity then return chi(x-z);
       else if z=infinity then return chi(y-x);
       else return chi((x-y)*(y-z)*(z-x));
       fi; fi; fi; fi; fi;
    end;
    return List(pg1,x->List(pg1,y->List(pg1,z->mat(x,y,z))));
end );


#############################################################################
#
#  AllOnesMat( <v>[, <n>] )  
#    
#  Returns the <A>n</A>-dimensional matrix of order <A>v</A> with all
#  entries <M>1</M>. By default, <A>n</A><M>=2</M>.
#
InstallGlobalFunction( AllOnesMat, function( v, n... )
    if n=[] then n:=2;
    else n:=n[1]; 
    fi;
    if n=0 then return 1;
    else return List([1..v],i->AllOnesMat(v,n-1));
    fi;
end );


#############################################################################
#
#  HadamardToIncidence( <M> )  
#    
#  Transforms the Hadamard matrix <A>M</A> to an incidence matrix by
#  replacing all <M>-1</M> entries by <M>0</M>.
#
InstallGlobalFunction( HadamardToIncidence, function( m )
    return (m+1)/2;
end );


#############################################################################
#
#  IncidenceToHadamard( <M> )  
#    
#  Transforms the incidence matrix <A>M</A> to a <M>(1,-1)</M>-matrix 
#  by replacing all <M>0</M> entries by <M>-1</M>.
#
InstallGlobalFunction( IncidenceToHadamard, function( m )
    return 2*m-1;
end );


#############################################################################
#
#  ProductConstructionMat( <H>, <n> )  
#    
#  Given a <M>2</M>-dimensional Hadamard matrix <A>H</A>, returns the 
#  <A>n</A>-dimensional proper Hadamard matrix obtained by the product
#  construction of Yang <Cite Key='YXY86'/>.
#
InstallGlobalFunction( ProductConstructionMat, function( h, n )
local v,rek;
    v:=Size(h);

    rek:=function(i,l)
      if i=n then 
      return Product(List(Combinations([1..n],2),x->h[l[x[1]]][l[x[2]]]));
      else return List([1..v],x->rek(i+1,Concatenation(l,[x])));
      fi;
    end;

    return rek(0,[]);

end );


#############################################################################
#
#  DigitConstructionMat( <H>, <n> )  
#    
#  Given a <M>2</M>-dimensional Hadamard matrix <A>H</A> of order 
#  <M>(2t)^<A>s</A></M>, returns the <M>2<A>s</A></M>-dimensional 
#  Hadamard matrix of order <M>2t</M>  obtained by Theorem 6.1.4 
#  of <Cite Key='YNX10'/>.
#
InstallGlobalFunction( DigitConstructionMat, function( h, s )
local t,rek,toint;
  t:=RootInt(Size(h),s);
  if t^s<>Size(h) or (t mod 2)=1 then
    ErrorNoReturn("order of the given Hadamard matrix must be of the form (2t)^s.\n");
  else
    toint:=function(digits,base)
      local i,x;
      i:=0;
      for x in digits do
        i:=i*base+x;
      od;
      return i;
    end;
    rek:=function(ind,lev)
      local i;
      if lev=0 then return h[toint(ind{[1..s]},t)+1][toint(ind{[s+1..2*s]},t)+1];
      else
        return List([0..t-1],i->rek(Concatenation(ind,[i]),lev-1));
      fi;
    end;
    return rek([],2*s);
  fi;
end );


#############################################################################
#
#  CyclicDimensionIncrease( <H> )  
#    
#  Given an <M>n</M>-dimensional Hadamard matrix <A>H</A>, returns the 
#  <M>(n+1)</M>-dimensional Hadamard matrix obtained by Theorem 6.1.5
#  of <Cite Key='YNX10'/>. The construction also works for cyclic cubes 
#  of symmetric designs.
#
InstallGlobalFunction( CyclicDimensionIncrease, function( h )
local v;

    v:=Size(h);
    return List([1..v],i->List([1..v],j->h[1+((i+j-2) mod v)]));
end );


#############################################################################
#
#  LatinSquareDimensionIncrease( <H>, <ls> )  
#    
#  Given an <M>n</M>-dimensional Hadamard matrix <A>H</A> of order <M>v</M>, 
#  returns the <M>(n+1)</M>-dimensional Hadamard matrix of order <M>v</M>
#  obtained by a generalization of <Cite Key='YNX10'/>, Theorem 6.1.5. 
#  A Latin square <A>ls</A> of order <M>v</M> is used instead of addition
#  modulo <M>v</M>. The construction also works for cubes of symmetric 
#  designs of propriety <M>n</M>.
#
InstallGlobalFunction( LatinSquareDimensionIncrease, function( h, ls )
local v;

    v:=Size(h);
    return List([1..v],i->List([1..v],j->h[ls[i][j]]));
end );


#############################################################################
#
#  IsHadamardMat( <H> )  
#    
#  Returns <C>true</C> if <A>H</A> is an <M>n</M>-dimensional Hadamard
#  matrix, and <C>false</C> otherwise.
#
InstallGlobalFunction( IsHadamardMat, function( h )
local v,n,ok,i,a;

    v:=Size(h);
    n:=NestingDepthA(h);
    ok:=true;
    i:=1;
    while ok and i<=n do
      a:=List(CubeLayers(h,i),Flat);
      ok:=AsSet(List(Combinations(a,2),x->x[1]*x[2]))=[0];
      i:=i+1;
    od;
    return ok;
end );


#############################################################################
#
#  IsProperHadamardMat( <H> )  
#    
#  Returns <C>true</C> if <A>H</A> is a proper <M>n</M>-dimensional 
#  Hadamard matrix, and <C>false</C> otherwise.
#
InstallGlobalFunction( IsProperHadamardMat, function( h )
local sl,tst;

    tst:=IdentityMat(Size(h))*Size(h);
    sl:=CubeSlices(h);
    return AsSet(List(sl,x->x*TransposedMat(x)=tst))=[true];
end );


#############################################################################
#
#  KramerMesnerSearch( <t>, <v>, <k>, <lambda>, <G>[, <opt>] )
#
#  Performs a search for <A>t</A>-(<A>v</A>,<A>k</A>,<A>lambda</A>) designs
#  with presrcribed automorphism group <A>G</A> by the Kramer-Mesner method.
#  A record with options can be supplied. By default, designs are returned 
#  in the <Package>Design</Package> package format 
#  <Ref Chap="Design" BookName="DESIGN"/> and isomorph-rejection is performed
#  by calling <Ref Func="BlockDesignFilter" Style="Text"/>. This can be turned
#  off by setting <A>opt.NonIsomorphic</A>:=<C>false</C>. By setting 
#  <A>opt.BaseBlocks</A>:=<C>true</C>, base blocks are returned instead
#  of designs (this automatically turns off isomorph-rejection). Other available 
#  options are:
#  <List>
#  <Item><A>SmallLambda</A>:=<C>true</C>/<C>false</C>. Perform the <Q>small 
#  lambda filter</Q>, i.e. remove <A>k</A>-orbits covering some of the 
#  <A>t</A>-orbits more than  <A>lambda</A> times. By default, this is 
#  done if <A>lambda</A>&lt;=3.</Item>
#  <Item><A>IntersectionNumbers</A>:=<A>lin</A>/<C>false</C>. Search
#  for designs with block intersection nubers in the list of integers
#  <A>lin</A> (e.g. quasi-symmetric designs).</Item>
#  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
#  and use inequivalent orbits as the first choice, to reduce the number
#  of isomorphic designs and speed-up the computation.</Item>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C> Print information on 
#  the progress of the computation.</Item>
#  </List>
#  Other options, such as <A>Solver</A>, are passed to the function
#  <Ref Func="SolveKramerMesner" Style="Text"/>; see its documentation.
#
InstallGlobalFunction( KramerMesnerSearch, function(t,v,k,lambda,g,opt...)
local tsub,b,ksub,m,bb,d,output,smalllambda,lin,cm,opt2,norm,n,verb,
      part,i,nksub,eq,m2,sol;

    eq:=function(n,set,rhs)
      return Concatenation(List([1..n],x->IversonBracket(x in set)),[rhs]);
    end;

    lin:=[];
    opt2:=rec();
    norm:=false;
    verb:=false;
    if Size(opt)>0 then
      if IsBound(opt[1].IntersectionNumbers) then
        lin:=opt[1].IntersectionNumbers;
        Unbind(opt[1].MinGroupSize);
      fi; 
      if IsBound(opt[1].Normalizer) then
        norm:=opt[1].Normalizer;
        Unbind(opt[1].Normalizer);
      fi; 
      if IsBound(opt[1].Verbose) then
        verb:=opt[1].Verbose;
        Unbind(opt[1].Verbose);
      fi; 
      opt2:=opt[1];
    fi;
    if PAGGlobalOptions.Silent=false then
      Print("Computing t-subset orbit representatives...\n");
    fi;
    tsub:=SubsetOrbitRep(g,v,t);
    if PAGGlobalOptions.Silent=false then
      Print(Size(tsub),"\n");
    fi;
    if PAGGlobalOptions.Silent=false then
      Print("Computing k-subset orbit representatives...\n");
    fi;
    b:=TDesignB(t,v,k,lambda);
    if b<Size(g) then
      if lin=[] then
        ksub:=SubsetOrbitRep(g,v,k,rec(SizeLE:=b));
      else
        ksub:=SubsetOrbitRep(g,v,k,rec(SizeLE:=b,IntersectionNumbers:=lin));
      fi;
    else
      if lin=[] then
        ksub:=SubsetOrbitRep(g,v,k);
      else
        ksub:=SubsetOrbitRep(g,v,k,rec(IntersectionNumbers:=lin));
      fi;
    fi;
    if PAGGlobalOptions.Silent=false then
      Print(Size(ksub),"\n");
    fi;
    smalllambda:=0;
    if Size(opt)>0 then
      if IsBound(opt[1].SmallLambda) then
        smalllambda:=opt[1].SmallLambda;
      fi; 
    fi;
    if smalllambda=0 then
      smalllambda:=lambda<=3;
    fi;
    if smalllambda then
      if PAGGlobalOptions.Silent=false then
        Print("Removing k-subset orbits covering t-subset orbits more than lambda times...\n");
      fi;
      ksub:=SmallLambdaFilter(g,tsub,ksub,lambda);
      if PAGGlobalOptions.Silent=false then
        Print(Size(ksub),"\n");
      fi;
    fi;
    if Size(ksub)>0 then
      if PAGGlobalOptions.Silent=false then
        Print("Computing the Kramer-Mesner matrix...\n");
      fi;
      m:=KramerMesnerMat(g,tsub,ksub,lambda,b);
      if PAGGlobalOptions.Silent=false then
        Print(DimensionsMat(m),"\n");
      fi;
      if lin<>[] then
        if PAGGlobalOptions.Silent=false then
          Print("Computing the compatibility matrix...\n");
        fi;
        cm:=CompatibilityMat(g,ksub,lin);
        if PAGGlobalOptions.Silent=false then
          Print(DimensionsMat(cm),"\n");
        fi;
      fi;
      if lin=[] then
        if norm then
          n:=Normalizer(SymmetricGroup(v),g);
          if verb then
            Print("Normalizer: ",Size(n),"\nCalculating inequivalent orbits...\n");
          fi;
          part:=InequivalentSubsetOrbits(n,ksub,rec(Partition:=true));
          if verb then
            Print(Size(part),"\n");
          fi;
          nksub:=Size(ksub);
          Print("Iterating...\n");
          sol:=[];
          for i in [1..Size(part)] do
            Print("Partition block #",i,": fixing ",First(part[i]),"\n"); 
            m2:=Concatenation(m,[eq(nksub,[First(part[i])],1)]);
            if i>1 then
              m2:=Concatenation(m2,[eq(nksub,Union(part{[1..i-1]}),0)]);
            fi;
            sol:=Concatenation(sol,SolveKramerMesner(m2,opt2));
          od;
          bb:=BaseBlocks(ksub,sol);
        else
          if PAGGlobalOptions.Silent=false then
            Print("Starting solver...\n");
          fi;
          bb:=BaseBlocks(ksub,SolveKramerMesner(m,opt2));
        fi;
      else
        if PAGGlobalOptions.Silent=false then
          Print("Starting solver...\n");
        fi;
        bb:=BaseBlocks(ksub,SolveKramerMesner(m,cm,opt2));
      fi;
      output:=3;
      if Size(opt)>=1 then
        if IsBound(opt[1].BaseBlocks) then
          if opt[1].BaseBlocks then
            output:=1;
          fi;
        fi;
        if IsBound(opt[1].NonIsomorphic) then
          if not opt[1].NonIsomorphic then
            output:=2;
          fi;
        fi;
      fi;
      if output=1 then
        return bb;
      else
        d:=List(bb,x->BlockDesign(v,x,g));
        if output=3 then
          if PAGGlobalOptions.Silent=false then
            Print("Performing isomorph rejection...\n");
          fi;
          d:=BlockDesignFilter(d);
          if PAGGlobalOptions.Silent=false then
            Print(Size(d),"\n");
          fi;
        fi;
        return d;
     fi;
   else
     return [];
   fi;
end );


#############################################################################
#
#  SteinerSearchOld( <t>, <v>, <ksub>, <G>[, <opt>] )
#
#  Performs a search for Steiner <A>t</A>-designs with prescribed automorphism 
#  group <A>G</A> and blocks from the subset orbit representatives <A>ksub</A>.
#  They may be given in format returned by the <Ref Func="SubsetOrbitRepOM"/>
#  function. The point set is <C>[1..</C><A>v</A><C>]</C>. A record <A>opt</A> 
#  with options can be supplied and will be passed to the function 
#  <Ref Func="SolveSteiner"/>; see its documentation. This old version uses
#  the <C>libexact</C> solver, P. Kaski and  O. Pottonen's implementation 
#  of the Dancing Links algorithm <Cite Key='KP08'/>. It does not use DLX 
#  files to communicate with the solver.
#
InstallGlobalFunction( SteinerSearchOld, function(t,v,ksub,g,opt...)
local lin,tsub,filename,sol;

    if opt=[] then
      opt:=rec();
    else
      opt:=opt[1]; 
    fi;
    tsub:=SubsetOrbitRep(g,v,t);
    sol:=SolveSteiner(g,tsub,ksub,opt);
    if Size(ksub)=2 and NestingDepthA(ksub[1])=3 and NestingDepthA(ksub[2])=1 then
      ksub:=Concatenation(ksub[1]);
    fi;
    return BlockDesignFilter(List(sol,x->BlockDesign(v,ksub{x},g)));
end );


#############################################################################
#
#  SteinerSearch( <t>, <v>, <ksub>, <G>[, <opt>] )
#
#  Performs a search for Steiner <A>t</A>-designs with prescribed automorphism 
#  group <A>G</A> and blocks from the subset orbit representatives <A>ksub</A>.
#  The orbits may be given in format returned by the <Ref Func="SubsetOrbitRepOM"/>
#  function. The point set is <C>[1..</C><A>v</A><C>]</C>. A record <A>opt</A> 
#  with options can be supplied: 
#  <List>
#  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C> Print information on 
#  the progress of the computation. The default is <C>false</C>.</Item>
#  <Item><A>NonIsomorphic</A>:=<C>true</C>/<C>false</C> Reject isomorphic
#  designs by calling <Ref Func="BlockDesignFilter" Style="Text"/> at the
#  end. The default is <C>true</C>.</Item>
#  <Item><A>Time</A>:=<C>true</C>/<C>false</C> Print date and time before
#  and after calling the solver. Uses the shell command <C>date</C>.
#  The default is <C>false</C>.</Item>
#  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
#  and use inequivalent orbits as the first choice, to reduce the number
#  of isomorphic designs and speed-up the computation. This can also be 
#  achieved "manually" by setting the <A>UseOrbits</A> option. The default 
#  is <C>false</C>.</Item>
#  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Compute partition of 
#  orbits into equivalence classes under the normalizer and use the 
#  exact-cover-with-colors approach. The default is <C>true</C> if the 
#  <A>Normalizer</A> option is also set.</Item>
#  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Call the solver
#  separately for every inequivalent orbit under the normalizer,
#  instead of modifying the exact cover problem. The default is 
#  <C>false</C>.</Item>
#  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
#  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
#  is used.</Item>
#  </List>
#  The <A>TempDir</A> option and some other options are also forwarded 
#  to <Ref Func="MakeDLX2" Style="Text"/> (<A>UseOrbits</A>) and 
#  <Ref Func="SolveDLX" Style="Text"/> (<A>Solver</A>, <A>M</A>). See 
#  the documentation of these functions.
#
InstallGlobalFunction( SteinerSearch, function(t,v,ksub,g,opt...)
local tsub,filename,input,output,command,sol,des,opt1,opt2,verb,filt,norm,
      part,n,iter,PartitionToVector,pvec,rvec,i,M,om,ksub1,po,m,perm,time,
      omtest,rez,tempdir;

    PartitionToVector:=function(part)
      local vec,i,j;
      vec:=[1..Sum(List(part,Size))];
      for j in [1..Size(part)] do for i in part[j] do vec[i]:=j; od; od;
      return vec;
    end;

    omtest:=x->Size(x)=2 and NestingDepthA(x[1]) in [2,3] and NestingDepthA(x[2])=1;

    if opt=[] then
      opt:=rec();
    else
      opt:=opt[1];
    fi;
    verb:=false; 
    if IsBound(opt.Verbose) then
      verb:=opt.Verbose;
    fi;
    time:=false; 
    if IsBound(opt.Time) then
      time:=opt.Time;
    fi;
    filt:=true; 
    if IsBound(opt.NonIsomorphic) then
      filt:=opt.NonIsomorphic;
    fi;
    norm:=false; 
    if IsBound(opt.Normalizer) then
      norm:=opt.Normalizer;
    fi;
    part:=norm; 
    if IsBound(opt.Partition) then
      part:=opt.Partition;
    fi;
    iter:=false; 
    if IsBound(opt.Iterate) then
      iter:=opt.Iterate;
    fi;
    tempdir:=PAGGlobalOptions.TempDir;
    if IsBound(opt.TempDir) then
       tempdir:=Directory(opt.TempDir);
    fi;

    if (NestingDepthA(ksub)>=4 and AsSet(List(ksub,omtest))=[true]) or 
       (NestingDepthA(ksub)=3 and not omtest(ksub)) then
      rez:=[1..Size(ksub)];
      for i in [1..Size(ksub)] do
        if verb then
          Print("Problem #",i,"...\n");
        fi;
        rez[i]:=SteinerSearch(t,v,ksub[i],g,opt);
      od;
      return rez;
    else

    tsub:=SubsetOrbitRep(g,v,t);

    om:= omtest(ksub);
    if om then
      if [] in ksub[1] then
        if verb then
          Print("No orbits for some columns of the orbit matrix!\n");
        fi;
        return [];
      fi;
    fi;

    opt1:=rec();
    if IsBound(opt.TempDir) then
      opt1.TempDir:=opt.TempDir;
    fi;
    if IsBound(opt.UseOrbits) then
      opt1.UseOrbits:=opt.UseOrbits;
      if norm and verb then
        Print("Warning: UseOrbits is given, not performing normalizer calculation!\n");
      fi;
    else
      if norm then
        n:=Normalizer(SymmetricGroup(v),g);
        if om then
          po:=List(Orbits(g,[1..v]),AsSet);
          m:=Intersection(List(po,x->Stabilizer(n,x,OnSets)));
          if verb then
            Print("Normalizer: ",Size(m),"\nCalculating inequivalent orbits...\n");
          fi;
          perm:=Sortex(List(ksub[1],Size));
          ksub:=List(ksub,x->Reversed(Permuted(x,perm)));;
          opt1.UseOrbits:=InequivalentSubsetOrbits(m,ksub[1][1],rec(Partition:=part));
          if verb then
            Print(Size(opt1.UseOrbits),"\n");
          fi;
        else
          if verb then
            Print("Normalizer: ",Size(n),"\nCalculating inequivalent orbits...\n");
          fi;
          opt1.UseOrbits:=InequivalentSubsetOrbits(n,ksub,rec(Partition:=part));
          if verb then
            Print(Size(opt1.UseOrbits),"\n");
          fi;
        fi;
      fi;
    fi;

    if om then
      ksub1:=Concatenation(ksub[1]);
    else
      ksub1:=ksub;
    fi;

    opt2:=rec();
    if IsBound(opt.TempDir) then
      opt2.TempDir:=opt.TempDir;
    fi;
    if IsBound(opt.Solver) then
      opt2.Solver:=opt.Solver;
    fi;
    if IsBound(opt.M) then
      opt2.M:=opt.M;
    fi;
    
    if iter then
      if not IsBound(opt1.UseOrbits) then
        Print("Normalizer data is needed for iterating!\n");
        return fail;
      fi;
      if NestingDepthA(opt1.UseOrbits)<>2 then
        Print("A partition of orbits into blocks equivalent under the normalizer is needed for iterating!\n");
        return fail;
      fi;
      Print("Iterating...\n");
      filename:=Filename(tempdir,"steiner0.dlx");
      M:=Size(ksub)+MakeDLX2(filename,g,tsub,ksub);
      M:=Int(11*M/10)+1000;
      if M>130000000 and not IsBound(opt2.M) then
        opt2.M:=M;
        Print("Increasing memory: M=",M,"\n");
      fi;
      pvec:=PartitionToVector(opt1.UseOrbits);
      filename := Filename( tempdir, "steiner0.pvec" );
      output := OutputTextFile( filename, false );
      WriteLine( output, String( Size(pvec) ) );
      WriteLine( output, Concatenation(List(pvec,x->Concatenation(String(x)," "))) );
      CloseStream( output );

      des:=[];
      for i in [1..Size(opt1.UseOrbits)] do
        Print("Partition block #",i,": fixing ",First(opt1.UseOrbits[i]),"\n"); 
        input := InputTextFile( Filename( tempdir, "steiner0.dlx" ) );
        filename:=Filename( tempdir, "steiner1.dlx" );
        output := OutputTextFile(filename,false);
        command := Filename( DirectoriesPackagePrograms( "PAG" ), "cutdlx" );
        Process( tempdir, command, input, output, [ Concatenation("-p",Filename( tempdir, "steiner0.pvec" )), Concatenation("-f",String(i)) ] );
        CloseStream( input );
        CloseStream( output );
        if time then
          Print("Starting search...\n");
          Exec("date");
        fi;
        sol:=SolveDLX(filename,opt2);
        if time then
          Exec("date");
        fi;
        rvec:=Concatenation([1..Size(pvec)]{Positions(List(pvec,x->x>=i),true)},[Size(pvec)+1..Size(ksub1)]);
        sol:=List(sol,x->rvec{x});
        des:=Concatenation(des,List(sol,x->BlockDesign(v,ksub1{x},g)));
      od;

    else
      filename:=Filename(tempdir,"steiner.dlx");
      M:=Size(ksub)+MakeDLX2(filename,g,tsub,ksub,opt1);
      M:=Int(11*M/10)+1000;
      if M>130000000 and not IsBound(opt2.M) then
        opt2.M:=M;
        Print("Increasing memory: M=",M,"\n");
      fi;
      if time then
        Print("Starting search...\n");
        Exec("date");
      fi;
      sol:=SolveDLX(filename,opt2);
      if time then
        Exec("date");
      fi;
      if IsBound(opt1.UseOrbits) then
        if NestingDepthA(opt1.UseOrbits)=2 then
          opt1.UseOrbits:=List(opt1.UseOrbits,First);
        fi;
        sol:=RectifySolutions(Size(ksub1),opt1.UseOrbits,sol);
      fi;
      des:=List(sol,x->BlockDesign(v,ksub1{x},g));
    fi;

    if filt and Size(des)>1 then
      if verb then
        Print("Eliminating isomorphic designs...\n");
      fi;
      des:=BlockDesignFilter(des);
      if verb then
        Print(Size(des),"\n");
      fi;
    fi;

    return des;
    fi;
end );


#############################################################################
#
#  ExtendSteinerDesign( <d>[, <opt>] )
#
#  Performs a search for extensions of a Steiner design <A>d</A>.
#  By default, the extended designs are assumed to be invariant under
#  the full automorphism group of <A>d</A>. This can be changed by
#  setting options in the record <A>opt</A>. Possible components are:
#  <List>
#  <Item><A>Group</A>:= <C>g</C> (permutation group) or <C>n</C> (integer).
#  If a permutation group <C>g</C> is given, it will be used for the
#  search. If an integer <C>n</C> is given, the <C>n</C>-th subgroup
#  of the full automorphism group of <A>d</A> will be used. Here 
#  <C>n</C><M>=1</M> means the full automorhism group, <C>n</C><M>=2</M> 
#  means the second largest subgroup etc. The subgroups are taken in 
#  reverse order from the list returned by
#  <C>AllSubgroupsConjugation( BlockDesignAut( </C><A>d</A><C> ) )</C>.
#  Furthermore, <C>n</C><M>=0</M> means the trivial group.
#  </Item>
#  <Item><A>MinGroupSize</A>:=<C>n</C>  Extend using subgroups of 
#  size at least <C>n</C> of the automorphism group of <A>d</A>. 
#  Examine the subgroups in descending order until extensions are
#  found or all subgroups are exhausted.</Item>
#  <Item><A>MaxGroupSize</A>:=<C>n</C>  Extend using subgroups of 
#  size at most <C>n</C> of the automorphism group of <A>d</A>.
#  Examine the subgroups in descenting order until extensions are
#  found or all subgroups are exhausted.</Item>
#  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
#  and use inequivalent orbits as the first choice, to reduce the number
#  of isomorphic designs and speed-up the computation.</Item>
#  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Compute partition of 
#  orbits into equivalence classes under the normalizer and use the 
#  exact-cover-with-colors approach. The default is <C>true</C> if the 
#  <A>Normalizer</A> option is also set to <C>true</C>.</Item>
#  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Call the solver
#  separately for every inequivalent orbit under the normalizer,
#  instead of modifying the exact cover problem. The default is 
#  <C>false</C>.</Item>
#  <Item><A>Time</A>:=<C>true</C>/<C>false</C> Print date and time before
#  and after calling the solver. Uses the shell command <C>date</C>.
#  The default is <C>false</C>.</Item>
#  <Item><A>NonIsomorphic</A>:=<C>true</C>/<C>false</C> Reject isomorphic
#  designs by calling <Ref Func="BlockDesignFilter" Style="Text"/> at the
#  end. The default is <C>true</C>.</Item>
#  </List>
#  Other options such as <A>Verbose</A>, <A>Solver</A>, <A>M</A>,  
#  <A>Iterate</A>, and <A>TempDir</A> are passed to the functions
#  <Ref Func="MakeDLX2" Style="Text"/> and 
#  <Ref Func="SolveDLX" Style="Text"/>.
#
InstallGlobalFunction( ExtendSteinerDesign, function(d,opt...)
local t,v,k,a,ksub,grp,g,des,verb,filt,time,
      BlockRepresentatives,CompatibleSubsetOrbits,NotCovered,
      tsub1,ksub1,sol,der,nor,n,part,makepart,filename, 
      mings,i,e,maxgs,opt2,PartitionToVector,iter,M,tempdir,
      input,output,command,pvec,rvec,sol1;
 
  BlockRepresentatives:=function(g,d)
  local orb;
    orb:=Orbits(g,BlockDesignBlocks(d),OnSets);
    if Union(orb)<>BlockDesignBlocks(d) then
      Print("The design is not G-invariant!\n");
      return [];
    else
      return List(List(orb,First),x->Concatenation(x,[d.v+1]));
    fi;
  end;

  CompatibleSubsetOrbits:=function(t,v,ksub,d)
  local b,tst,nb;
    b:=List(BlockDesignBlocks(d),x->Concatenation(x,[v]));
    nb:=Size(b);
    tst:=function(ksub)
      local i,ok;
      ok:=true;
      i:=0;
      while ok and i<nb do
        i:=i+1;
        ok:=Size(Intersection(ksub,b[i]))<t;
      od;
      return ok;
    end;
    return Filtered(ksub,tst);
  end;

  NotCovered:=function(tsub,d)
  local b;
    b:=BlockDesignBlocks(d);
    return Filtered(tsub,y->not true in List(b,x->IsSubset(x,y)));
  end;

  PartitionToVector:=function(part)
  local vec,i,j;
    vec:=[1..Sum(List(part,Size))];
    for j in [1..Size(part)] do for i in part[j] do vec[i]:=j; od; od;
    return vec;
  end;

  tempdir:=PAGGlobalOptions.TempDir;

  if opt=[] then
    opt:=rec();
  else
    opt:=opt[1];
  fi;
  mings:=0; 
  if IsBound( opt.MinGroupSize ) then
    mings := opt.MinGroupSize;
    Unbind(opt.MinGroupSize);
  fi;
  maxgs:=0;
  if IsBound( opt.MaxGroupSize ) then
    maxgs := opt.MaxGroupSize;
    Unbind(opt.MaxGroupSize);
  fi;

  if mings>0 or maxgs>0 then
    a:=BlockDesignAut(d);
    g:=Reversed(AllSubgroupsConjugation(a));
    if mings>0 then
      g:=Filtered(g,x->Size(x)>=mings);
    fi;
    if maxgs>0 then
      g:=Filtered(g,x->Size(x)<=maxgs);
    fi;
    i:=1;
    e:=[];
    while e=[] and i<=Size(g) do
      opt.Group:=g[i];
      opt2:=ShallowCopy(opt);
      e:=ExtendSteinerDesign(d,opt2);
      i:=i+1;
    od;
    return e;
  else
  grp:=1; 
  if IsBound( opt.Group ) then
    grp := opt.Group;
    Unbind(opt.Group);
  fi;
  nor:=false;
  if IsBound( opt.Normalizer ) then
    nor := opt.Normalizer;
    Unbind(opt.Normalizer);
  fi;
  makepart:=nor;
  if IsBound( opt.Partition ) then
    makepart := opt.Partition;
    Unbind(opt.Partition);
  fi;
  iter:=false;
  if IsBound( opt.Iterate ) then
    iter := opt.Iterate;
    if not nor or not makepart then
      Print("Warning: setting Normalizer and Partition options to true for iterating!\n");
      nor:=true;
      makepart:=true;
    fi;
    Unbind(opt.Iterate);
  fi;
  time:=false; 
  if IsBound(opt.Time) then
    time:=opt.Time;
    Unbind(opt.Time);
  fi;
  filt:=true; 
  if IsBound(opt.NonIsomorphic) then
    filt:=opt.NonIsomorphic;
    Unbind(opt.NonIsomorphic);
  fi;
  verb:=false; 
  if IsBound(opt.Verbose) then
    verb:=opt.Verbose;
  fi;

  t:=Size(AllTDesignLambdas(d));
  if AllTDesignLambdas(d)[t]<> 1 then
    Print("Not a Steiner design: lambda=",AllTDesignLambdas(d)[t],"\n");
    return fail;
  fi;
  v:=d.v+1;
  k:=Size(d.blocks[1])+1;
  if IsGroup(grp) then
    g:=grp;
  else
    if grp=0 then
      g:=Group(());
    else
      a:=BlockDesignAut(d);
      if grp=1 then
        g:=a;
      else
        g:=Reversed(AllSubgroupsConjugation(a)); 
        g:=g[grp];
      fi;
    fi;
  fi;
  Print("Extending ",t-1,"-(",v-1,",",k-1,",1) design with group of order ",Size(g),"\n");
  if Size(g)=1 then
    if verb then
      Print("Making all subsets...\n");
    fi;
    ksub:=Combinations([1..v],k);
    if verb then
      Print(Size(ksub),"\n");
    fi;
  else
    ksub:=SubsetOrbitRepSteiner(g,t,v,k,rec(Verbose:=verb));
  fi;

  filename:=Filename(PAGGlobalOptions.TempDir,"derived.dlx");

  tsub1 := NotCovered(SubsetOrbitRep( g, v-1, t ), d );
  ksub1 := CompatibleSubsetOrbits( t, v, ksub, d );
  if verb then
    Print("Compatible orbits: ",Size(ksub1),"\n");
  fi;
  if Size(ksub1)>0 then
    der := BlockRepresentatives( g, d );
    if nor then
#      n:=Intersection(Normalizer(SymmetricGroup(v),g),BlockDesignAut(d));
      n:=Stabilizer(Normalizer(SymmetricGroup(v),g),d.blocks,OnSetsSets);
      if verb then
        Print("Normalizer index: ",Size(n)/Size(g),"\n");
      fi;
      if Size(n)>Size(g) then
        part:=InequivalentSubsetOrbits(n,ksub1,rec(Partition:=makepart));
        if verb then
          Print("Inequivalent orbits: ",Size(part),"\n");
        fi;
        if iter then
          Print("Iterating...\n");
          filename:=Filename(tempdir,"derived0.dlx");
          M:=Size(ksub1)+MakeDLX2(filename,g,tsub1,ksub1);
          M:=Int(11*M/10)+1000;
          if M>130000000 and not IsBound(opt.M) then
            opt.M:=M;
            Print("Increasing memory: M=",M,"\n");
          fi;
          pvec:=PartitionToVector(part);
          filename := Filename( tempdir, "derived0.pvec" );
          output := OutputTextFile( filename, false );
          WriteLine( output, String( Size(pvec) ) );
          WriteLine( output, Concatenation(List(pvec,x->Concatenation(String(x)," "))) );
          CloseStream( output );
          sol:=[];
          for i in [1..Size(part)] do
            Print("Partition block #",i,": fixing ",First(part[i]),"\n");
            input := InputTextFile( Filename( tempdir, "derived0.dlx" ) );
            filename:=Filename( tempdir, "derived1.dlx" );
            output := OutputTextFile(filename,false);
            command := Filename( DirectoriesPackagePrograms( "PAG" ), "cutdlx" );
            Process( tempdir, command, input, output, [ Concatenation("-p",Filename( tempdir, "derived0.pvec" )), Concatenation("-f",String(i)) ] );
            CloseStream( input );
            CloseStream( output );
            if time then
              Print("Starting search...\n");
              Exec("date");
            fi;
            sol1:=SolveDLX(filename,opt);
            if time then
              Exec("date");
            fi;
            rvec:=Concatenation([1..Size(pvec)]{Positions(List(pvec,x->x>=i),true)},[Size(pvec)+1..Size(ksub1)]);
            sol1:=List(sol1,x->rvec{x});
            sol:=Concatenation(sol,sol1);
          od;
        else
          opt.UseOrbits:=part;
          MakeDLX2(filename,g,tsub1,ksub1,opt);
          Unbind(opt.UseOrbits);
          if time then
            Print("Starting search...\n");
            Exec("date");
          fi;
          sol:=SolveDLX(filename,opt);
          if time then
            Exec("date");
          fi;
          if makepart then
            part:=List(part,First);
          fi;
          sol:=RectifySolutions(Size(ksub1),part,sol);
        fi;
      else
        MakeDLX2(filename,g,tsub1,ksub1,opt);
        if time then
          Print("Starting search...\n");
          Exec("date");
        fi;
        sol:=SolveDLX(filename,opt);
        if time then
          Exec("date");
        fi;
      fi;
    else
      MakeDLX2(filename,g,tsub1,ksub1,opt);
      if time then
        Print("Starting search...\n");
        Exec("date");
      fi;
      sol:=SolveDLX(filename,opt);
      if time then
        Exec("date");
      fi;
    fi;
    des:=List(sol,x->BlockDesign(v,Concatenation(der,ksub1{x}),g));   
    if filt then
      if verb and Size(des)>0 then
        Print("Eliminating isomorphic designs...\n");
      fi;
      des:=BlockDesignFilter(des);
      if verb and Size(des)>0 then
        Print(Size(des),"\n");
      fi;
    fi;
    return des;   
  else
    return [];
  fi;
  fi;
end );


#############################################################################
#
#  ExtendSteinerBlocks( <t>, <v>, <d>[, <opt>] )
#
#  Performs a search for Steiner <A>t</A>-designs containing a set of 
#  blocks <A>d</A>. The blocks should be given in <Package>Design</Package> 
#  package format. If the argument <A>v</A> is equal to <A>d</A><C>.v</C>,
#  the designs are assumed to be invariant under the full automorphism group 
#  of <A>d</A>. This can be changed by setting options in the record <A>opt</A>. 
#  If the argument <A>v</A> is greater than <A>d</A><C>.v</C>, a permutation
#  group should be given by the <A>Group</A> option. Possible components of 
#  <A>opt</A> are:
#  <List>
#  <Item><A>Group</A>:= <C>g</C> (permutation group) or <C>n</C> (integer).
#  If a permutation group <C>g</C> is given, it will be used for the
#  search. If an integer <C>n</C> is given, the <C>n</C>-th subgroup
#  of the full automorphism group of <A>d</A> will be used. Here 
#  <C>n</C><M>=1</M> means the full automorhism group, <C>n</C><M>=2</M> 
#  means the second largest subgroup etc. The subgroups are taken in 
#  reverse order from the list returned by
#  <C>AllSubgroupsConjugation( BlockDesignAut( </C><A>d</A><C> ) )</C>.
#  Furthermore, <C>n</C><M>=0</M> means the trivial group.
#  </Item>
#  <Item><A>BlockCandidates</A>:=<C>ksub</C>  Use list of 
#  <M>k</M>-subsets <C>ksub</C> as block candidates and return the
#  compatible ones. If this option is not given, all <M>k</M>-subsets 
#  of <C>[1..</C><A>v</A><C>]</C> (or the corresponding orbit 
#  representatives) are used and a search for extensions is
#  performed.</Item>
#  <Item><A>MinGroupSize</A>:=<C>n</C>  Extend using subgroups of 
#  size at least <C>n</C> of the automorphism group of <A>d</A>. 
#  Examine the subgroups in descending order until extensions are
#  found or all subgroups are exhausted.</Item>
#  <Item><A>MaxGroupSize</A>:=<C>n</C>  Extend using subgroups of 
#  size at most <C>n</C> of the automorphism group of <A>d</A>.
#  Examine the subgroups in descenting order until extensions are
#  found or all subgroups are exhausted.</Item>
#  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
#  and use inequivalent orbits as the first choice, to reduce the number
#  of isomorphic designs and speed-up the computation.</Item>
#  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Compute partition of 
#  orbits into equivalence classes under the normalizer and use the 
#  exact-cover-with-colors approach. The default is <C>true</C> if the 
#  <A>Normalizer</A> option is also set to <C>true</C>.</Item>
#  <Item><A>Time</A>:=<C>true</C>/<C>false</C> Print date and time before
#  and after calling the solver. Uses the shell command <C>date</C>.
#  The default is <C>false</C>.</Item>
#  <Item><A>NonIsomorphic</A>:=<C>true</C>/<C>false</C> Reject isomorphic
#  designs by calling <Ref Func="BlockDesignFilter" Style="Text"/> at the
#  end. The default is <C>true</C>.</Item>
#  </List>
#  Other options such as <A>Verbose</A>, <A>Solver</A>, <A>M</A>,  
#  <A>Iterate</A>, and <A>TempDir</A> are passed to the functions
#  <Ref Func="MakeDLX2" Style="Text"/> and 
#  <Ref Func="SolveDLX" Style="Text"/>.
#
InstallGlobalFunction( ExtendSteinerBlocks, function(t,v,d,opt...)
local k,a,ksub,grp,g,des,verb,filt,time,
      BlockRepresentatives,CompatibleSubsetOrbits,NotCovered,
      tsub1,ksub1,sol,der,nor,n,part,makepart,filename, 
      mings,maxgs,i,e;
 
  BlockRepresentatives:=function(g,d)
  local orb;
    orb:=Orbits(g,BlockDesignBlocks(d),OnSets);
    if Union(orb)<>BlockDesignBlocks(d) then
      Print("The design is not G-invariant!\n");
      return [];
    else
      return List(orb,First);
    fi;
  end;

  CompatibleSubsetOrbits:=function(t,v,ksub,d)
  local b,tst,nb;
    b:=BlockDesignBlocks(d);
    nb:=Size(b);
    tst:=function(ksub)
      local i,ok;
      ok:=true;
      i:=0;
      while ok and i<nb do
        i:=i+1;
        ok:=Size(Intersection(ksub,b[i]))<t;
      od;
      return ok;
    end;
    return Filtered(ksub,tst);
  end;

  NotCovered:=function(tsub,d)
  local b;
    b:=BlockDesignBlocks(d);
    return Filtered(tsub,y->not true in List(b,x->IsSubset(x,y)));
  end;

  if opt=[] then
    opt:=rec();
  else
    opt:=opt[1];
  fi;
  mings:=0; 
  if IsBound( opt.MinGroupSize ) then
    mings := opt.MinGroupSize;
    Unbind(opt.MinGroupSize);
  fi;
  maxgs:=0; 
  if IsBound( opt.MaxGroupSize ) then
    maxgs := opt.MaxGroupSize;
    Unbind(opt.MaxGroupSize);
  fi;
 
  if mings>0 or maxgs>0 then
    a:=BlockDesignAut(d);
    g:=Reversed(AllSubgroupsConjugation(a));
    if mings>0 then
      g:=Filtered(g,x->Size(x)>=mings);
    fi;
    if maxgs>0 then
      g:=Filtered(g,x->Size(x)<=maxgs);
    fi;
    i:=1;
    e:=[];
    while e=[] and i<=Size(g) do
      opt.Group:=g[i];
      e:=ExtendSteinerBlocks(t,v,d,opt);
      i:=i+1;
    od;
    return e;
  else
  grp:=1; 
  if IsBound( opt.Group ) then
    grp := opt.Group;
    Unbind(opt.Group);
  fi;
  nor:=false;
  if IsBound( opt.Normalizer ) then
    nor := opt.Normalizer;
    Unbind(opt.Normalizer);
  fi;
  makepart:=nor;
  if IsBound( opt.Partition ) then
    makepart := opt.Partition;
    Unbind(opt.Partition);
  fi;
  time:=false; 
  if IsBound(opt.Time) then
    time:=opt.Time;
    Unbind(opt.Time);
  fi;
  filt:=true; 
  if IsBound(opt.NonIsomorphic) then
    filt:=opt.NonIsomorphic;
    Unbind(opt.NonIsomorphic);
  fi;
  verb:=false; 
  if IsBound(opt.Verbose) then
    verb:=opt.Verbose;
  fi;
  ksub:=[];
  if IsBound(opt.BlockCandidates) then
    ksub:=opt.BlockCandidates;
  fi; 

  k:=Size(d.blocks[1]);
  if IsGroup(grp) then
    g:=grp;
  else
    if grp=0 then
      g:=Group(());
    else
      a:=BlockDesignAut(d);
      if grp=1 then
        g:=a;
      else
        g:=Reversed(AllSubgroupsConjugation(a)); 
        g:=g[grp];
      fi;
    fi;
  fi;
  Print("Extending ",Size(d.blocks)," blocks to a ",t,"-(",v,",",k,",1) design with group of order ",Size(g),"\n");
  if ksub=[] then
    if Size(g)=1 then
      if verb then
        Print("Making all subsets...\n");
      fi;
      ksub:=Combinations([1..v],k);
      if verb then
        Print(Size(ksub),"\n");
      fi;
    else
      ksub:=SubsetOrbitRepSteiner(g,t,v,k,rec(Verbose:=verb));
    fi;
  else
    if verb then
      Print("Block candidates: ",Size(ksub),"\n");
    fi;
  fi;

  filename:=Filename(PAGGlobalOptions.TempDir,"extendblocks.dlx");

  tsub1 := NotCovered(SubsetOrbitRep( g, v, t ), d );
  ksub1 := CompatibleSubsetOrbits( t, v, ksub, d );
  if verb then
    Print("Compatible orbits: ",Size(ksub1),"\n");
  fi;
  if IsBound(opt.BlockCandidates) then
    return ksub1;
  fi;
  if Size(ksub1)>0 then
    der := BlockRepresentatives( g, d );
    if nor then
      n:=Stabilizer(Normalizer(SymmetricGroup(v),g),d.blocks,OnSetsSets);
      if verb then
        Print("Normalizer index: ",Size(n)/Size(g),"\n");
      fi;
      if Size(n)>Size(g) then
        part:=InequivalentSubsetOrbits(n,ksub1,rec(Partition:=makepart));
        if verb then
          Print("Inequivalent orbits: ",Size(part),"\n");
        fi;
        opt.UseOrbits:=part;
        MakeDLX2(filename,g,tsub1,ksub1,opt);
        Unbind(opt.UseOrbits);
        if time then
          Print("Starting search...\n");
          Exec("date");
        fi;
        sol:=SolveDLX(filename,opt);
        if time then
          Exec("date");
        fi;
        if makepart then
          part:=List(part,First);
        fi;
        sol:=RectifySolutions(Size(ksub1),part,sol);
      else
        MakeDLX2(filename,g,tsub1,ksub1,opt);
        if time then
          Print("Starting search...\n");
          Exec("date");
        fi;
        sol:=SolveDLX(filename,opt);
        if time then
          Exec("date");
        fi;
      fi;
    else
      MakeDLX2(filename,g,tsub1,ksub1,opt);
      if time then
        Print("Starting search...\n");
        Exec("date");
      fi;
      sol:=SolveDLX(filename,opt);
      if time then
        Exec("date");
      fi;
    fi;
    des:=List(sol,x->BlockDesign(v,Concatenation(der,ksub1{x}),g));   
    if filt then
      if verb and Size(des)>0 then
        Print("Eliminating isomorphic designs...\n");
      fi;
      des:=BlockDesignFilter(des);
      if verb and Size(des)>0 then
        Print(Size(des),"\n");
      fi;
    fi;
    return des;   
  else
    return [];
  fi;
  fi;
end );


#############################################################################
#
#  ReadMOLS( <filename> )  
#
#  Read a list of MOLS sets from a file. The file starts with the number
#  of rows <M>m</M>, columns <M>n</M>, and size of the sets <M>s</M>,
#  followed by the matrix entries. Integers in the file are separated 
#  by whitespaces.
#
InstallGlobalFunction( ReadMOLS, function( filename )
local input,output,command;

    command:=Filename(DirectoriesPackagePrograms("PAG"), "togapmat");
    input:=InputTextFile( filename );
    if input=fail then
      Print("Cannot open file.\n");
      return ;
    else
      output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"readmat.g"), false);
      Process(PAGGlobalOptions.TempDir, command, input, output, []); 
      CloseStream(output);
      CloseStream(input);
      return ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"readmat.g") )();
    fi;
end );


#############################################################################
#
#  WriteMOLS( <filename>, <list> )  
#
#  Write a list of MOLS sets to a file. The number of rows <M>m</M>,
#  columns <M>n</M>, and size of the sets <M>s</M> is written first, 
#  followed by the matrix entries. Integers are separated by whitespaces.
#
InstallGlobalFunction( WriteMOLS, function( filename, list )
local output, mat, row, entry, str, s, set;

    if NestingDepthA(list)=2 then
      WriteMOLS(filename,[[list]]);
    else 
      if NestingDepthA(list)=3 then
        WriteMOLS(filename,List(list,x->[x]));
      else
        s:=Size(list[1]);
        mat:=DimensionsMat(list[1][1]);
        output:=OutputTextFile( filename, false); 
        str:=Concatenation(String(mat[1])," ",String(mat[2])," ",String(s),"\n");
        WriteLine(output,str);
        for set in list do
          for mat in set do
            for row in mat do
              str:="";
              for entry in row do
                str:=Concatenation(str,String(entry)," ");
              od;
              WriteLine(output,str);  
            od;
            WriteLine(output,"");
          od;
          WriteLine(output,"");
        od;
        CloseStream(output);
      fi;
    fi;
    return ;
end );


#############################################################################
#
#  MOLSToOrthogonalArray( <ls> ) 
#
#  Transforms the set of MOLS <A>ls</A> to an equivalent orthogonal array.
#
InstallGlobalFunction( MOLSToOrthogonalArray, function( ls )
local n;

  n:=Size(ls[1]);
  return Concatenation(List([1..n],i->List([1..n],j->Concatenation([i,j],List(ls,x->x[i][j])))));
end );


#############################################################################
#
#  OrthogonalArrayToMOLS( <oa> ) 
#
#  Transforms the orthogonal array <A>oa</A> to an equivalent set of MOLS.
#
InstallGlobalFunction( OrthogonalArrayToMOLS, function( oa )
local n,s,ls,tup,i;

  s:=Size(oa[1])-2;
  n:=Maximum(Union(oa));
  ls:=List([1..s],k->List([1..n],i->List([1..n],j->0)));
  for tup in oa do
    for i in [1..s] do
      ls[i][tup[1]][tup[2]]:=tup[i+2];
    od; 
  od;
  return ls;
end );


#############################################################################
#
#  MOLSToTransversalDesign( <ls> ) 
#
#  Transforms the set of MOLS <A>ls</A> to an equivalent transversal design.
#
InstallGlobalFunction( MOLSToTransversalDesign, function( ls )
local n,s,a;

  n:=Size(ls[1]);
  s:=Size(ls)+2;
  a:=List([0..s-1],i->n*i);
  return BlockDesign(n*s,List(MOLSToOrthogonalArray(ls),x->x+a));
end );


#############################################################################
#
#  TransversalDesignToMOLS( <td> ) 
#
#  Transforms the transversal design <A>td</A> to an equivalent set of MOLS.
#
InstallGlobalFunction( TransversalDesignToMOLS, function( td )
local b,n,s,a;

  b:=td.blocks;
  s:=Size(b[1]);
  n:=(td.v)/s;
  a:=List([0..s-1],i->n*i);
  return OrthogonalArrayToMOLS(List(b,x->x-a));
end );


#############################################################################
#
#  MOLSAut( <ls>[, <opt>] ) 
#
#  Compute the full auto(para)topy group of a set of MOLS <A>ls</A>. The
#  optional argument <A>opt</A> is a record for options. Possible components 
#  are:
#  <List>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Compute the full autotopy
#  group of <A>ls</A>. This is the default.</Item>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Compute the full
#  autoparatopy group of <A>ls</A>.</Item>
#  </List>
#
InstallGlobalFunction( MOLSAut, function( ls, opt... )
local opt2,n;

  if NestingDepthA(ls)=2 then
    ls:=[ls];
  fi;
  n:=Size(ls[1]);
  if Size(opt)>=1 then
    opt2:=StructuralCopy(opt[1]); 
    if IsBound(opt[1].Paratopy) then
         if not opt[1].Paratopy then
           opt2.PointClasses:=n;
         fi;
    else
      opt2.PointClasses:=n;
      if IsBound(opt[1].Isotopy) then
         if not opt[1].Isotopy then
           Unbind(opt2.PointClasses);
         fi;
      fi;
    fi;
  else
    opt2:=rec(PointClasses:=n);
  fi;

  return BlockDesignAut(MOLSToTransversalDesign(ls),opt2);
end );


#############################################################################
#
#  MOLSFilter( <ls>[, <opt>] )  
#
#  Eliminates isotopic/paratopic copies from a list of MOLS sets <A>ls</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible 
#  components are:
#  <List>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic MOLS sets. 
#  This is the default.</Item>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic MOLS sets.</Item>
#  </List>
#  Any other components will be forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
#  function; see its documentation.
#
InstallGlobalFunction( MOLSFilter, function( ls, opt... )
local opt2,n,pos;

  if ls=[] then return [];
  else
    if NestingDepthA(ls)=3 then
      ls:=List(ls,x->[x]);
    fi;
    n:=Size(ls[1][1]);
    pos:=false;
    if Size(opt)>=1 then
      opt2:=StructuralCopy(opt[1]); 
      if IsBound(opt[1].Paratopy) then
         if not opt[1].Paratopy then
           opt2.PointClasses:=n;
         fi;
      fi;
      if IsBound(opt[1].Isotopy) then
        if opt[1].Isotopy then 
          opt2.PointClasses:=n;
        fi;
      fi;
      if IsBound(opt[1].Positions) then
        pos:=opt[1].Positions; 
      fi;
    else
      opt2:=rec();
    fi;
    opt2.Positions:=true;

    if pos then
      return BlockDesignFilter(List(ls,MOLSToTransversalDesign),opt2);
    else
      return ls{BlockDesignFilter(List(ls,MOLSToTransversalDesign),opt2)};
    fi;
  fi;
end );


#############################################################################
#
#  FieldToMOLS( <F> ) 
#
#  Construct a complete set of MOLS from the finite field <A>F</A>.
#
InstallGlobalFunction( FieldToMOLS, function( f )
local e;
    e:=Elements(f);
    return List(e{[2..Size(e)]},a->List(e,i->List(e,j->Position(e,a*i+j))));
end );


#############################################################################
#
#  IsAutotopyGroup( <n>, <s>, <G> ) 
#
#  Check if <A>G</A> is an autotopy group for transversal designs with
#  <A>s</A><M>+2</M> point classes of order <A>n</A>.
#
InstallGlobalFunction( IsAutotopyGroup, function( n, s, g )
local pcl,o;

    pcl:=List([0..s+1],i->[1..n]+n*i);
    o:=Orbits(g);
    return AsSet(List(o,y->Sum(List(pcl,x->IversonBracket(IsSubset(x,y))))))=[1];
end );


#############################################################################
#
#  MOLSSubsetOrbitRep( <n>, <s>, <G> ) 
#
#  Computes representatives of pairs and transversals of the <A>s</A><M>+2</M>
#  point classes for the construction of MOLS of order <A>n</A> with prescribed autotopy
#  group <A>G</A>. A list containing pair representatives in the first component and 
#  transversal representatives in the second component is returned.
#
InstallGlobalFunction( MOLSSubsetOrbitRep, function( n, s, g )
local gen,rep,pairs,o1;

    o1:=List(Orbits(g,[1..(s+1)*n]),Minimum);
    pairs:=Filtered(Concatenation(List(o1,i->Cartesian([i],[(Int((i-1)/n)+1)*n+1..(s+2)*n]))),x->IsMinimalImage(g,x,OnSets));
    if not PAGGlobalOptions.Silent then
      Print("Pairs: ",Size(pairs),"\n");
    fi;

    gen:=function(n,s,g,U,i)
      local e,U1,o;
      if i=s+2 then
        Add(rep,U);
      else
        for e in [i*n+1..(i+1)*n] do
          U1:=Concatenation(U,[e]);
          if IsMinimalImage(g,U1,OnSets) then
            o:=Orbit(g,U1,OnSets);
            if not false in List(pairs,x->Size(Filtered(o,y->IsSubset(y,x)))<=1) then
              gen(n,s,g,U1,i+1);
            fi;
          fi;
        od;
      fi;
      return ;
    end;

    rep:=[];
    gen(n,s,g,[],0);
    if not PAGGlobalOptions.Silent then
      Print("Transversals: ",Size(rep),"\n");
    fi;
    return [pairs,rep];
end );


#############################################################################
#
#  KramerMesnerMOLS( <n>, <s>, <G>[, <opt>] ) 
#
#  If <Ref Func="IsAutotopyGroup"/>(<A>G</A>) returns <C>true</C>,
#  call <Ref Func="KramerMesnerMOLSAutotopy"/>; otherwise call
#  <Ref Func="KramerMesnerMOLSAutoparatopy"/>.
#
InstallGlobalFunction( KramerMesnerMOLS, function( n, s, g, opt... )

    if IsAutotopyGroup(n,s,g) then
      if opt=[] then
        return KramerMesnerMOLSAutotopy(n,s,g);
      else
        return KramerMesnerMOLSAutotopy(n,s,g,opt[1]);
      fi;
    else
      if opt=[] then
        return KramerMesnerMOLSAutoparatopy(n,s,g);
      else
        return KramerMesnerMOLSAutoparatopy(n,s,g,opt[1]);
      fi;
    fi;
end );


#############################################################################
#
#  KramerMesnerMOLSAutotopy( <n>, <s>, <G>[, <opt>] ) 
#
#  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
#  autotopy group <A>G</A>. By default, A.Wassermann's LLL solver 
#  <C>solvediophant</C> is used for <A>s</A><M>=1</M>, and the backtracking
#  solver <C>solvecm</C> is used for <A>s</A><M>&gt;1</M>. This can be changed
#  by setting options in the record <A>opt</A>. Available options are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>.</Item>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> Use <C>solvecm</C>.</Item>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic solutions. 
#  This is the default.</Item>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic solutions.
#  All solutions are returned if either option is set to <C>false</C>.</Item>
#  </List>
#
InstallGlobalFunction( KramerMesnerMOLSAutotopy, function( n, s, g, opt... )
local rep,m,row,bb,inc,rez,output;
   
    output:=1; 
    if opt=[] then
      if s=1 then
        opt:=[rec(Solver:="solvediophant")];
      else
        opt:=[rec(Solver:="solvecm")];
      fi;
    fi;
    if IsBound(opt[1].Paratopy) then
      if opt[1].Paratopy then
        output:=1;
      else
        output:=3;
      fi;
    fi; 
    if IsBound(opt[1].Isotopy) then
      if opt[1].Isotopy then
        output:=2;
      else
        output:=3;
      fi;
    fi; 
    if PAGGlobalOptions.Silent=false then
      Print("Computing orbit representatives...\n");
    fi;
    rep:=MOLSSubsetOrbitRep(n,s,g);
    if rep[2]<>[] then
      if PAGGlobalOptions.Silent=false then
        Print("Computing the Kramer-Mesner matrix...\n");
      fi;
      m:=KramerMesnerMat(g,rep[1],rep[2],1);
      if PAGGlobalOptions.Silent=false then
        Print(DimensionsMat(m),"\n");
      fi;
      if PAGGlobalOptions.Silent=false then
        Print("Starting solver...\n");
      fi;
      if IsBound(opt[1].Solver) then
        if opt[1].Solver="solvecm" then
          row:=List(rep[2],x->Size(Orbit(g,x,OnSets)));
          row:=Concatenation(row,[n*n]);
          m:=Concatenation(m,[row]);
        fi;
      fi;
      bb:=BaseBlocks(rep[2],AsSet(SolveKramerMesner(m,opt[1])));
      if bb<>[] then
        inc:=List(bb,y->Concatenation(List(y,x->Orbit(g,x,OnSets))));
        rez:=List(inc,x->TransversalDesignToMOLS(BlockDesign(n*(s+2),x)));
        if output=1 then
          if PAGGlobalOptions.Silent=false then
            Print("Performing paratopy rejection...\n");
          fi;
          rez:=MOLSFilter(rez,rec(Paratopy:=true));
          if PAGGlobalOptions.Silent=false then
            Print(Size(rez),"\n");
          fi;
        fi;
        if output=2 then
          if PAGGlobalOptions.Silent=false then
            Print("Performing isotopy rejection...\n");
          fi;
          rez:=MOLSFilter(rez,rec(Isotopy:=true));
          if PAGGlobalOptions.Silent=false then
            Print(Size(rez),"\n");
          fi;
        fi;
        return rez;
      else
        return [];
      fi;
    else
      return [];
    fi;
end );


#############################################################################
#
#  KramerMesnerMOLSAutoparatopy( <n>, <s>, <G>[, <opt>] ) 
#
#  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
#  autoparatopy group <A>G</A>. By default, A.Wassermann's LLL solver 
#  <C>solvediophant</C> is used for <A>s</A><M>=1</M>, and the backtracking
#  solver <C>solvecm</C> is used for <A>s</A><M>&gt;1</M>. This can be changed
#  by setting options in the record <A>opt</A>. Available options are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>.</Item>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> Use <C>solvecm</C>.</Item>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic solutions. 
#  This is the default.</Item>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic solutions.
#  All solutions are returned if either option is set to <C>false</C>.</Item>
#  </List>
#
InstallGlobalFunction( KramerMesnerMOLSAutoparatopy, function( n, s, g, opt... )
local rep,m,row,bb,inc,rez,r,grp,output;

    output:=1; 
    if opt=[] then
      if s=1 then
        opt:=[rec(Solver:="solvediophant")];
      else
        opt:=[rec(Solver:="solvecm")];
      fi;
    fi;
    if IsBound(opt[1].Paratopy) then
      if opt[1].Paratopy then
        output:=1;
      else
        output:=3;
      fi;
    fi; 
    if IsBound(opt[1].Isotopy) then
      if opt[1].Isotopy then
        output:=2;
      else
        output:=3;
      fi;
    fi; 
    if PAGGlobalOptions.Silent=false then
      Print("Computing orbit representatives...\n");
    fi;
    grp:=List([0..s+1],i->[1..n]+n*i);
    rep:=[1,2];
    r:=SubsetOrbitRep(g,n*(s+2),2);
    rep[1]:=Filtered(r,y->AsSet(List(grp,x->Size(Intersection(x,y))))=[0,1]);
    if not PAGGlobalOptions.Silent then
      Print("Pairs: ",Size(rep[1]),"\n");
    fi;
    r:=SubsetOrbitRep(g,n*(s+2),s+2);
    rep[2]:=Filtered(r,y->AsSet(List(grp,x->Size(Intersection(x,y))))=[1]);
    if not PAGGlobalOptions.Silent then
      Print("Transversals: ",Size(rep[2]),"\n");
    fi;
    if rep[2]<>[] then
      if PAGGlobalOptions.Silent=false then
        Print("Computing the Kramer-Mesner matrix...\n");
      fi;
      m:=KramerMesnerMat(g,rep[1],rep[2],1);
      if PAGGlobalOptions.Silent=false then
        Print(DimensionsMat(m),"\n");
      fi;
      if PAGGlobalOptions.Silent=false then
        Print("Starting solver...\n");
      fi;
      if IsBound(opt[1].Solver) then
        if opt[1].Solver="solvecm" then
          row:=List(rep[2],x->Size(Orbit(g,x,OnSets)));
          row:=Concatenation(row,[n*n]);
          m:=Concatenation(m,[row]);
        fi;
      fi;
      bb:=BaseBlocks(rep[2],AsSet(SolveKramerMesner(m,opt[1])));
      if bb<>[] then
        inc:=List(bb,y->Concatenation(List(y,x->Orbit(g,x,OnSets))));
        rez:=List(inc,x->TransversalDesignToMOLS(BlockDesign(n*(s+2),x)));
        if output=1 then
          if PAGGlobalOptions.Silent=false then
            Print("Performing paratopy rejection...\n");
          fi;
          rez:=MOLSFilter(rez,rec(Paratopy:=true));
          if PAGGlobalOptions.Silent=false then
            Print(Size(rez),"\n");
          fi;
        fi;
        if output=2 then
          if PAGGlobalOptions.Silent=false then
            Print("Performing isotopy rejection...\n");
          fi;
          rez:=MOLSFilter(rez,rec(Isotopy:=true));
          if PAGGlobalOptions.Silent=false then
            Print(Size(rez),"\n");
          fi;
        fi;
        return rez;
      else
        return [];
      fi;
    else
      return [];
    fi;
end );


#############################################################################
#
#  RightDevelopment( <G>, <ds> ) 
#
#  Returns a block design that is the development of the difference 
#  set <A>ds</A> by right multiplication in the group <A>G</A>.
#  If <A>ds</A> is a tiling of the group <A>G</A> or a list of disjoint 
#  difference sets, a mosaic of symmetric designs is returned.
#
InstallGlobalFunction( RightDevelopment, function( g, ds )
local e,de,be;

    if NestingDepthA(ds)=1 then
      return BlockDesign(Size(g),[ds],PermRepresentationRight(g));
    else
      e:=Elements(g);
      de:=List(ds,x->e{x});
      be:=List(e,x->de*x);
      return BlocksToIncidenceMat(be);
    fi;

end );


#############################################################################
#
#  LeftDevelopment( <G>, <ds> ) 
#
#  Returns a block design that is the development of the difference 
#  set <A>ds</A> by left multiplication in the group <A>G</A>.
#  If <A>ds</A> is a tiling of the group <A>G</A> or a list of disjoint 
#  difference sets, a mosaic of symmetric designs is returned.
#
InstallGlobalFunction( LeftDevelopment, function( g, ds )
local e,de,be;

    if NestingDepthA(ds)=1 then
      return BlockDesign(Size(g),[ds],PermRepresentationLeft(g));
    else
      e:=Elements(g);
      de:=List(ds,x->e{x});
      be:=List(e,x->x*de);
      return BlocksToIncidenceMat(be);
    fi;

end );


#############################################################################
#
#  CameronSeidelSet( <m> ) 
#
#  Returns a list of <M>2^{m/2}</M> symplectic <M>m\times m</M> matrices 
#  over <M>GF(2)</M> such that the difference of any two of them is
#  a regular matrix. Here <A>m</A> is an even integer. The construction
#  is described on page 6 of the paper <Cite Key='CS73'/>.
#
InstallGlobalFunction( CameronSeidelSet, function( m )
local k,Tr,b,B1,B2;

    k:=m/2;
    Tr:=x->Sum([1..k],i->x^(2^i));
    b:=function(x,y) return x[1]*y[2]+x[2]*y[1]; end;
    B1:=List([0..k-1],i->Z(2^k)^i);
    B2:=Concatenation(Cartesian(B1,[0*Z(2)]),Cartesian([0*Z(2)],B1));
    return List(Elements(GF(2^k)),a->List(B2,x->List(B2,y->Tr(a*b(x,y)))));
end );


#############################################################################
#
#  OrthogonalNormalBasis( <k> ) 
#
#  Attempts to find a basis for the field <M>GF(2^k)</M> over <M>GF(2)</M>
#  that is orthogonal with respect to the trace inner product <M>Tr(xy)</M>.
#  This should work for odd integers <A>k</A>, but might fail for even
#  integers.
#
InstallGlobalFunction( OrthogonalNormalBasis, function( k )
local e,Tr,Gram,i,B;

    e:=Elements(GF(2^k));
    Tr:=x->Sum([1..k],i->x^(2^i));
    Gram:=v->List(v,x->List(v,y->IversonBracket(Tr(x*y)=Z(2)^0)));
    i:=0;
    repeat
      i:=i+1;
      B:=List([0..k-1],j->e[i]^(2^j));
    until Gram(B)=IdentityMat(k) or i=Size(e);
    if Gram(B)=IdentityMat(k) then
      return B;
    else
      return fail;
    fi;
end );


#############################################################################
#
#  KerdockSet( <m> ) 
#
#  Returns a Kerdock set of <M>2^{m-1}</M> symplectic <M>m\times m</M> matrices 
#  over <M>GF(2)</M> such that the difference of any two of them is a regular 
#  matrix. Here <A>m</A> is an even integer. The construction is based on
#  Example 2.4 in the paper <Cite Key='WK95'/>.
#
InstallGlobalFunction( KerdockSet, function( m )
local e,B1,B2,p,vec,Tr;

    e:=Elements(GF(2^(m-1)));
    B1:=OrthogonalNormalBasis(m-1);
    B2:=Concatenation(List(B1,x->[x,0*Z(2)]),[[0*Z(2),Z(2)^0]]);
    p:=Cartesian(List([1..m],x->[0,1]));
    vec:=List(p,x->x*B2);
    Tr:=x->Sum([1..m-1],i->x^(2^i));
    return Z(2)^0*List(e,a->List(B2,x->p[Position(vec,[a^2*x[1]+a*Tr(a*x[1])+a*x[2],Tr(a*x[1])])]));
end );


#############################################################################
#
#  SingerDifferenceSets( <q>, <n> ) 
#
#  Returns the classical Singer difference sets in the cyclic group
#  of order <M>v=(q^n-1)/(q-1)</M>, e.g. <C>Group(CyclicPerm(v))</C>.
#  The difference sets are subsets of <C>[1..v]</C> to make them compatible
#  with the <Package>DifSets</Package> package. For each <M>D</M> returned,
#  <M>D-1</M> is a difference set in the integers modulo <M>v</M> (a subset
#  of <C>[0..v-1]</C>).
#  
InstallGlobalFunction( SingerDifferenceSets, function( q, n )
local v,w,z,tr;

    v:=(q^n-1)/(q-1);
    w:=PrimitiveElement(GF(q^n));
    tr:=x->Sum([0..n-1],y->x^(q^y));
    z:=0*w;
    return Union(List([0..v-1],b->List(Filtered([1..v-1],x->Gcd(x,v)=1),r->Filtered([0..v-1],i->tr(w^(r*i+b))=z))))+1;
end );


#############################################################################
#
#  NormalizedSingerDifferenceSets( <q>, <n> ) 
#
#  Returns the classical Singer difference sets in the cyclic group
#  of order <M>v=(q^n-1)/(q-1)</M> that are normalized. If <M>D</M>
#  is a difference set, this means that the elements of 
#  <M>D-1</M> sum up to <M>0</M> modulo <M>v</M>.
#  
InstallGlobalFunction( NormalizedSingerDifferenceSets, function( q, n )
local v,w,z,tr;

    v:=(q^n-1)/(q-1);
    w:=PrimitiveElement(GF(q^n));
    tr:=x->Sum([0..n-1],y->x^(q^y));
    z:=0*w;
    return AsSet(List(Filtered([1..v-1],x->Gcd(x,v)=1),r->Filtered([0..v-1],i->tr(w^(r*i))=z)))+1;
end );


#############################################################################
#
#  PaleyDifferenceSet( <q> ) 
#
#  Returns the <A>q</A>-dimensional Paley difference set in <M>GF(q)</M>.
#  This is a <M>(q,(q-1)/2,(q-3)/4)</M> difference set in the additive 
#  group of <M>GF(q)</M>. See <Cite Key='KR24'/> for more details.
#  
InstallGlobalFunction( PaleyDifferenceSet, function( q )
local r;

    r:=Concatenation([0*Z(q)],List([0..q-2],i->Z(q)^i));
    return List([0..(q-3)/2],i->r*Z(q)^(2*i));
end );


#############################################################################
#
#  PowerDifferenceSet( <q>, <m> ) 
#
#  Returns the <A>q</A>-dimensional difference set constructed from
#  the <A>m</A>-th powers in <M>GF(q)</M>. Paley difference sets are
#  power difference sets for <M>m=2</M>. See <Cite Key='KR24'/> for
#  more details.
#  
InstallGlobalFunction( PowerDifferenceSet, function( q, m )
local r;

    r:=Concatenation([0*Z(q)],List([0..q-2],i->Z(q)^i));
    return List([0..((q-1)/m-1)],i->r*Z(q)^(m*i));
end );


#############################################################################
#
#  TwinPrimePowerDifferenceSet( <q> ) 
#
#  Returns the <A>q</A>-dimensional twin prime power difference set. 
#  For <M>n=(q+1)^2/4</M>, this is a <M>(4n-1,2n-1,n-1)</M> difference 
#  set in the direct product <M>GF(q)\times GF(q+2)</M>. Both <A>q</A> 
#  and <A>q</A><M>+2</M> must be powers of primes. See <Cite Key='KR24'/> 
#  for more details.
#
InstallGlobalFunction( TwinPrimePowerDifferenceSet, function( q )
local ze,d1,d2,d3;

    ze:=[0*Z(q),0*Z(q+2)];
    d1:=Concatenation(List([0..(q-3)/2],i->List([0..(q-1)/2],j->Concatenation([ze],List([0..q-2],k->[Z(q)^(2*i+k),Z(q+2)^(2*j+k)])))));
    d2:=Concatenation(List([0..(q-3)/2],i->List([0..(q-1)/2],j->Concatenation([ze],List([1..q-1],k->[Z(q)^(2*i+k),Z(q+2)^(2*j+k)])))));
    d3:=Concatenation([List([1..q],x->ze)],List([0..q-2],i->Concatenation([ze],List([0..q-2],k->[Z(q)^(i+k),0*Z(q+2)]))));
    return Concatenation(d1,d2,d3);
end );


#############################################################################
#
#  EquivalentDifferenceSets( <g>, <D> ) 
#
#  Given a difference set or list of difference sets <A>D</A>
#  in a group <A>g</A>, returns the set of all difference sets 
#  equivalent to the ones in <A>D</A>. 
#  
InstallGlobalFunction( EquivalentDifferenceSets, function( g, ds )
local aut,e,dse,autorb;

    if NestingDepthA(ds)=1 then
      ds:=[ds];
    fi;
    e:=Elements(g);
    dse:=List(ds,x->e{x});
    aut:=Elements(AutomorphismGroup(g));
    autorb:=Union(List(dse,z->List(aut,y->AsSet(List(z,x->Position(e,Image(y,x)))))));
    return Union(List(autorb,x->LeftDevelopment(g,x).blocks));
end );


#############################################################################
#
#  IversonBracket( <P> ) 
#
#  Returns 1 if <A>P</A> is true, and 0 otherwise. 
#
InstallGlobalFunction( IversonBracket, function( P )

  if P then return 1;
  else return 0;
  fi;
end );


#############################################################################
#
#  SymmetricDifference( <X>, <Y> ) 
#
#  Returns the symmetric difference of two sets <A>X</A> and <A>Y</A>. 
#
InstallGlobalFunction( SymmetricDifference, function( x, y )

  return Difference(Union(x,y),Intersection(x,y));  
end );


#############################################################################
#
#  AddWeights( <wd> ) 
#
#  Makes a weight distribudion <A>wd</A> more readable by adding the weights
#  and skipping zero components. The argument <A>wd</A> is the weight 
#  distribution of a code returned by the <C>WeightDistribution</C> command
#  from the package <Package>GUAVA</Package>. 
#
InstallGlobalFunction( AddWeights, function( wd )

  return Filtered(List([1..Size(wd)],i->[i-1,wd[i]]),x->x[2]>0);
end );


#############################################################################
#
#  AdjacencyMat( <g> ) 
#
#  Returns the adjacency matrix of the graph <A>g</A> in 
#  <Package>GRAPE</Package> format. 
#
InstallGlobalFunction( AdjacencyMat, function( g )

  return List([1..g.order],i->List([1..g.order],j->IversonBracket(IsEdge(g,[i,j]))));
end );


#############################################################################
#
#  Cliquer( <g>[, <opt>] ) 
#
#  Searches for cliques in the graph <A>g</A>. Uses <C>Cliquer</C> by 
#  S.Niskanen and P.Ostergard <Cite Key='NO03'/>. The graph can either
#  be given in <Package>GRAPE</Package> format, or as a list <C>[v,elist]</C>
#  where <C>v</C> is the number of vertices and <C>elist</C> is a list of
#  edges (<M>2</M>-element subsets of <C>[1..v]</C>). The optional argument 
#  <A>opt</A> is a record for options. Possible components are:
#  <List>
#  <Item><A>Silent</A>:=<C>true</C>/<C>false</C> Work silently, or report
#  progress. The default is taken from <C>PAGGlobalOptions</C>.</Item>
#  <Item><A>FindAll</A>:=<C>true</C>/<C>false</C> Find all cliques, or
#  search for a single clique. The default is <C>true</C>.</Item>
#  <Item><A>CliqueSize</A>:=<C>n</C> or <C>[min,max]</C> Search for cliques
#  of size <C>n</C>, or size from <C>min</C> to <C>max</C>. By default, 
#  searches for cliques of maximum size.</Item>
#  <Item><A>Order</A>:=<C>n</C> Reorder vertices by ordering function
#  number <C>n</C>. Available functions are <C>n</C><M>=1</M> <C>ident</C>, 
#  <C>n</C><M>=2</M> <C>reverse</C>, <C>n</C><M>=3</M> <C>degree</C>, 
#  <C>n</C><M>=4</M> <C>random</C>, and <C>n</C><M>=5</M> <C>greedy</C> 
#  (default).</Item>
#  </List>
#
InstallGlobalFunction( Cliquer, function( g, opt... )
local v,e,input,output,x,command,silent,copt,cmin,cmax,vord,all;

  if IsGraph(g) then
    v:=OrderGraph(g);
    e:=UndirectedEdges(g);
  else
    v:=g[1];
    e:=AsSet(g[2]);
  fi;
  e:=e-1;
  output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"cliquer.in"), false );
  PrintTo(output, v,"\n");
  for x in e do
    PrintTo(output, x[1]," ",x[2],"\n");
  od;
  PrintTo(output, "-1\n");
  CloseStream(output);

  silent:=PAGGlobalOptions.Silent;
  cmin:=0;
  cmax:=0;
  vord:=0;
  all:=true;
  if Size(opt)>=1 then
    if IsBound(opt[1].Silent) then
         silent := opt[1].Silent;
    fi;
    if IsBound(opt[1].CliqueSize) then
      if IsInt(opt[1].CliqueSize) then
        opt[1].CliqueSize:=[opt[1].CliqueSize];
      fi; 
      cmin:=Minimum(opt[1].CliqueSize);
      cmax:=Maximum(opt[1].CliqueSize);
    fi;
    if IsBound(opt[1].Order) then
      vord:=opt[1].Order;
    fi;
    if IsBound(opt[1].FindAll) then
      all:=opt[1].FindAll;
    fi;
  fi;

  command:=Filename(DirectoriesPackagePrograms("PAG"), "pagcliquer");
  copt:=[Concatenation("-l",String(cmin)),Concatenation("-u",String(cmax))];
  if silent then copt:=Concatenation(copt,["-V"]); 
  else copt:=Concatenation(copt,["-v"]); fi;
  if vord>0 then copt:=Concatenation(copt,[Concatenation("-o",String(vord))]); fi;
  if not all then copt:=Concatenation(copt,["-A"]); fi;

  input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"cliquer.in") );
  Process(PAGGlobalOptions.TempDir, command, input, OutputTextUser(), copt );
  CloseStream(input);

  return ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"cliquer.out") )();
end );


#############################################################################
#
#  DisjointCliques( <L>[, <opt>] ) 
#
#  Given a list <A>L</A> of <M>k</M>-sets of integers, searches for
#  cliques of mutually disjoint <M>k</M>-sets from the list. The sets 
#  must be of equal size <M>k</M>! Uses <C>Cliquer</C> by S.Niskanen 
#  and P.Ostergard <Cite Key='NO03'/>. The optional argument <A>opt</A> 
#  is a record for options. Possible components are:
#  <List>
#  <Item><A>Silent</A>:=<C>true</C>/<C>false</C> Work silently, or report
#  progress. The default is taken from <C>PAGGlobalOptions</C>.</Item>
#  <Item><A>FindAll</A>:=<C>true</C>/<C>false</C> Find all cliques, or
#  search for a single clique. The default is <C>true</C>.</Item>
#  <Item><A>CliqueSize</A>:=<C>n</C> or <C>[min,max]</C> Search for cliques
#  of size <C>n</C>, or size from <C>min</C> to <C>max</C>. By default, 
#  searches for cliques of maximum size.</Item>
#  <Item><A>Order</A>:=<C>n</C> Reorder vertices by ordering function
#  number <C>n</C>. Available functions are <C>n</C><M>=1</M> <C>ident</C>, 
#  <C>n</C><M>=2</M> <C>reverse</C>, <C>n</C><M>=3</M> <C>degree</C>, 
#  <C>n</C><M>=4</M> <C>random</C>, and <C>n</C><M>=5</M> <C>greedy</C> 
#  (default).</Item>
#  </List>
#
InstallGlobalFunction( DisjointCliques, function( l, opt... )
local v,e,input,output,x,y,command,silent,copt,cmin,cmax,vord,all;

  output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"disjointcliques.in"), false );
  PrintTo(output, Size(l), " ", Size(l[1]), "\n");
  for x in l do
    for y in x do
      PrintTo(output, y, " ");
    od;
    PrintTo(output, "\n");
  od;
  CloseStream(output);

  silent:=PAGGlobalOptions.Silent;
  cmin:=0;
  cmax:=0;
  vord:=0;
  all:=true;
  if Size(opt)>=1 then
    if IsBound(opt[1].Silent) then
         silent := opt[1].Silent;
    fi;
    if IsBound(opt[1].CliqueSize) then
      if IsInt(opt[1].CliqueSize) then
        opt[1].CliqueSize:=[opt[1].CliqueSize];
      fi; 
      cmin:=Minimum(opt[1].CliqueSize);
      cmax:=Maximum(opt[1].CliqueSize);
    fi;
    if IsBound(opt[1].Order) then
      vord:=opt[1].Order;
    fi;
    if IsBound(opt[1].FindAll) then
      all:=opt[1].FindAll;
    fi;
  fi;

  command:=Filename(DirectoriesPackagePrograms("PAG"), "disjointcliques");
  copt:=[Concatenation("-l",String(cmin)),Concatenation("-u",String(cmax))];
  if silent then copt:=Concatenation(copt,["-V"]); 
  else copt:=Concatenation(copt,["-v"]); fi;
  if vord>0 then copt:=Concatenation(copt,[Concatenation("-o",String(vord))]); fi;
  if not all then copt:=Concatenation(copt,["-A"]); fi;

  input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"disjointcliques.in") );
  Process(PAGGlobalOptions.TempDir, command, input, OutputTextUser(), copt );
  CloseStream(input);

  return ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"disjointcliques.out") )();
end );


#############################################################################
#
#  DifferenceCube( <G>, <ds>, <d> ) 
#
#  Returns the <A>d</A>-dimenional difference cube constructed 
#  from a difference set <A>ds</A> in a group <A>G</A>. 
#
InstallGlobalFunction( DifferenceCube, function( g, ds, d )
local el,dc;

  if IsGroup(g) then
    el:=Elements(g);
  else
    el:=g;
  fi;
  ds:=el{ds};

  dc:=function(x,i)
    if i=1 then
      return IversonBracket(x in ds);
    else
      return List(el,y->dc(x*y,i-1));
    fi;
  end;

  return List(el,x->dc(x,d));

end );


#############################################################################
#
#  GroupCube( <G>, <dds>, <d> ) 
#
#  Returns the <A>d</A>-dimenional group cube constructed from
#  a symmetric design <A>dds</A> such that the blocks are
#  difference sets in the group <A>G</A>. 
#
InstallGlobalFunction( GroupCube, function( g, dds, d )

  return List(dds,x->DifferenceCube(g,x,d-1));

end );


#############################################################################
#
#  CubeSlice( <C>, <x>, <y>, <fixed> ) 
#
#  Returns a 2-dimensional slice of the cube <A>C</A> obtained by varying 
#  coordinates in positions <A>x</A> and <A>y</A>, and taking fixed values 
#  for the remaining coordinates given in a list <A>fixed</A>. 
#
InstallGlobalFunction( CubeSlice, function( c, x, y, fix )
local rek,x1,y1,v,d;

  v:=Size(c);
  d:=NestingDepthA(c);
  x1:=Minimum([x,y]);
  y1:=Maximum([x,y]);

  rek:=function(c,fix,i)
    if i>d then 
      if x=x1 then return c;
      else return TransposedMat(c);
      fi;
    else 
      if i<x1 then return rek(c[fix[1]],fix{[2..Size(fix)]},i+1);
      else 
        if i=x1 then return rek(c,fix,i+1);
        else 
          if i<y1 then return rek(c{[1..v]}[fix[1]],fix{[2..Size(fix)]},i+1);
          else 
            if i=y1 then return rek(c,fix,i+1);
            else return rek(c{[1..v]}{[1..v]}[fix[1]],fix{[2..Size(fix)]},i+1);
            fi;
          fi;
        fi;   
      fi;
    fi;
  end;

  return rek(c,fix,1);

end );


#############################################################################
#
#  CubeSlices( <C>[, <x>, <y>][, <fixed>] ) 
#
#  Returns 2-dimensional slices of a cube <A>C</A>. Optional arguments are 
#  the varying coordinates <A>x</A> and <A>y</A>, and values of the fixed 
#  coordinates in a list <A>fixed</A>. If optional arguments are not given, 
#  all possibilities will be supplied. For a <M>d</M>-dimensional cube <A>C</A>
#  of order <M>v</M>, the following calls will return:
#  <List>
#  <Item>CubeSlices( <A>C</A>, <A>x</A>, <A>y</A> ) <M>\ldots v^{d-2}</M> slices 
#  obtained by varying values of the fixed coordinates.</Item>
#  <Item>CubeSlices( <A>C</A>, <A>fixed</A> ) <M>\ldots {d\choose 2}</M> slices 
#  obtained by varying the non-fixed coordinates <M>x &lt; y</M>.</Item>
#  <Item>CubeSlices( <A>C</A> ) <M>\ldots {d\choose 2}\cdot v^{d-2}</M> slices 
#  obtained by varying both the non-fixed coordinates <M>x &lt; y</M> and values
#  of the fixed coordinates.</Item>
#
InstallGlobalFunction( CubeSlices, function( arg... )
local v,d;

  v:=Size(arg[1]);
  d:=NestingDepthA(arg[1]);
  if Size(arg)=1 then
    return List(Cartesian(Combinations([1..d],2),Cartesian(List([1..d-2],x->[1..v]))),y->CubeSlice(arg[1],y[1][1],y[1][2],y[2]));
  fi;
  if Size(arg)=2 then
    return List(Combinations([1..d],2),y->CubeSlice(arg[1],y[1],y[2],arg[2]));
  fi;
  if Size(arg)=3 then
    return List(Cartesian(List([1..d-2],x->[1..v])),y->CubeSlice(arg[1],arg[2],arg[3],y));
  fi;
  if Size(arg)=4 then
    return CubeSlice(arg[1],arg[2],arg[3],arg[4]);
  fi;

end );


#############################################################################
#
#  CubeLayer( <C>, <x>, <fixed> ) 
#
#  Returns an <M>(n-1)</M>-dimensional layer of the <M>n</M>-dimensional
#  cube <A>C</A> obtained by setting coordinate <A>x</A> to the value 
#  <A>fixed</A> and varying the remaining coordinates. 
#
InstallGlobalFunction( CubeLayer, function( c, x, fix )
local n,rek;

  rek:=function(c,x,fix,n)
    if x=n then return c[fix];
    else return List(c,l->rek(l,x,fix,n-1));
    fi;
  end;

  n:=NestingDepthA(c);
  return rek(c,n+1-x,fix,n);

end );


#############################################################################
#
#  CubeLayers( <C>, <x> ) 
#
#  Returns the <M>(n-1)</M>-dimensional layers of the <M>n</M>-dimensional
#  cube <A>C</A> obtained by fixing coordinate <A>x</A>.
#
InstallGlobalFunction( CubeLayers, function( c, x )

return List([1..Size(c)],fix->CubeLayer(c,x,fix));

end );


#############################################################################
#
#  CubeProjection( <C>, <p> ) 
#
#  Returns the projection of the <M>n</M>-dimensional cube <A>C</A> 
#  on a pair of coordinates <A>p</A>.
#
InstallGlobalFunction( CubeProjection, function( c, p )
local v;

  v:=Size(c);
  if NestingDepthA(c)=2 and p=[1,2] then return c;
  else return List([1..v],i->List([1..v],j->Sum(Flat(CubeLayer(CubeLayer(c,p[1],i),p[2]-1,j)))));
  fi;
end );


#############################################################################
#
#  CubeProjections( <C> ) 
#
#  Returns the projections of the <M>n</M>-dimensional cube <A>C</A> 
#  on all pairs of coordinates.
#
InstallGlobalFunction( CubeProjections, function( c )

  return List(Combinations([1..NestingDepthA(c)],2),p->CubeProjection(c,p));
end );


#############################################################################
#
#  OrthogonalArrayProjection( <C>, <t> ) 
#
#  Returns the projection of the orthogonal array <A>oa</A> 
#  on a tuple of coordinates <A>t</A>.
#
InstallGlobalFunction( OrthogonalArrayProjection, function( oa, t )

  return AsSortedList(List(oa,x->x{t}));
end );


#############################################################################
#
#  OrthogonalArrayProjections( <oa>[, <k> ] ) 
#
#  Returns the projections of the orthogonal array <A>oa</A> 
#  on all <A>k</A>-tuples of coordinates. If the second argument
#  is not given, <A>k</A><M>=2</M> is assumed.
#
InstallGlobalFunction( OrthogonalArrayProjections, function( oa, opt... )
local k;

  if Size(opt)>=1 then
    k:=opt[1];
  else
    k:=2;
  fi;
  return List(Combinations([1..Size(oa[1])],k),t->OrthogonalArrayProjection(oa,t));
end );


#############################################################################
#
#  CubeToOrthogonalArray( <C> ) 
#
#  Transforms the incidence cube <A>C</A> to an equivalent orthogonal array.
#
InstallGlobalFunction( CubeToOrthogonalArray, function( c )
local v,d,oa;

  v:=Size(c);
  d:=NestingDepthA(c);

  oa:=function(c,e,x)
    if e=1 then
      return List(Positions(c,1),y->Concatenation(x,[y]));
    else 
      return Concatenation(List([1..v],i->oa(c[i],e-1,Concatenation(x,[i]))));
    fi;
  end;

  return Concatenation(List([1..v],i->oa(c[i],d-1,[i])));

end );


#############################################################################
#
#  OrthogonalArrayToCube( <oa> ) 
#
#  Transforms the orthogonal array <A>oa</A> to an equivalent incidence cube.
#
InstallGlobalFunction( OrthogonalArrayToCube, function( oa )
local v,d,cr;

  d:=Size(oa[1]);
  v:=Maximum(Union(oa));

  cr:=function(i,x)
    if i=0 then
      return IversonBracket(x in oa);
    else
      return List([1..v],y->cr(i-1,Concatenation(x,[y])));
    fi;
  end;

  return cr(d,[]);

end );


#############################################################################
#
#  CubeToTransversalDesign( <C> ) 
#
#  Transforms the incidence cube <A>C</A> to an equivalent transversal design.
#
InstallGlobalFunction( CubeToTransversalDesign, function( c )
local v,d,a;

  v:=Size(c);
  d:=NestingDepthA(c);
  a:=List([0..d-1],i->v*i);
  return BlockDesign(v*d,List(CubeToOrthogonalArray(c),x->x+a));
end );


#############################################################################
#
#  OrthogonalArrayToTransversalDesign( <oa> ) 
#
#  Transforms the orthogonal array <A>oa</A> to an equivalent transversal design.
#
InstallGlobalFunction( OrthogonalArrayToTransversalDesign, function( oa )
local v,d,a;

  v:=Size(Union(oa));
  d:=Size(oa[1]);
  a:=List([0..d-1],i->v*i);
  return BlockDesign(v*d,List(oa,x->x+a));
end );


#############################################################################
#
#  TransversalDesignToCube( <TD> ) 
#
#  Transforms the transversal design <A>TD</A> to an equivalent incidence cube.
#
InstallGlobalFunction( TransversalDesignToCube, function( td )
local b,v,d,cr;

  b:=td.blocks;
  d:=Size(b[1]);
  v:=(td.v)/d;

  cr:=function(i,x)
    if i=0 then
      return IversonBracket(x in b);
    else
      return List([(d-i)*v+1..(d-i+1)*v],y->cr(i-1,Concatenation(x,[y])));
    fi;
  end;

  return cr(d,[]);

end );


#############################################################################
#
#  LatinSquareToCube( <TD> ) 
#
#  Transforms the Latin square <A>L</A> to an equivalent incidence cube.
#
InstallGlobalFunction( LatinSquareToCube, function( l )
local n;

  n:=Size(l);
  return List([1..n],i->List([1..n],j->List([1..n],k->IversonBracket(l[i][j]=k)))); 
end );


#############################################################################
#
#  DifferenceSetToOrthogonalArray( [<G>,] <ds> ) 
#
#  Transforms a (higher-dimensional) difference set to an orthogonal array. 
#  The argument <A>G</A> is a group and <A>ds</A> is a difference set in 
#  the <Package>DifSets</Package> package format, with positive integers
#  as elements. If the first argument is not given, <A>ds</A> contains 
#  finite field elements and the operation is addition. This is used 
#  for Paley difference sets and twin prime power difference sets.  
#
InstallGlobalFunction( DifferenceSetToOrthogonalArray, function( arg... )
local e,ds,q;

  if Size(arg)=2 then
    e:=Elements(arg[1]);
    if NestingDepthA(arg[2])=1 then
      ds:=TransposedMat([List([1..Size(arg[2])],x->e[1]),e{arg[2]}]);
    else
      ds:=List(arg[2],x->e{x});
    fi;
    return Concatenation(List(ds,y->List(e,x->List(y*x,z->Position(e,z)))));
  else
    if NestingDepthA(arg[1])=1 then
      e:=Elements(DefaultField(arg[1]));
      ds:=TransposedMat([List([1..Size(arg[1])],x->Zero(e[1])),arg[1]]);
    else 
      ds:=arg[1];
      if NestingDepthA(ds)=2 then
        e:=Elements(DefaultField(Union(ds)));
      else
        q:=Size(DefaultField(List(Union(ds),x->x[1])));
        e:=Cartesian(Elements(GF(q)),Elements(GF(q+2)));
      fi;
    fi;
    return Concatenation(List(ds,y->List(e,x->List(y+x,z->Position(e,z)))));
  fi;
end );


#############################################################################
#
#  Development3( <G>, <ds> ) 
#
#  Transforms a difference set of propriety <M>3</M> to an orthogonal 
#  array. The argument <A>G</A> is a group and <A>ds</A> is a 
#  difference set.
#
InstallGlobalFunction( Development3, function( g, ds )
local e,dse;

  e:=Elements(g);
  dse:=List(ds,x->Concatenation(e{x},e{[1]}));
  return List(Union(List(e,x->dse*x)),x->List(x,y->Position(e,y)));
end );


#############################################################################
#
#  CubeTest( <C> ) 
#
#  Test whether an incidence cube <A>C</A> is a cube of symmetric designs.
#  The result should be <C>[[v,k,lambda]]</C>. Anything else means that
#  <A>C</A> is not a <M>(v,k,lambda)</M> cube.
#
InstallGlobalFunction( CubeTest, function( c )
local v;

  if Union(List(CubeSlices(c),x->List(x,AsSet)))<>[[0,1]] then
    return false;
  else
    v:=Size(c);
    return AsSet(List(CubeSlices(c),x->AllTDesignLambdas(BlockDesign(v,List(x,y->Positions(y,1))))));
  fi;
end );


#############################################################################
#
#  Cube3Test( <C> ) 
#
#  Test whether an incidence cube <A>C</A> is a three-dimensional 
#  symmetric design of propriety <M>3</M>. The result should be 
#  <C>[v,[k],[lambda]]</C>. Anything else means that <A>C</A> is 
#  not a <M>\mathcal{C}^3_3(v,k,\lambda)</M>-cube.
#
InstallGlobalFunction( Cube3Test, function( c )
local ktest,ltest;

   ktest:=y->AsSet(List(CubeSlices(y),x->Sum(Flat(x))));
   ltest:=y->Union(List([1,2,3],i->List(Combinations(List(CubeLayers(y,i),Flat),2),x->x[1]*x[2])));
   return [Size(c),ktest(c),ltest(c)];
end );


#############################################################################
#
#  CubeProjectionTest( <C> ) 
#
#  Test whether an incidence cube <A>C</A> is a projection cube of symmetric 
#  designs. The result should be <C>[[v,k,lambda]]</C>. Anything else means that
#  <A>C</A> is not a <M>(v,k,lambda)</M> projection cube.
#
InstallGlobalFunction( CubeProjectionTest, function( c )
local pr;

  pr:=CubeProjections(c);
  if Union(List(pr,x->List(x,AsSet)))<>[[0,1]] then
    return false;
  else
    return AsSet(List(pr,x->AllTDesignLambdas(BlockDesign(Size(x),Difference(IncidenceMatToBlocks(x),[[]])))));
  fi;
end );


#############################################################################
#
#  OrthogonalArrayProjectionTest( <oa> ) 
#
#  Test whether an orthogonal array <A>oa</A> corresponds to a projection 
#  cube of symmetric <M>(v,k,\lambda)</M> designs. The result should be 
#  <C>[[v,k,lambda]]</C>. Anything else means that  <A>oa</A> does not 
#  correspond to a projection cube.
#
InstallGlobalFunction( OrthogonalArrayProjectionTest, function( oa )
local n,v,k,l,testmat,p,ok,oap,m;

  n:=Size(oa[1]);
  v:=Size(Union(oa));
  k:=Size(oa)/v;
  l:=k*(k-1)/(v-1);
  if IsInt(k) and IsInt(l) then
    testmat:=l*AllOnesMat(v)+(k-l)*IdentityMat(v);
    ok:=true;
    for p in Combinations([1..n],2) do
      if ok then
        oap:=List(oa,x->x{p});
        m:=BlocksToIncidenceMat(List([1..v],r->List(Filtered(oap,x->x[2]=r),x->x[1])));
        ok:=m*TransposedMat(m)=testmat;
      fi;
    od;
    if ok then 
      return [[v,k,l]];
    else 
      return false;
    fi;
  else
    return false;
  fi;
end );


#############################################################################
#
#  SliceInvariant( <C> ) 
#
#  Computes a paratopy invariant of the cube <A>C</A>
#  based on automorphism group sizes of its slices. Cubes 
#  equivalent under paratopy have the same invariant.
#
InstallGlobalFunction( SliceInvariant, function( c )
local v,n,toaut,insert,paral;

  v:=Size(c);
  n:=NestingDepthA(c);
  toaut:=m->Size(BlockDesignAut(BlockDesign(v,List(m,x->Positions(x,1)))));
    if n=2 then
    return [toaut(c)];
  fi;
  if n=3 then
    return Collected(List(Combinations([1..n],2),x->Collected(List(CubeSlices(c,x[1],x[2]),y->toaut(y)))));
  fi;
  if n>3 then
    insert:=function(l,el)
      return List([0..Size(l)],pos->Concatenation(l{[1..pos]},[el],l{[pos+1..Size(l)]}));
    end;
    paral:=List(Cartesian(List([1..n-3],x->[1..v])),y->List(y,z->[z]));
    paral:=Concatenation(List(paral,x->insert(x,[1..3])));
    paral:=List(paral,Cartesian);
    return Collected(List(Combinations([1..n],2),p->Collected(List(paral,y->Collected(List(y,x->toaut(CubeSlice(c,p[1],p[2],x))))))));
  fi;
end );


#############################################################################
#
#  CubeAut( <C>[, <opt>] )  
#
#  Computes the full auto(para)topy group of an incidence cube <A>C</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible 
#  components are:
#  <List>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Compute the full autotopy
#  group of <A>C</A>. This is the default.</Item>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Compute the full
#  autoparatopy group of <A>C</A>.</Item>
#  </List>
#  Any other components will be forwarded to the <Ref Func="BlockDesignAut" Style="Text"/>
#  function; see its documentation.
#
InstallGlobalFunction( CubeAut, function( c, opt... )
local opt2,v;

  v:=Size(c);
  if Size(opt)>=1 then
    opt2:=StructuralCopy(opt[1]); 
    if IsBound(opt[1].Paratopy) then
         if not opt[1].Paratopy then
           opt2.PointClasses:=v;
         else
           opt2.ParatopyClasses:=v;
         fi;
    else
      if IsBound(opt[1].Isotopy) then
         if not opt[1].Isotopy then
           opt2.ParatopyClasses:=v;
         else
           opt2.PointClasses:=v;
         fi;
      fi;
    fi;
  else
    opt2:=rec(PointClasses:=v);
  fi;

  return BlockDesignAut(CubeToTransversalDesign(c),opt2);
end );


#############################################################################
#
#  OrthogonalArrayAut( <oa>[, <opt>] )  
#
#  Computes the full auto(para)topy group of an orthogonal array <A>oa</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible 
#  components are:
#  <List>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Compute the full autotopy
#  group of <A>oa</A>. This is the default.</Item>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Compute the full
#  autoparatopy group of <A>oa</A>.</Item>
#  </List>
#  Any other components are forwarded to the <Ref Func="BlockDesignAut" Style="Text"/>
#  function; see its documentation.
#
InstallGlobalFunction( OrthogonalArrayAut, function( oa, opt... )
local opt2,v;

  v:=Size(Union(oa));
  if Size(opt)>=1 then
    opt2:=StructuralCopy(opt[1]);
    if IsBound(opt[1].Paratopy) then
         if not opt[1].Paratopy then
           opt2.PointClasses:=v;
         else
           opt2.ParatopyClasses:=v;
         fi;
    else
      if IsBound(opt[1].Isotopy) then
         if not opt[1].Isotopy then
           opt2.ParatopyClasses:=v;
         else
           opt2.PointClasses:=v;
         fi;
      fi;
    fi;
  else
    opt2:=rec(PointClasses:=v);
  fi;

  return BlockDesignAut(OrthogonalArrayToTransversalDesign(oa),opt2);
end );


#############################################################################
#
#  CubeFilter( <cl>[, <opt>] )  
#
#  Eliminates equivalent copies from a list of incidence cubes <A>cl</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible 
#  components are:
#  <List>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic cubes. 
#  This is the default.</Item>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic cubes.</Item>
#  </List>
#  Any other components will be forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
#  function; see its documentation.
#
InstallGlobalFunction( CubeFilter, function( cl, opt... )
local opt2,v,pos;

  if cl=[] then return [];
  else
    v:=Size(cl[1]);
    pos:=false;
    if Size(opt)>=1 then
      opt2:=StructuralCopy(opt[1]); 
      if IsBound(opt[1].Paratopy) then
         if not opt[1].Paratopy then
           opt2.PointClasses:=v;
         fi;
      fi;
      if IsBound(opt[1].Isotopy) then
        if opt[1].Isotopy then 
          opt2.PointClasses:=v;
        fi;
      fi;
      if IsBound(opt[1].Positions) then
        pos:=opt[1].Positions; 
      fi;
    else
      opt2:=rec();
    fi;
    opt2.Positions:=true;
    if not IsBound(opt2.PointClasses) then
       opt2.ParatopyClasses:=v;
    fi;

    if pos then
      return BlockDesignFilter(List(cl,CubeToTransversalDesign),opt2);
    else
      return cl{BlockDesignFilter(List(cl,CubeToTransversalDesign),opt2)};
    fi;
  fi;
end );


#############################################################################
#
#  OrthogonalArrayFilter( <oal>[, <opt>] )  
#
#  Eliminates equivalent copies from a list of orthogonal arrays <A>oal</A>. 
#  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
#  The optional argument <A>opt</A> is a record for options. Possible 
#  components are:
#  <List>
#  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic orthogonal 
#  arrays. This is the default.</Item>
#  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic orthogonal
#  arrays.</Item>
#  </List>
#  Any other components are forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
#  function; see its documentation.
#
InstallGlobalFunction( OrthogonalArrayFilter, function( oal, opt... )
local opt2,v,pos;

  if oal=[] then return [];
  else
    v:=Size(Union(oal[1]));
    pos:=false;
    if Size(opt)>=1 then
      opt2:=StructuralCopy(opt[1]);
      if IsBound(opt[1].Paratopy) then
         if not opt[1].Paratopy then
           opt2.PointClasses:=v;
         fi;
      fi;
      if IsBound(opt[1].Isotopy) then
        if opt[1].Isotopy then
          opt2.PointClasses:=v;
        fi;
      fi;
      if IsBound(opt[1].Positions) then
        pos:=opt[1].Positions;
      fi;
    else
      opt2:=rec();
    fi;
    opt2.Positions:=true;
    if not IsBound(opt2.PointClasses) then
       opt2.ParatopyClasses:=v;
    fi;

    if pos then
      return BlockDesignFilter(List(oal,OrthogonalArrayToTransversalDesign),opt2);
    else
      return oal{BlockDesignFilter(List(oal,OrthogonalArrayToTransversalDesign),opt2)};
    fi;
  fi;
end );


#############################################################################
#
#  SDPSeriesGroup( <m> ) 
#
#  Returns a group for the designs of <Ref Func="SDPSeriesDesign"/>.
#  This is the elementary Abelian group of order <M>4^m</M>. 
#
InstallGlobalFunction( SDPSeriesGroup, function( m )

  if m=1 then
    return Group((1,2),(3,4));
  else
    return DirectProduct(SDPSeriesGroup(m-1),SDPSeriesGroup(1));
  fi;
end );


#############################################################################
#
#  SDPSeriesHadamardMat( <m>, <i> ) 
#
#  Returns a Hadamard matrix of order <M>4^m</M> for the SDP series 
#  of designs. The argument <A>i</A> must be 1, 2, or 3. See documentation
#  for the <Ref Func="SDPSeriesDesign"/> function.
#
InstallGlobalFunction( SDPSeriesHadamardMat, function( m, i )

  if m=1 then
    return [ [ -1, 1, 1, 1 ], [ 1, -1, 1, 1 ], [ 1, 1, -1, 1 ], [ 1, 1, 1, -1 ] ];
  fi;
  if m=2 then
    if i=1 then return 
[ [ -1, 1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1 ], 
  [ 1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1 ], 
  [ 1, 1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1 ], 
  [ 1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1 ], 
  [ -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1 ], 
  [ -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1 ], 
  [ -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1 ], 
  [ -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1 ], 
  [ -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1 ], 
  [ -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, 1, 1 ], 
  [ -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, 1, 1 ], 
  [ -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1 ], 
  [ -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1 ] ];
    fi;
    if i=2 then return 
[ [ -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1 ], 
  [ 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1 ], 
  [ 1, 1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1 ], 
  [ 1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1 ], 
  [ -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1 ], 
  [ -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1 ], 
  [ -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1 ], 
  [ -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1 ], 
  [ -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1 ], 
  [ -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1 ], 
  [ 1, -1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1 ], 
  [ -1, 1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1 ], 
  [ -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1 ], 
  [ -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1 ] ];
    fi;
    if i=3 then return 
[ [ -1, 1, -1, -1, 1, -1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1 ], 
  [ 1, -1, -1, -1, -1, 1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1 ], 
  [ 1, 1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1 ], 
  [ 1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1 ], 
  [ -1, 1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1 ], 
  [ -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1, -1, -1, 1, -1 ], 
  [ -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1, -1, -1, -1, 1 ], 
  [ 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1 ], 
  [ -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1 ], 
  [ -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1, -1, -1, 1, -1 ], 
  [ -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1, -1, -1, -1, 1 ], 
  [ 1, -1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1, -1, 1, -1, -1 ], 
  [ -1, 1, 1, 1, -1, 1, -1, -1, -1, 1, -1, -1, 1, -1, -1, -1 ], 
  [ -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, -1, 1, 1, -1, 1 ], 
  [ -1, -1, -1, 1, -1, -1, -1, 1, -1, -1, -1, 1, 1, 1, 1, -1 ] ];
    fi;
  fi;
  if m>2 then
    return KroneckerProduct(SDPSeriesHadamardMat(m-1,i),SDPSeriesHadamardMat(1,i));
  fi;
end );


#############################################################################
#
#  SDPSeriesDesign( <m>, <i> ) 
#
#  Returns a symmetric block design with parameters 
#  <M>(4^m,2^{m-1}(2^m-1),2^{m-1}(2^{m-1}-1))</M>. 
#  The argument <A>i</A> must be 1, 2, or 3. 
#  If <A>i</A><M>=1</M>, the design is the symplectic design
#  of Kantor <Cite Key='WK75'/>. This design has the symmetric
#  difference property (SDP). If <A>i</A><M>=2</M> or <A>i</A><M>=3</M>,
#  two other non-isomorphic designs with the same parameters
#  are returned. They are not SDP designs, but have the property that 
#  all their blocks are difference sets in the group returned by
#  <Ref Func="SDPSeriesGroup"/>. Developments of these blocks are
#  isomorphic to the design for <A>i</A><M>=1</M>, so the two other 
#  designs are not developments of their blocks.
#
InstallGlobalFunction( SDPSeriesDesign, function( m, i )

  return List((SDPSeriesHadamardMat(m,i)*(-1)^IversonBracket(m=1)+1)/2,x->Positions(x,1));
end );


#############################################################################
#
#  IncidenceMatToBlocks( <M> )  
#
#  Transforms an incidence matrix <A>M</A> to a list of blocks.
#  Rows correspond to points, and columns to blocks.
#
InstallGlobalFunction( IncidenceMatToBlocks, function( m )
local s;

  s:=Difference(Union(m),[0]);
  if Size(s)=1 then
    s:=s[1];
    return List(TransposedMat(m),x->Positions(x,s));
  else
    return List(TransposedMat(m),x->List(s,y->Positions(x,y)));
  fi;
end );


#############################################################################
#
#  BlocksToIncidenceMat( <d> )  
#
#  Transforms a list of blocks <A>d</A> to an incidence matrix.
#  Points correspond to rows, and blocks to columns.
#
InstallGlobalFunction( BlocksToIncidenceMat, function( d )

  if NestingDepthA(d)=2 then
    return List(Union(d),y->List(d,x->IversonBracket(y in x)));
  else
    return List(Union(Concatenation(d)),y->List(d,x->Sum([1..Size(x)],i->i*IversonBracket(y in x[i]))));
  fi;
end );


#############################################################################
#
#  ReadMat( <filename>[, <opt>] ) 
#
#  Reads a list of <M>m\times n</M> integer matrices from a file. The file starts with 
#  the number of rows <M>m</M> and columns <M>n</M> followed by the matrix entries. 
#  Integers in the file are separated by whitespaces. The last argument is a record 
#  <A>opt</A> for options. The possible components of <A>opt</A> are:
#  <List>
#  <Item><A>Format</A>:=<A>"inc"</A>  If defined, the matrices are assumed to have
#  <M>0/1</M> entries not necessarily separated by whitespaces.</Item>
#  <Item><A>Format</A>:=<C>"om"</C>  If defined, the file is assumed to contain 
#  orbit matrices. After <M>m</M> and <M>n</M>, the point and block orbit size
#  vectors <M>\nu</M> and <M>\beta</M> follow, then the matrices.</Item>
#  </List>
#
InstallGlobalFunction( ReadMat, function( filename, opt... )
local input,output,command,inc,om,rez,s,state,l,m,nu,beta,oml,row;

    inc:=false;
    om:=false;
    if Size(opt)>=1 then
      if IsBound(opt[1].Format) then
         inc := opt[1].Format = "inc";
         om := opt[1].Format = "om";
      fi;
    fi;
    if om then
      rez:=[];
      input:=InputTextFile(filename);
      s:=ReadLine(input);
      if s<> fail then
        s:=NormalizedWhitespace(s);
      fi;
      state:=0;
      while s<>fail do
        if s<>"" then
        if s[1] in ['0','1','2','3','4','5','6','7','8','9'] then
          l:=EvalString(Concatenation("[",ReplacedString(s," ",","),"]"));
          if state=0 or state=1 then
            m:=l[1];
            om:=[1..m];
            state:=2;
          elif state=2 then
            nu:=l;
            state:=3;
          elif state=3 then
            state:=4;
            beta:=l;
            oml:=[];
            row:=0;
          elif state=4 then
            row:=row+1;
            om[row]:=l;
            if row=m then
              row:=0;
              Append(oml,[ShallowCopy(om)]);
            fi;
          fi;
        fi;
        fi;
        s:=ReadLine(input);
        if s<> fail then
          s:=NormalizedWhitespace(s);
        fi;
      od;
      CloseStream(input);
      if Size(oml)>0 then
        if Size(rez)=0 then
          Append(rez,[nu,beta,oml]);
        else
          Append(rez,[[nu,beta,oml]]);
        fi;
      fi;
      return rez;
    else
      if inc then 
        command:=Filename(DirectoriesPackagePrograms("PAG"), "togapmatinc");
      else
        command:=Filename(DirectoriesPackagePrograms("PAG"), "togapmat");
      fi;
      input:=InputTextFile( filename );
      if input=fail then
        Print("Cannot open file.\n");
        return ;
      else
        output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"readmat.g"), false);
        Process(PAGGlobalOptions.TempDir, command, input, output, ["-S"]); 
        CloseStream(output);
        CloseStream(input);
        return ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"readmat.g") )();
      fi;
    fi;
end );


#############################################################################
#
#  WriteMat( <filename>, <list>[, <opt>] ) 
#
#  Writes a list of <M>m\times n</M> integer matrices to a file. The number of 
#  rows <M>m</M> and columns <M>n</M> is written first, followed by the matrix 
#  entries. Integers are separated by whitespaces. The last argument is a record 
#  <A>opt</A> for options. The possible components of <A>opt</A> are:
#  <List>
#  <Item><A>Format</A>:=<C>"inc"</C>  If defined, the matrices are assumed to have
#  <M>0/1</M> entries and the entries are written without whitespaces.</Item>
#  </List>
#
InstallGlobalFunction( WriteMat, function( filename, list, opt... )
local output, mat, row, entry, str, inc;

    inc:=" ";
    if Size(opt)>=1 then
      if IsBound(opt[1].Format) then
         if opt[1].Format = "inc" then
           inc:="";
         fi;
      fi;
    fi;
    if NestingDepthA(list)=2 then
      WriteMat(filename,[list]);
    else 
      mat:=DimensionsMat(list[1]);
      output:=OutputTextFile( filename, false); 
      str:=Concatenation(String(mat[1])," ",String(mat[2]),"\n");
      WriteLine(output,str);
      for mat in list do
        for row in mat do
          str:="";
          for entry in row do
            str:=Concatenation(str,String(entry),inc);
          od;
          WriteLine(output,str);  
        od;
        WriteLine(output,"");
      od;
      CloseStream(output);
    fi;
    return ;
end );


#############################################################################
#
#  MosaicParameters( <M> ) 
#
#  Returns a string with the parameters of the mosaic of combinatorial 
#  designs <A>M</A>. See <Cite Key='GGP18'/> for the definition. Entries
#  <M>0</M> in the matrix <A>M</A> are considered empty, and other integers
#  are considered as incidences of distinct designs.
#
InstallGlobalFunction( MosaicParameters, function( m )
local v,d,c,par,i,b,p,k;

  if NestingDepthA(m)=3 then
    return MosaicParameters( BlocksToIncidenceMat(m) );
  else
    v:=Size(m);
    d:=IncidenceMatToBlocks(m);
    if NestingDepthA(d)=2 then
      d:=List(d,x->[x]);
    fi;
    c:=Size(d[1]);
    par:="";
    for i in [1..c] do
      if par<>"" then
        par:=Concatenation(par," + ");
      fi;
      b:=BlockDesign(v,List(d,x->x[i]));
      p:=AllTDesignLambdas(b);
      k:=BlockSizes(b);
      if Size(k)=1 then
        k:=k[1];
      fi;
      par:=Concatenation(par,String(Size(p)-1),"-(",String(v),",",String(k),",",String(p[Size(p)]),")"); 
    od; 
    return par;
  fi;
end );


#############################################################################
#
#  MosaicToBlockDesigns( <M> ) 
#
#  Transforms a mosaic of combinatorial designs <A>M</A> with <M>c</M> 
#  colors to a list of <M>c</M> block designs in the 
#  <Package>Design</Package> package format.
#
InstallGlobalFunction( MosaicToBlockDesigns, function( m )
local v,b,c;

  v:=Size(m);
  b:=IncidenceMatToBlocks(m);
  c:=Size(b[1]);
  return List([1..c],i->BlockDesign(v,List(b,x->x[i])));
end );


#############################################################################
#
#  DifferenceMosaic( <G>, <dds> )  
#
#  Returns the mosaic of symmetric designs obtained from a list
#  of disjoint difference sets <A>dds</A> in the group <G>. 
#
InstallGlobalFunction( DifferenceMosaic, function( g, dds )
local e,to0,m;

  to0:=function ( x )
    if x = fail then
        return 0;
    else
        return x;
    fi;
  end;
  e:=Elements(g);
  m:=List(e,y->y*List(dds,x->e{x}));
  return List(m,z->List(e,y->to0(Position(List(z,x->y in x),true))));
end );


#############################################################################
#
#  PowersMosaic( <q>, <n> )  
#
#  Returns the mosaic of symmetric designs constructed from <A>n</A>-th
#  powers in the field <M>GF(</M><A>q</A><M>)</M>.
#
InstallGlobalFunction( PowersMosaic, function( q, n  )
local e,nze,p,ds,dds,g;

  e:=Elements(GF(q));
  nze:=e{[2..q]};
  p:=AsSet(List(nze,x->x^n));
  ds:=AsSet(List(nze,x->AsSet(x*p)));
  dds:=List(ds,y->List(y,x->Position(e,x)));
  g:=Group(GeneratorsSmallest(Group(List(nze,y->Sortex(List(e,x->x+y))))));
  return DifferenceMosaic(g,dds);
end );


#############################################################################
#
#  PAGGlobalOptions 
#
#  Record with global options for the PAG package.
#
InstallValue( PAGGlobalOptions, rec( 
   Silent := false,
   TempDir := DirectoryTemporary()
  )
);

InstallValue( PAGProcessResult, [] );
MakeReadWriteGlobal("PAGProcessResult");

#E  PAG.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
