%{
// Parser file to convert Penn Treebank into lambek calculus
// by Joseph Nunn and Sean Fulop, 2015

#include <cstdio>
#include <iostream>
#include <cstdarg>
#include <string>
#include <stdlib.h>
#include <stack>
#include <map>
#include <list>

using namespace std;
 
extern "C" int yylex() ;
extern "C" int yyparse() ;
extern "C" FILE *yyin ;

// Sets type info generation debugging flag
#define TDEBUG
// Uncomment undef here to turn off type info generation debugging messages
//#undef TDEBUG
 
#define SIZEOF_ARRAY( a ) ( sizeof( a ) / sizeof( a[ 0 ] ) )
 
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

// List of lefthand side rule names, if you add a new rule add the name to the list here to be able to use it in the grammar for generating type info!
char const *ruleNames[] = { "start"
						  , "eolf"
						  , "headphrase"
						  , "headclause"
						  , "clause"
						  , "phrase"
						  , "word"
						  , "subword"
						  , "s"
						  , "pause"
						  , "terminal"
						  , "nonterminal" } ;
 
list <string> rules( ruleNames, ruleNames + SIZEOF_ARRAY( ruleNames ) );
 
// Need a stack for each lefthand side name
map < const string, stack <string> > rulestacks ;

// Populate rulename to stack mapping
void makeRuleStacks( list <string> ruleList ) {
  for ( list<string>::iterator name = ruleList.begin() ; name != ruleList.end() ; ++name ) {
	rulestacks.insert( pair< const string, stack <string> >( *name, stack <string>() ) ) ;
  }
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
start : clause eolf { printf( "%s:%s\n", $1, rulestacks[ "clause" ].top().c_str() ) ;
                      rulestacks[ "clause" ].pop() ; } ;
      | start clause eolf { printf("%s:%s\n", $2, rulestacks[ "clause" ].top().c_str() ) ;
                            rulestacks[ "clause" ].pop() ; } ;
	  | eolf
	  | start '\n' ;

eolf : '\n'
     | "End of File" ;

headphrase : '@' phrase { $$ = $2 ;
                          rulestacks[ "headphrase" ].push( rulestacks[ "phrase" ].top().c_str() ) ;
	                      rulestacks[ "phrase" ].pop() ;
                          #ifdef TDEBUG
						     printf( "in headphrase rule: top of stack is %s\n", rulestacks[ "headphrase" ].top().c_str() ) ;
                          #endif
                        } ;

headclause : '@' clause { $$ = $2 ;
                          rulestacks[ "headclause" ].push( rulestacks[ "clause" ].top().c_str() ) ;
	                      rulestacks[ "clause" ].pop() ;
                          #ifdef TDEBUG
						     printf( "in headclause rule: top of stack is %s\n", rulestacks[ "headclause" ].top().c_str() ) ;
						  #endif
                        } ;

clause : '(' s phrase headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                       rulestacks[ "clause" ].push( output( "type(%s@%s, s)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ) ;
                                       rulestacks[ "headphrase" ].pop() ;
		                               rulestacks[ "phrase" ].pop() ;
                                       #ifdef TDEBUG
									      printf( "in clause rule 1: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
                                     } ;
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

phrase : '(' nonterminal word phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           rulestacks[ "phrase" ].push( output( "type(%s@%s)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ) ;
                                           rulestacks[ "word" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;
										   #ifdef TDEBUG
                                              printf( "in phrase rule 1: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                           #endif
                                         } ;
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
       | '(' nonterminal word ')' { $$ = $3 ;
                                    rulestacks[ "phrase" ].push( output( "type(%s, _)", 1, rulestacks[ "word" ].top().c_str() ) ) ;
		                            rulestacks[ "word" ].pop() ;
									#ifdef TDEBUG
		                               printf( "in phrase rule 13: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
		                            #endif
		                          } ;
       | '(' nonterminal word word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal headphrase ')' { $$ = $3 ; } ;
       | '(' nonterminal phrase ')' { $$ = $3 ; } ;
       | '(' nonterminal clause ')' { $$ = $3 ; } ;
	   | '(' nonterminal headclause ')' { $$ = $3 ; } ;
       | '(' nonterminal headphrase phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;
       | '(' nonterminal phrase headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ; } ;

/*phstart : '(' nonterminal ; */

word : '@' subword { $$ = $2 ;
                     rulestacks[ "word" ].push( rulestacks[ "subword" ].top().c_str() ) ;
                     rulestacks[ "subword" ].pop() ;
					 #ifdef TDEBUG
                        printf( "in word rule 1: top of stack is %s\n", rulestacks[ "word" ].top().c_str() ) ;
                     #endif
                   } ;
     | subword { $$ = $1 ;
                 rulestacks[ "word" ].push( rulestacks[ "subword" ].top().c_str() ) ;
	             rulestacks[ "subword" ].pop() ;
				 #ifdef TDEBUG
	                printf( "in word rule 2: top of stack is %s\n", rulestacks[ "word" ].top().c_str() ) ;
	             #endif
	   } ;

subword : '(' pos '@' terminal ')' { $$ = $4 ;
                                     rulestacks[ "subword" ].push( output( "type(%s, _)", 1, rulestacks[ "terminal" ].top().c_str() ) ) ;
                                     rulestacks[ "terminal" ].pop() ;
									 #ifdef TDEBUG
                                        printf( "in subword rule: top of stack is %s\n", rulestacks[ "subword" ].top().c_str() ) ;
                                     #endif
                                   } ;

s : S_TOKEN {} ;

pos : POS_TOKEN {} ;

terminal : TERMINAL_TOKEN { rulestacks[ "terminal" ].push( $1 ) ;
                            #ifdef TDEBUG
                               printf( "in terminal rule: top of stack is %s\n", rulestacks[ "terminal" ].top().c_str() ) ;
                            #endif
                          } ;

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

	// Configure the rule stacks	
	makeRuleStacks( rules ) ;
	
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
  } else yyerror( "No input file specified!\n" ) ;
}
