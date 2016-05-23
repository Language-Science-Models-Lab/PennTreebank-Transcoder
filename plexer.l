%{
// Scanner file to convert Penn Treebank into lambek calculus
// by Joseph Nunn and Sean Fulop, 2015

#include "pgrammar.tab.h"  // gets the token types that we return

#define YY_DECL extern "C" int yylex()

#define yyterminate() return EOF_TOKEN

extern void yyerror(const char *) ;

%}

/* definitions */

POS  CC|CD|DT|EX|FW|IN|JJ|JJR|JJS|LS|MD|NN|NNS|NNP|NNPS|PDT|POS|PRP|PRP\$|RB|RBR|RBS|RP|SYM|TO|UH|VB|VBD|VBG|VBN|VBP|VBZ|WDT|WP|WP\$|WRB|-NONE-

TERMINAL \*T\*|\*U\*|\*ICH\*|[A-Z]?[-a-z\.\*']+[A-Z]?[-a-z0-9\.]*[A-Z]*|[0-9]*\.?[0-9]*-?[0-9]*\.?[0-9]*|[A-Z]\." "?[A-Z]?\.?|[A-Z]|[0-9]+[-a-z]+|%

FRAGMENT \(FRAG.*

S S(BAR)?Q?~?|SINV~?|S-CLF~?|S-TPC~?|S-ADV~?

NONTERMINAL [-,\.`':\+]*[A-Z][-\+,:$\.~`'A-Z]+

%%

 /* rules */

 /* match comment lines and take no action (discarding) */
\#.* ;

 /* discard fragments so labeled */
{FRAGMENT} ;

 /* find elements of the Penn trees and return them */
{S} { yylval.str = strdup( yytext ) ;
    /*  printf( "%s ", yytext ) ; */
      return S_TOKEN ; }

{POS} { yylval.str = strdup( yytext ) ;
        /* printf( "%s ", yytext ) ; */
        return POS_TOKEN ; }

{TERMINAL} { yylval.str = strdup( yytext ) ;
             return TERMINAL_TOKEN ; }

[A-Z][A-Z]+[a-z]*/\) { yylval.str = strdup( yytext ) ;
                       return TERMINAL_TOKEN ; }
 /* the above is not part of the TERMINAL defs because it uses trailing context, which is more expensive in disjunctions of regexps */

{NONTERMINAL} { yylval.str = strdup( yytext ) ;
                return NON_TERMINAL_TOKEN ; }



 /* return former character tokens @, (, ), \n as literals */
[\@\(\)\n] return yytext[ 0 ] ;

 /* match punctuations and dollar signs and discard */
\(\." "\@\.\)|\(," "\@,\)|\(;" "\@;\)|\($" "\@$\)|\(``" "\@``\)|\(''" "\@''\)|\(:" "\@--\)|\(:" "\@:\)|\(:" "\@;\) 

[ \t\r] { /* ignore whitespace */ }

 /* default to error */
. { const char *errorMsg = "\n Syntax error in scan: character %c seen\n" ;
    char buf[ strlen( errorMsg ) ] ;
    sprintf( buf, errorMsg, yytext[ 0 ] ) ;
    yyerror( buf ) ; }

%%
