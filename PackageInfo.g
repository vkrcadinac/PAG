#############################################################################
##  
##  PackageInfo.g for the package "Prescribed Automorphism Groups" (PAG)
## 
##  Vedran Krcadinac
##

SetPackageInfo( rec(
PackageName := "PAG",
Subtitle := "Prescribed Automorphism Groups",
Version := "0.2.1",
Date := "14/04/2023",
License := "GPL-2.0-or-later",
PackageWWWHome :=
  Concatenation( "https://vkrcadinac.github.io/", ~.PackageName ),

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/vkrcadinac/", ~.PackageName ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
SupportEmail := "vedran.krcadinac@math.hr",
ArchiveURL := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),
ArchiveFormats := ".tar.gz",

Persons := [
  rec( 
    LastName      := "Krcadinac",
    FirstNames    := "Vedran",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "vedran.krcadinac@math.hr",
    WWWHome       := "https://web.math.pmf.unizg.hr/~krcko/homepage.html",
    PostalAddress := Concatenation( [
                     "University of Zagreb, Faculty of Science,\n", 
                     "Department of Mathematics\n",
                     "Bijenicka cesta 30, HR-10000 Zagreb, Croatia" ] ),
    Place         := "Zagreb, Croatia",
    Institution   := "University of Zagreb"
     ),  
  
],

Status := "dev",

README_URL := 
  Concatenation( ~.PackageWWWHome, "/README.txt" ),
PackageInfoURL := 
  Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),

AbstractHTML := 
  "The <span class=\"pkgname\">PAG</span> package contains functions for \
   constructing combinatorial objects with prescribed automorphism groups.",

PackageDoc := rec(
  BookName  := "PAG",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Prescribed Automorphism Groups",
),

Dependencies := rec(
  # GAP version, use the version string for specifying a least version,
  # prepend a '=' for specifying an exact version.
  GAP := "4.11",
  NeededOtherPackages := [["GAPDoc", "1.5"],
                          ["images", "1.3"],
                          ["GRAPE", "4.8"],
                          ["DESIGN", "1.7"]],
  SuggestedOtherPackages := [["AssociationSchemes", "2.0"],
                             ["GUAVA", "3.15"],
                             ["DifSets", "2.3.1"]],

  ExternalConditions := []
                      
),

##  Provide a test function for the availability of this package.
##  For packages containing nothing but GAP code, just say 'ReturnTrue' here.
##  For packages which may not work or will have only partial functionality,
##  use 'LogPackageLoadingMessage( PACKAGE_WARNING, ... )' statements to
##  store messages which may be viewed later with `DisplayPackageLoadingLog'.
##  Do not call `Print' or `Info' in the `AvailabilityTest' function of the 
##  package.
##
##  With the package loading mechanism of GAP >=4.4, the availability
##  tests of other packages, as given under .Dependencies above, will be 
##  done automatically and need not be included in this function.
##
#AvailabilityTest := ReturnTrue,
AvailabilityTest := function()
  local path, file;
    # test for existence of the compiled binary
    path:= DirectoriesPackagePrograms( "PAG" );
    file:= Filename( path, "hello" );
    if file = fail then
      LogPackageLoadingMessage( PACKAGE_WARNING,
          [ "The program `hello' is not compiled,",
            "`HelloWorld()' is thus unavailable.",
            "See the installation instructions;",
            "type: ?Installing the Example package" ] );
    fi;
    # if the hello binary was vital to the package we would return
    # the following ...
    # return file <> fail;
    # since the hello binary is not vital we return ...
    return true;
  end,

##  *Optional*, but recommended: path relative to package root to a file
##  which contains a short test (to run for no more than several minutes)
##  which may be used to check that a package works as expected.
##  This file can either consist of 'Test' calls or be a test file to be
##  read via 'Test' itself; it is assumed that the latter case occurs if
##  and only if the file contains the string 'gap> START_TEST('. For
##  deposited packages, these tests are run regularly as a part of the
##  standard GAP test suite. See  '?Tests files for a GAPpackage',
##  '?TestPackage', and also '?TestDirectory' for more information.
TestFile := "tst/testall.g",

Keywords := ["automorphism group", "block design", "latin square", "Hadamard matrix"],

AutoDoc := rec(
  TitlePage := rec(
    Abstract := """
    &PAG; is a &GAP; package for constructing combinatorial objects with
    prescribed automorphism groups. 
    """,
    Copyright := """
      <Index>License</Index>
      &copyright; 2023 by Vedran Krcadinac<P/>
      The &PAG; package is free software;
      you can redistribute it and/or modify it under the terms of the
      <URL Text="GNU General Public License">http://www.fsf.org/licenses/gpl.html</URL>
      as published by the Free Software Foundation; either version 2 of the License,
      or (at your option) any later version.
      """,
    Acknowledgements := """
      Development of the &PAG; package has been supported by the Croatian
      Science Foundation under the project IP-2020-02-9752. 
      """,
  ),
),

));

