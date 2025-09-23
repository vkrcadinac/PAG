#############################################################################
##
##
#W  PAG.gd        Prescribed Automorphism Groups (PAG)
#W                by Vedran Krcadinac 
##
##  Declarations and documentation for functions of the PAG package.
##
##


#############################################################################
##
#F  PrimitiveGroupsOfDegree( <v> ) 
##
##  <#GAPDoc Label="PrimitiveGroupsOfDegree">
##  <ManSection>
##  <Func Name="PrimitiveGroupsOfDegree" Arg="v"/>
##
##  <Description>
##  Returns a list of all primitive permutation groups on <A>v</A> points.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PrimitiveGroupsOfDegree" );

#############################################################################
##
#F  TransitiveGroupsOfDegree( <v> ) 
##
##  <#GAPDoc Label="TransitiveGroupsOfDegree">
##  <ManSection>
##  <Func Name="TransitiveGroupsOfDegree" Arg="v"/>
##
##  <Description>
##  Returns a list of all transitive permutation groups on <A>v</A> points.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TransitiveGroupsOfDegree" );

#############################################################################
##
#F  ConjugationFilter( <v>, <gl>[, <opt>] ) 
##
##  <#GAPDoc Label="ConjugationFilter">
##  <ManSection>
##  <Func Name="ConjugationFilter" Arg="v, gl[, opt]"/>
##
##  <Description>
##  Given a list of permutation groups <A>gl</A>, returns a set 
##  of representatives up to conjugation in the symmetric group 
##  of degree <A>v</A>, i.e. up to permutation isomorphism. If 
##  <A>gl</A> is partitioned into blocks, it is assumed that the 
##  groups from different blocks are not equivalent and the function 
##  is applied to each block. This reduces the number of ccnjugation
##  tests and makes the computation faster. The list <A>gl</A> can 
##  be partitioned using invariants given in the record <A>opt</A>.
##  If the record has a component <A>Invariant</A>, the list is 
##  partitioned accordingly and no conjugation tests are performed.
##  Here are the values that <A>Invariant</A> can take: 
##  <List>
##  <Item><A>Invariant</A>:="OrbitSizes"  The orbit sizes of 
##  <C>g</C> on <C>[1..</C><A>v</A><C>]</C> are used to partition
##  <A>gl</A>.</Item> 
##  <Item><A>Invariant</A>:="CycleLengths"  The cycle lengths of 
##  all elements of <C>g</C> on <C>[1..</C><A>v</A><C>]</C> are 
##  used to partition <A>gl</A>.</Item> 
##  <Item><A>Invariant</A>:=<C>function</C>  Any function that 
##  is an invariant of permutation isomorphism can also be
##  given and is then used to partition <A>gl</A>.</Item> 
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ConjugationFilter" );

#############################################################################
##
#F  ConjugationFilter2( <v>, <gl>[, <opt>] ) 
##
##  <#GAPDoc Label="ConjugationFilter2">
##  <ManSection>
##  <Func Name="ConjugationFilter2" Arg="v, gl[, opt]"/>
##
##  <Description>
##  Given a list of permutation groups <A>gl</A>, returns a set 
##  of representatives up to conjugation in the symmetric group 
##  of degree <A>v</A>, i.e. up to permutation isomorphism. Uses 
##  <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno 
##  <Cite Key='MP14'/>. The last argument <A>opt</A> is a record 
##  for options. The possible components of <A>opt</A> are:
##  <List>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files 
##  in the named directory. By default, 
##  <C>PAGGlobalOptions.TempDir</C> is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ConjugationFilter2" );

#############################################################################
##
#F  Homogeneity( <G> ) 
##
##  <#GAPDoc Label="Homogeneity">
##  <ManSection>
##  <Func Name="Homogeneity" Arg="G"/>
##
##  <Description>
##  Returns the degree of homogeneity of the permutation group <A>G</A>, i.e. the largest
##  integer <M>k</M> such that <A>G</A> is <M>k</M>-homogeneous. This means that every
##  <M>k</M>-subset of points can be mapped to every other. Kantor <Cite Key='WK72'/>
##  classified all groups that are <M>k</M>-homogenous but not <M>k</M>-transitive.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Homogeneity" );

#############################################################################
##
#F  CyclicPerm( <n> ) 
##
##  <#GAPDoc Label="CyclicPerm">
##  <ManSection>
##  <Func Name="CyclicPerm" Arg="n"/>
##
##  <Description>
##  Returns the cyclic permutation (1,...,<A>n</A>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CyclicPerm" );

#############################################################################
##
#F  MovePerm( <p>, <from>, <to> ) 
##
##  <#GAPDoc Label="MovePerm">
##  <ManSection>
##  <Func Name="MovePerm" Arg="p, from, to"/>
##
##  <Description>
##  Moves permutation <A>p</A> acting on the set <A>from</A> to a
##  permutation acting on the set <A>to</A>. The arguments <A>from</A>
##  and <A>to</A> should be lists of integers of the same size. 
##  Alternatively, if instead of <A>from</A> and <A>to</A> just
##  one integer argument <A>by</A> is given, the permutation is 
##  moved from <C>MovedPoints(</C><A>p</A><C>)</C> to
##  <C>MovedPoints(</C><A>p</A><C>)+</C><A>by</A>; see
##  <Ref Func="MovedPoints" BookName="ref"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MovePerm" );

#############################################################################
##
#F  MoveGroup( <G>, <from>, <to> ) 
##
##  <#GAPDoc Label="MoveGroup">
##  <ManSection>
##  <Func Name="MoveGroup" Arg="G, from, to"/>
##
##  <Description>
##  Apply <Ref Func="MovePerm"/> to each generator of the group <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MoveGroup" );

#############################################################################
##
#F  ToGroup( <G>, <f> ) 
##
##  <#GAPDoc Label="ToGroup">
##  <ManSection>
##  <Func Name="ToGroup" Arg="G, f"/>
##
##  <Description>
##  Apply function <A>f</A> to each generator of the group <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ToGroup" );

#############################################################################
##
#F  MultiPerm( <p>, <set>, <m> ) 
##
##  <#GAPDoc Label="MultiPerm">
##  <ManSection>
##  <Func Name="MultiPerm" Arg="p, set, m"/>
##
##  <Description>
##  Repeat the action of a permutation <A>m</A> times. The new 
##  permutation acts on <A>m</A> disjoint copies of <A>set</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MultiPerm" );

#############################################################################
##
#F  MultiGroup( <G>, <set>, <m> ) 
##
##  <#GAPDoc Label="MultiGroup">
##  <ManSection>
##  <Func Name="MultiGroup" Arg="G, set, m"/>
##
##  <Description>
##  Apply <Ref Func="MultiPerm"/> to each generator of the group <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MultiGroup" );

#############################################################################
##
#F  RestrictedGroup( <G>, <set> ) 
##
##  <#GAPDoc Label="RestrictedGroup">
##  <ManSection>
##  <Func Name="RestrictedGroup" Arg="G, set"/>
##
##  <Description>
##  Apply <Ref Func="RestrictedPerm" BookName="ref"/> to each generator of the group <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "RestrictedGroup" );

#############################################################################
##
#F  TidyGroup( <G>, <set>[, <opt>] ) 
##
##  <#GAPDoc Label="TidyGroup">
##  <ManSection>
##  <Func Name="TidyGroup" Arg="G, set[, opt]"/>
##
##  <Description>
##  Given a permutation group <A>G</A> and a set, returns a 
##  permutationally isomorphic group such that its orbits 
##  contain consecutive integers and are sorted by size. The 
##  optional argument <A>opt</A> is a record with component 
##  <List>
##  <Item><A>MinimalGeneratingSet</A>:=<C>true</C>/<C>false</C>  
##  Use a minimal generating set of <A>G</A>. The default is 
##  <C>true</C>.</Item>
##  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C>  
##  Put orbits that are equivalent under the normalizer in
##  consecutive places. It is assumed that <A>set</A> is
##  of the form <C>[1..v]</C> and the normalizer of <A>G</A>
##  in <C>SymmetricGroup(v)</C> is computed. The default is 
##  <C>true</C>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TidyGroup" );

#############################################################################
##
#F  AllSubgroupsConjugation( <G> ) 
##
##  <#GAPDoc Label="AllSubgroupsConjugation">
##  <ManSection>
##  <Func Name="AllSubgroupsConjugation" Arg="G"/>
##
##  <Description>
##  Returns a list of all subgroups of <A>G</A> up to conjugation. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AllSubgroupsConjugation" );

#############################################################################
##
#F  PermRepresentationRight( <G> ) 
##
##  <#GAPDoc Label="PermRepresentationRight">
##  <ManSection>
##  <Func Name="PermRepresentationRight" Arg="G"/>
##
##  <Description>
##  Returns the regular permutation representation of a group <A>G</A>
##  by right multiplication.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PermRepresentationRight" );

#############################################################################
##
#F  PermRepresentationLeft( <G> ) 
##
##  <#GAPDoc Label="PermRepresentationLeft">
##  <ManSection>
##  <Func Name="PermRepresentationLeft" Arg="G"/>
##
##  <Description>
##  Returns the regular permutation representation of a group <A>G</A>
##  by left multiplication.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PermRepresentationLeft" );

#############################################################################
##
#F  ExtendedPermRepresentation( <G> ) 
##
##  <#GAPDoc Label="ExtendedPermRepresentation">
##  <ManSection>
##  <Func Name="ExtendedPermRepresentation" Arg="G"/>
##
##  <Description>
##  Returns the extended permutation representation of a group <A>G</A>
##  including right multiplication, left multiplication, and group
##  automorphisms. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ExtendedPermRepresentation" );

#############################################################################
##
#F  AllPermRepresentations( <G>, <nu> ) 
##
##  <#GAPDoc Label="AllPermRepresentations">
##  <ManSection>
##  <Func Name="AllPermRepresentations" Arg="G, nu"/>
##
##  <Description>
##  Returns all permutation representations of a group <A>G</A>
##  on orbits of size given in a list of integers <A>nu</A>.
##  The integers should be divisors of the order of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AllPermRepresentations" );

#############################################################################
##
#F  SubsetOrbitRep( <G>, <v>, <k>[, <opt>] ) 
##
##  <#GAPDoc Label="SubsetOrbitRep">
##  <ManSection>
##  <Func Name="SubsetOrbitRep" Arg="G, v, k[, opt]"/>
##
##  <Description>
##  Computes orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  under the action of the permutation group <A>G</A>. The basic algorithm
##  is described in <Cite Key='KVK21'/>. The algorithm for short orbits 
##  is described in <Cite Key='KV16'/>. The last argument is a record 
##  <A>opt</A> for options. The possible components of <A>opt</A> are:
##  <List>
##  <Item><A>SizeLE</A>:=<A>n</A>  If defined, only representatives of orbits of
##  size less or equal to <A>n</A> are computed.</Item>
##  <Item><A>IntersectionNumbers</A>:=<A>lin</A>  If defined, only representatives
##  of good orbits are returned. These are orbits with intersection
##  numbers in the list of integers <A>lin</A>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRep" );

#############################################################################
##
#F  SubsetOrbitRepIN( <G>, <v>, <k>, <lin>[, <opt>] ) 
##
##  <#GAPDoc Label="SubsetOrbitRepIN">
##  <ManSection>
##  <Func Name="SubsetOrbitRepIN" Arg="G, v, k, lin[, opt]"/>
##
##  <Description>
##  Computes orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  under the action of the permutation group <A>G</A> with intersection 
##  numbers in the list <A>lin</A>. Parts of the search tree with partial 
##  subsets intersecting in more than the largest number in <A>lin</A> 
##  are skipped. Short orbits are computed separately. The algorithm is 
##  described in <Cite Key='KVK21'/>. The last (optional) argument 
##  <A>opt</A> is a record for options. The possible components are:
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>FilteringLevel</A>:=<A>n</A>  Apply filrering of the
##  search tree up to subsets of size <A>n</A>. By default, 
##  <A>n</A>=<A>k</A>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepIN" );

#############################################################################
##
#F  SubsetOrbitRepIN2( <G>, <v>, <k>, <x>, <y>[, <opt>] ) 
##
##  <#GAPDoc Label="SubsetOrbitRepIN2">
##  <ManSection>
##  <Func Name="SubsetOrbitRepIN2" Arg="G, v, k, x, y[, opt]"/>
##
##  <Description>
##  Computes orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  under the action of the permutation group <A>G</A> with intersection 
##  numbers <A>x</A> and <A>y</A>. Calls a <C>C</C>-subroutine for the 
##  time-critical part of the computation and should be faster than
##  <Ref Func="SubsetOrbitRepIN"/>. The algorithm is described in 
##  <Cite Key='KVK21'/>. The last (optional) argument <A>opt</A> is 
##  a record for options. Possible components are:
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>Long</A>:=<C>true</C>/<C>false</C>  Compute and return
##  the long orbits (of size equal to <M>|G|</M>).</Item>
##  <Item><A>Short</A>:=<C>true</C>/<C>false</C>  Compute and return
##  the short orbits (of size less than <M>|G|</M>).</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepIN2" );

#############################################################################
##
#F  SubsetOrbitRepSteiner( <G>, <t>, <v>, <k>[, <opt>] ) 
##
##  <#GAPDoc Label="SubsetOrbitRepSteiner">
##  <ManSection>
##  <Func Name="SubsetOrbitRepSteiner" Arg="G, t, v, k[, opt]"/>
##
##  <Description>
##  Computes orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  under the action of the permutation group <A>G</A> with intersection 
##  numbers strictly less than <A>t</A>. Calls <C>C</C>-subroutines 
##  for the time-critical parts of the computation. The algorithm is 
##  described in <Cite Key='KVK21'/>. The last (optional) argument 
##  <A>opt</A> is a record for options. Possible components are:
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>Long</A>:=<C>true</C>/<C>false</C>  Compute and return
##  the long orbits (of size equal to <M>|G|</M>).</Item>
##  <Item><A>Short</A>:=<C>true</C>/<C>false</C>  Compute and return
##  the short orbits (of size less than <M>|G|</M>).</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepSteiner" );

