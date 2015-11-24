%{
// Parser file to convert Penn Treebank into lambek calculus
// by Joseph Nunn and Sean Fulop, 2015

#include <cstdio>
#include <iostream>
#include <cstdarg>
#include <string.h>
#include <stdlib.h>

using namespace std;
 
extern "C" int yylex() ;
extern "C" int yyparse() ;
extern "C" FILE *yyin ;

void yyerror( const char *msg ) {
  fprintf(stderr, "%s\n", msg) ;
}
 
// Outputs desired format string with args subbed in, please explicitly terminate string with null character '\0'
inline char* output( const char* format, int numArgs, ... ) {
  int argLengths, index ;
  va_list args, argCopy ;

  argLengths = 0 ;
  va_start( args, numArgs ) ;

  // Compute number and total length of all arg strings
  va_copy( argCopy, args ) ;
  for ( index = 0 ; index < numArgs ; index++ ) { 
	argLengths += strlen( va_arg( argCopy, char* ) ) ;
  }
  va_end( argCopy ) ;

  // Subtact the number of args to print * 2, the characters replaced in the format string
  char* temp = (char*)malloc( strlen( format ) + argLengths - ( numArgs * 2 ) + 1 ) ;
  vsprintf( temp, format, args ) ;

  va_end( args ) ;
  return temp ;
}

// Holds pointer to type information as parse happens like the $$ variable
char* typeInfo ;
 
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
start : clause eolf { printf( "%s:\n", $1 ) ; } ;
      | start clause eolf { printf("%s:\n", $2 ) ; } ;
	  | eolf
	  | start '\n' ;

eolf : '\n'
     | "End of File" ;

headphrase : '@' phrase { $$ = $2 ; } ;

headclause : '@' clause { $$ = $2 ; } ;

clause : '(' s phrase headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s phrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s phrase headclause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
	   | '(' s headphrase ')' { $$ = $3 ; }
       | '(' s headphrase phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s headphrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s phrase ')' { $$ = $3 ; } ;
       | '(' s clause ')' { $$ = $3 ; } ;
	   | '(' s headclause ')' { $$ = $3 ; } ;
	   | '(' s word ')' { $$ = $3 ; } ;
       | '(' s word clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s word headclause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s word phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' s word headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;

/*clstart : '(' s ; */

phrase : '(' nonterminal word phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal word headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal word clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal phrase word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal headphrase word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal clause word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal phrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal phrase headclause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal headphrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal clause headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal clause phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal headclause phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal word ')' { $$ = $3 ; } ;
       | '(' nonterminal word word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal headphrase ')' { $$ = $3 ; } ;
       | '(' nonterminal phrase ')' { $$ = $3 ; } ;
       | '(' nonterminal clause ')' { $$ = $3 ; } ;
	   | '(' nonterminal headclause ')' { $$ = $3 ; } ;
       | '(' nonterminal headphrase phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal phrase headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;

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
