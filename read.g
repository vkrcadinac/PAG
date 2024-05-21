
#############################################################################
##
#R  Read the install files.
##

# Read the main implementation file.
ReadPackage( "PAG", "lib/PAG.gi" );

# Read functions depending on the package AssociationSchemes if it's available.
if IsPackageMarkedForLoading( "AssociationSchemes", "" ) then
  ReadPackage( "PAG", "lib/PAG-AssociationSchemes.gi" );
else
  ReadPackage( "PAG", "lib/PAG-NoAssociationSchemes.gi" );
fi;

# Read functions depending on the package FinInG if it's available.
if IsPackageMarkedForLoading( "FinInG", "" ) then
  ReadPackage( "PAG", "lib/PAG-FinInG.gi" );
fi;

#E  read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here