#############################################################################
##
#F  SubsetOrbitRepOM( <G>, <t>, <v>, <k>, <beta>, <OM>[, <opt>] ) 
##
##  <#GAPDoc Label="SubsetOrbitRepOM">
##  <ManSection>
##  <Func Name="SubsetOrbitRepOM" Arg="G, t, v, k, beta, OM[, opt]"/>
##
##  <Description>
##  Computes subset orbit representatives compatible with an orbit
##  matrix or list of orbit matrices <A>OM</A> with block orbit sizes
##  <A>beta</A>. For each orbit matrix, the result is returned as a 
##  list of two components. The first component is a list of sets of 
##  orbit representatives compatible with a column of the orbit matrix. 
##  The second component is a list of numbers indicating how many 
##  orbits have to be taken from each set. Calls 
##  <Ref Func="SubsetOrbitRepSteiner"/> to generate the subset orbits.
##  The last (optional) argument <A>opt</A> is a record for options. 
##  Possible components are:
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepOM" );

#############################################################################
##
#F  SubsetOrbitRepShort1( <G>, <v>, <k>, <size> ) 
##
##  <#GAPDoc Label="SubsetOrbitRepShort1">
##  <ManSection>
##  <Func Name="SubsetOrbitRepShort1" Arg="G, v, k, size"/>
##
##  <Description>
##  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
##  than the order of the group <A>G</A>. The algorithm is described in 
##  <Cite Key='KV16'/>. The implementation uses <Ref Func="OrbitFilter1"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepShort1" );

#############################################################################
##
#F  SubsetOrbitRepShort2( <G>, <v>, <k>, <size> ) 
##
##  <#GAPDoc Label="SubsetOrbitRepShort2">
##  <ManSection>
##  <Func Name="SubsetOrbitRepShort2" Arg="G, v, k, size"/>
##
##  <Description>
##  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
##  than the order of the group <A>G</A>. The algorithm is described in 
##  <Cite Key='KV16'/>. The implementation uses <Ref Func="OrbitFilter2"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepShort2" );

#############################################################################
##
#F  SubsetOrbitRepShort3( <G>, <v>, <k>, <size>[, <opt>] ) 
##
##  <#GAPDoc Label="SubsetOrbitRepShort3">
##  <ManSection>
##  <Func Name="SubsetOrbitRepShort3" Arg="G, v, k, size[, opt]"/>
##
##  <Description>
##  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
##  than the order of the group <A>G</A>. The algorithm is described in 
##  <Cite Key='KV16'/>. This implementation calls a C program and allows 
##  specifying intersection numbers in a record <A>opt</A>. Possible 
##  components are:
##  <List>
##  <Item><A>IntersectionNumbers</A>:=<C>lin</C>  A set <C>lin</C> of up
##  to four intersection numbers can be given.</Item> 
##  <Item><A>SteinerT</A>:=<C>t</C>  Computes short orbits for Steiner 
##  <C>t</C>-designs. An integer <C>t</C> in [2,3,4] can be given;
##  this means that the intersection numbers are [0..<C>t</C>-1].
##  </Item> 
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepShort3" );

#############################################################################
##
#F  IsGoodSubsetOrbit( <G>, <rep>, <lin> ) 
##
##  <#GAPDoc Label="IsGoodSubsetOrbit">
##  <ManSection>
##  <Func Name="IsGoodSubsetOrbit" Arg="G, rep, lin"/>
##
##  <Description>
##  Check if the subset orbit generated by the permutation group <A>G</A>
##  and the representative <A>rep</A> is a good orbit with respect
##  to the list of intersection numbers <A>lin</A>. This means that the
##  intersection size of any pair of sets from the orbit is an integer
##  in <A>lin</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsGoodSubsetOrbit" );

#############################################################################
##
#F  AreCompatibleSubsetOrbits( <G>, <rep1>, <rep2>, <lin> ) 
##
##  <#GAPDoc Label="AreCompatibleSubsetOrbits">
##  <ManSection>
##  <Func Name="AreCompatibleSubsetOrbits" Arg="G, rep1, rep2, lin"/>
##
##  <Description>
##  Check if the subset orbits generated by the permutation group <A>G</A>
##  and the representatives <A>rep1</A> and <A>rep2</A> are compatible with 
##  respect to the list of intersection numbers <A>lin</A>. This means that 
##  the intersection size of any pair of subsets from the two orbits is an 
##  integer in <A>lin</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AreCompatibleSubsetOrbits" );

#############################################################################
##
#F  SmallLambdaFilter( <G>, <tsub>, <ksub>, <lambda> ) 
##
##  <#GAPDoc Label="SmallLambdaFilter">
##  <ManSection>
##  <Func Name="SmallLambdaFilter" Arg="G, tsub, ksub, lambda"/>
##
##  <Description>
##  Remove <M>k</M>-subset representatives from <A>ksub</A> such that the 
##  corresponding <A>G</A>-orbit covers some of the <M>t</M>-subset 
##  representatives from <A>tsub</A> more than <A>lambda</A> times. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SmallLambdaFilter" );

#############################################################################
##
#F  OrbitFilter1( <G>, <obj>, <action> ) 
##
##  <#GAPDoc Label="OrbitFilter1">
##  <ManSection>
##  <Func Name="OrbitFilter1" Arg="G, obj, action"/>
##
##  <Description>
##  Takes a list of objects <A>obj</A> and returns one representative
##  from each orbit of the group <A>G</A> acting by <A>action</A>.
##  The result is a sublist of <A>obj</A>. The algorithm uses the 
##  &GAP; function <Ref Func="Orbit" BookName="ref"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitFilter1" );

#############################################################################
##
#F  OrbitFilter2( <G>, <obj>, <action> ) 
##
##  <#GAPDoc Label="OrbitFilter2">
##  <ManSection>
##  <Func Name="OrbitFilter2" Arg="G, obj, action"/>
##
##  <Description>
##  Takes a list of objects <A>obj</A> and returns one representative
##  from each orbit of the group <A>G</A> acting by <A>action</A>.
##  Canonical representatives are returned, so the result is not a 
##  sublist of <A>obj</A>. The algorithm uses the 
##  <Ref Func="CanonicalImage" BookName="Images"/>
##  function from the package <Package>Images</Package>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitFilter2" );

#############################################################################
##
#F  InequivalentSubsetOrbits( <N>, <ksub>[, <opt>] ) 
##
##  <#GAPDoc Label="InequivalentSubsetOrbits">
##  <ManSection>
##  <Func Name="InequivalentSubsetOrbits" Arg="N, ksub[, opt]"/>
##
##  <Description>
##  Takes a list of subset orbit representatives <A>ksub</A> and returns 
##  indices of the ones that cannot be mapped onto each other by the 
##  permutation group <A>N</A> (typically the normalizer of the group
##  generating the orbits). Uses the 
##  <Ref Func="CanonicalImage" BookName="Images"/> function from the 
##  <Package>Images</Package> package. The optional argument <A>opt</A> 
##  is a record for options. Possible components are:
##  <List>
##  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Returns a partition 
##  of <A>ksub</A> into <A>N</A>-equivalent subsets, not just one 
##  representative from each block. The partition is also given by 
##  indices.</Item> 
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "InequivalentSubsetOrbits" );

#############################################################################
##
#F  InequivalentSubsetOrbitPairs( <N>, <G>, <ksub>[, <opt>] ) 
##
##  <#GAPDoc Label="InequivalentSubsetOrbitPairs">
##  <ManSection>
##  <Func Name="InequivalentSubsetOrbitPairs" Arg="N, G, ksub[, opt]"/>
##
##  <Description>
##  Takes a list of subset orbit representatives <A>ksub</A> and returns 
##  indices of the pairs that cannot be mapped onto each other by the 
##  permutation group <A>N</A> (typically the normalizer of the group
##  <A>G</A> generating the orbits). Uses the 
##  <Ref Func="CanonicalImage" BookName="Images"/> function from the 
##  <Package>Images</Package> package. The optional argument <A>opt</A> 
##  is a record for options. Possible components are:
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>IntersectionNumbers</A>:=<A>lin</A>  If defined, only
##  pairs of compatible orbits are returned. This means that each
##  element from one orbit intersects each element from the other 
##  in a subset of size given in the list of integers <A>lin</A>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "InequivalentSubsetOrbitPairs" );

#############################################################################
##
#F  KramerMesnerMat( <G>, <tsub>, <ksub>[, <lambda>][, <b>] ) 
##
##  <#GAPDoc Label="KramerMesnerMat">
##  <ManSection>
##  <Func Name="KramerMesnerMat" Arg="G, tsub, ksub[, lambda][, b]"/>
##
##  <Description>
##  Returns the Kramer-Mesner matrix for a permutation group <A>G</A>. The 
##  rows are labelled by <M>t</M>-subset orbits represented by <A>tsub</A>, and
##  the columns by <M>k</M>-subset orbits represented by <A>ksub</A>. A column
##  of constants <A>lambda</A> is added if the optional argument <A>lambda</A>
##  is given. Another row is added if the optional argument <A>b</A> is
##  given, repesenting the constraint that sizes of the chosen <M>k</M>-subset
##  orbits must sum up to the number of blocks <A>b</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMat" );

#############################################################################
##
#F  KramerMesnerMat( <G>, <tsub>, <ksub>[, <lambda>][, <b>] ) 
##
##  <#GAPDoc Label="KramerMesnerMat2">
##  <ManSection>
##  <Func Name="KramerMesnerMat2" Arg="G, tsub, ksub[, lambda][, b]"/>
##
##  <Description>
##  Returns the Kramer-Mesner matrix for a permutation group <A>G</A>. The 
##  rows are labelled by <M>t</M>-subset orbits represented by <A>tsub</A>, and
##  the columns by <M>k</M>-subset orbits represented by <A>ksub</A>. A column
##  of constants <A>lambda</A> is added if the optional argument <A>lambda</A>
##  is given. Another row is added if the optional argument <A>b</A> is
##  given, repesenting the constraint that sizes of the chosen <M>k</M>-subset
##  orbits must sum up to the number of blocks <A>b</A>. This function calls
##  a <C>C</C>-subroutine for the time-critical part of the computation and 
##  should be faster than <Ref Func="KramerMesnerMat"/>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMat2" );

#############################################################################
##
#F  MakeDLX( <filename>, <G>, <tsub>, <ksub>[, <opt>] ) 
##
##  <#GAPDoc Label="MakeDLX">
##  <ManSection>
##  <Func Name="MakeDLX" Arg="filename, G, tsub, ksub[, opt]"/>
##
##  <Description>
##  Creates a DLX file <A>filename</A> for the permutation group <A>G</A>, 
##  <M>t</M>-subset and <M>k</M>-subset orbits representatives <A>tsub</A> 
##  and <A>ksub</A>. The orbits must be such that the corresponding 
##  Kramer-Mesner matrix has only <M>0</M>-<M>1</M> entries. The <A>ksub</A>
##  argument may be given as returned by <Ref Func="SubsetOrbitRepOM"/>.
##  In that case additional equations will be added to make the solutions
##  compatible with the orbit matrix. For the DLX file format, see
##  <Cite Key='DK17'/>. The optional argument <A>opt</A> is a record for 
##  options. Possible components are:
##  <List>
##  <Item><A>UseOrbits</A>:=<C>list</C> Add equations and variables (in 
##  Knuth's terms: items and options) so that at least one of the orbits 
##  given in <C>list</C> must be chosen. This can be used to prune parts 
##  of the search tree leading to isomorphic designs, by using the 
##  normalizer.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MakeDLX" );

#############################################################################
##
#F  MakeDLX2( <filename>, <G>, <tsub>, <ksub>[, <opt>] ) 
##
##  <#GAPDoc Label="MakeDLX2">
##  <ManSection>
##  <Func Name="MakeDLX2" Arg="filename, G, tsub, ksub[, opt]"/>
##
##  <Description>
##  Creates a DLX file <A>filename</A> for the permutation group <A>G</A>, 
##  <M>t</M>-subset and <M>k</M>-subset orbits representatives <A>tsub</A> 
##  and <A>ksub</A>. The orbits must be such that the corresponding 
##  Kramer-Mesner matrix has only <M>0</M>-<M>1</M> entries. The <A>ksub</A>
##  argument may be given as returned by <Ref Func="SubsetOrbitRepOM"/>.
##  In that case additional equations will be added to make the solutions
##  compatible with the orbit matrix. For the DLX file format, see
##  <Cite Key='DK17'/>. The optional argument <A>opt</A> is a record for 
##  options. Possible components are:
##  <List>
##  <Item><A>UseOrbits</A>:=<C>list</C> Add equations and variables (in 
##  Knuth's terms: items and options) so that at least one of the orbits 
##  given in <C>list</C> must be chosen. This can be used to prune parts 
##  of the search tree leading to isomorphic designs, by using the 
##  normalizer.</Item>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
##  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
##  is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MakeDLX2" );

#############################################################################
##
#F  RectifySolutions( <norb>, <list>, <sol> ) 
##
##  <#GAPDoc Label="RectifySolutions">
##  <ManSection>
##  <Func Name="RectifySolutions" Arg="norb, list, sol"/>
##
##  <Description>
##  Make solution(s) <A>sol</A> of a DLX file produced by <Ref Func="MakeDLX"/>
##  with the <C>UseOrbits</C>:=<A>list</A> option compatible with <A>norb</A> 
##  orbits. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "RectifySolutions" );

#############################################################################
##
#F  KramerMesnerMatOM( <G>, <tsub>, <ksub>, <lambda> ) 
##
##  <#GAPDoc Label="KramerMesnerMatOM">
##  <ManSection>
##  <Func Name="KramerMesnerMatOM" Arg="G, tsub, ksub, lambda"/>
##
##  <Description>
##  Returns the Kramer-Mesner matrix for a permutation group <A>G</A> 
##  compatible with an orbit matrix. Rows are labeled by <M>t</M>-subset 
##  orbits <A>tsub</A>. The <M>k</M>-subset orbits <A>ksub</A> labeling 
##  the columns should be given as returned by the function
##  <Ref Func="SubsetOrbitRepOM"/>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMatOM" );

#############################################################################
##
#F  WriteDLX( <filename>, <KM> ) 
##
##  <#GAPDoc Label="WriteDLX">
##  <ManSection>
##  <Func Name="WriteDLX" Arg="filename, KM"/>
##
##  <Description>
##  Write a Kramer-Mesner matrix <A>KM</A> to a file in format suitable
##  for Donald Knuth's DLX3 program <Cite Key='DK17'/>. The matrix must
##  contain only <M>0</M>-<M>1</M> entries, except in the last column.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "WriteDLX" );

