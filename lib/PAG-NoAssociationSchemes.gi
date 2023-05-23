#############################################################################
##
##
#W  PAG.gi        Prescribed Automorphism Groups (PAG)
#W                by Vedran Krcadinac 
##
##  Definition of functions in the PAG package depending
##  on the suggested package AssociationSchemes.
##


#############################################################################
#
#  BlockScheme( <d> )  
#
#  Returns the block intersection scheme of a block design <A>d</A>.
#  If <A>d</A> is not block schematic, returns <C>fail</C>. Uses the package 
#  <Package>AssociationSchemes</Package>. If this package is not available,
#  <C>BlockScheme</C> will not be loaded. The optional argument <A>opt</A> is 
#  a record for options. If it contains the component <A>Matrix</A>:=<C>true</C>,
#  the block intersection matrix is returned instead. 
#
InstallGlobalFunction( BlockScheme, function( d, opt... )
local input,output,command;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"blockintmat.in"), false );
    PrintTo(output, NrBlockDesignPoints(d), " ", NrBlockDesignBlocks(d),"\n");
    PrintTo(output, BlockDesignBlocks(d));
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "blockintmat");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"blockintmat.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"blockintmat.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []); 
    CloseStream(output);
    CloseStream(input);

    return ReadAsFunction(Filename(PAGGlobalOptions.TempDir,"blockintmat.out"))();
end );


#############################################################################
#
#  PointPairScheme( <d>[, <opt>] )  
#
#  Returns the point pair scheme of a block design <A>d</A>. If <A>d</A> is 
#  not point pair schematic, returns <C>fail</C>. Uses the package 
#  <Package>AssociationSchemes</Package>. If this package is not available,
#  <C>BlockScheme</C> will not be loaded. The optional argument <A>opt</A> is 
#  a record for options. If it contains the component <A>Matrix</A>:=<C>true</C>,
#  the point pair inclusion matrix is returned instead. 
#  The point pair scheme was defined by Cameron <Cite Key='PC75'/> for Steiner 
#  <M>3</M>-designs. This command is a slight generalisation that works for
#  arbitrary designs.
#
InstallGlobalFunction( PointPairScheme, function( d, opt... )
local input,output,command;

    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"pointpairmat.in"), false );
    PrintTo(output, NrBlockDesignPoints(d), " ", NrBlockDesignBlocks(d),"\n");
    PrintTo(output, BlockDesignBlocks(d));
    CloseStream(output);

    command:=Filename(DirectoriesPackagePrograms("PAG"), "pointpairmat");
    input:=InputTextFile( Filename(PAGGlobalOptions.TempDir,"pointpairmat.in") );
    output:=OutputTextFile( Filename(PAGGlobalOptions.TempDir,"pointpairmat.out"), false);
    Process(PAGGlobalOptions.TempDir, command, input, output, []); 
    CloseStream(output);
    CloseStream(input);

    return ReadAsFunction(Filename(PAGGlobalOptions.TempDir,"pointpairmat.out"))();
end );


