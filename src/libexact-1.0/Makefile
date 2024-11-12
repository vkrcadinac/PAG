# 
# libexact v1.0 --- a software library for solving combinatorial 
#                   exact covering problems
# 
# Copyright (C) 2008 Petteri Kaski <petteri.kaski@cs.helsinki.fi>
#                    Olli Pottonen <olli.pottonen@tkk.fi>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
# MA  02110-1301, USA.

MAKE = make
CC = c99
CFLAGS = -O3
AR = ar

all: libexact.a solve test examples

libexact.a: exact.o util.o
	$(AR) -r libexact.a exact.o util.o

solve: solve.o libexact.a
	$(CC) -o solve solve.o libexact.a

test: test.o libexact.a
	$(CC) -o test test.o libexact.a

examples: libexact.a
	cd examples && $(MAKE) && cd ..

check:	test
	./test

clean:
	rm -f *.o *.a *~ solve test
	cd examples && $(MAKE) clean && cd ..