#############################################################################
##
#F  CompatibilityMat( <G>, <ksub>, <lin> ) 
##
##  <#GAPDoc Label="CompatibilityMat">
##  <ManSection>
##  <Func Name="CompatibilityMat" Arg="G, ksub, lin"/>
##
##  <Description>
##  Returns the compatibility matrix of the <M>k</M>-subset representatives
##  <A>ksub</A> with respect to the group <A>G</A> and list of intersection 
##  numbers <A>lin</A>. Entries are <M>1</M> if intersection sizes of subsets 
##  in the corresponding <A>G</A>-orbits are all integers in <A>lin</A>, and
##  <M>0</M> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CompatibilityMat" );

#############################################################################
##
#F  ExpandMatRHS( <mat>, <lambda> ) 
##
##  <#GAPDoc Label="ExpandMatRHS">
##  <ManSection>
##  <Func Name="ExpandMatRHS" Arg="mat, lambda"/>
##
##  <Description>
##  Add a column of <A>lambda</A>'s to the right of the matrix <A>mat</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ExpandMatRHS" );

#############################################################################
##
#F  SolveKramerMesner( <mat>[, <cm>][, <opt>] ) 
##
##  <#GAPDoc Label="SolveKramerMesner">
##  <ManSection>
##  <Func Name="SolveKramerMesner" Arg="mat[, cm][, opt]"/>
##
##  <Description>
##  Solve a system of linear equations determined by the matrix <A>mat</A>
##  over <M>\{0,1\}</M>. By default, A.Wassermann's LLL solver <C>solvediophant2</C>
##  <Cite Key='AW21'/> is used. If the second argument is a compatibility
##  matrix <A>cm</A>, the backtracking program <C>solvecm</C> from the papers 
##  <Cite Key='KNP11'/> and <Cite Key='KV16'/> is used. The solver can also
##  be chosen explicitly in the record <A>opt</A>. Possible components are:
##  <List>
##  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
##  <C>solvediophant2</C>. Without <A>cm</A>, this is the default.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>.</Item>
##  <Item><A>Solver</A>:=<C>"solvecm"</C> Use <C>solvecm</C>. This is
##  the default if <A>cm</A> is given.</Item>
##  <Item><A>Solver</A>:=<C>"libexact"</C> Use <C>libexact</C>.
##  This is P. Kaski and  O. Pottonen's implementation of the Dancing Links
##  algorithm, see <Cite Key='KP08'/>. The coefficients of <A>mat</A> must 
##  be in <M>\{0,1\}</M>. Other options are passed to the function 
##  <Ref Func="SolveDLX"/>; see its documentation.</Item>
##  <Item><A>Solver</A>:=<C>"dlx3"</C> / <C>"ssxcc"</C> / <C>"ssxcc-binary"</C> / 
##  <C>"ssmcc"</C>  Use one of D. E. Knuth's implementations of the Dancing 
##  Links or Dancing Cells algorithms; see <Cite Key='DK00'/> and
##  <Cite Key='DK25'/>. The coefficients of <A>mat</A> must be in <M>\{0,1\}</M>.
##  Other options are passed to the function <Ref Func="SolveDLX"/>; see 
##  its documentation.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SolveKramerMesner" );

#############################################################################
##
#F  SolveDLX( <filename>[, <opt>] ) 
##
##  <#GAPDoc Label="SolveDLX">
##  <ManSection>
##  <Func Name="SolveDLX" Arg="filename[, opt]"/>
##
##  <Description>
##  Solve an exact cover problem given in the file <A>filename</A>. 
##  The file must be in Donald Knuth's DLX3 format <Cite Key='DK17'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Solver</A>:=<C>"dlx3"</C> / <C>"ssxcc"</C> / <C>"ssxcc-binary"</C> / 
##  <C>"ssmcc"</C>  If defined, one of D. E. Knuth's implementations of the Dancing 
##  Links or Dancing Cells algorithms is used; see <Cite Key='DK00'/> and
##  <Cite Key='DK25'/>. The default is <C>dlx3</C>.</Item> 
##  <Item><A>M</A>:=<A>n</A>  Set memory option for Knuth's solvers to <C>n</C>.
##  The default is <M>130000000</M>.</Item>
##  <Item><A>Solver</A>:=<C>"libexact"</C> If defined, <C>libexact</C> is used.
##  This is P. Kaski and  O. Pottonen's implementation of the Dancing Links
##  algorithm; see <Cite Key='KP08'/>.</Item>
##  <Item><A>UseOrbits</A>:=<C>list</C> Return only solutions using at least 
##  one of the orbits (or sets of orbits) given in <C>list</C>. This can be 
##  used to prune parts of the search tree leading to isomorphic designs, 
##  using the normalizer.</Item>
##  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Restart solver for eached 
##  of the fixed orbits given in <A>UseOrbits</A>. By default, this is done 
##  only if sets of more than one orbit are fixed. Otherwise the solver is 
##  started once with additional rows and columns for the fixed orbits.</Item>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
##  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
##  is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SolveDLX" );

#############################################################################
##
#F  SolveSteiner( <G>, <tsub>, <ksub>[, <opt>] ) 
##
##  <#GAPDoc Label="SolveSteiner">
##  <ManSection>
##  <Func Name="SolveSteiner" Arg="G, tsub, ksub[, opt]"/>
##
##  <Description>
##  Set up and solve exact cover problem for the permutation group <A>G</A>, 
##  <M>t</M>-subset and <M>k</M>-subset orbits representatives <A>tsub</A> 
##  and <A>ksub</A>. The orbits must be such that the corresponding 
##  Kramer-Mesner matrix has only <M>0</M>-<M>1</M> entries. The <A>ksub</A>
##  argument may be given as returned by <Ref Func="SubsetOrbitRepOM"/>.
##  In that case additional equations will be added to make the solutions
##  compatible with the orbit matrix. The optional argument <A>opt</A> is 
##  a record for options. Possible components are:
##  <List>
##  <Item><A>Solver</A>:=<C>"libexact"</C> If defined, <C>libexact</C> is 
##  used. This is P. Kaski and  O. Pottonen's implementation of the Dancing 
##  Links algorithm, see <Cite Key='KP08'/>.</Item>
##  <Item><A>UseOrbits</A>:=<C>list</C> Add equations and variables (in 
##  Knuth's terms: items and options) so that at least one of the orbits 
##  given in <C>list</C> must be chosen. This can be used to prune parts 
##  of the search tree leading to isomorphic designs, by using the 
##  normalizer. A partition of orbits can also be given in <C>list</C> to
##  avoid multiple solutions and reduce the search tree further.</Item>
##  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Re-create exact cover
##  problem and restart solver for eached of the fixed orbits given in 
##  <A>UseOrbits</A>. By default, the fixed orbits are modelled by adding
##  a single equation (item), duplicatng variables (options) and starting 
##  the solver once. If a partition is given in <A>UseOrbits</A>, iterating
##  is the default.</Item>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C> Report fixing of orbits
##  when iterating and restarting the solver.</Item> 
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SolveSteiner" );

#############################################################################
##
#F  BaseBlocks( <ksub>, <sol> )
##
##  <#GAPDoc Label="BaseBlocks">
##  <ManSection>
##  <Func Name="BaseBlocks" Arg="ksub, sol"/>
##  
##  <Description>
##  Returns base blocks of design(s) from solution(s) <A>sol</A> by picking
##  them from <M>k</M>-subset orbit representatives <A>ksub</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "BaseBlocks" );

#############################################################################
##
#F  OrbitMats( <t>, <v>, <k>, <lambda>, <nu>, <beta> )
##
##  <#GAPDoc Label="OrbitMats">
##  <ManSection>
##  <Func Name="OrbitMats" Arg="t, v, k, lambda, nu, beta"/>
##  
##  <Description>
##  Returns orbit matrices for <M>t</M>-<M>(v,k,lambda)</M> designs
##  with point and block orbit size vectors <A>nu</A> and <A>beta</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMats" );

#############################################################################
##
#F  OrbitMatsWide( <t>, <v>, <k>, <lambda>, <nu>, <beta>[, <opt>] )  
##
##  <#GAPDoc Label="OrbitMatsWide">
##  <ManSection>
##  <Func Name="OrbitMatsWide" Arg="t, v, k, lambda, nu, beta[, opt]"/>
##  
##  <Description>
##  Returns orbit matrices for <M>t</M>-<M>(v,k,lambda)</M> designs
##  with point and block orbit size vectors <A>nu</A> and <A>beta</A>.
##  Uses an algorithm suited for matrices with few rows and many 
##  columns, i.e. short <A>nu</A> and long <A>beta</A>. A.Wassermann's 
##  LLL solver <C>solvediophant2</C> is called. 
##  The function <Ref Func="OrbitMats" Style="Text"/> returns matrices 
##  in canonical form, therefore inequivalent. In contrast, this function 
##  may return equivalent matrices multiple times. This can be changed 
##  by setting options. Possible components of the record <A>opt</A> are:
##  <List>
##  <Item><A>Inequivalent</A>:=<C>true</C>/<C>false</C> If set to <C>true</C>, 
##  equivalent copies of the orbit matrices are eliminated.</Item>
##  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  canonical forms of the orbit matrices are returned.</Item>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
##  <C>solvediophant2</C>. This is the default.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>. 
##  </Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatsWide" );

#############################################################################
##
#F  OrbitMatsWide2( <t>, <v>, <k>, <lambda>, <nu>, <bo>[, <opt>] )  
##
##  <#GAPDoc Label="OrbitMatsWide2">
##  <ManSection>
##  <Func Name="OrbitMatsWide2" Arg="t, v, k, lambda, nu, bo[, opt]"/>
##  
##  <Description>
##  Returns orbit matrices for <M>t</M>-<M>(v,k,lambda)</M> designs
##  with point size vector <A>nu</A> and block orbit sizes from a
##  set of integers <A>bo</A>. Typically, <A>bo</A> contains divisors 
##  of the group order. Uses an algorithm suited for matrices with 
##  few rows (i.e. short <A>nu</A>-vector) and many columns. 
##  A.Wassermann's LLL solver <C>solvediophant2</C> is called. The 
##  function <Ref Func="OrbitMats" Style="Text"/> returns matrices in 
##  canonical form, therefore inequivalent. By default, this function 
##  may return equivalent matrices. This can be changed by setting 
##  options. Possible components of the record <A>opt</A> are:
##  <List>
##  <Item><A>Inequivalent</A>:=<C>true</C>/<C>false</C> If set to <C>true</C>, 
##  equivalent copies of the orbit matrices are eliminated.</Item>
##  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  canonical forms of the orbit matrices are returned.</Item>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
##  <C>solvediophant2</C>. This is the default.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>. 
##  </Item>
##  <Item><A>StopAfter</A>:=<M>n</M> Stop search after <M>n</M> solutions 
##  have been found. By default, the search goes on until all solutions 
##  are found.</Item>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
##  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
##  is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatsWide2" );

#############################################################################
##
#F  ColumnsOM( <g>, <t>, <v>, <k>[, <opt>] )  
##
##  <#GAPDoc Label="ColumnsOM">
##  <ManSection>
##  <Func Name="ColumnsOM" Arg="g, t, v, k[, opt]"/>
##  
##  <Description>
##  Returns candidates for columns of orbit matrices corresponding to
##  Steiner <M>t</M>-<M>(v,k,1)</M> designs with <A>g</A> as group of
##  automorphisms. The optional argument <A>opt</A> is a record for 
##  options with possible components:
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>Bounds</A>:=<C>true</C>/<C>false</C>  With each column 
##  also return an upper bound on how many times it may be used in 
##  the orbit matrix.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ColumnsOM" );

#############################################################################
##
#F  OrbitMatsWide3( <t>, <v>, <k>, <g>[, <opt>] )  
##
##  <#GAPDoc Label="OrbitMatsWide3">
##  <ManSection>
##  <Func Name="OrbitMatsWide3" Arg="t, v, k, g[, opt]"/>
##  
##  <Description>
##  Returns orbit matrices for Steiner <M>t</M>-<M>(v,k,1)</M> designs
##  with <A>g</A> as group of automorphisms. This version computes the
##  point and block orbit sizes, the column candidates and upper bounds
##  on how many times they may be used from the group <A>g</A>. Uses 
##  an algorithm suited for matrices with few rows and many columns. 
##  A.Wassermann's LLL solver <C>solvediophant2</C> is called. The 
##  function <Ref Func="OrbitMats" Style="Text"/> returns matrices in 
##  canonical form, therefore inequivalent. By default, this function 
##  may return equivalent matrices. This can be changed by setting 
##  options. Possible components of the record <A>opt</A> are:
##  <List>
##  <Item><A>Inequivalent</A>:=<C>true</C>/<C>false</C> If set to <C>true</C>, 
##  equivalent copies of the orbit matrices are eliminated.</Item>
##  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  canonical forms of the orbit matrices are returned.</Item>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C>  Print comments
##  reporting the progress of the calculation.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant2"</C> or <C>"sd2"</C> Use 
##  <C>solvediophant2</C>. This is the default.</Item>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>. 
##  </Item>
##  <Item><A>StopAfter</A>:=<M>n</M> Stop search after <M>n</M> solutions 
##  have been found. By default, the search goes on until all solutions 
##  are found.</Item>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
##  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
##  is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatsWide3" );

#############################################################################
##
#F  SubsetOrbitTypes( <g>, <v>, <ksub>, <i> )  
##
##  <#GAPDoc Label="SubsetOrbitTypes">
##  <ManSection>
##  <Func Name="SubsetOrbitTypes" Arg="g, v, ksub, i"/>
##  
##  <Description>
##  Computes the types of index <A>i</A> for the subset orbit
##  representatives <A>ksub</A> under the permutation group 
##  <A>g</A> of degree <A>v</A>. The type information is 
##  returned as a record. The supplied arguments are also 
##  returned as components of the record.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitTypes" );

#############################################################################
##
#F  OrbitMatFilter( <nu>, <beta>, <om>[, <opt>] )  
##
##  <#GAPDoc Label="OrbitMatFilter">
##  <ManSection>
##  <Func Name="OrbitMatFilter" Arg="nu, beta, om[, opt]"/>
##  
##  <Description>
##  Eliminates equivalent copies from a list of orbit matrices <A>om</A>. 
##  All of the matrices should have the same orbit size
##  vectors <A>nu</A> and <A>beta</A>. Two matrices are equivalent if 
##  one can be transformed into the other by row and column permutations 
##  respecting these vectors. Uses <C>nauty/Traces 2.8</C> by B.D.McKay 
##  and A.Piperno <Cite Key='MP14'/>. The optional argument <A>opt</A> 
##  is a record for options. Possible components of <A>opt</A> are:
##  <List>
##  <Item><A>Canonical</A>:=<C>true</C>/<C>false</C> Puts the matrices in
##  canonical form.</Item>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
##  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
##  is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatFilter" );

