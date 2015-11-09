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
%token EOF_TOKEN 0 "End of File" ;

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

headphrase : '@' phrase ;

headclause : '@' clause ;

clause : '(' s phrase headphrase ')'
       | '(' s phrase clause ')'
	   | '(' s phrase headclause ')'
	   | '(' s headphrase ')'
	   | '(' s headphrase phrase ')'
	   | '(' s headphrase clause ')'
       | '(' s phrase ')'
       | '(' s clause ')'
	   | '(' s headclause ')'
	   | '(' s word ')'
	   | '(' s word clause ')'
	   | '(' s word headclause ')'
	   | '(' s word phrase ')'
	   | '(' s word headphrase ')' ;

/*clstart : '(' s ; */

phrase : '(' nonterminal word phrase ')'
       | '(' nonterminal word headphrase ')'
       | '(' nonterminal word clause ')'
       | '(' nonterminal phrase word ')'
       | '(' nonterminal headphrase word ')'
       | '(' nonterminal clause word ')'
       | '(' nonterminal phrase clause ')'
	   | '(' nonterminal phrase headclause ')'
       | '(' nonterminal headphrase clause ')'
       | '(' nonterminal clause headphrase ')'
       | '(' nonterminal clause phrase ')'
	   | '(' nonterminal headclause phrase ')'
       | '(' nonterminal word ')'
       | '(' nonterminal word word ')'
       | '(' nonterminal headphrase ')'
       | '(' nonterminal phrase ')'
       | '(' nonterminal clause ')'
	   | '(' nonterminal headclause ')'
       | '(' nonterminal headphrase phrase ')'
       | '(' nonterminal phrase headphrase ')' ;

/*phstart : '(' nonterminal ; */

word : '@' subword
     | subword

subword : '(' pos '@' terminal ')' { printf("%s ", $<str>4); } ;

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
