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
#  than the order of the group <A>G</A>. The algorithm is described in <Cite Key='KV16'/>. 
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
#  SubsetOrbitRepIN( <G>, <v>, <k>, <opt>] ) 
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
      Print("Joininig long and short orbtis...\n");    
    fi;

    rep:=OrbitFilter1(g,Union(rep,srep),OnSets);

    if verb then
      Print(Size(rep),"\n");    
    fi;

    return rep;
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
#  over <M>{0,1}</M>. By default, A.Wassermann's LLL solver <C>solvediophant</C>.
#  <Cite Key='AW98'/> is used. If the second argument is a compatibility
#  matrix <A>cm</A>, the backtracing solver <C>solvecm</C> from the papers 
#  <Cite Key='KNP11'/> and <Cite Key='KV16'/> is used. The solver can also
#  be chosen explicitly in the record <A>opt</A>. Possible components 
#  of <A>opt</A> are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> If defined, the 
#  solver <C>solvediophant</C> is used.</Item>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> If defined, the 
#  solver <C>solvecm</C> is used.</Item>
#  </List>
#
InstallGlobalFunction( SolveKramerMesner, function( mat, arg... )
local input,output,row,el,command,cm,opt,sol;

    cm:=[];
    opt:=rec();
    sol:=1;
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
    fi;

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
      output:=OutputTextUser();
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
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "sol2gap");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.out") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"solve.g"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []);
    CloseStream(input);
    CloseStream(output);

    return ReadAsFunction( Filename(PAGGlobalOptions.TempDir,"solve.g") )();
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
#  TDesignB( <t>, <v>, <k>, <lambda> )  
#
#  The number of blocks of a <A>t</A>-(<A>v</A>,<A>k</A>,<A>lambda</A>) design. 
#
InstallGlobalFunction( TDesignB, function( t, v, k, lambda )

    return lambda*Binomial(v,t)/Binomial(k,t);
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
#  BlockDesignAut( <d>[, opt] )  
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
#  of size <A>s</A> that cannont be mapped onto each other. By default
#  all points are in the same class.</Item>
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
local input,output,command,str,n,l1,l2,ng,clo,g,abl,cmd;

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
      n:=NrBlockDesignPoints(d)+NrBlockDesignBlocks(d);
      ng:=Size(l1)/n-1;
      l2:=List([0..ng],i->l1{[n*i+1..n*(i+1)]});
      g:=Group(List(l2,PermList));
   fi;

   if not abl then
     g:=RestrictedGroup(g,[1..NrBlockDesignPoints(d)]);
   fi;
   return g;
end );


#############################################################################
#
# HadamardMatAut( <H>[, <opt>] )  
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
#  BlockDesignFilter( <dl>[, opt] )  
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
#  of size <A>s</A> that cannont be mapped onto each other. By default
#  all points are in the same class.</Item>
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
#  HadamardMatFilter( <hl>[, opt] )  
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
#  BlockScheme( <d> )  
#
#  Returns the block intersection scheme of a schematic block design <A>d</A>.
#  If <A>d</A> is not schematic, returns <C>fail</C>. Uses the package 
#  <Package>AssociationSchemes</Package>.
#
InstallGlobalFunction( BlockScheme, function( d )

    return HomogeneousCoherentConfiguration(List(d.blocks,y->List(d.blocks,x->Size(Intersection(x,y)))));
end );


