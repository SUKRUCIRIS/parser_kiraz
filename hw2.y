%{
#include <kiraz/stmt.h>
#include <kiraz/hw2-lexer.hpp>

int yyerror(const char *s);

#define YYSTYPE std::shared_ptr<kiraz::Stmt>
#define YYDEBUG 1

#define YY_USER_ACTION                                       \
  yylloc.first_line = yylloc.last_line;                      \
  yylloc.first_column = yylloc.last_column;                  \
  if (yylloc.first_line == yylineno)                         \
     yylloc.last_column += yyleng;                           \
  else {                                                     \
     int col;                                                \
     for (col = 1; yytext[yyleng - col] != '\n'; ++col) {}   \
     yylloc.last_column = col;                               \
     yylloc.last_line = yylineno;                            \
  }
  std::shared_ptr<kiraz::Stmt> new_number;
  unsigned char new_started=1;
%}

%locations

%token    IDENTIFIER

// Operators
%token    OP_RETURNS
%token    OP_EQUALS
%token    OP_ASSIGN
%token    OP_GT
%token    OP_LT
%token    OP_GE
%token    OP_LE
%token    OP_LPAREN
%token    OP_RPAREN
%token    OP_LBRACE
%token    OP_RBRACE
%token    OP_COLON
%token    OP_PLUS
%token    OP_MINUS
%token    OP_MULT
%token    OP_DIVF
%token    OP_COMMA
%token    OP_NEWLINE
%token    OP_SCOLON
%token    OP_DOT
%token    OP_NOT

// Literals
%token    L_INTEGER
%token    L_STRING
%token    L_BOOLEAN

// Keywords
%token    KW_IF
%token    KW_FUNC
%token    KW_WHILE
%token    KW_CLASS
%token    KW_IMPORT

%%

input: 	%empty
		| second{new_started=1;}
		| input OP_NEWLINE{new_started=1;}
		| input OP_SCOLON{new_started=1;}
		;

second: second OP_PLUS first { kiraz::Stmt::add<kiraz::stmt::Operator>(0,kiraz::Stmt::get_root(),new_number); }
		| second OP_MINUS first { kiraz::Stmt::add<kiraz::stmt::Operator>(1,kiraz::Stmt::get_root(),new_number); }
		| first
		;

first: 	first OP_MULT paran { kiraz::Stmt::add<kiraz::stmt::Operator>(2,kiraz::Stmt::get_root(),new_number); }
		| first OP_DIVF paran { kiraz::Stmt::add<kiraz::stmt::Operator>(3,kiraz::Stmt::get_root(),new_number); }
		| paran
		;

paran: 	OP_LPAREN second OP_RPAREN
		| int

int: posi_int {
	new_number=std::make_shared<kiraz::stmt::Integer>(kiraz::stmt::Integer(true, kiraz::Token::last()));
	if(new_started==1){
		kiraz::Stmt::add<kiraz::stmt::Integer>(true, kiraz::Token::last());
		new_started=0;
	}
	}
	| nega_int {
		new_number=std::make_shared<kiraz::stmt::Integer>(kiraz::stmt::Integer(false, kiraz::Token::last()));
		if(new_started==1){
			kiraz::Stmt::add<kiraz::stmt::Integer>(false, kiraz::Token::last());
			new_started=0;
		}
		}
	;

posi_int: 	L_INTEGER
			| OP_PLUS L_INTEGER
			; 

nega_int: 	OP_MINUS L_INTEGER;

%%

int yyerror(const char *s) {
    fmt::print("** Parser Error at line# {} char# {}. Current token: {}\n", yylineno, yylloc.first_column, kiraz::Token::last().get_repr());
    kiraz::Stmt::reset_root();
    return 1;
}