#############################################################################
##
#F  TDesignB( <t>, <v>, <k>, <lambda> )  
##
##  <#GAPDoc Label="TDesignB">
##  <ManSection>
##  <Func Name="TDesignB" Arg="t, v, k, lambda"/>
##  
##  <Description>
##  The number of blocks of a <A>t</A>-(<A>v</A>,<A>k</A>,<A>lambda</A>) design. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TDesignB" );

#############################################################################
##
#F  OrbitMatDual( <nu>, <beta>, <om> )  
##
##  <#GAPDoc Label="OrbitMatDual">
##  <ManSection>
##  <Func Name="OrbitMatDual" Arg="nu, beta, om"/>
##  
##  <Description>
##  Returns the dual of the orbit matrix <A>om</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatDual" );

#############################################################################
##
#F  OrbitMatRowTest( <v>, <k>, <lambda>, <nu>, <beta>, <om> )  
##
##  <#GAPDoc Label="OrbitMatRowTest">
##  <ManSection>
##  <Func Name="OrbitMatRowTest" Arg="v, k, lambda, nu, beta, om"/>
##  
##  <Description>
##  Computes row products of <A>om</A> and tests if it is an
##  orbit matrix for a <M>2</M>-<M>(v,k,lambda)</M> design. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatRowTest" );

#############################################################################
##
#F  OrbitMatColumnTest( <v>, <k>, <lambda>, <x>, <y>, <nu>, <beta>, <om> )  
##
##  <#GAPDoc Label="OrbitMatColumnTest">
##  <ManSection>
##  <Func Name="OrbitMatColumnTest" Arg="v, k, lambda, x, y, nu, beta, om"/>
##  
##  <Description>
##  Computes column products of <A>om</A> and tests if it is an orbit 
##  matrix for a quasi-symmetric <M>2</M>-<M>(v,k,lambda)</M> design 
##  with intersection numbers <A>x</A> and <A>y</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrbitMatColumnTest" );

#############################################################################
##
#F  IntersectionNumbers( <d>[, <opt>] )  
##
##  <#GAPDoc Label="IntersectionNumbers">
##  <ManSection>
##  <Func Name="IntersectionNumbers" Arg="d[, opt]"/>
##  
##  <Description>
##  Returns the list of intersection numbers of the block design <A>d</A>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components of <A>opt</A> are:
##  <List>
##  <Item><A>Frequencies</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  frequencies of the intersection numbers are also returned.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IntersectionNumbers" );

#############################################################################
##
#F  BlockDesignAut( <d>[, <opt>] )  
##
##  <#GAPDoc Label="BlockDesignAut">
##  <ManSection>
##  <Func Name="BlockDesignAut" Arg="d[, opt]"/>
##  
##  <Description>
##  Computes the full automorphism group of a block design <A>d</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  This is an alternative for the <C>AutGroupBlockDesign</C> function from 
##  the <Package>Design</Package> package <Ref Chap="Automorphism groups and 
##  isomorphism testing for block designs" BookName="DESIGN"/>. The optional 
##  argument <A>opt</A> is a record for options. Possible components 
##  of <A>opt</A> are:
##  <List>
##  <Item><A>Traces</A>:=<C>true</C>/<C>false</C>  Use <C>Traces</C>. 
##  This is the default.</Item>
##  <Item><A>SparseNauty</A>:=<C>true</C>/<C>false</C>  Use <C>nauty</C>
##  for sparse graphs.</Item>
##  <Item><A>DenseNauty</A>:=<C>true</C>/<C>false</C>  Use <C>nauty</C>
##  for dense graphs. This is usually the slowest program, but it allows
##  vertex invariants. Vertex invariants are ignored by the other programs.</Item>
##  <Item><A>BlockAction</A>:=<C>true</C>/<C>false</C>  If set to 
##  <C>true</C>, the action of the automorphisms on blocks is also 
##  given. In this case automorphisms are permutations of degree
##  <M>v+b</M>. By default, only the action on points is given,
##  i.e. automorphisms are permutations of degree <M>v</M>.</Item>
##  <Item><A>Dual</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  dual automorphisms (correlations) are also included. They will 
##  appear only for self-dual symmetric designs (with the same number
##  of points and blocks). The default is <C>false</C>.</Item>
##  <Item><A>PointClasses</A>:=<A>s</A>   Color the points into classes 
##  of size <A>s</A> that cannot be mapped onto each other (for autotopy). 
##  By default, all points are in the same class.</Item>
##  <Item><A>ParatopyClasses</A>:=<A>s</A>   Make point classes of size 
##  <A>s</A> that can be exchanged (for autoparatopy).</Item>
##  <Item><A>VertexInvariant</A>:=<A>n</A>   Use vertex invariant number 
##  <A>n</A>. The numbering is the same as in <C>dreadnaut</C>, e.g. 
##  <A>n</A>=1: <C>twopaths</C>, <A>n</A>=2: <C>adjtriang</C>, etc. The 
##  default is <C>twopaths</C>. Vertex invariants only work with dense
##  <C>nauty</C>. They are ignored by sparse <C>nauty</C> and 
##  <C>Traces</C>.</Item>
##  <Item><A>Mininvarlevel</A>:=<A>n</A>   Set <C>mininvarlevel</C>
##  to <A>n</A>. The default is <A>n</A>=0.</Item>
##  <Item><A>Maxinvarlevel</A>:=<A>n</A>   Set <C>maxinvarlevel</C>
##  to <A>n</A>. The default is <A>n</A>=2.</Item>
##  <Item><A>Invararg</A>:=<A>n</A>   Set <C>invararg</C> to <A>n</A>. 
##  The default is <A>n</A>=0.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "BlockDesignAut" );

#############################################################################
##
#F  HadamardMatAut( <H>[, <opt>] )  
##
##  <#GAPDoc Label="HadamardMatAut">
##  <ManSection>
##  <Func Name="HadamardMatAut" Arg="H[, opt]"/>
##  
##  <Description>
##  Computes the full automorphism group of a Hadamard matrix <A>H</A>.
##  Represents the matrix by a colored graph (see <Cite Key='BM79'/>) and
##  uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible components 
##  of <A>opt</A> are:
##  <List>
##  <Item><A>Dual</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  dual automorphisms (transpositions) are also allowed. The default is 
##  <C>false</C>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "HadamardMatAut" );

#############################################################################
##
#F  MatAut( <M> )  
##
##  <#GAPDoc Label="MatAut">
##  <ManSection>
##  <Func Name="MatAut" Arg="M"/>
##  
##  <Description>
##  Computes the full autotopy group of a matrix <A>M</A>. It is
##  assumed that the entries of <A>M</A> are consecutive integers. 
##  Permutations of rows, columns and symbols are allowed.
##  Represents the matrix by a colored graph and uses 
##  <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MatAut" );

#############################################################################
##
#F  BlockDesignFilter( <dl>[, <opt>] )  
##
##  <#GAPDoc Label="BlockDesignFilter">
##  <ManSection>
##  <Func Name="BlockDesignFilter" Arg="dl[, opt]"/>
##  
##  <Description>
##  Eliminates isomorphic copies from a list of block designs <A>dl</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  This is an alternative for the <C>BlockDesignIsomorphismClassRepresentatives</C> 
##  function from the <Package>Design</Package> package <Ref Chap="Automorphism 
##  groups and isomorphism testing for block designs" BookName="DESIGN"/>. 
##  The optional argument <A>opt</A> is a record for options. Possible components 
##  of <A>opt</A> are:
##  <List>
##  <Item><A>Traces</A>:=<C>true</C>/<C>false</C>  Use <C>Traces</C>. 
##  This is the default.</Item>
##  <Item><A>SparseNauty</A>:=<C>true</C>/<C>false</C>  Use <C>nauty</C>
##  for sparse graphs.</Item>
##  <Item><A>PointClasses</A>:=<A>s</A>   Color the points into classes 
##  of size <A>s</A> that cannot be mapped onto each other (for isotopy). 
##  By default, all points are in the same class.</Item>
##  <Item><A>ParatopyClasses</A>:=<A>s</A>   Make point classes of size 
##  <A>s</A> that can be exchanged (for paratopy).</Item>
##  <Item><A>Positions</A>:=<C>true</C>/<C>false</C> Return positions 
##  of nonisomorphic designs instead of the designs themselves.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "BlockDesignFilter" );

#############################################################################
##
#F  HadamardMatFilter( <hl>[, <opt>] )  
##
##  <#GAPDoc Label="HadamardMatFilter">
##  <ManSection>
##  <Func Name="HadamardMatFilter" Arg="hl[, opt]"/>
##  
##  <Description>
##  Eliminates equivalent copies from a list of Hadamard matrices <A>hl</A>. 
##  Represents the matrices by colored graphs (see <Cite Key='BM79'/>) and
##  uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible components 
##  of <A>opt</A> are:
##  <List>
##  <Item><A>Dual</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, 
##  dual equivalence is allowed (i.e. the matrices can be transposed). The 
##  default is <C>false</C>.</Item>
##  <Item><A>Positions</A>:=<C>true</C>/<C>false</C> Return positions 
##  of inequivalent Hadamard matrices instead of the matrices themselves.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "HadamardMatFilter" );

#############################################################################
##
#F  MatFilter( <ml>[, <opt>] )  
##
##  <#GAPDoc Label="MatFilter">
##  <ManSection>
##  <Func Name="MatFilter" Arg="ml[, opt]"/>
##  
##  <Description>
##  Eliminates equivalent copies from a list of matrices <A>ml</A>. 
##  It is assumed that all of the matrices have the same set of consecutive 
##  integers as entries. Two matrices are equivalent (isotopic) if one can be 
##  transformed into the other by permutating rows, columns and symbols. 
##  Represents the matrices by colored graphs and uses <C>nauty/Traces 2.8</C> 
##  by B.D.McKay and A.Piperno <Cite Key='MP14'/>. The optional argument 
##  <A>opt</A> is a record for options. Possible components of <A>opt</A> are:
##  <List>
##  <Item><A>Positions</A>:=<C>true</C>/<C>false</C> Return positions 
##  of inequivalent matrices instead of the matrices themselves.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MatFilter" );

#############################################################################
##
#F  AllOnesMat( <v>[, <n>] )  
##
##  <#GAPDoc Label="AllOnesMat">
##  <ManSection>
##  <Func Name="AllOnesMat" Arg="v[, n]"/>
##  
##  <Description>
##  Returns the <A>n</A>-dimensional matrix of order <A>v</A> with all
##  entries <M>1</M>. By default, <A>n</A><M>=2</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AllOnesMat" );

#############################################################################
##
#F  Paley1Mat( <q> )  
##
##  <#GAPDoc Label="Paley1Mat">
##  <ManSection>
##  <Func Name="Paley1Mat" Arg="q"/>
##  
##  <Description>
##  Returns a Paley type I Hadamard matrix of order <M><A>q</A>+1</M> constructed 
##  from the squares in <M>GF(<A>q</A>)</M>. The argument should be a prime power 
##  <M><A>q</A>\equiv 3 \pmod{4}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Paley1Mat" );

#############################################################################
##
#F  Paley2Mat( <q> )  
##
##  <#GAPDoc Label="Paley2Mat">
##  <ManSection>
##  <Func Name="Paley2Mat" Arg="q"/>
##  
##  <Description>
##  Returns a Paley type II Hadamard matrix of order <M>2(<A>q</A>+1)</M> 
##  constructed from the squares in <M>GF(<A>q</A>)</M>. The argument should 
##  be a prime power <M><A>q</A>\equiv 1 \pmod{4}</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Paley2Mat" );

#############################################################################
##
#F  Paley3DMat( <v> )  
##
##  <#GAPDoc Label="Paley3DMat">
##  <ManSection>
##  <Func Name="Paley3DMat" Arg="v"/>
##  
##  <Description>
##  Returns a three-dimensional Hadamard matrix of order <A>v</A> obtained by 
##  the Paley-like construction introduced in <Cite Key='KPT23b'/>. The argument 
##  should be an even number <A>v</A> such that <M><A>v</A>-1</M> is a prime 
##  power.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Paley3DMat" );

#############################################################################
##
#F  HadamardToIncidence( <M> )  
##
##  <#GAPDoc Label="HadamardToIncidence">
##  <ManSection>
##  <Func Name="HadamardToIncidence" Arg="M"/>
##  
##  <Description>
##  Transforms the Hadamard matrix <A>M</A> to an incidence matrix by
##  replacing all <M>-1</M> entries by <M>0</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "HadamardToIncidence" );

#############################################################################
##
#F  IncidenceToHadamard( <M> )  
##
##  <#GAPDoc Label="IncidenceToHadamard">
##  <ManSection>
##  <Func Name="IncidenceToHadamard" Arg="M"/>
##  
##  <Description>
##  Transforms the incidence matrix <A>M</A> to a <M>(1,-1)</M>-matrix 
##  by replacing all <M>0</M> entries by <M>-1</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IncidenceToHadamard" );

#############################################################################
##
#F  ProductConstructionMat( <H>, <n> )  
##
##  <#GAPDoc Label="ProductConstructionMat">
##  <ManSection>
##  <Func Name="ProductConstructionMat" Arg="H, n"/>
##  
##  <Description>
##  Given a <M>2</M>-dimensional Hadamard matrix <A>H</A>, returns the 
##  <A>n</A>-dimensional proper Hadamard matrix obtained by the product
##  construction of Yang <Cite Key='YXY86'/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ProductConstructionMat" );

#############################################################################
##
#F  DigitConstructionMat( <H>, <s> )  
##
##  <#GAPDoc Label="DigitConstructionMat">
##  <ManSection>
##  <Func Name="DigitConstructionMat" Arg="H, s"/>
##  
##  <Description>
##  Given a <M>2</M>-dimensional Hadamard matrix <A>H</A> of order 
##  <M>(2t)^s</M>, returns the <M>2s</M>-dimensional Hadamard matrix 
##  of order <M>2t</M>  obtained by Theorem 6.1.4 of <Cite Key='YNX10'/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DigitConstructionMat" );

