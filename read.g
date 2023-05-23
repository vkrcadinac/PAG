
#############################################################################
##
#R  Read the install files.
##

# Read the main implementation file.
ReadPackage( "PAG", "lib/PAG.gi" );

# Read functions depending on the package AssociationSchemes only if it is available.
if IsPackageMarkedForLoading( "AssociationSchemes", "" ) then
  ReadPackage( "PAG", "lib/PAG-AssociationSchemes.gi" );
else
  ReadPackage( "PAG", "lib/PAG-NoAssociationSchemes.gi" );
fi;

#E  read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

