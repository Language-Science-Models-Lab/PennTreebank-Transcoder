
# Makefile for Penn treebank transformer

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

