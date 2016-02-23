
# Makefile for Penn treebank transformer

CXX = g++

all: osx

#penntransform: penntransform.tab.o penntransform.o
#	${CC} -o $@ penntransform.tab.o penntransform.o

Penngrammar.tab.c Penngrammar.tab.h: Penngrammar.y
	bison -vd Penngrammar.y

lex.yy.c: Pennlexer.l Penngrammar.tab.h
	flex -l Pennlexer.l

osx: Penngrammar.tab.c lex.yy.c
	${CXX} -O3 Penngrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=0

linux: Penngrammar.tab.c lex.yy.c
	${CXX} -O3 Penngrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=0

osx-debug: Penngrammar.tab.c lex.yy.c
	${CXX} -g Penngrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=1 -DTDEBUG=1

linux-debug: Penngrammar.tab.c lex.yy.c
	${CXX} -g Penngrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=1 -DTDEBUG=1

osx-trace: Penngrammar.tab.c lex.yy.c
	${CXX} -O3 Penngrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=0 -DTDEBUG=1

linux-trace: Penngrammar.tab.c lex.yy.c
	${CXX} -O3 Penngrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=0 -DTDEBUG=1

clean:
	rm -f Penngrammar.tab.c Penngrammar.tab.h lex.yy.c ptrans
	rm -rf ptrans.dSYM

#.SUFFIXES:	.pgm .l .y .c

