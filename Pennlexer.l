%{
// Scanner file to convert Penn Treebank into lambek calculus
// by Joseph Nunn and Sean Fulop, 2015
#include <cstdio>
#include <iostream>
#include <string>

using namespace std;
#define YY_DECL extern "C" int yylex()

extern void yyerror(const char *) ;

#include "Penngrammar.tab.h"  // gets the token types that we return
%}

/* definitions */

POS  CC|CD|DT|EX|FW|IN|JJ|JJR|JJS|LS|MD|NN|NNS|NNP|NNPS|PDT|POS|PRP|PRP\$|RB|RBR|RBS|RP|SYM|TO|UH|VB|VBD|VBG|VBN|VBP|VBZ|WDT|WP|WP\$|WRB|-NONE-

TERMINAL \*T\*|\*U\*|\*ICH\*|[A-Z]?[-a-z\.\*']+[A-Z]?[-a-z0-9\.]*[A-Z]*|[0-9]*\.?[0-9]*-?[0-9]*\.?[0-9]*|[A-Z]\." "?[A-Z]?\.?|[A-Z]|[0-9]+[-a-z]+|%

FRAGMENT \(FRAG.*$

NONTERMINAL [-,\.`':\+]*[A-Z][-\+,:\.~`'A-Z]+

S S(BAR)?Q?~?|SINV~?|S-CLF~?

%%

 /* rules */

 /* match comment lines and take no action (discarding)*/
\#.*$ ;

 /* discard fragments so labeled */
{FRAGMENT} ;

 /* find elements of the Penn trees and return them */

 {S} { printf("%s ",yytext); return S_TOKEN;  }

{POS} { printf("%s ",yytext); return POS_TOKEN ; }

{TERMINAL} { yylval.tok = strdup( yytext ) ;
             return TERMINAL_TOKEN ; }

{NONTERMINAL} return NON_TERMINAL_TOKEN ;

 /* match punctuations and dollar signs and discard */
\(\." "\@\.\)|\(," "\@,\)|\(;" "\@;\)|\($" "\@$\)|\(``" "\@``\)|\(''" "\@''\)|\(:" "\@--\)|\(:" "\@:\)|\(:" "\@;\) 

\@ return HEAD_TOKEN ;

\( return L_PAREN_TOKEN ;

\) return R_PAREN_TOKEN ;

\n|\r return EOL_TOKEN ;

[ \t] { /* ignore whitespace */ }

. { char buf[35] ;
    sprintf( buf, "Scan error: character %c seen\n", *yytext) ;
    yyerror( buf ) ; }

%%
/*
main(argc, argv)
int argc;
char **argv;
{
    if(argc > 1) {
	if(!(yyin = fopen(argv[1], "r"))) {
	    perror(argv[1]);
	    return (1);
	}
    }
    yylex();
}*/




