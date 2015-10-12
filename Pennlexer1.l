 /*			-*-bison-*- */

 /*
 * scanner for Penn treebank
 *
 */


 /* definitions */

POS  CC|CD|DT|EX|FW|IN|JJ|JJR|JJS|LS|MD|NN|NNS|NNP|NNPS|PDT|POS|PRP|PRP\$|RB|RBR|RBS|RP|SYM|TO|UH|VB|VBD|VBG|VBN|VBP|VBZ|WDT|WP|WP\$|WRB|-NONE-

TERMINAL [A-Z]?[-a-z]*|[,;]

NONTERMINAL [A-Z][A-Z][A-Z]?~?|[A-Z][A-Z][A-Z]?~?-[A-Z]+

 
%%

 /* rules */

 /* match comment lines and take no action (discarding)*/
\#.*$

 /* find elements of the Penn trees and return them */

S printf( "S\n" );

{POS} printf( "POS\n" );

{TERMINAL} printf( "Terminal\n" );

{NONTERMINAL} printf( "Nonterm\n" );

 /* match closing period and discard */
\(\." "\@\.\)

\@ printf( "HEAD\n" );

\( printf( "LPAREN_TOKEN\n" );

\) printf( "RPAREN_TOKEN\n" );

%%

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
}