#############################################################################
#
#  KramerMesnerSearch( <t>, <v>, <k>, <lambda>, <G>[, <opt>] )
#
#  Performs a search for <A>t</A>-(<A>v</A>,<A>k</A>,<A>lambda</A>) designs
#  with presrcribed automorphism group <A>G</A> by the Kramer-Mesner method.
#  A record with options can be supplied. By default, a list of base blocks
#  for the constructed designs is returned. If <A>opt.Design</A> is defined,
#  the designs are returned in the <Package>Design</Package> package format 
#  <Ref Chap="Design" BookName="DESIGN"/>. If <A>opt.NonIsomorphic</A> is 
#  defined, the designs are returned in <Package>Design</Package> format and 
#  isomorph-rejection is performed. Other available options are:
#  <List>
#  <Item><A>SmallLambda</A>:=<C>true</C>/<C>false</C>. Perform the <Q>small 
#  lambda filter</Q>, i.e. remove <A>k</A>-orbits covering some of the 
#  <A>t</A>-orbits more than  <A>lambda</A> times. By default, this is 
#  done if <A>lambda</A>&lt;=3.</Item>
#  <Item><A>IntersectionNumbers</A>:=<A>lin</A>/<C>false</C>. Search
#  for designs with block intersection nubers in the list of integers
#  <A>lin</A> (e.g. quasi-symmetric designs).</Item>
#  </List>
#
InstallGlobalFunction( KramerMesnerSearch, function(t,v,k,lambda,g,opt...)
local tsub,b,ksub,m,bb,d,output,smalllambda,lin,cm;

    lin:=[];
    if Size(opt)>0 then
      if IsBound(opt[1].IntersectionNumbers) then
        lin:=opt[1].IntersectionNumbers;
      fi; 
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
      if PAGGlobalOptions.Silent=false then
        Print("Starting solver...\n");
      fi;
      if lin=[] then
        bb:=BaseBlocks(ksub,SolveKramerMesner(m));
      else
        bb:=BaseBlocks(ksub,SolveKramerMesner(m,cm));
      fi;
      output:=1;
      if Size(opt)>=1 then
        if IsBound(opt[1].Design) then
          output:=2;
        fi;
        if IsBound(opt[1].NonIsomorphic) then
          output:=3;
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
          d:=BlockDesignIsomorphismClassRepresentatives(d);
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
#  CayleyTableOfGroup( <g> ) 
#
#  Returns a Cayley table of the group <A>g</A>. The elements
#  are integers <M>1,\ldots,</M><C>Order(</C><A>g</A><C>)</C>.
#
InstallGlobalFunction( CayleyTableOfGroup, function( g )
local e;

    e:=Elements(g);
    return List(e,x->List(e,y->Position(e,x*y)));
end );


#############################################################################
#
#  MOLSAut( <ls>[, <opt>] ) 
#
#  Compute autotopism, autoparatopism, or automorphism groups of MOLS sets 
#  in the list <A>ls</A>. A record with options can be supplied. By default, 
#  autotopism groups are computed. If <A>opt.Paratopism</A> is defined, 
#  autoparastrophisms are allowed, i.e. autoparatopism groups are computed.
#  If <A>opt.Isomorphism</A> is defined, automorphism groups are computed.
#
InstallGlobalFunction( MOLSAut, function( ls, opt... )
local single,r,c,s,lsfile,input,output,command,str,first,last,res,stropt;

    if NestingDepthA(ls)=2 then
      single:=true;
      ls:=[[ls]];
    else
      single:=false;
    fi;
    if NestingDepthA(ls)=3 then
      ls:=List(ls,x->[x]);
    fi;
    s:=Size(ls[1]);
    r:=Size(ls[1][1]);
    c:=Size(ls[1][1][1]);
    stropt:="";
    if Size(opt)>0 then
      if IsBound(opt[1].Paratopism) then
        stropt:="-c";
      fi; 
      if IsBound(opt[1].Isomorphism) then
        stropt:="-i";
      fi; 
    fi;

    lsfile := Filename(PAGGlobalOptions.TempDir,"molsaut.in");
    WriteMOLS(lsfile,ls); 
    input:=InputTextFile(lsfile);
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"molsaut.out"), false);
    command:=Filename(DirectoriesPackagePrograms("PAG"), "molsaut");
    Process(PAGGlobalOptions.TempDir, command, input, output, [stropt]); 
    CloseStream(input);
    CloseStream(output);
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"molsaut.out") );
    str:=ReadAll(input);
    CloseStream(input);
    NormalizeWhitespace(str);
    str:=ReplacedString(str,"()","(())");
    str:=ReplacedString(str,", );",");");
    first:=Positions(str,'=');
    last:=Positions(str,';');
    res:=List([1..Size(ls)],i->GeneratorsOfGroup(EvalString(str{[first[i]+1..last[i]]})));
    res:=List(res,x->List(x,y->RestrictedPerm(y,[1..r+(s+1)*c])));
    res:=List(res,Group);
    if single then
      res:=res[1];
    fi;
    return res;