#############################################################################
##
#F  CyclicDimensionIncrease( <H> )  
##
##  <#GAPDoc Label="CyclicDimensionIncrease">
##  <ManSection>
##  <Func Name="CyclicDimensionIncrease" Arg="H"/>
##  
##  <Description>
##  Given an <M>n</M>-dimensional Hadamard matrix <A>H</A>, returns the 
##  <M>(n+1)</M>-dimensional Hadamard matrix obtained by Theorem 6.1.5
##  of <Cite Key='YNX10'/>. The construction also works for cubes of 
##  symmetric designs of propriety <M>n</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CyclicDimensionIncrease" );

#############################################################################
##
#F  LatinSquareDimensionIncrease( <H>, <ls> )  
##
##  <#GAPDoc Label="LatinSquareDimensionIncrease">
##  <ManSection>
##  <Func Name="LatinSquareDimensionIncrease" Arg="H, ls"/>
##  
##  <Description>
##  Given an <M>n</M>-dimensional Hadamard matrix <A>H</A> of order <M>v</M>, 
##  returns the <M>(n+1)</M>-dimensional Hadamard matrix of order <M>v</M>
##  obtained by a generalization of <Cite Key='YNX10'/>, Theorem 6.1.5. 
##  A Latin square <A>ls</A> of order <M>v</M> is used instead of addition
##  modulo <M>v</M>. The construction also works for cubes of symmetric 
##  designs of propriety <M>n</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LatinSquareDimensionIncrease" );

#############################################################################
##
#F  IsHadamardMat( <H> )  
##
##  <#GAPDoc Label="IsHadamardMat">
##  <ManSection>
##  <Func Name="IsHadamardMat" Arg="H"/>
##  
##  <Description>
##  Returns <C>true</C> if <A>H</A> is an <M>n</M>-dimensional Hadamard
##  matrix and <C>false</C> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsHadamardMat" );

#############################################################################
##
#F  IsProperHadamardMat( <H> )  
##
##  <#GAPDoc Label="IsProperHadamardMat">
##  <ManSection>
##  <Func Name="IsProperHadamardMat" Arg="H"/>
##  
##  <Description>
##  Returns <C>true</C> if <A>H</A> is a proper <M>n</M>-dimensional 
##  Hadamard matrix and <C>false</C> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsProperHadamardMat" );

#############################################################################
##
#F  BlockScheme( <d>[, <opt>] )  
##
##  <#GAPDoc Label="BlockScheme">
##  <ManSection>
##  <Func Name="BlockScheme" Arg="d[, opt]"/>
##  
##  <Description>
##  Returns the block intersection association scheme of a block design 
##  <A>d</A>, or <C>fail</C> if <A>d</A> is not block schematic. 
##  The optional argument <A>opt</A> is a record for options. If 
##  it contains the component <A>Matrix</A>:=<C>true</C>, the 
##  block intersection matrix is returned instead. 
##  Uses the package <Package>AssociationSchemes</Package>. If the 
##  package is not available, <C>BlockScheme</C> always returns the 
##  block intersection matrix and does not check if it defines an 
##  association scheme.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "BlockScheme" );

#############################################################################
##
#F  PointPairScheme( <d>[, <opt>] )  
##
##  <#GAPDoc Label="PointPairScheme">
##  <ManSection>
##  <Func Name="PointPairScheme" Arg="d[, opt]"/>
##  
##  <Description>
##  Returns the point pair association scheme of a block design <A>d</A>, 
##  or <C>fail</C> if <A>d</A> is not point pair schematic. The optional 
##  argument <A>opt</A> is a record for options. If it contains the component 
##  <A>Matrix</A>:=<C>true</C>, the point pair inclusion matrix is returned 
##  instead. The point pair scheme was defined by Cameron <Cite Key='PC75'/> 
##  for Steiner <M>3</M>-designs. This command is a slight generalisation 
##  that works for arbitrary designs.
##  Uses the package <Package>AssociationSchemes</Package>. If the 
##  package is not available, <C>PointPairScheme</C> always returns the 
##  point pair inclusion matrix and does not check if it defines an 
##  association scheme.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PointPairScheme" );

#############################################################################
##
#F  KramerMesnerSearch( <t>, <v>, <k>, <lambda>, <G>[, <opt>] )
##
##  <#GAPDoc Label="KramerMesnerSearch">
##  <ManSection>
##  <Func Name="KramerMesnerSearch" Arg="t, v, k, lambda, G[, opt]"/>
##  
##  <Description>
##  Performs a search for <A>t</A>-(<A>v</A>,<A>k</A>,<A>lambda</A>) designs
##  with prescribed automorphism group <A>G</A> by the Kramer-Mesner method.
##  A record with options can be supplied. By default, designs are returned 
##  in the <Package>Design</Package> package format 
##  <Ref Chap="Design" BookName="DESIGN"/> and isomorph-rejection is performed
##  by calling <Ref Func="BlockDesignFilter" Style="Text"/>. It can be turned
##  off by setting <A>opt.NonIsomorphic</A>:=<C>false</C>. By setting 
##  <A>opt.BaseBlocks</A>:=<C>true</C>, base blocks are returned instead
##  of designs. This automatically turns off isomorph-rejection. Other available 
##  options are:
##  <List>
##  <Item><A>SmallLambda</A>:=<C>true</C>/<C>false</C>. Perform the <Q>small 
##  lambda filter</Q>, i.e. remove <A>k</A>-orbits covering some of the 
##  <A>t</A>-orbits more than  <A>lambda</A> times. By default, this is 
##  done if <A>lambda</A>&lt;=3.</Item>
##  <Item><A>IntersectionNumbers</A>:=<A>lin</A>/<C>false</C>. Search
##  for designs with block intersection nubers in the list of integers
##  <A>lin</A> (e.g. quasi-symmetric designs).</Item>
##  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
##  and use inequivalent orbits as the first choice, to reduce the number
##  of isomorphic designs and speed-up the computation.</Item>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C> Print information on 
##  the progress of the computation.</Item>
##  </List>
##  Other options, such as <A>Solver</A>, are passed to the function
##  <Ref Func="SolveKramerMesner" Style="Text"/>; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerSearch" );

#############################################################################
##
#F  SteinerSearchOld( <t>, <v>, <ksub>, <G>[, <opt>] )
##
##  <#GAPDoc Label="SteinerSearchOld">
##  <ManSection>
##  <Func Name="SteinerSearchOld" Arg="t, v, ksub, G[, opt]"/>
##  
##  <Description>
##  Performs a search for Steiner <A>t</A>-designs with prescribed automorphism 
##  group <A>G</A> and blocks from the subset orbit representatives <A>ksub</A>.
##  They may be given in format returned by the <Ref Func="SubsetOrbitRepOM"/>
##  function. The point set is <C>[1..</C><A>v</A><C>]</C>. A record <A>opt</A> 
##  with options can be supplied and will be passed to the function 
##  <Ref Func="SolveSteiner"/>; see its documentation. This old version uses
##  the <C>libexact</C> solver, P. Kaski and  O. Pottonen's implementation 
##  of the Dancing Links algorithm <Cite Key='KP08'/>. It does not use DLX 
##  files to communicate with the solver.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SteinerSearchOld" );

#############################################################################
##
#F  SteinerSearch( <t>, <v>, <ksub>, <G>[, <opt>] )
##
##  <#GAPDoc Label="SteinerSearch">
##  <ManSection>
##  <Func Name="SteinerSearch" Arg="t, v, ksub, G[, opt]"/>
##  
##  <Description>
##  Performs a search for Steiner <A>t</A>-designs with prescribed automorphism 
##  group <A>G</A> and blocks from the subset orbit representatives <A>ksub</A>.
##  The orbits may be given in format returned by the <Ref Func="SubsetOrbitRepOM"/>
##  function. The point set is <C>[1..</C><A>v</A><C>]</C>. A record <A>opt</A> 
##  with options can be supplied: 
##  <List>
##  <Item><A>Verbose</A>:=<C>true</C>/<C>false</C> Print information on 
##  the progress of the computation. The default is <C>false</C>.</Item>
##  <Item><A>NonIsomorphic</A>:=<C>true</C>/<C>false</C> Reject isomorphic
##  designs by calling <Ref Func="BlockDesignFilter" Style="Text"/> at the
##  end. The default is <C>true</C>.</Item>
##  <Item><A>Time</A>:=<C>true</C>/<C>false</C> Print date and time before
##  and after calling the solver. Uses the shell command <C>date</C>.
##  The default is <C>false</C>.</Item>
##  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
##  and use inequivalent orbits as the first choice, to reduce the number
##  of isomorphic designs and speed-up the computation. This can also be 
##  achieved "manually" by setting the <A>UseOrbits</A> option. The default 
##  is <C>false</C>.</Item>
##  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Compute partition of 
##  orbits into equivalence classes under the normalizer and use the 
##  exact-cover-with-colors approach. The default is <C>true</C> if the 
##  <A>Normalizer</A> option is also set.</Item>
##  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Call the solver
##  separately for every inequivalent orbit under the normalizer,
##  instead of modifying the exact cover problem. The default is 
##  <C>false</C>.</Item>
##  <Item><A>TempDir</A>:=<C>"dir_name"</C> Put all temporary files in
##  the named directory. By default, <C>PAGGlobalOptions.TempDir</C>
##  is used.</Item>
##  </List>
##  The <A>TempDir</A> option and some other options are also forwarded 
##  to <Ref Func="MakeDLX2" Style="Text"/> (<A>UseOrbits</A>) and 
##  <Ref Func="SolveDLX" Style="Text"/> (<A>Solver</A>, <A>M</A>). See 
##  the documentation of these functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SteinerSearch" );

#############################################################################
##
#F  ExtendSteinerDesign( <d>[, <opt>] )
##
##  <#GAPDoc Label="ExtendSteinerDesign">
##  <ManSection>
##  <Func Name="ExtendSteinerDesign" Arg="d[, opt]"/>
##  
##  <Description>
##  Performs a search for extensions of a Steiner design <A>d</A>.
##  By default, the extended designs are assumed to be invariant under
##  the full automorphism group of <A>d</A>. This can be changed by
##  setting options in the record <A>opt</A>. Possible components are:
##  <List>
##  <Item><A>Group</A>:= <C>g</C> (permutation group) or <C>n</C> (integer).
##  If a permutation group <C>g</C> is given, it will be used for the
##  search. If an integer <C>n</C> is given, the <C>n</C>-th subgroup
##  of the full automorphism group of <A>d</A> will be used. Here 
##  <C>n</C><M>=1</M> means the full automorhism group, <C>n</C><M>=2</M> 
##  means the second largest subgroup etc. The subgroups are taken in 
##  reverse order from the list returned by
##  <C>AllSubgroupsConjugation( BlockDesignAut( </C><A>d</A><C> ) )</C>.
##  Furthermore, <C>n</C><M>=0</M> means the trivial group.
##  </Item>
##  <Item><A>MinGroupSize</A>:=<C>n</C>  Extend using subgroups of 
##  size at least <C>n</C> of the automorphism group of <A>d</A>. 
##  Examine the subgroups in descending order until extensions are
##  found or all subgroups are exhausted.</Item>
##  <Item><A>MaxGroupSize</A>:=<C>n</C>  Extend using subgroups of 
##  size at most <C>n</C> of the automorphism group of <A>d</A>.
##  Examine the subgroups in descenting order until extensions are
##  found or all subgroups are exhausted.</Item>
##  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
##  and use inequivalent orbits as the first choice, to reduce the number
##  of isomorphic designs and speed-up the computation.</Item>
##  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Compute partition of 
##  orbits into equivalence classes under the normalizer and use the 
##  exact-cover-with-colors approach. The default is <C>true</C> if the 
##  <A>Normalizer</A> option is also set to <C>true</C>.</Item>
##  <Item><A>Iterate</A>:=<C>true</C>/<C>false</C> Call the solver
##  separately for every inequivalent orbit under the normalizer,
##  instead of modifying the exact cover problem. The default is 
##  <C>false</C>.</Item>
##  <Item><A>Time</A>:=<C>true</C>/<C>false</C> Print date and time before
##  and after calling the solver. Uses the shell command <C>date</C>.
##  The default is <C>false</C>.</Item>
##  <Item><A>NonIsomorphic</A>:=<C>true</C>/<C>false</C> Reject isomorphic
##  designs by calling <Ref Func="BlockDesignFilter" Style="Text"/> at the
##  end. The default is <C>true</C>.</Item>
##  </List>
##  Other options such as <A>Verbose</A>, <A>Solver</A>, <A>M</A>,  
##  <A>Iterate</A>, and <A>TempDir</A> are passed to the functions
##  <Ref Func="MakeDLX2" Style="Text"/> and 
##  <Ref Func="SolveDLX" Style="Text"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ExtendSteinerDesign" );

#############################################################################
##
#F  ExtendSteinerBlocks( <t>, <v>, <d>[, <opt>] )
##
##  <#GAPDoc Label="ExtendSteinerBlocks">
##  <ManSection>
##  <Func Name="ExtendSteinerBlocks" Arg="t, v, d[, opt]"/>
##  
##  <Description>
##  Performs a search for Steiner <A>t</A>-designs containing a set of 
##  blocks <A>d</A>. The blocks should be given in <Package>Design</Package> 
##  package format. If the argument <A>v</A> is equal to <A>d</A><C>.v</C>,
##  the designs are assumed to be invariant under the full automorphism group 
##  of <A>d</A>. This can be changed by setting options in the record <A>opt</A>. 
##  If the argument <A>v</A> is greater than <A>d</A><C>.v</C>, a permutation
##  group should be given by the <A>Group</A> option. Possible components of 
##  <A>opt</A> are:
##  <List>
##  <Item><A>Group</A>:= <C>g</C> (permutation group) or <C>n</C> (integer).
##  If a permutation group <C>g</C> is given, it will be used for the
##  search. If an integer <C>n</C> is given, the <C>n</C>-th subgroup
##  of the full automorphism group of <A>d</A> will be used. Here 
##  <C>n</C><M>=1</M> means the full automorhism group, <C>n</C><M>=2</M> 
##  means the second largest subgroup etc. The subgroups are taken in 
##  reverse order from the list returned by
##  <C>AllSubgroupsConjugation( BlockDesignAut( </C><A>d</A><C> ) )</C>.
##  Furthermore, <C>n</C><M>=0</M> means the trivial group.
##  </Item>
##  <Item><A>BlockCandidates</A>:=<C>ksub</C>  Use list of 
##  <M>k</M>-subsets <C>ksub</C> as block candidates and return the
##  compatible ones. If this option is not given, all <M>k</M>-subsets 
##  of <C>[1..</C><A>v</A><C>]</C> (or the corresponding orbit 
##  representatives) are used and a search for extensions is
##  performed.</Item>
##  <Item><A>MinGroupSize</A>:=<C>n</C>  Extend using subgroups of 
##  size at least <C>n</C> of the automorphism group of <A>d</A>. 
##  Examine the subgroups in descending order until extensions are
##  found or all subgroups are exhausted.</Item>
##  <Item><A>MaxGroupSize</A>:=<C>n</C>  Extend using subgroups of 
##  size at most <C>n</C> of the automorphism group of <A>d</A>.
##  Examine the subgroups in descenting order until extensions are
##  found or all subgroups are exhausted.</Item>
##  <Item><A>Normalizer</A>:=<C>true</C>/<C>false</C> Compute the normalizer 
##  and use inequivalent orbits as the first choice, to reduce the number
##  of isomorphic designs and speed-up the computation.</Item>
##  <Item><A>Partition</A>:=<C>true</C>/<C>false</C> Compute partition of 
##  orbits into equivalence classes under the normalizer and use the 
##  exact-cover-with-colors approach. The default is <C>true</C> if the 
##  <A>Normalizer</A> option is also set to <C>true</C>.</Item>
##  <Item><A>Time</A>:=<C>true</C>/<C>false</C> Print date and time before
##  and after calling the solver. Uses the shell command <C>date</C>.
##  The default is <C>false</C>.</Item>
##  <Item><A>NonIsomorphic</A>:=<C>true</C>/<C>false</C> Reject isomorphic
##  designs by calling <Ref Func="BlockDesignFilter" Style="Text"/> at the
##  end. The default is <C>true</C>.</Item>
##  </List>
##  Other options such as <A>Verbose</A>, <A>Solver</A>, <A>M</A>,  
##  <A>Iterate</A>, and <A>TempDir</A> are passed to the functions
##  <Ref Func="MakeDLX2" Style="Text"/> and 
##  <Ref Func="SolveDLX" Style="Text"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ExtendSteinerBlocks" );

