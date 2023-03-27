# GAP package Prescribed Automorphism Groups (PAG)

* Website: https://vkrcadinac.github.io/PAG/
* Repository: https://github.com/vkrcadinac/PAG

PAG is a [GAP](https://www.gap-system.org) package for constructing 
combinatorial objects with prescribed automorphism groups.

The package uses external binaries. To compile them on UNIX-like
environments, change to the 'pkg/PAG-*' directory of your GAP 
installation and call

        ./configure.sh 

This produces a Makefile in the current directory. Now call

        make all

to compile the binares. They are placed in the 'bin' subdirectory.
To load the package start GAP and type

        LoadPackage("PAG");

For details on how to use the package see the documentation in the
'doc' subdirectory. 


## Authors

GAP code and C programs in the 'src' subdirectory, exept the ones 
listed below:
* Vedran Krcadinac (vedran.krcadinac@math.hr)

Solvediophant:
* Alfred Wassermann (Alfred.Wassermann@uni-bayreuth.de)

Nauty and Traces:
* Brendan McKay (Brendan.McKay@anu.edu.au)
* Adolfo Piperno (piperno@di.uniroma1.it)


## License

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

## License for Nauty and Traces

This is the license for the software package Nauty and
Traces, package versions 2.6r3 and later.

Five categories of software are included in the package:
A. All files not listed as B-E below, copyright Brendan McKay (1984-)
B. Files traces.h, traces.c and dretodot.c, copyright Adolfo Piperno (2008-)
C. File watercluster2.c and genposetg.c, copyright Gunnar Brinkmann (2009-)
D. Files planarity.h and planarity.c, copyright Magma project.
E. Files nautycliquer.h and nautycliquer.c, copyright to Sampo
   Niskanen and Patric Östergård.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this software except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Brendan McKay: Australian National University; Brendan.McKay@anu.edu.au
Adolfo Piperno: University of Rome "Sapienza"; piperno@di.uniroma1.it
Gunnar Brinkmann: University of Ghent; Gunnar.Brinkmann@UGent.be
Magma Administration: University of Sydney; admin@maths.usyd.edu.au
Patric Ostergard: Aalto Univerity; patric.ostergard@aalto.fi