end );


#############################################################################
#
#  MOLSFilter( <ls>[, <opt>] ) 
#
#  Returns representatives of isotopism, paratopism, or isomorphism classes of MOLS
#  sets in the list <A>ls</A>. A record with options can be supplied. By default, 
#  isotopism class representatives are returned. If <A>opt.Paratopism</A> is defined, 
#  main (paratopism) class representatives are returned. If <A>opt.Isomorphism</A> 
#  is defined, isomorphism class representatives are returned.
#
InstallGlobalFunction( MOLSFilter, function( ls, opt... )
local r,c,s,lsfile,input,output,command,str,first,last,res,stropt;

    if NestingDepthA(ls)=2 then
      ls:=[[ls]];
    fi;
    if NestingDepthA(ls)=3 then
      ls:=List(ls,x->[x]);
    fi;
    s:=Size(ls[1]);
    r:=Size(ls[1][1]);
    c:=Size(ls[1][1][1]);
    stropt:="";
    if Size(opt)>0 then
      if IsBound(opt[1].Paratopism) then
        stropt:="-c";
      fi; 
      if IsBound(opt[1].Isomorphism) then
        stropt:="-i";
      fi; 
    fi;

    lsfile := Filename(PAGGlobalOptions.TempDir,"molsfilter.in");
    WriteMOLS(lsfile,ls); 
    input:=InputTextFile(lsfile);
    lsfile := Filename(PAGGlobalOptions.TempDir,"molsfilter.out");
    output:=OutputTextFile( lsfile, false);
    command:=Filename(DirectoriesPackagePrograms("PAG"), "molsfilter");
    Process(PAGGlobalOptions.TempDir, command, input, output, [stropt]); 
    CloseStream(input);
    CloseStream(output);
    return ReadMOLS(lsfile);
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
#  IsotopismToPerm( <n>, <l> ) 
#
#  Transforms an isotopism, i.e. a list <A>l</A> of three permutations of 
#  degree <A>n</A>, to a single permutation of degree <M>3</M><A>n</A>. 
#
InstallGlobalFunction( IsotopismToPerm, function( n, l )
    return l[1]*MovePerm(l[2],[1..n],[(n+1)..(2*n)])*MovePerm(l[3],[1..n],[(2*n+1)..(3*n)]);
end );


#############################################################################
#
#  PermToIsotopism( <n>, <l> ) 
#
#  Transforms a permutation <A>p</A> of degree <M>3</M><A>n</A> to an
#  isotopism, i.e. a list of three permutations of degree <A>n</A>. 
#
InstallGlobalFunction( PermToIsotopism, function( n, p )
    return [ RestrictedPerm(p,[1..n]), MovePerm(RestrictedPerm(p,[(n+1)..(2*n)]),[(n+1)..(2*n)],[1..n]),
      MovePerm(RestrictedPerm(p,[(2*n+1)..(3*n)]),[(2*n+1)..(3*n)],[1..n]) ];
end );


#############################################################################
#
#  MOLSSubsetOrbitRep( <n>, <s>, <G> ) 
#
#  Computes representatives of pairs and <M>(</M><A>s</A><M>+2)</M>-tuples
#  for the construction of MOLS of order <A>n</A> with prescribed autotopism
#  group <A>G</A>. A list containing pairs representatives in the first 
#  component and tuples representatives in the second component is returned.
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
      Print("Tuples: ",Size(rep),"\n");
    fi;
    return [pairs,rep];
end );


#############################################################################
#
#  TuplesToMOLS( <n>, <s>, <T> ) 
#
#  Transforms a set of <M>(</M><A>s</A><M>+2)</M>-tuples <A>T</A> to a 
#  set of MOLS of order <A>n</A>.
#
InstallGlobalFunction( TuplesToMOLS, function( n, s, tup )
local i,x,ls;
    ls:=List([1..s],z->List([1..n],x->List([1..n],y->0)));
    for i in [1..s] do
      for x in tup do
        ls[i][x[1]][x[2]-n]:=x[i+2]-(i+1)*n;
      od;
    od;
    return ls;
end );


