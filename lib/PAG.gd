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
##  <Item><A>IntesectionNumbers</A>:=<A>lin</A>  If defined, only representatives
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
#F  SubsetOrbitRepShort1( <G>, <v>, <k>, <size> ) 
##
##  <#GAPDoc Label="SubsetOrbitRepShort1">
##  <ManSection>
##  <Func Name="SubsetOrbitRepShort1" Arg="G, v, k, size"/>
##
##  <Description>
##  Computes <A>G</A>-orbit representatives of <A>k</A>-subsets of [1..<A>v</A>] 
##  of size less or equal <A>size</A>. Here, <A>size</A> is an integer smaller 
##  than the order of the group <A>G</A>. The algorithm is described in <Cite Key='KV16'/>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SubsetOrbitRepShort1" );

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
##  over <M>\{0,1\}</M>. By default, A.Wassermann's LLL solver <C>solvediophant</C>
##  <Cite Key='AW98'/> is used. If the second argument is a compatibility
##  matrix <A>cm</A>, the backtracking program <C>solvecm</C> from the papers 
##  <Cite Key='KNP11'/> and <Cite Key='KV16'/> is used. The solver can also
##  be chosen explicitly in the record <A>opt</A>. Possible components are:
##  <List>
##  <Item><A>Solver</A>:=<C>"solvediophant"</C> If defined, <C>solvediophant</C> 
##  is used.</Item>
##  <Item><A>Solver</A>:=<C>"solvecm"</C> If defined, <C>solvecm</C> is used.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "SolveKramerMesner" );

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
##  of size <A>s</A> that cannot be mapped onto each other. By default
##  all points are in the same class.</Item>
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
##  of size <A>s</A> that cannot be mapped onto each other. By default
##  all points are in the same class.</Item>
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
#F  BlockScheme( <d> )  
##
##  <#GAPDoc Label="BlockScheme">
##  <ManSection>
##  <Func Name="BlockScheme" Arg="d"/>
##  
##  <Description>
##  Returns the block intersection scheme of a schematic block design <A>d</A>.
##  If <A>d</A> is not schematic, returns <C>fail</C>. Uses the package 
##  <Package>AssociationSchemes</Package>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "BlockScheme" );

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
##  with presrcribed automorphism group <A>G</A> by the Kramer-Mesner method.
##  A record with options can be supplied. By default, a list of base blocks
##  for the constructed designs is returned. If <A>opt.Design</A> is defined,
##  the designs are returned in the <Package>Design</Package> package format 
##  <Ref Chap="Design" BookName="DESIGN"/>. If <A>opt.NonIsomorphic</A> is 
##  defined, the designs are returned in <Package>Design</Package> format and 
##  isomorph-rejection is performed. Other available options are:
##  <List>
##  <Item><A>SmallLambda</A>:=<C>true</C>/<C>false</C>. Perform the <Q>small 
##  lambda filter</Q>, i.e. remove <A>k</A>-orbits covering some of the 
##  <A>t</A>-orbits more than  <A>lambda</A> times. By default, this is 
##  done if <A>lambda</A>&lt;=3.</Item>
##  <Item><A>IntersectionNumbers</A>:=<A>lin</A>. Search for designs with 
##  block intersection nubers in the list of integers <A>lin</A> (e.g. 
##  quasi-symmetric designs).</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerSearch" );

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
##  of rows <M>m</M>, columns <M>n</M>, and size of the sets <M>s</M>,
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
##  columns <M>n</M>, and size of the sets <M>s</M> is written first, 
##  followed by the matrix entries. Integers are separated by whitespaces.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "WriteMOLS" );

#############################################################################
##
#F  CayleyTableOfGroup( <G> ) 
##
##  <#GAPDoc Label="CayleyTableOfGroup">
##  <ManSection>
##  <Func Name="CayleyTableOfGroup" Arg="G"/>
##
##  <Description>
##  Returns a Cayley table of the group <A>G</A>. The elements
##  are integers <M>1,\ldots,</M><C>Order(</C><A>G</A><C>)</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CayleyTableOfGroup" );