#############################################################################
##
#F  ReadMOLS( <filename> ) 
##
##  <#GAPDoc Label="ReadMOLS">
##  <ManSection>
##  <Func Name="ReadMOLS" Arg="filename"/>
##
##  <Description>
##  Read a list of MOLS sets from a file. The file starts with the number
##  of rows <M>m</M>, columns <M>n</M>, and the size of the sets <M>s</M>,
##  followed by the matrix entries. Integers in the file are separated 
##  by whitespaces.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ReadMOLS" );

#############################################################################
##
#F  WriteMOLS( <filename>, <list> ) 
##
##  <#GAPDoc Label="WriteMOLS">
##  <ManSection>
##  <Func Name="WriteMOLS" Arg="filename, list"/>
##
##  <Description>
##  Write a list of MOLS sets to a file. The number of rows <M>m</M>,
##  columns <M>n</M>, and the size of the sets <M>s</M> is written first, 
##  followed by the matrix entries. Integers are separated by whitespaces.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "WriteMOLS" );

#############################################################################
##
#F  MOLSToOrthogonalArray( <ls> ) 
##
##  <#GAPDoc Label="MOLSToOrthogonalArray">
##  <ManSection>
##  <Func Name="MOLSToOrthogonalArray" Arg="ls"/>
##
##  <Description>
##  Transforms the set of MOLS <A>ls</A> to an equivalent orthogonal array.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MOLSToOrthogonalArray" );

#############################################################################
##
#F  OrthogonalArrayToMOLS( <oa> ) 
##
##  <#GAPDoc Label="OrthogonalArrayToMOLS">
##  <ManSection>
##  <Func Name="OrthogonalArrayToMOLS" Arg="oa"/>
##
##  <Description>
##  Transforms the orthogonal array <A>oa</A> to an equivalent set of MOLS.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayToMOLS" );

#############################################################################
##
#F  MOLSToTransversalDesign( <ls> ) 
##
##  <#GAPDoc Label="MOLSToTransversalDesign">
##  <ManSection>
##  <Func Name="MOLSToTransversalDesign" Arg="ls"/>
##
##  <Description>
##  Transforms the set of MOLS <A>ls</A> to an equivalent transversal design.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MOLSToTransversalDesign" );

#############################################################################
##
#F  TransversalDesignToMOLS( <td> ) 
##
##  <#GAPDoc Label="TransversalDesignToMOLS">
##  <ManSection>
##  <Func Name="TransversalDesignToMOLS" Arg="td"/>
##
##  <Description>
##  Transforms the transversal design <A>td</A> to an equivalent set of MOLS.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TransversalDesignToMOLS" );

#############################################################################
##
#F  MOLSAut( <ls>[, <opt>] ) 
##
##  <#GAPDoc Label="MOLSAut">
##  <ManSection>
##  <Func Name="MOLSAut" Arg="ls[, opt]"/>
##
##  <Description>
##  Computes the full auto(para)topy group of a set of MOLS <A>ls</A>.
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Compute the full autotopy
##  group of <A>ls</A>. This is the default.</Item>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Compute the full
##  autoparatopy group of <A>ls</A>.</Item>
##  </List>
##  Any other components are forwarded to the <Ref Func="BlockDesignAut" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MOLSAut" );

#############################################################################
##
#F  MOLSFilter( <ls>[, <opt>] )  
##
##  <#GAPDoc Label="MOLSFilter">
##  <ManSection>
##  <Func Name="MOLSFilter" Arg="ls[, opt]"/>
##  
##  <Description>
##  Eliminates isotopic/paratopic copies from a list of MOLS sets <A>ls</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic MOLS sets. 
##  This is the default.</Item>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic MOLS sets.</Item>
##  </List>
##  Any other components are forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MOLSFilter" );

#############################################################################
##
#F  FieldToMOLS( <F> ) 
##
##  <#GAPDoc Label="FieldToMOLS">
##  <ManSection>
##  <Func Name="FieldToMOLS" Arg="F"/>
##
##  <Description>
##  Construct a complete set of MOLS from the finite field <A>F</A>.
##  A similar function is <Ref Func="MOLS" BookName="Guava"/> from 
##  the package <Package>Guava</Package>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "FieldToMOLS" );

#############################################################################
##
#F  IsAutotopyGroup( <n>, <s>, <G> ) 
##
##  <#GAPDoc Label="IsAutotopyGroup">
##  <ManSection>
##  <Func Name="IsAutotopyGroup" Arg="n, s, G"/>
##
##  <Description>
##  Check if <A>G</A> is an autotopy group for transversal designs with
##  <A>s</A><M>+2</M> point classes of order <A>n</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsAutotopyGroup" );

#############################################################################
##
#F  MOLSSubsetOrbitRep( <n>, <s>, <G> ) 
##
##  <#GAPDoc Label="MOLSSubsetOrbitRep">
##  <ManSection>
##  <Func Name="MOLSSubsetOrbitRep" Arg="n, s, G"/>
##
##  <Description>
##  Computes representatives of pairs and transversals of the <A>s</A><M>+2</M>
##  point classes for the construction of MOLS of order <A>n</A> with prescribed autotopy
##  group <A>G</A>. A list containing pair representatives in the first component and 
##  transversal representatives in the second component is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MOLSSubsetOrbitRep" );

#############################################################################
##
#F  KramerMesnerMOLS( <n>, <s>, <G>[, <opt>] ) 
##
##  <#GAPDoc Label="KramerMesnerMOLS">
##  <ManSection>
##  <Func Name="KramerMesnerMOLS" Arg="n, s, G[, opt]"/>
##
##  <Description>
##  If the function <Ref Func="IsAutotopyGroup"/>(<A>G</A>) returns <C>true</C>
##  for the group <A>G</A>, call <Ref Func="KramerMesnerMOLSAutotopy"/>; otherwise 
##  call <Ref Func="KramerMesnerMOLSAutoparatopy"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMOLS" );

#############################################################################
##
#F  KramerMesnerMOLSAutotopy( <n>, <s>, <G>[, <opt>] ) 
##
##  <#GAPDoc Label="KramerMesnerMOLSAutotopy">
##  <ManSection>
##  <Func Name="KramerMesnerMOLSAutotopy" Arg="n, s, G[, opt]"/>
##
##  <Description>
##  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
##  autotopy group <A>G</A>. By default, A.Wassermann's LLL solver 
##  <C>solvediophant</C> is used for <A>s</A><M>=1</M>, and the backtracking
##  solver <C>solvecm</C> is used for <A>s</A><M>&gt;1</M>. This can be changed
##  by setting options in the record <A>opt</A>. Available options are:
##  <List>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>.</Item>
##  <Item><A>Solver</A>:=<C>"solvecm"</C> Use <C>solvecm</C>.</Item>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic solutions. 
##  This is the default.</Item>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic solutions.
##  All solutions are returned if either option is set to <C>false</C>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMOLSAutotopy" );

#############################################################################
##
#F  KramerMesnerMOLSAutoparatopy( <n>, <s>, <G>[, <opt>] ) 
##
##  <#GAPDoc Label="KramerMesnerMOLSAutoparatopy">
##  <ManSection>
##  <Func Name="KramerMesnerMOLSAutoparatopy" Arg="n, s, G[, opt]"/>
##
##  <Description>
##  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
##  autoparatopy group <A>G</A>. By default, A.Wassermann's LLL solver 
##  <C>solvediophant</C> is used for <A>s</A><M>=1</M>, and the backtracking
##  solver <C>solvecm</C> is used for <A>s</A><M>&gt;1</M>. This can be changed
##  by setting options in the record <A>opt</A>. Available options are:
##  <List>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> Use <C>solvediophant</C>.</Item>
##  <Item><A>Solver</A>:=<C>"solvecm"</C> Use <C>solvecm</C>.</Item>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic solutions. 
##  This is the default.</Item>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic solutions.
##  All solutions are returned if either option is set to <C>false</C>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMOLSAutoparatopy" );

#############################################################################
##
#F  RightDevelopment( <G>, <ds> ) 
##
##  <#GAPDoc Label="RightDevelopment">
##  <ManSection>
##  <Func Name="RightDevelopment" Arg="G, ds"/>
##
##  <Description>
##  Returns a block design that is the development of the difference 
##  set <A>ds</A> by right multiplication in the group <A>G</A>.
##  If <A>ds</A> is a tiling of the group <A>G</A> or a list of disjoint 
##  difference sets, a mosaic of symmetric designs is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "RightDevelopment" );

#############################################################################
##
#F  LeftDevelopment( <G>, <ds> ) 
##
##  <#GAPDoc Label="LeftDevelopment">
##  <ManSection>
##  <Func Name="LeftDevelopment" Arg="G, ds"/>
##
##  <Description>
##  Returns a block design that is the development of the difference 
##  set <A>ds</A> by left multiplication in the group <A>G</A>.
##  If <A>ds</A> is a tiling of the group <A>G</A> or a list of disjoint 
##  difference sets, a mosaic of symmetric designs is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LeftDevelopment" );

#############################################################################
##
#F  CameronSeidelSet( <m> ) 
##
##  <#GAPDoc Label="CameronSeidelSet">
##  <ManSection>
##  <Func Name="CameronSeidelSet" Arg="m"/>
##
##  <Description>
##  Returns a list of <M>2^{m/2}</M> symplectic <M>m\times m</M> matrices 
##  over <M>GF(2)</M> such that the difference of any two of them is
##  a regular matrix. Here <A>m</A> is an even integer. The construction
##  is described on page 6 of the paper <Cite Key='CS73'/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CameronSeidelSet" );

#############################################################################
##
#F  OrthogonalNormalBasis( <k> ) 
##
##  <#GAPDoc Label="OrthogonalNormalBasis">
##  <ManSection>
##  <Func Name="OrthogonalNormalBasis" Arg="k"/>
##
##  <Description>
##  Attempts to find a basis for the field <M>GF(2^k)</M> over <M>GF(2)</M>
##  that is orthogonal with respect to the trace inner product <M>Tr(xy)</M>.
##  This should work for odd integers <A>k</A>, but might fail for even
##  integers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalNormalBasis" );

#############################################################################
##
#F  KerdockSet( <m> ) 
##
##  <#GAPDoc Label="KerdockSet">
##  <ManSection>
##  <Func Name="KerdockSet" Arg="m"/>
##
##  <Description>
##  Returns a Kerdock set of <M>2^{m-1}</M> symplectic <M>m\times m</M> matrices 
##  over <M>GF(2)</M> such that the difference of any two of them is a regular 
##  matrix. Here <A>m</A> is an even integer. The construction is based on
##  Example 2.4 in the paper <Cite Key='WK95'/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KerdockSet" );

#############################################################################
##
#F  SingerDifferenceSets( <q>, <n> ) 
##
##  <#GAPDoc Label="SingerDifferenceSets">
##  <ManSection>
##  <Func Name="SingerDifferenceSets" Arg="q, n"/>
##
##  <Description>
##  Returns the classical Singer difference sets in the cyclic group
##  of order <M>v=(q^n-1)/(q-1)</M>, e.g. <C>Group(CyclicPerm(v))</C>.
##  The difference sets are subsets of <C>[1..v]</C> to make them compatible
##  with the <Package>DifSets</Package> package. For each <M>D</M> returned,
##  <M>D-1</M> is a difference set in the integers modulo <M>v</M> (a subset
##  of <C>[0..v-1]</C>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SingerDifferenceSets" );

#############################################################################
##
#F  NormalizedSingerDifferenceSets( <q>, <n> ) 
##
##  <#GAPDoc Label="NormalizedSingerDifferenceSets">
##  <ManSection>
##  <Func Name="NormalizedSingerDifferenceSets" Arg="q, n"/>
##
##  <Description>
##  Returns the classical Singer difference sets in the cyclic group
##  of order <M>v=(q^n-1)/(q-1)</M> that are normalized. If <M>D</M>
##  is a difference set, this means that the elements of 
##  <M>D-1</M> sum up to <M>0</M> modulo <M>v</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "NormalizedSingerDifferenceSets" );

#############################################################################
##
#F  PaleyDifferenceSet( <q> ) 
##
##  <#GAPDoc Label="PaleyDifferenceSet">
##  <ManSection>
##  <Func Name="PaleyDifferenceSet" Arg="q"/>
##
##  <Description>
##  Returns the <A>q</A>-dimensional Paley difference set in <M>GF(q)</M>.
##  This is a <M>(q,(q-1)/2,(q-3)/4)</M> difference set in the additive 
##  group of <M>GF(q)</M>. See <Cite Key='KR24'/> for more details.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PaleyDifferenceSet" );

