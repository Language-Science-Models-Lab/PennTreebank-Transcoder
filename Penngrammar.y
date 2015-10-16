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

%%

 /*node:		lparen node rparen
	|	head node
	|	pos 
	|	nonterm
	;*/
parsetree : parsetree pos | parsetree terminal | parsetree nonterminal | parsetree head | parsetree lparen | parsetree rparen | parsetree eol | parsetree s | pos | terminal | nonterminal | head | lparen | rparen | eol | s

pos : POS_TOKEN { printf("POS token\n"); } ;

terminal : TERMINAL_TOKEN { printf("TERMINAL token\n"); } ;

nonterminal : NON_TERMINAL_TOKEN { printf("NON_TERMINAL token\n"); } ;

head : HEAD_TOKEN { printf("HEAD token\n"); } ;

lparen : L_PAREN_TOKEN { printf("L_PAREN token\n"); } ;

rparen : R_PAREN_TOKEN { printf("R_PAREN token\n"); } ;

eol : EOL_TOKEN { printf("EOL token\n"); } ;

s : S_TOKEN { printf("S token\n"); } ;

%%
int main(int argc, char** argv) {
	// open a file handle to given file:
  if ( argc > 1 ) {
	FILE *myfile = fopen( argv[1], "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open a.snazzle.file!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	
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