#############################################################################
##
#F  MOLSAut( <ls>[, <opt>] ) 
##
##  <#GAPDoc Label="MOLSAut">
##  <ManSection>
##  <Func Name="MOLSAut" Arg="ls[, opt]"/>
##
##  <Description>
##  Compute autotopism, autoparatopism, or automorphism groups of MOLS sets 
##  in the list <A>ls</A>. A record with options can be supplied. By default, 
##  autotopism groups are computed. If <A>opt.Paratopism</A> is defined, 
##  autoparatopism groups are computed. If <A>opt.Isomorphism</A> is defined, 
##  automorphism groups are computed.
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
##  Returns representatives of isotopism, paratopism, or isomorphism classes of MOLS
##  sets in the list <A>ls</A>. A record with options can be supplied. By default, 
##  isotopism class representatives are returned. If <A>opt.Paratopism</A> is defined, 
##  paratopism class representatives (main class representatives) are returned. If 
##  <A>opt.Isomorphism</A> is defined, isomorphism class representatives are returned.
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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "FieldToMOLS" );

#############################################################################
##
#F  IsotopismToPerm( <n>, <l> ) 
##
##  <#GAPDoc Label="IsotopismToPerm">
##  <ManSection>
##  <Func Name="IsotopismToPerm" Arg="n, l"/>
##
##  <Description>
##  Transforms an isotopism, i.e. a list <A>l</A> of three permutations of 
##  degree <A>n</A>, to a single permutation of degree <M>3</M><A>n</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsotopismToPerm" );

#############################################################################
##
#F  PermToIsotopism( <n>, <p> ) 
##
##  <#GAPDoc Label="PermToIsotopism">
##  <ManSection>
##  <Func Name="PermToIsotopism" Arg="n, p"/>
##
##  <Description>
##  Transforms a permutation <A>p</A> of degree <M>3</M><A>n</A> to an
##  isotopism, i.e. a list of three permutations of degree <A>n</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "PermToIsotopism" );

#############################################################################
##
#F  MOLSSubsetOrbitRep( <n>, <s>, <G> ) 
##
##  <#GAPDoc Label="MOLSSubsetOrbitRep">
##  <ManSection>
##  <Func Name="MOLSSubsetOrbitRep" Arg="n, s, G"/>
##
##  <Description>
##  Computes representatives of pairs and <M>(</M><A>s</A><M>+2)</M>-tuples
##  for the construction of MOLS of order <A>n</A> with prescribed autotopism
##  group <A>G</A>. A list containing pairs representatives in the first 
##  component and tuples representatives in the second component is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "MOLSSubsetOrbitRep" );

#############################################################################
##
#F  TuplesToMOLS( <n>, <s>, <T> ) 
##
##  <#GAPDoc Label="TuplesToMOLS">
##  <ManSection>
##  <Func Name="TuplesToMOLS" Arg="n, s, T"/>
##
##  <Description>
##  Transforms a set of <M>(</M><A>s</A><M>+2)</M>-tuples <A>T</A> to a 
##  set of MOLS of order <A>n</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TuplesToMOLS" );

#############################################################################
##
#F  KramerMesnerMOLS( <n>, <s>, <G>[, <opt>] ) 
##
##  <#GAPDoc Label="KramerMesnerMOLS">
##  <ManSection>
##  <Func Name="KramerMesnerMOLS" Arg="n, s, G[, opt]"/>
##
##  <Description>
##  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
##  autotopism group <A>G</A>. A record <A>opt</A> with options can be supplied.
##  By default, A.Wassermann's LLL solver <C>solvediophant</C> is used and
##  all constructed MOLS are returned, i.e. no filtering is performed. Available 
##  options are:
##  <List>
##  <Item><A>Solver</A>:=<C>"solvecm"</C> The backtracing solver <C>solvecm</C> 
##  is used.</Item>
##  <Item><A>Filter</A>:=<C>"Isotopism"</C> Non-isotopic MOLS are returned.</Item>
##  <Item><A>Filter</A>:=<C>"Paratopism"</C> Non-paratopic MOLS are returned.</Item>
##  <Item><A>Filter</A>:=<C>"Isomorphism"</C> Non-isomorphic MOLS are returned.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMOLS" );