#############################################################################
#
#  KramerMesnerMOLS( <n>, <s>, <G>[, <opt>] ) 
#
#  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
#  autotopism group <A>G</A>. A record <A>opt</A> with options can be supplied.
#  By default, A.Wassermann's LLL solver <C>solvediophant</C> is used and
#  all constructed MOLS are returned, i.e. no filtering is performed. Available 
#  options are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> The backtracing solver <C>solvecm</C> 
#  is used.</Item>
#  <Item><A>Filter</A>:=<C>"Isotopism"</C> Non-isotopic MOLS are returned.</Item>
#  <Item><A>Filter</A>:=<C>"Paratopism"</C> Non-paratopic MOLS are returned.</Item>
#  <Item><A>Filter</A>:=<C>"Isomorphism"</C> Non-isomorphic MOLS are returned.</Item>
#  </List>
#
InstallGlobalFunction( KramerMesnerMOLS, function( n, s, g, opt... )
local rep,m,row,bb,inc,rez;
    if opt=[] then
      opt:=[rec(Filter:=false)];
    fi;
    if not IsBound(opt[1].Filter) then
      opt[1].Filter:=false;
    fi; 
    rep:=MOLSSubsetOrbitRep(n,s,g);
    if rep[2]<>[] then
      m:=KramerMesnerMat(g,rep[1],rep[2],1);
      if not PAGGlobalOptions.Silent then
        Print("KM matrix: ",DimensionsMat(m),"\n");
      fi; 
      if IsBound(opt[1].Solver) then
        if opt[1].Solver="solvecm" then
          row:=List(rep[2],x->Size(Orbit(g,x,OnSets)));
          row:=Concatenation(row,[n*n]);
          m:=Concatenation(m,[row]);
        fi;
      fi;
      bb:=BaseBlocks(rep[2],AsSet(SolveKramerMesner(m,opt[1])));
      if not PAGGlobalOptions.Silent then
        Print("Solutions: ",Size(bb),"\n");
      fi;
      if bb<>[] then
        inc:=List(bb,y->Concatenation(List(y,x->Orbit(g,x,OnSets))));
        rez:=List(inc,x->TuplesToMOLS(n,s,x));
        if opt[1].Filter="Isotopism" then
          rez:=MOLSFilter(rez);
          if not PAGGlobalOptions.Silent then
            Print("Nonisotopic: ",Size(rez),"\n");
          fi;
        fi;
        if opt[1].Filter="Paratopism" then
          rez:=MOLSFilter(rez,rec(Paratopism:=true));
          if not PAGGlobalOptions.Silent then
            Print("Nonparatopic: ",Size(rez),"\n");
          fi;
        fi;
        if opt[1].Filter="Isomorphism" then
          rez:=MOLSFilter(rez,rec(Isomorphism:=true));
          if not PAGGlobalOptions.Silent then
            Print("Nonisomorphic: ",Size(rez),"\n");
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
#  KramerMesnerMOLSParatopism( <n>, <s>, <G>[, <opt>] ) 
#
#  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
#  autoparatopism group <A>G</A>. A record <A>opt</A> with options can be supplied.
#  By default, A.Wassermann's LLL solver <C>solvediophant</C> is used and
#  all constructed MOLS are returned, i.e. no filtering is performed. Available 
#  options are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> The backtracing solver <C>solvecm</C> 
#  is used.</Item>
#  <Item><A>Filter</A>:=<C>"Isotopism"</C> Non-isotopic MOLS are returned.</Item>
#  <Item><A>Filter</A>:=<C>"Paratopism"</C> Non-paratopic MOLS are returned.</Item>
#  <Item><A>Filter</A>:=<C>"Isomorphism"</C> Non-isomorphic MOLS are returned.</Item>
#  </List>
#
InstallGlobalFunction( KramerMesnerMOLSParatopism, function( n, s, g, opt... )
local rep,m,row,bb,inc,rez,r,grp;
    if opt=[] then
      opt:=[rec(Filter:=false)];
    fi;
    if not IsBound(opt[1].Filter) then
      opt[1].Filter:=false;
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
      Print("Pairs: ",Size(rep[2]),"\n");
    fi;
    if rep[2]<>[] then
      m:=KramerMesnerMat(g,rep[1],rep[2],1);
      if not PAGGlobalOptions.Silent then
        Print("KM matrix: ",DimensionsMat(m),"\n");
      fi; 
      if IsBound(opt[1].Solver) then
        if opt[1].Solver="solvecm" then
          row:=List(rep[2],x->Size(Orbit(g,x,OnSets)));
          row:=Concatenation(row,[n*n]);
          m:=Concatenation(m,[row]);
        fi;
      fi;
      bb:=BaseBlocks(rep[2],AsSet(SolveKramerMesner(m,opt[1])));
      if not PAGGlobalOptions.Silent then
        Print("Solutions: ",Size(bb),"\n");
      fi;
      if bb<>[] then
        inc:=List(bb,y->Concatenation(List(y,x->Orbit(g,x,OnSets))));
        rez:=List(inc,x->TuplesToMOLS(n,s,x));
        if opt[1].Filter="Isotopism" then
          rez:=MOLSFilter(rez);
          if not PAGGlobalOptions.Silent then
            Print("Nonisotopic: ",Size(rez),"\n");
          fi;
        fi;
        if opt[1].Filter="Paratopism" then
          rez:=MOLSFilter(rez,rec(Paratopism:=true));
          if not PAGGlobalOptions.Silent then
            Print("Nonparatopic: ",Size(rez),"\n");
          fi;
        fi;
        if opt[1].Filter="Isomorphism" then
          rez:=MOLSFilter(rez,rec(Isomorphism:=true));
          if not PAGGlobalOptions.Silent then
            Print("Nonisomorphic: ",Size(rez),"\n");
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
#
InstallGlobalFunction( RightDevelopment, function( g, ds )

    return BlockDesign(Size(g),[ds],PermRepresentationRight(g));

end );


#############################################################################
#
#  LeftDevelopment( <G>, <ds> ) 
#
#  Returns a block design that is the development of the difference 
#  set <A>ds</A> by left multiplication in the group <A>G</A>.
#
InstallGlobalFunction( LeftDevelopment, function( g, ds )

    return BlockDesign(Size(g),[ds],PermRepresentationLeft(g));

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
#  OrthogonalArrayToCube( <OA> ) 
#
#  Transforms the orthogonal array <A>OA</A> to an equivalent incidence cube.
#
InstallGlobalFunction( OrthogonalArrayToCube, function( oa )
local v,d,cr;

  d:=Size(oa[1]);
  v:=Maximum(Maximum(oa));

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
#  CubeTest( <C> ) 
#
#  Test whether an incidence cube <A>C</A> is a cube of symmetric designs.
#  The result should be <C>[[v,k,lambda]]</C>. Anything else means that
#  <A>C</A> is not a <M>(v,k,lambda)</M> cube.
#
InstallGlobalFunction( CubeTest, function( c )
local v;

  v:=Size(c);
  return AsSet(List(CubeSlices(c),x->AllTDesignLambdas(BlockDesign(v,List(x,y->Positions(y,1))))));
end );


#############################################################################
#
#  CubeInvariant( <C> ) 
#
#  Computes an equivalence invariant of the cube <A>C</A>
#  based on automorphism group sizes of its slices. Cubes 
#  equivalent under paratopy have the same invariant.
#
InstallGlobalFunction( CubeInvariant, function( c )
local v,d;

  v:=Size(c);
  d:=NestingDepthA(c);
  return Collected(List(Combinations([1..d],2),x->Collected(List(CubeSlices(c,x[1],x[2]),y->Size(BlockDesignAut(BlockDesign(v,List(y,z->Positions(z,1)))))))));
end );


#############################################################################
#
#  CubeAut( <C>[, opt] )  
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
         fi;
    else
      opt2.PointClasses:=v;
      if IsBound(opt[1].Isotopy) then
         if not opt[1].Isotopy then
           Unbind(opt2.PointClasses);
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
#  CubeFilter( <cl>[, opt] )  
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
local opt2,v;

  if cl=[] then return [];
  else
    v:=Size(cl[1]);
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
    else
      opt2:=rec();
    fi;
    opt2.Positions:=true;

    return cl{BlockDesignFilter(List(cl,CubeToTransversalDesign),opt2)};
  fi;
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

#E  PAG.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
