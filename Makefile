
# Makefile for Penn treebank transformer

CC = gcc -g

all: penntransform-osx

#penntransform: penntransform.tab.o penntransform.o
#	${CC} -o $@ penntransform.tab.o penntransform.o

Penngrammar.tab.c Penngrammar.tab.h: Penngrammar.y
	bison -vd Penngrammar.y

lex.yy.c: Pennlexer.l Penngrammar.tab.h
	flex Pennlexer.l

penntransform-osx: Penngrammar.tab.c lex.yy.c
	g++ Penngrammar.tab.c lex.yy.c -ll -o penntransform

penntransform-linux: Penngrammar.tab.c lex.yy.c
	g++ Penngrammar.tab.c lex.yy.c -lfl -o penntransform

#penntransform.o: penntransform.c penntransform.tab.h
#.SUFFIXES:	.pgm .l .y .c

