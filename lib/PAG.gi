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
#  over <M>\{0,1\}</M>. By default, A.Wassermann's LLL solver <C>solvediophant</C>
#  <Cite Key='AW98'/> is used. If the second argument is a compatibility
#  matrix <A>cm</A>, the backtracking program <C>solvecm</C> from the papers 
#  <Cite Key='KNP11'/> and <Cite Key='KV16'/> is used. The solver can also
#  be chosen explicitly in the record <A>opt</A>. Possible components are:
#  <List>
#  <Item><A>Solver</A>:=<C>"solvediophant"</C> If defined, <C>solvediophant</C> 
#  is used.</Item>
#  <Item><A>Solver</A>:=<C>"solvecm"</C> If defined, <C>solvecm</C> is used.</Item>
#  <Item><A>Solver</A>:=<C>"libexact"</C> If defined, <C>libexact</C> is used.
#  This is P. Kaski and  O. Pottonen's implementation of the Dancing Links
#  algorithm, see <Cite Key='KP08'/>. For this solver the coefficients of
#  <A>mat</A> must be in <M>\{0,1\}</M>!</Item>
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
      if opt.Solver="libexact" then
        sol:=3;
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

  return AsSet(List(oa,x->x{t}));
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
#  ReadMat( <filename> )  
#
#  Read a list of integer matrices from a file. The file starts with the number
#  of rows <M>m</M> and columns <M>n</M> followed by the matrix entries. Integers
#  in the file are separated by whitespaces.
#
InstallGlobalFunction( ReadMat, function( filename )
local input,output,command;

    command:=Filename(DirectoriesPackagePrograms("PAG"), "togapmat");
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
end );


#############################################################################
#
#  WriteMat( <filename>, <list> ) 
#
#  Write a list of <M>m\times n</M> integer matrices to a file. The number of 
#  rows <M>m</M> and columns <M>n</M> is written first, followed by the matrix 
#  entries. Integers are separated by whitespaces.
#
InstallGlobalFunction( WriteMat, function( filename, list )
local output, mat, row, entry, str;

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
            str:=Concatenation(str,String(entry)," ");
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

#E  PAG.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