#############################################################################
##
#F  KramerMesnerMOLSParatopism( <n>, <s>, <G>[, <opt>] ) 
##
##  <#GAPDoc Label="KramerMesnerMOLSParatopism">
##  <ManSection>
##  <Func Name="KramerMesnerMOLSParatopism" Arg="n, s, G[, opt]"/>
##
##  <Description>
##  Search for MOLS sets of order <A>n</A> and size <A>s</A> with prescribed
##  autoparatopism group <A>G</A>. A record <A>opt</A> with options can be supplied.
##  By default, A.Wassermann's LLL solver <C>solvediophant</C> is used and
##  all constructed MOLS are returned, i.e. no filtering is performed. Available 
##  options are:
##  <List>
##  <Item><A>Solver</A>:=<C>"solvecm"</C> The backtracing solver <C>solvecm</C> 
##  is used.</Item>
##  <Item><A>Filter</A>:=<C>"Isotopism"</C> Non-isotopic MOLS are returned.</Item>
##  <Item><A>Filter</A>:=<C>"Paratopism"</C> Non-paratopic MOLS are returned.</Item>
##  <Item><A>Filter</A>:=<C>"Isomorphism"</C> Non-isomorphic MOLS are returned.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "KramerMesnerMOLSParatopism" );

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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LeftDevelopment" );

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
#F  DifferenceCube( <G>, <ds>, <d> ) 
##
##  <#GAPDoc Label="DifferenceCube">
##  <ManSection>
##  <Func Name="DifferenceCube" Arg="G, ds, d"/>
##
##  <Description>
##  Returns the <A>d</A>-dimenional difference cube constructed from
##  a difference set <A>ds</A> in the group <A>G</A>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DifferenceCube" );

#############################################################################
##
#F  GroupCube( <G>, <dds>, <d> ) 
##
##  <#GAPDoc Label="GroupCube">
##  <ManSection>
##  <Func Name="GroupCube" Arg="G, dds, d"/>
##
##  <Description>
##  Returns the <A>d</A>-dimenional group cube constructed from
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
##  Returns a 2-dimensional slice of the cube <A>C</A> obtained by varying 
##  coordinates in positions <A>x</A> and <A>y</A>, and taking fixed values 
##  for the remaining coordinates given in a list <A>fixed</A>. 
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
##  Returns 2-dimensional slices of the cube <A>C</A>. Optional arguments are 
##  the varying coordinates <A>x</A> and <A>y</A>, and values of the fixed 
##  coordinates in a list <A>fixed</A>. If optional arguments are not given, 
##  all possibilities will be supplied. For a <M>d</M>-dimensional cube <A>C</A>
##  of order <M>v</M>, the following calls will return:
##  <List>
##  <Item>CubeSlices( <A>C</A>, <A>x</A>, <A>y</A> ) <M>\ldots v^{d-2}</M> slices 
##  obtained by varying values of the fixed coordinates.</Item>
##  <Item>CubeSlices( <A>C</A>, <A>fixed</A> ) <M>\ldots {d\choose 2}</M> slices 
##  obtained by varying the non-fixed coordinates <M>x &lt; y</M>.</Item>
##  <Item>CubeSlices( <A>C</A> ) <M>\ldots {d\choose 2}\cdot v^{d-2}</M> slices 
##  obtained by varying both the non-fixed coordinates <M>x &lt; y</M> and values
##  of the fixed coordinates.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeSlices" );

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
#F  OrthogonalArrayToCube( <OA> ) 
##
##  <#GAPDoc Label="OrthogonalArrayToCube">
##  <ManSection>
##  <Func Name="OrthogonalArrayToCube" Arg="OA"/>
##
##  <Description>
##  Transforms the orthogonal array <A>OA</A> to an equivalent incidence cube.
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
#F  TransversalDesignToCube( <TD> ) 
##
##  <#GAPDoc Label="TransversalDesignToCube">
##  <ManSection>
##  <Func Name="TransversalDesignToCube" Arg="TD"/>
##
##  <Description>
##  Transforms the transversal design <A>TD</A> to an equivalent incidence cube.
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
#F  CubeTest( <C> ) 
##
##  <#GAPDoc Label="CubeTest">
##  <ManSection>
##  <Func Name="CubeTest" Arg="C"/>
##
##  <Description>
##  Test whether an incidence cube <A>C</A> is a cube of symmetric designs.
##  The result should be <C>[[v,k,lambda]]</C>. Anything else means that
##  <A>C</A> is not a <M>(v,k,lambda)</M> cube.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeTest" );

#############################################################################
##
#F  CubeInvariant( <C> ) 
##
##  <#GAPDoc Label="CubeInvariant">
##  <ManSection>
##  <Func Name="CubeInvariant" Arg="C"/>
##
##  <Description>
##  Computes an equivalence invariant of the cube <A>C</A>
##  based on automorphism group sizes of its slices. Cubes
##  equivalent under paratopy have the same invariant.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeInvariant" );

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
##  Any other components will be forwarded to the <Ref Func="BlockDesignAut" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeAut" );

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
##  Any other components will be forwarded to the <Ref Func="BlockDesignFilter" Style="Text"/>
##  function; see its documentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CubeFilter" );

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


#E  PAG.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
