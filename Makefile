
# Makefile for Penn treebank transformer

CC = gcc -g

all: penntransform


penntransform: penntransform.tab.o penntransform.o
	${CC} -o $@ penntransform.tab.o penntransform.o

penntransform.tab.c penntransform.tab.h: Penngrammar.y
	bison -vd Penngrammar.y

penntransform.c: Pennlexer.l
	flex -o $*.c $<

penntransform.o: penntransform.c penntransform.tab.h

.SUFFIXES:	.pgm .l .y .c

