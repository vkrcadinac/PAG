##  This creates the documentation, needs: GAPDoc and AutoDoc packages, pdflatex
##  
##  Call with GAP from within the package directory.
##

if fail = LoadPackage("AutoDoc", ">= 2016.01.21") then
    Error("AutoDoc 2016.01.21 or newer is required");
fi;

AutoDoc(rec(
    autodoc := true,
    gapdoc := rec(
        main := "main.xml"
    ),
    scaffold := rec(
        includes := [ "PAG.xml" ],
        bib := "bib.xml", 
        entities := rec( 
            io := "<Package>io</Package>", 
            PackageName := "<Package>PackageName</Package>" 
        )
    )
));

QUIT;
