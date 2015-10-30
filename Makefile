
# Makefile for Penn treebank transformer

CC = gcc -g

all: osx

#penntransform: penntransform.tab.o penntransform.o
#	${CC} -o $@ penntransform.tab.o penntransform.o

Penngrammar.tab.c Penngrammar.tab.h: Penngrammar.y
	bison -vd Penngrammar.y

lex.yy.c: Pennlexer.l Penngrammar.tab.h
	flex Pennlexer.l

osx: Penngrammar.tab.c lex.yy.c
	g++ Penngrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=0

linux: Penngrammar.tab.c lex.yy.c
	g++ Penngrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=0

osx-debug: Penngrammar.tab.c lex.yy.c
	g++ Penngrammar.tab.c lex.yy.c -ll -o ptrans -DDEBUG=1

linux-debug: Penngrammar.tab.c lex.yy.c
	g++ Penngrammar.tab.c lex.yy.c -lfl -o ptrans -DDEBUG=1

#penntransform.o: penntransform.c penntransform.tab.h
#.SUFFIXES:	.pgm .l .y .c

