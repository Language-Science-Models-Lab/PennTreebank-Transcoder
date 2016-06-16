%{
// Scanner file to convert Penn Treebank into lambda calculus terms

/*
 MIT License

 Copyright (c) 2016 Joseph Lee Nunn III and Sean Fulop

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE. 
*/

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
