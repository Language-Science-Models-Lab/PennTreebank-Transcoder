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

//typedef int Token ;
%}

//%define parse.error verbose

%union {
  char *tok ;
  //  char *sval ;
}

%token <tok> POS_TOKEN ;
%token <tok> TERMINAL_TOKEN ;
%token <tok> NON_TERMINAL_TOKEN ;
%token <tok> HEAD_TOKEN ;
%token <tok> L_PAREN_TOKEN ;
%token <tok> R_PAREN_TOKEN ;
%token <tok> EOL_TOKEN ;
%token <tok> S_TOKEN ;

%start start ;

%debug

 //%define parse.lac full
//%define parse.error verbose
//		       %define parse.trace

%type <tok> sentence ;

%%
 /*
parsetree : parsetree pos | parsetree terminal | parsetree nonterminal | parsetree head | parsetree lparen | parsetree rparen | parsetree eol | parsetree s | pos | terminal | nonterminal | head | lparen | rparen | eol | s
 */

start : sentence
      | sentence start
      | eol start
      | start eol ;

sentence : lparen s phrase headphrase rparen eol { printf("\n"); }
	     | lparen s headphrase rparen eol { printf("\n"); } ;

headphrase : head phrase ;

phrase : lparen nonterminal word phrase rparen
       | lparen nonterminal word headphrase rparen	
       | lparen nonterminal phrase word rparen
       | lparen nonterminal headphrase word rparen	
       | lparen nonterminal word rparen 
       | lparen nonterminal word word rparen
       | lparen nonterminal headphrase rparen
       | lparen nonterminal phrase rparen
       | lparen nonterminal headphrase phrase rparen
       | lparen nonterminal phrase headphrase rparen ;

word : head lparen pos head terminal rparen { printf("%s ", $<tok>5); }
     | lparen pos head terminal rparen { printf("%s ", $<tok>4); } ;

pos : POS_TOKEN { } ;

terminal : TERMINAL_TOKEN { } ;

nonterminal : NON_TERMINAL_TOKEN { } ;

head : HEAD_TOKEN { } ;

lparen : L_PAREN_TOKEN { } ;

rparen : R_PAREN_TOKEN { } ;

eol : EOL_TOKEN { } ;

s : S_TOKEN {  } ;



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
/*
void yyerror(const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
	}*/

