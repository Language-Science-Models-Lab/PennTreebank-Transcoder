%{
// Parser file to convert Penn Treebank into lambek calculus
// by Joseph Nunn and Sean Fulop, 2015
  
#include <iostream> //Must include for building on OSX
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include <stdlib.h>
#include <stack>
#include <map>
#include <list>

using namespace std;
 
extern "C" int yylex() ;
extern "C" int yyparse() ;
extern "C" FILE *yyin ;
 
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

// Holds the built string for pushing on a rulestack before popping
char* result ;

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

eolf : '\n' { $$ = (char*)"\n" ; }
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
                                       result = output( "type(%s@%s, s)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
    								   rulestacks[ "headphrase" ].pop() ;
		                               rulestacks[ "phrase" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;
                                      
                                       #ifdef TDEBUG
									      printf( "in clause rule 1: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
                                     } ;
       | '(' s phrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                   result = output( "type(%s@%s, s)", 2, rulestacks[ "clause" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                                           rulestacks[ "clause" ].pop() ;
		                               rulestacks[ "phrase" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 2: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
                                     } ;
       | '(' s phrase headclause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                       result = output( "type(%s@%s, s)", 2, rulestacks[ "headclause" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                                             rulestacks[ "headclause" ].pop() ;
		                               rulestacks[ "phrase" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 3: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
	   | '(' s headphrase ')' { $$ = $3 ; 
                                    rulestacks[ "clause" ].push( output( "type(%s, s)", 1, rulestacks[ "headphrase" ].top().c_str() ) ) ;
		                            rulestacks[ "headphrase" ].pop() ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 4: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s headphrase phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                       result = output( "type(%s@%s, s)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                                              rulestacks[ "headphrase" ].pop() ;
		                               rulestacks[ "phrase" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 5: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s headphrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                       result = output( "type(%s@%s, s)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                                              rulestacks[ "headphrase" ].pop() ;
		                               rulestacks[ "clause" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 6: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s phrase ')' { $$ = $3 ;
                            rulestacks[ "clause" ].push( output( "type(%s, s)", 1, rulestacks[ "phrase" ].top().c_str() ) ) ;
		                            rulestacks[ "phrase" ].pop() ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 7: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s clause ')' { $$ = $3 ;
                            const char* tword = rulestacks[ "clause" ].top().c_str() ;
										 rulestacks[ "clause" ].pop() ;

                            rulestacks[ "clause" ].push( output( "type(%s, s)", 1, tword ) ) ;
		        
                                       #ifdef TDEBUG
									      printf( "in clause rule 8: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
	   | '(' s headclause ')' { $$ = $3 ;
                            rulestacks[ "clause" ].push( output( "type(%s, s)", 1, rulestacks[ "headclause" ].top().c_str() ) ) ;
		                            rulestacks[ "headclause" ].pop() ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 9: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
	   | '(' s word ')' { $$ = $3 ;
                            rulestacks[ "clause" ].push( output( "type(%s, s)", 1, rulestacks[ "word" ].top().c_str() ) ) ;
		                            rulestacks[ "word" ].pop() ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 10: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s word clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                 result = output( "type(%s@%s, s)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                                             rulestacks[ "clause" ].pop() ;
		                               rulestacks[ "word" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 11: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s word headclause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                     result = output( "type(%s@%s, s)", 2, rulestacks[ "headclause" ].top().c_str(), rulestacks[ "word" ].top().c_str() ) ;
                                                             rulestacks[ "word" ].pop() ;
		                               rulestacks[ "headclause" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 12: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
							           #endif
 } ;
       | '(' s word phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                 result = output( "type(%s@%s, s)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                                             rulestacks[ "phrase" ].pop() ;
		                               rulestacks[ "word" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 13: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
                                                                   #endif
 } ;
       | '(' s word headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                     result = output( "type(%s@%s, s)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "word" ].top().c_str() ) ;
                                                             rulestacks[ "word" ].pop() ;
		                               rulestacks[ "headphrase" ].pop() ;
                                       rulestacks[ "clause" ].push( result ) ;

                                       #ifdef TDEBUG
									      printf( "in clause rule 14: top of stack is %s\n", rulestacks[ "clause" ].top().c_str() ) ;
                                                                   #endif
 } ;

/*clstart : '(' s ; */

phrase : '(' nonterminal word phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                           rulestacks[ "word" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;
                                       
										   #ifdef TDEBUG
                                              printf( "in phrase rule 1: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                           #endif
                                         } ;
       | '(' nonterminal word headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "headphrase" ].top().c_str() ) ;
                                           rulestacks[ "word" ].pop() ;
		                                   rulestacks[ "headphrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;
 
                                               #ifdef TDEBUG
                                                  printf( "in phrase rule 2: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
		                                       } ;
       | '(' nonterminal word clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                           rulestacks[ "word" ].pop() ;
		                                   rulestacks[ "clause" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;
 											   #ifdef TDEBUG
                                                  printf( "in phrase rule 3: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
											  } ;
       | '(' nonterminal phrase word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                           rulestacks[ "word" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;
 											   #ifdef TDEBUG
                                                  printf( "in phrase rule 4: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
											  } ;
       | '(' nonterminal headphrase word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "word" ].top().c_str() ) ;
                                           rulestacks[ "headphrase" ].pop() ;
		                                   rulestacks[ "word" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;
 											   #ifdef TDEBUG
                                                  printf( "in phrase rule 5: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
											  } ;
       | '(' nonterminal clause word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "word" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                           rulestacks[ "word" ].pop() ;
		                                   rulestacks[ "clause" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;
											   #ifdef TDEBUG
                                                  printf( "in phrase rule 6: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
											  } ;
       | '(' nonterminal phrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "phrase" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                           rulestacks[ "phrase" ].pop() ;
		                                   rulestacks[ "clause" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;		
										   #ifdef TDEBUG
                                                  printf( "in phrase rule 7: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
											  } ;
       | '(' nonterminal phrase headclause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headclause" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                           rulestacks[ "headclause" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	
											   #ifdef TDEBUG
                                                  printf( "in phrase rule 8: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                               #endif
											  } ;
       | '(' nonterminal headphrase clause ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                           rulestacks[ "headphrase" ].pop() ;
		                                   rulestacks[ "clause" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	
											     #ifdef TDEBUG
                                                    printf( "in phrase rule 9: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                                 #endif
											  } ;
       | '(' nonterminal clause headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                           rulestacks[ "headphrase" ].pop() ;
		                                   rulestacks[ "clause" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	

											     #ifdef TDEBUG
                                                    printf( "in phrase rule 10: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                                 #endif
											  } ;
       | '(' nonterminal clause phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "phrase" ].top().c_str(), rulestacks[ "clause" ].top().c_str() ) ;
                                           rulestacks[ "phrase" ].pop() ;
		                                   rulestacks[ "clause" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	

											     #ifdef TDEBUG
                                                    printf( "in phrase rule 11: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                                 #endif
											  } ;
       | '(' nonterminal headclause phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headclause" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                           rulestacks[ "headclause" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	

											     #ifdef TDEBUG
                                                    printf( "in phrase rule 12: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                                 #endif
									           } ;
       | '(' nonterminal word ')' { $$ = $3 ;
                                    rulestacks[ "phrase" ].push( output( "%s", 1, rulestacks[ "word" ].top().c_str() ) ) ;
		                            rulestacks[ "word" ].pop() ;
									#ifdef TDEBUG
		                               printf( "in phrase rule 13: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
		                            #endif
		                          } ;
       | '(' nonterminal word word ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                         const char* tword = rulestacks[ "word" ].top().c_str() ;
										 rulestacks[ "word" ].pop() ;
										 const char* bword = rulestacks[ "word" ].top().c_str() ;
										 rulestacks[ "word" ].pop() ;
                                         result = output( "type(%s@%s, _)", 2, tword, bword ) ;               
                                         rulestacks[ "phrase" ].push( result ) ;	

										 #ifdef TDEBUG
                                            printf( "in phrase rule 14: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                         #endif
									 } ;
       | '(' nonterminal headphrase ')' { $$ = $3 ;
                                    rulestacks[ "phrase" ].push( output( "%s", 1, rulestacks[ "headphrase" ].top().c_str() ) ) ;
		                            rulestacks[ "headphrase" ].pop() ;

										  #ifdef TDEBUG
                                             printf( "in phrase rule 15: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                          #endif
									 } ;
       | '(' nonterminal phrase ')' { $$ = $3 ;
                                    rulestacks[ "phrase" ].push( output( "%s", 1, rulestacks[ "phrase" ].top().c_str() ) ) ;
		                            rulestacks[ "phrase" ].pop() ;

									  #ifdef TDEBUG
                                         printf( "in phrase rule 16: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                      #endif
									 } ;
       | '(' nonterminal clause ')' { $$ = $3 ;
                                    rulestacks[ "phrase" ].push( output( "%s", 1, rulestacks[ "clause" ].top().c_str() ) ) ;
		                            rulestacks[ "clause" ].pop() ;

									  #ifdef TDEBUG
                                         printf( "in phrase rule 17: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                      #endif
									 } ;
	   | '(' nonterminal headclause ')' { $$ = $3 ;
                                    rulestacks[ "phrase" ].push( output( "%s", 1, rulestacks[ "headclause" ].top().c_str() ) ) ;
		                            rulestacks[ "headclause" ].pop() ;

										  #ifdef TDEBUG
                                             printf( "in phrase rule 18: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                          #endif
										 } ;
       | '(' nonterminal headphrase phrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                           rulestacks[ "headphrase" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	
										     	 #ifdef TDEBUG
                                                    printf( "in phrase rule 19: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                                 #endif
											     } ;
       | '(' nonterminal phrase headphrase ')' { $$ = output( "[%s %s]", 2, $3, $4 ) ;
                                           result = output( "type(%s@%s, _)", 2, rulestacks[ "headphrase" ].top().c_str(), rulestacks[ "phrase" ].top().c_str() ) ;
                                           rulestacks[ "headphrase" ].pop() ;
		                                   rulestacks[ "phrase" ].pop() ;               
                                           rulestacks[ "phrase" ].push( result ) ;	

											     #ifdef TDEBUG
                                                    printf( "in phrase rule 20: top of stack is %s\n", rulestacks[ "phrase" ].top().c_str() ) ;
                                                 #endif
											    } ;

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
	  printf( "Can't open input file!" ) ;
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
