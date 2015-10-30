# README #

Repository includes 3 important files:

Pennlexer.l is meant to be processed using Flex, using commands like this:

flex Pennlexer.l  # This will tell Flex to create the C program for a lexer with the standard name lex.yy.c

gcc lex.yy.c -lfl # This will compile the output C program and produce an executable lexer with the standard name a.out

Then a.out can be executed with the target filename as argument.

Penngrammar.y is meant to be processed by Bison.

Makefile is the all-important thing that compiles everything together.