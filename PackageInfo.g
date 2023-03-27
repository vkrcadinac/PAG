#############################################################################
##  
##  PackageInfo.g for the package "Prescribed Automorphism Groups" (PAG)
## 
##  Vedran Krcadinac
##

SetPackageInfo( rec(
PackageName := "PAG",
Subtitle := "Prescribed Automorphism Groups",
Version := "0.2.0",
Date := "27/03/2023",
License := "GPL-2.0-or-later",
PackageWWWHome :=
  Concatenation( "https://gap-packages.github.io/", LowercaseString( ~.PackageName ) ),

##  Optional:
##    - Type and the URL of the source code repository
##    - URL of the public issue tracker
##    - Support email address
##
##  SourceRepository :=
##    rec( Type := "vcs", # e.g. "git", "hg", "svn", "cvs", etc.
##         URL  := "http://hosting-service.com/mypackage"),
##  IssueTrackerURL := "http://issue-tracker.com/mypackage",
##  SupportEmail := "support@mypackage.org",
##
# SourceRepository :=
#    rec( Type := "git/hg/svn/cvs", # edit as necessary
#         URL := ""),
# IssueTrackerURL := "",
# SupportEmail := "",

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-packages/", LowercaseString( ~.PackageName ) ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
SupportEmail := "vedran.krcadinac@math.hr",

##  URL of the archive(s) of the current package release, but *without*
##  the format extension(s), like '.tar.gz' or '-win.zip', which are given next.
##  The archive file name *must be changed* with each version of the archive
##  (and probably somehow contain the package name and version).
##  The paths of the files in the archive must begin with the name of the
##  directory containing the package (in our "example" probably:
##  example/init.g, ...    or example-3.3/init.g, ...  )
# 
ArchiveURL := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),

##  All provided formats as list of file extensions, separated by white
##  space or commas.
##  Currently recognized formats are:
##      .tar.gz    the UNIX standard
##      .tar.bz2   compressed with 'bzip2', often smaller than with gzip
##      -win.zip   zip-format for DOS/Windows, text files must have DOS 
##                 style line breaks (CRLF)
##  
##  In the future we may also provide .deb or .rpm formats which allow
##  a convenient installation and upgrading on Linux systems.
##  
# ArchiveFormats := ".tar.gz", # the others are generated automatically
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

##  For a central overview of all packages and a collection of all package
##  archives it is necessary to have two files accessible which should be
##  contained in each package:
##     - A README file, containing a short abstract about the package
##       content and installation instructions.
##     - The PackageInfo.g file you are currently reading or editing!
##  You must specify URLs for these two files, these allow to automate 
##  the updating of package information on the GAP Website, and inclusion
##  and updating of the package in the GAP distribution.
#
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

##  *Optional*: the LoadPackage mechanism produces a nice default banner from
##  the info in this file. Normally, there is no need to change it, and we
##  recommend that you don't as this minimizes work for everybody (you and the
##  GAP team) on the long run.
##
##  However, if you reall think that you need a custom banner, you can provide
##  a string here that is used as a banner. GAP decides when the banner is 
##  shown and when it is not shown (note the ~-syntax in this example).
# BannerString := Concatenation( 
#     "----------------------------------------------------------------\n",
#     "Loading  Example ", ~.Version, "\n",
#     "by ",
#     JoinStringsWithSeparator( List( Filtered( ~.Persons, r -> r.IsAuthor ),
#                                     r -> Concatenation(
#         r.FirstNames, " ", r.LastName, " (", r.WWWHome, ")\n" ) ), "   " ),
#     "For help, type: ?Example package \n",
#     "----------------------------------------------------------------\n" ),

##  *Optional*: if you need a custom BannerString but would like to include
##  information in it that is only available once your package is being loaded
##  (i.e., which is computed in your init.g file, such as the presence and
##  versions of external software your package depends on), then you can
##  use a BannerFunction instead. The difference is that the BannerString is
##  usually computed when GAP starts, i.e., long before your init.g is run.
##  While the BannerFunction is called right before the banner is to be
##  displayed, which is after your init.g has been executed.
##
# BannerFunction := function(info)
#       local l;
#       # modify the default banner string, and insert something before
#       # its last line (which is a separator string)
#       l:=SplitString(DefaultPackageBannerString(info), "\n");
#       Add(l, " ...  some extra information ... ", Length(l));
#       return JoinStringsWithSeparator(l,"\n");
#     end,

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

Keywords := ["automorphism group", "block design", "latin square", "hadamard matrix"],

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

