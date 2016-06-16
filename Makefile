
# Makefile for Penn treebank transformer

# MIT License

# Copyright (c) 2016 Joseph Lee Nunn III and Sean Fulop

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


CXX = g++

all: osx

pgrammar.tab.c pgrammar.tab.h: pgrammar.y
	bison -vd pgrammar.y

lex.yy.c: plexer.l pgrammar.tab.h
	flex -l plexer.l

osx: pgrammar.tab.c lex.yy.c
	${CXX} -O3 pgrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=0

linux: pgrammar.tab.c lex.yy.c
	${CXX} -O3 pgrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=0

osx-debug: pgrammar.tab.c lex.yy.c
	${CXX} -g pgrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=1 -DTDEBUG=1

linux-debug: pgrammar.tab.c lex.yy.c
	${CXX} -g pgrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=1 -DTDEBUG=1

osx-trace: pgrammar.tab.c lex.yy.c
	${CXX} -O3 pgrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=0 -DTDEBUG=1

linux-trace: pgrammar.tab.c lex.yy.c
	${CXX} -O3 pgrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=0 -DTDEBUG=1

clean:
	rm -f pgrammar.tab.c pgrammar.tab.h pgrammar.output lex.yy.c ptrans
	rm -rf ptrans.dSYM

#.SUFFIXES:	.pgm .l .y .c

