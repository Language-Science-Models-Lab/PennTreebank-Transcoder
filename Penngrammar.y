
%{ 
#include <stdio.h>
%}

%%
node:		lparen node rparen
	|	head node
	|	pos 
	|	nonterm
	;

