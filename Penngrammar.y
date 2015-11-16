%{
// Parser file to convert Penn Treebank into lambek calculus
// by Joseph Nunn and Sean Fulop, 2015

#include <cstdio>
#include <iostream>

using namespace std;
 
extern "C" int yylex() ;
extern "C" int yyparse() ;
extern "C" FILE *yyin ;

void yyerror( const char *msg ) {
  fprintf(stderr, "%s\n", msg) ;
}

%}

%union {
  char *str ;
}

%token <str> POS_TOKEN ;
%token <str> TERMINAL_TOKEN ;
%token <str> NON_TERMINAL_TOKEN ;
%token <str> S_TOKEN ;
%token <str> EOF_TOKEN 0 "End of File" ;
%type <str> s pos terminal nonterminal subword word phrase clause headphrase headclause start eolf

%start start ;

/* Needed to build, even when not building debug version */
%debug

%%

/* Important not to check for start eolf, as $accept : start eof is the top level invisible rule!, see top of bison generated .output file */
start : clause eolf { printf("\n"); } ;
      | start clause eolf { printf("\n"); } ;
	  | eolf
	  | start '\n' ;

eolf : '\n'
     | "End of File" ;

headphrase : '@' phrase { $$ = $2 ; } ;

headclause : '@' clause { $$ = $2 ; } ;

clause : '(' s phrase headphrase ')' { $$ = $2 ; } ;
       | '(' s phrase clause ')' { $$ = $2 ; } ;
	   | '(' s phrase headclause ')' { $$ = $2 ; } ;
	   | '(' s headphrase ')' { $$ = $2 ; } ;
	   | '(' s headphrase phrase ')' { $$ = $2 ; } ;
	   | '(' s headphrase clause ')' { $$ = $2 ; } ;
       | '(' s phrase ')' { $$ = $2 ; } ;
       | '(' s clause ')' { $$ = $2 ; } ;
	   | '(' s headclause ')' { $$ = $2 ; } ;
	   | '(' s word ')' { $$ = $2 ; } ;
	   | '(' s word clause ')' { $$ = $2 ; } ;
	   | '(' s word headclause ')' { $$ = $2 ; } ;
	   | '(' s word phrase ')' { $$ = $2 ; } ;
	   | '(' s word headphrase ')' { $$ = $2 ; } ;

/*clstart : '(' s ; */

phrase : '(' nonterminal word phrase ')' { $$ = $3 ; } ;
       | '(' nonterminal word headphrase ')' { $$ = $3 ; } ;
       | '(' nonterminal word clause ')' { $$ = $3 ; } ;
       | '(' nonterminal phrase word ')' { $$ = $3 ; } ;
       | '(' nonterminal headphrase word ')' { $$ = $3 ; } ;
       | '(' nonterminal clause word ')' { $$ = $3 ; } ;
       | '(' nonterminal phrase clause ')' { $$ = $3 ; } ;
	   | '(' nonterminal phrase headclause ')' { $$ = $3 ; } ;
       | '(' nonterminal headphrase clause ')' { $$ = $3 ; } ;
       | '(' nonterminal clause headphrase ')' { $$ = $3 ; } ;
       | '(' nonterminal clause phrase ')' { $$ = $3 ; } ;
	   | '(' nonterminal headclause phrase ')' { $$ = $3 ; } ;
       | '(' nonterminal word ')' { $$ = $3 ; } ;
       | '(' nonterminal word word ')' { const char* formatStr = "[ %s %s ]" ; // Two formatted arguments
                                         $$ = (char*)malloc( strlen( formatStr ) + strlen( $3 ) + strlen( $4 ) - 4 ) ; // the magic number to use is 2 * number of printed arguments
                                         sprintf( $$, formatStr, $3, $4 ) ;
										 printf( "%s", $$ ) ; }
       | '(' nonterminal headphrase ')' { $$ = $3 ; } ;
       | '(' nonterminal phrase ')' { $$ = $3 ; } ;
       | '(' nonterminal clause ')' { $$ = $3 ; } ;
	   | '(' nonterminal headclause ')' { $$ = $3 ; } ;
       | '(' nonterminal headphrase phrase ')' { $$ = $3 ; } ;
       | '(' nonterminal phrase headphrase ')' { $$ = $3 ; } ;

/*phstart : '(' nonterminal ; */

word : '@' subword { $$ = $2 ; }
| subword { $$ = $1 ; }

subword : '(' pos '@' terminal ')' { $$ = $4 ; } ;

s : S_TOKEN {} ;

pos : POS_TOKEN {} ;

terminal : TERMINAL_TOKEN {} ;

nonterminal : NON_TERMINAL_TOKEN {} ;

%%

int main(int argc, char** argv) {
	// open a file handle to given file:
  if ( argc > 1 ) {
	FILE *myfile = fopen( argv[1], "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open file!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	// set debugger to trace to stderr; redirect to errorlog if desired
	yydebug = DEBUG;

	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
  } else yyerror( "No input file specified!\n" ) ;
}