#############################################################################
##
#F  PowerDifferenceSet( <q>, <m> ) 
##
##  <#GAPDoc Label="PowerDifferenceSet">
##  <ManSection>
##  <Func Name="PowerDifferenceSet" Arg="q, m"/>
##
##  <Description>
##  Returns the <A>q</A>-dimensional difference set constructed from
##  the <A>m</A>-th powers in <M>GF(q)</M>. Paley difference sets are
##  power difference sets for <M>m=2</M>. See <Cite Key='KR24'/> for
##  more details.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PowerDifferenceSet" );

#############################################################################
##
#F  TwinPrimePowerDifferenceSet( <q> ) 
##
##  <#GAPDoc Label="TwinPrimePowerDifferenceSet">
##  <ManSection>
##  <Func Name="TwinPrimePowerDifferenceSet" Arg="q"/>
##
##  <Description>
##  Returns the <A>q</A>-dimensional twin prime power difference set. 
##  For <M>n=(q+1)^2/4</M>, this is a <M>(4n-1,2n-1,n-1)</M> difference 
##  set in the direct product <M>GF(q)\times GF(q+2)</M>. Both <A>q</A> 
##  and <A>q</A><M>+2</M> must be powers of primes. See <Cite Key='KR24'/> 
##  for more details.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TwinPrimePowerDifferenceSet" );

#############################################################################
##
#F  EquivalentDifferenceSets( <g>, <D> ) 
##
##  <#GAPDoc Label="EquivalentDifferenceSets">
##  <ManSection>
##  <Func Name="EquivalentDifferenceSets" Arg="g, D"/>
##
##  <Description>
##  Given a difference set or list of difference sets <A>D</A>
##  in a group <A>g</A>, returns the set of all difference sets 
##  equivalent to the ones in <A>D</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "EquivalentDifferenceSets" );

#############################################################################
##
#F  IversonBracket( <P> ) 
##
##  <#GAPDoc Label="IversonBracket">
##  <ManSection>
##  <Func Name="IversonBracket" Arg="P"/>
##
##  <Description>
##  Returns 1 if <A>P</A> is true, and 0 otherwise. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IversonBracket" );

#############################################################################
##
#F  SymmetricDifference( <X>, <Y> ) 
##
##  <#GAPDoc Label="SymmetricDifference">
##  <ManSection>
##  <Func Name="SymmetricDifference" Arg="X, Y"/>
##
##  <Description>
##  Returns the symmetric difference of two sets <A>X</A> and <A>Y</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SymmetricDifference" );

#############################################################################
##
#F  AddWeights( <wd> ) 
##
##  <#GAPDoc Label="AddWeights">
##  <ManSection>
##  <Func Name="AddWeights" Arg="wd"/>
##
##  <Description>
##  Makes a weight distribudion <A>wd</A> more readable by adding the weights
##  and skipping zero components. The argument <A>wd</A> is the weight
##  distribution of a code returned by the <C>WeightDistribution</C> command
##  from the <Package>GUAVA</Package> package. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AddWeights" );

#############################################################################
##
#F  AdjacencyMat( <g> ) 
##
##  <#GAPDoc Label="AdjacencyMat">
##  <ManSection>
##  <Func Name="AdjacencyMat" Arg="g"/>
##
##  <Description>
##  Returns the adjacency matrix of the graph <A>g</A> in 
##  <Package>GRAPE</Package> format. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AdjacencyMat" );

#############################################################################
##
#F  Cliquer( <g>[, <opt>] )  
##
##  <#GAPDoc Label="Cliquer">
##  <ManSection>
##  <Func Name="Cliquer" Arg="g[, opt]"/>
##
##  <Description>
##  Searches for cliques in the graph <A>g</A>. Uses <C>Cliquer</C> by 
##  S.Niskanen and P.Ostergard <Cite Key='NO03'/>. The graph can either
##  be given in <Package>GRAPE</Package> format, or as a list <C>[v,elist]</C>
##  where <C>v</C> is the number of vertices and <C>elist</C> is a list of
##  edges (<M>2</M>-element subsets of <C>[1..v]</C>). The optional argument 
##  <A>opt</A> is a record for options. Possible components are:
##  <List>
##  <Item><A>Silent</A>:=<C>true</C>/<C>false</C> Work silently, or report
##  progress. The default is taken from <C>PAGGlobalOptions</C>.</Item>
##  <Item><A>FindAll</A>:=<C>true</C>/<C>false</C> Find all cliques, or
##  search for a single clique. The default is <C>true</C>.</Item>
##  <Item><A>CliqueSize</A>:=<C>n</C> or <C>[min,max]</C> Search for cliques
##  of size <C>n</C>, or size from <C>min</C> to <C>max</C>. By default, 
##  searches for cliques of maximum size.</Item>
##  <Item><A>Order</A>:=<C>n</C> Reorder vertices by ordering function
##  number <C>n</C>. Available functions are <C>n</C><M>=1</M> <C>ident</C>, 
##  <C>n</C><M>=2</M> <C>reverse</C>, <C>n</C><M>=3</M> <C>degree</C>, 
##  <C>n</C><M>=4</M> <C>random</C>, and <C>n</C><M>=5</M> <C>greedy</C> 
##  (default).</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Cliquer" );

#############################################################################
##
#F  DisjointCliques( <L>[, <opt>] )  
##
##  <#GAPDoc Label="DisjointCliques">
##  <ManSection>
##  <Func Name="DisjointCliques" Arg="L[, opt]"/>
##
##  <Description>
##  Given a list <A>L</A> of <M>k</M>-sets of integers, searches for
##  cliques of mutually disjoint <M>k</M>-sets from the list. The sets 
##  must be of equal size <M>k</M>. Uses <C>Cliquer</C> by S.Niskanen 
##  and P.Ostergard <Cite Key='NO03'/>. The optional argument <A>opt</A> 
##  is a record for options with possible components:
##  <List>
##  <Item><A>Silent</A>:=<C>true</C>/<C>false</C> Work silently, or report
##  progress. The default is taken from <C>PAGGlobalOptions</C>.</Item>
##  <Item><A>FindAll</A>:=<C>true</C>/<C>false</C> Find all cliques, or
##  search for a single clique. The default is <C>true</C>.</Item>
##  <Item><A>CliqueSize</A>:=<C>n</C> or <C>[min,max]</C> Search for cliques
##  of size <C>n</C>, or size from <C>min</C> to <C>max</C>. By default, 
##  searches for cliques of maximum size.</Item>
##  <Item><A>Order</A>:=<C>n</C> Reorder vertices by ordering function
##  number <C>n</C>. Available functions are <C>n</C><M>=1</M> <C>ident</C>, 
##  <C>n</C><M>=2</M> <C>reverse</C>, <C>n</C><M>=3</M> <C>degree</C>, 
##  <C>n</C><M>=4</M> <C>random</C>, and <C>n</C><M>=5</M> <C>greedy</C> 
##  (default).</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DisjointCliques" );

#############################################################################
##
#F  DifferenceCube( <G>, <ds>, <n> ) 
##
##  <#GAPDoc Label="DifferenceCube">
##  <ManSection>
##  <Func Name="DifferenceCube" Arg="G, ds, n"/>
##
##  <Description>
##  Returns the <A>n</A>-dimenional difference cube constructed from
##  a difference set <A>ds</A> in the group <A>G</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DifferenceCube" );

#############################################################################
##
#F  GroupCube( <G>, <dds>, <n> ) 
##
##  <#GAPDoc Label="GroupCube">
##  <ManSection>
##  <Func Name="GroupCube" Arg="G, dds, n"/>
##
##  <Description>
##  Returns the <A>n</A>-dimenional group cube constructed from
##  a symmetric design <A>dds</A> such that the blocks are
##  difference sets in the group <A>G</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "GroupCube" );

#############################################################################
##
#F  CubeSlice( <C>, <x>, <y>, <fixed> ) 
##
##  <#GAPDoc Label="CubeSlice">
##  <ManSection>
##  <Func Name="CubeSlice" Arg="C, x, y, fixed"/>
##
##  <Description>
##  Returns a 2-dimensional slice of the incidence cube <A>C</A> 
##  obtained by varying coordinates in positions <A>x</A> and <A>y</A>, and 
##  taking fixed values for the remaining coordinates given in a list 
##  <A>fixed</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeSlice" );

#############################################################################
##
#F  CubeSlices( <C>[, <x>, <y>][, <fixed>] ) 
##
##  <#GAPDoc Label="CubeSlices">
##  <ManSection>
##  <Func Name="CubeSlices" Arg="C[, x, y][, fixed]"/>
##
##  <Description>
##  Returns 2-dimensional slices of the incidence cube <A>C</A>. Optional 
##  arguments are the varying coordinates <A>x</A> and <A>y</A>, and values of the 
##  fixed coordinates in a list <A>fixed</A>. If optional arguments are not given, 
##  all possibilities are supplied. For an <M>n</M>-dimensional cube <A>C</A>
##  of order <M>v</M>, the following calls will return:
##  <List>
##  <Item>CubeSlices( <A>C</A>, <A>x</A>, <A>y</A> ) <M>\ldots v^{n-2}</M> slices 
##  obtained by varying values of the fixed coordinates.</Item>
##  <Item>CubeSlices( <A>C</A>, <A>fixed</A> ) <M>\ldots {n\choose 2}</M> slices 
##  obtained by varying the non-fixed coordinates <M>x &lt; y</M>.</Item>
##  <Item>CubeSlices( <A>C</A> ) <M>\ldots {n\choose 2}\cdot v^{n-2}</M> slices 
##  obtained by varying both the non-fixed coordinates <M>x &lt; y</M> and values
##  of the fixed coordinates.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeSlices" );

#############################################################################
##
#F  CubeLayer( <C>, <x>, <fixed> ) 
##
##  <#GAPDoc Label="CubeLayer">
##  <ManSection>
##  <Func Name="CubeLayer" Arg="C, x, fixed"/>
##
##  <Description>
##  Returns an <M>(n-1)</M>-dimensional layer of the <M>n</M>-dimensional
##  cube <A>C</A> obtained by setting coordinate <A>x</A> to the value 
##  <A>fixed</A> and varying the remaining coordinates. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeLayer" );

#############################################################################
##
#F  CubeLayers( <C>, <x> ) 
##
##  <#GAPDoc Label="CubeLayers">
##  <ManSection>
##  <Func Name="CubeLayers" Arg="C, x"/>
##
##  <Description>
##  Returns the <M>(n-1)</M>-dimensional layers of the <M>n</M>-dimensional
##  cube <A>C</A> obtained by fixing coordinate <A>x</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeLayers" );

#############################################################################
##
#F  CubeProjection( <C>, <p> ) 
##
##  <#GAPDoc Label="CubeProjection">
##  <ManSection>
##  <Func Name="CubeProjection" Arg="C, p"/>
##
##  <Description>
##  Returns the projection of the <M>n</M>-dimensional cube <A>C</A> 
##  on a pair of coordinates <A>p</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeProjection" );

#############################################################################
##
#F  CubeProjections( <C> ) 
##
##  <#GAPDoc Label="CubeProjections">
##  <ManSection>
##  <Func Name="CubeProjections" Arg="C"/>
##
##  <Description>
##  Returns the projections of the <M>n</M>-dimensional cube <A>C</A> 
##  on all pairs of coordinates.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeProjections" );

#############################################################################
##
#F  OrthogonalArrayProjection( <oa>, <t> ) 
##
##  <#GAPDoc Label="OrthogonalArrayProjection">
##  <ManSection>
##  <Func Name="OrthogonalArrayProjection" Arg="oa, t"/>
##
##  <Description>
##  Returns the projection of the orthogonal array <A>oa</A> 
##  on a tuple of coordinates <A>t</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayProjection" );

#############################################################################
##
#F  OrthogonalArrayProjections( <oa>[, <k>] ) 
##
##  <#GAPDoc Label="OrthogonalArrayProjections">
##  <ManSection>
##  <Func Name="OrthogonalArrayProjections" Arg="oa[, k]"/>
##
##  <Description>
##  Returns the projections of the orthogonal array <A>oa</A> 
##  on all <A>k</A>-tuples of coordinates. If the second argument
##  is not given, <A>k</A><M>=2</M> is assumed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayProjections" );

#############################################################################
##
#F  CubeToOrthogonalArray( <C> ) 
##
##  <#GAPDoc Label="CubeToOrthogonalArray">
##  <ManSection>
##  <Func Name="CubeToOrthogonalArray" Arg="C"/>
##
##  <Description>
##  Transforms the incidence cube <A>C</A> to an equivalent orthogonal array.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeToOrthogonalArray" );

#############################################################################
##
#F  OrthogonalArrayToCube( <oa> ) 
##
##  <#GAPDoc Label="OrthogonalArrayToCube">
##  <ManSection>
##  <Func Name="OrthogonalArrayToCube" Arg="oa"/>
##
##  <Description>
##  Transforms the orthogonal array <A>oa</A> to an equivalent incidence cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayToCube" );

#############################################################################
##
#F  CubeToTransversalDesign( <C> ) 
##
##  <#GAPDoc Label="CubeToTransversalDesign">
##  <ManSection>
##  <Func Name="CubeToTransversalDesign" Arg="C"/>
##
##  <Description>
##  Transforms the incidence cube <A>C</A> to an equivalent transversal design.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeToTransversalDesign" );

#############################################################################
##
#F  OrthogonalArrayToTransversalDesign( <oa> ) 
##
##  <#GAPDoc Label="OrthogonalArrayToTransversalDesign">
##  <ManSection>
##  <Func Name="OrthogonalArrayToTransversalDesign" Arg="oa"/>
##
##  <Description>
##  Transforms the orthogonal array <A>oa</A> to an equivalent transversal design.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayToTransversalDesign" );

#############################################################################
##
#F  TransversalDesignToCube( <td> ) 
##
##  <#GAPDoc Label="TransversalDesignToCube">
##  <ManSection>
##  <Func Name="TransversalDesignToCube" Arg="td"/>
##
##  <Description>
##  Transforms the transversal design <A>td</A> to an equivalent incidence cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TransversalDesignToCube" );

#############################################################################
##
#F  LatinSquareToCube( <L> ) 
##
##  <#GAPDoc Label="LatinSquareToCube">
##  <ManSection>
##  <Func Name="LatinSquareToCube" Arg="L"/>
##
##  <Description>
##  Transforms the Latin square <A>L</A> to an equivalent incidence cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LatinSquareToCube" );

#############################################################################
##
#F  DifferenceSetToOrthogonalArray( [<G>,] <ds> ) 
##
##  <#GAPDoc Label="DifferenceSetToOrthogonalArray">
##  <ManSection>
##  <Func Name="DifferenceSetToOrthogonalArray" Arg="[G, ]ds"/>
##
##  <Description>
##  Transforms a (higher-dimensional) difference set to an orthogonal array. 
##  The argument <A>G</A> is a group and <A>ds</A> is a difference set in 
##  the <Package>DifSets</Package> package format, with positive integers
##  as elements. If the first argument is not given, <A>ds</A> contains 
##  finite field elements and the operation is addition. This is used 
##  for Paley difference sets and twin prime power difference sets.  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DifferenceSetToOrthogonalArray" );

#############################################################################
##
#F  Development3( <G>, <ds> ) 
##
##  <#GAPDoc Label="Development3">
##  <ManSection>
##  <Func Name="Development3" Arg="G, ds"/>
##
##  <Description>
##  Transforms a difference set of propriety <M>3</M> to an orthogonal 
##  array. The argument <A>G</A> is a group and <A>ds</A> is a 
##  difference set.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Development3" );

#############################################################################
##
#F  CubeTest( <C> ) 
##
##  <#GAPDoc Label="CubeTest">
##  <ManSection>
##  <Func Name="CubeTest" Arg="C"/>
##
##  <Description>
##  Test whether an incidence cube <A>C</A> is a cube of symmetric designs.
##  The result should be <C>[[v,k,lambda]]</C>. Anything else means that
##  <A>C</A> is not a <M>\mathcal{C}^n(v,k,\lambda)</M>-cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeTest" );

#############################################################################
##
#F  Cube3Test( <C> ) 
##
##  <#GAPDoc Label="Cube3Test">
##  <ManSection>
##  <Func Name="Cube3Test" Arg="C"/>
##
##  <Description>
##  Test whether an incidence cube <A>C</A> is a three-dimensional 
##  symmetric design of propriety <M>3</M>. The result should be 
##  <C>[v,[k],[lambda]]</C>. Anything else means that <A>C</A> is 
##  not a <M>\mathcal{C}^3_3(v,k,\lambda)</M>-cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "Cube3Test" );

#############################################################################
##
#F  CubeProjectionTest( <C> ) 
##
##  <#GAPDoc Label="CubeProjectionTest">
##  <ManSection>
##  <Func Name="CubeProjectionTest" Arg="C"/>
##
##  <Description>
##  Test whether an incidence cube <A>C</A> is a projection cube of symmetric 
##  designs. The result should be <C>[[v,k,lambda]]</C>. Anything else means that
##  <A>C</A> is not a <M>(v,k,\lambda)</M> projection cube. The function 
##  <Ref Func="OrthogonalArrayProjectionTest"/> is usually much faster.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeProjectionTest" );

#############################################################################
##
#F  OrthogonalArrayProjectionTest( <oa> ) 
##
##  <#GAPDoc Label="OrthogonalArrayProjectionTest">
##  <ManSection>
##  <Func Name="OrthogonalArrayProjectionTest" Arg="oa"/>
##
##  <Description>
##  Test whether an orthogonal array <A>oa</A> corresponds to a projection 
##  cube of symmetric <M>(v,k,\lambda)</M> designs. The result should be 
##  <C>[[v,k,lambda]]</C>. Anything else means that  <A>oa</A> does not 
##  correspond to a projection cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayProjectionTest" );

#############################################################################
##
#F  SliceInvariant( <C> ) 
##
##  <#GAPDoc Label="SliceInvariant">
##  <ManSection>
##  <Func Name="SliceInvariant" Arg="C"/>
##
##  <Description>
##  Computes a paratopy invariant of the cube <A>C</A> based on 
##  automorphism group sizes of parallel slices. Cubes equivalent 
##  under paratopy have the same invariant.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SliceInvariant" );

#############################################################################
##
#F  CubeAut( <C>[, <opt>] )  
##
##  <#GAPDoc Label="CubeAut">
##  <ManSection>
##  <Func Name="CubeAut" Arg="C[, opt]"/>
##  
##  <Description>
##  Computes the full auto(para)topy group of an incidence cube <A>C</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Compute the full autotopy
##  group of <A>C</A>. This is the default.</Item>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Compute the full
##  autoparatopy group of <A>C</A>.</Item>
##  </List>
##  Any other components are forwarded to the <Ref Func="BlockDesignAut" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeAut" );

#############################################################################
##
#F  OrthogonalArrayAut( <C>[, <opt>] )  
##
##  <#GAPDoc Label="OrthogonalArrayAut">
##  <ManSection>
##  <Func Name="OrthogonalArrayAut" Arg="oa[, opt]"/>
##  
##  <Description>
##  Computes the full auto(para)topy group of an orthogonal array <A>oa</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Compute the full autotopy
##  group of <A>oa</A>. This is the default.</Item>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Compute the full
##  autoparatopy group of <A>oa</A>.</Item>
##  </List>
##  Any other components are forwarded to the <Ref Func="BlockDesignAut" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayAut" );

#############################################################################
##
#F  CubeFilter( <cl>[, <opt>] )  
##
##  <#GAPDoc Label="CubeFilter">
##  <ManSection>
##  <Func Name="CubeFilter" Arg="cl[, opt]"/>
##  
##  <Description>
##  Eliminates equivalent copies from a list of incidence cubes <A>cl</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic cubes. 
##  This is the default.</Item>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic cubes.</Item>
##  </List>
##  Any other components are forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeFilter" );

#############################################################################
##
#F  OrthogonalArrayFilter( <oal>[, <opt>] )  
##
##  <#GAPDoc Label="OrthogonalArrayFilter">
##  <ManSection>
##  <Func Name="OrthogonalArrayFilter" Arg="oal[, opt]"/>
##  
##  <Description>
##  Eliminates equivalent copies from a list of orthogonal arrays <A>oal</A>. 
##  Uses <C>nauty/Traces 2.8</C> by B.D.McKay and A.Piperno <Cite Key='MP14'/>. 
##  The optional argument <A>opt</A> is a record for options. Possible 
##  components are:
##  <List>
##  <Item><A>Paratopy</A>:=<C>true</C>/<C>false</C> Eliminate paratopic orthogonal 
##  arrays. This is the default.</Item>
##  <Item><A>Isotopy</A>:=<C>true</C>/<C>false</C> Eliminate isotopic orthogonal
##  arrays.</Item>
##  </List>
##  Any other components are forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OrthogonalArrayFilter" );

#############################################################################
##
#F  SDPSeriesGroup( <m> ) 
##
##  <#GAPDoc Label="SDPSeriesGroup">
##  <ManSection>
##  <Func Name="SDPSeriesGroup" Arg="m"/>
##
##  <Description>
##  Returns a group for the designs of <Ref Func="SDPSeriesDesign"/>.
##  This is the elementary Abelian group of order <M>4^m</M>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SDPSeriesGroup" );

#############################################################################
##
#F  SDPSeriesHadamardMat( <m>, <i> ) 
##
##  <#GAPDoc Label="SDPSeriesHadamardMat">
##  <ManSection>
##  <Func Name="SDPSeriesHadamardMat" Arg="m, i"/>
##
##  <Description>
##  Returns a Hadamard matrix of order <M>4^m</M> for the SDP series 
##  of designs. The argument <A>i</A> must be 1, 2, or 3. See documentation
##  for the <Ref Func="SDPSeriesDesign"/> function.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SDPSeriesHadamardMat" );

#############################################################################
##
#F  SDPSeriesDesign( <m>, <i> ) 
##
##  <#GAPDoc Label="SDPSeriesDesign">
##  <ManSection>
##  <Func Name="SDPSeriesDesign" Arg="m, i"/>
##
##  <Description>
##  Returns a symmetric block design with parameters 
##  <M>(4^m,2^{m-1}(2^m-1),2^{m-1}(2^{m-1}-1))</M>. 
##  The argument <A>i</A> must be 1, 2, or 3. 
##  If <A>i</A><M>=1</M>, the design is the symplectic design
##  of Kantor <Cite Key='WK75'/>. This design has the symmetric
##  difference property (SDP). If <A>i</A><M>=2</M> or <A>i</A><M>=3</M>,
##  two other non-isomorphic designs with the same parameters
##  are returned. They are not SDP designs, but have the property that 
##  all their blocks are difference sets in the group returned by
##  <Ref Func="SDPSeriesGroup"/>. Developments of these blocks are
##  isomorphic to the design for <A>i</A><M>=1</M>, so the two other 
##  designs are not developments of their blocks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SDPSeriesDesign" );

#############################################################################
##
#F  IncidenceMatToBlocks( <M> )  
##
##  <#GAPDoc Label="IncidenceMatToBlocks">
##  <ManSection>
##  <Func Name="IncidenceMatToBlocks" Arg="M"/>
##  
##  <Description>
##  Transforms an incidence matrix <A>M</A> to a list of blocks.
##  Rows correspond to points, and columns to blocks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IncidenceMatToBlocks" );

#############################################################################
##
#F  BlocksToIncidenceMat( <d> )  
##
##  <#GAPDoc Label="BlocksToIncidenceMat">
##  <ManSection>
##  <Func Name="BlocksToIncidenceMat" Arg="d"/>
##  
##  <Description>
##  Transforms a list of blocks <A>d</A> to an incidence matrix.
##  Points correspond to rows, and blocks to columns.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "BlocksToIncidenceMat" );

#############################################################################
##
#F  ReadMat( <filename>[, <opt>] ) 
##
##  <#GAPDoc Label="ReadMat">
##  <ManSection>
##  <Func Name="ReadMat" Arg="filename[, opt]"/>
##
##  <Description>
##  Reads a list of <M>m\times n</M> integer matrices from a file. The file starts with 
##  the number of rows <M>m</M> and columns <M>n</M> followed by the matrix entries. 
##  Integers in the file are separated by whitespaces. The last argument is a record 
##  <A>opt</A> for options. The possible components of <A>opt</A> are:
##  <List>
##  <Item><A>Format</A>:=<C>"inc"</C>  If defined, the matrices are assumed to have
##  <M>0/1</M> entries not necessarily separated by whitespaces.</Item>
##  <Item><A>Format</A>:=<C>"om"</C>  If defined, the file is assumed to contain 
##  orbit matrices. After <M>m</M> and <M>n</M>, the point and block orbit size
##  vectors <M>\nu</M> and <M>\beta</M> follow, then the matrices.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ReadMat" );

#############################################################################
##
#F  WriteMat( <filename>, <list>[, <opt>] ) 
##
##  <#GAPDoc Label="WriteMat">
##  <ManSection>
##  <Func Name="WriteMat" Arg="filename, list[, opt]"/>
##
##  <Description>
##  Writes a list of <M>m\times n</M> integer matrices to a file. The number of 
##  rows <M>m</M> and columns <M>n</M> is written first, followed by the matrix 
##  entries. Integers are separated by whitespaces. The last argument is a record 
##  <A>opt</A> for options. The possible components of <A>opt</A> are:
##  <List>
##  <Item><A>Format</A>:=<C>"inc"</C>  If defined, the matrices are assumed to have
##  <M>0/1</M> entries and the entries are written without whitespaces.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "WriteMat" );

#############################################################################
##
#F  MosaicParameters( <M> ) 
##
##  <#GAPDoc Label="MosaicParameters">
##  <ManSection>
##  <Func Name="MosaicParameters" Arg="M"/>
##
##  <Description>
##  Returns a string with the parameters of the mosaic of combinatorial 
##  designs <A>M</A>. See <Cite Key='GGP18'/> for the definition. Entries
##  <M>0</M> in the matrix <A>M</A> are considered empty, and other integers
##  are considered as incidences of distinct designs.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MosaicParameters" );

#############################################################################
##
#F  MosaicToBlockDesigns( <M> )  
##
##  <#GAPDoc Label="MosaicToBlockDesigns">
##  <ManSection>
##  <Func Name="MosaicToBlockDesigns" Arg="M"/>
##  
##  <Description>
##  Transforms a mosaic of combinatorial designs <A>M</A> with <M>c</M> 
##  colors to a list of <M>c</M> block designs in the 
##  <Package>Design</Package> package format.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MosaicToBlockDesigns" );

#############################################################################
##
#F  AffineMosaic( <k>, <n>, <q> ) 
##
##  <#GAPDoc Label="AffineMosaic">
##  <ManSection>
##  <Func Name="AffineMosaic" Arg="k, n, q"/>
##
##  <Description>
##  Returns a mosaic of designs with blocks being <A>k</A>-dimensional subspaces 
##  of the affine space <M>AG(</M><A>n</A><M>,</M><A>q</A><M>)</M>. 
##  Uses the <Package>FinInG</Package> package. If the package is not 
##  available, the function is not loaded. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "AffineMosaic" );

#############################################################################
##
#F  DifferenceMosaic( <G>, <dds> ) 
##
##  <#GAPDoc Label="DifferenceMosaic">
##  <ManSection>
##  <Func Name="DifferenceMosaic" Arg="G, dds"/>
##
##  <Description>
##  Returns the mosaic of symmetric designs obtained from a list
##  of disjoint difference sets <A>dds</A> in the group <A>G</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DifferenceMosaic" );

#############################################################################
##
#F  PowersMosaic( <q>, <n> ) 
##
##  <#GAPDoc Label="PowersMosaic">
##  <ManSection>
##  <Func Name="PowersMosaic" Arg="q, n"/>
##
##  <Description>
##  Returns the mosaic of symmetric designs constructed from <A>n</A>-th
##  powers in the field <M>GF(</M><A>q</A><M>)</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PowersMosaic" );

#############################################################################
##
#V  PAGGlobalOptions 
##
##  <#GAPDoc Label="PAGGlobalOptions">
##  <ManSection>
##  <Var Name="PAGGlobalOptions"/>
##  
##  <Description>
##  A record with global options for the PAG package. Components are:
##  <List>
##  <Item><A>Silent</A>:=<C>true</C>/<C>false</C>  If set to <C>true</C>, functions such as SolveKramerMesner
##  will not print comments reporting the progress of the calculation.</Item>
##  <Item><A>TempDir</A>:=<C>directory object</C>  Temporary directory used to communicate
##  with external programs.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalVariable( "PAGGlobalOptions",
   "record with global options for the PAG package");


DeclareGlobalVariable( "PAGProcessResult", "global variable for returning results");

#E  PAG.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
