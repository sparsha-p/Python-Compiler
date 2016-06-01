%{  
    #include <stdio.h>
	#include <string.h>
	#include <iostream>
	using namespace std;
	typedef struct line {
		int indent;
		string str;
	};
    
    #ifndef YYSTYPE
	#define YYSTYPE string
	#endif
    
    extern int  yylineno;
    extern char yytext[];
    int indent_level = 0;
    extern FILE* outFile_p;
    int noerror=1;
    int yylex(void);
    void yyerror(char* msg);
%}
%token MESSAGE CLASS
%token DEFINED   
%token DEF
%token NEWLINE
%token NAME
%token INDENT DEDENT
%token PRINT
%token FOR WHILE IF
%token BREAK CONTINUE RETURN
%token OPERA IN NOT OR AND STAR
%token LBRACE RBRACE LBRACKET RBRACKET COLON DOT COMMA
%token SUB ADD
%token INTEGER TRUE FALSE
//%type <ptr> funcname func_args_list func_arg func_code

%start single_input
%%
single_input: input 
	{
		$$ = $1;
		fprintf(outFile_p, "%s", $$.c_str());
	}
;	
input: /* empty */ 
     | input NEWLINE { $$ = $1 + ";" + $2; }
     | input stmt { $$ = $1 + $2; }
     | input error {}
;

stmt: simple_stmt { $$ = $1;}
	| compound_stmt { $$ = $1;}
;
simple_stmt: small_stmt NEWLINE { $$ = $1 + ";" + $2; }
;
small_stmt: flow_stmt { $$ = $1; }
	| print_stmt { $$ = $1; }
	| expr_stmt { $$ = $1; }
;

flow_stmt: return_stmt { $$ = $1; }
;
print_stmt: PRINT NAME { $$ = "print " + $2; }
;
expr_stmt: comparison { $$ = $1; }
; 
return_stmt: RETURN flag { $$ = "return " + $2; }
;
flag: TRUE { $$ = "true"; }
	| FALSE { $$ = "false"; }
;

compound_stmt: for_stmt { $$ = $1; }
	| if_stmt { $$ = $1; }
	| funcdef { $$ = $1; }
;

/* function */
funcdef: DEF NAME parameters COLON suite
	{
		$$ = "function " + $2 + $3 + $5;
	}
;
parameters: LBRACE varargslist RBRACE
	{
		$$ = "(" + $2 + ")";
	}
;	
varargslist: /* empty */
	| NAME { $$ = $1; }
	| varargslist COMMA NAME { $$ = $1 + "," + $3; }
;

/* for */
for_stmt: FOR exprlist IN func_call COLON suite
	{
		$$ = "for (" + $2 + "=0;" + $2 + "<" + $4 + ";" + $2 + "++) " + $6; 
	}
;
exprlist: NAME { $$ = $1; }
	| NAME COMMA NAME { $$ = $1 + "," + $3; }
;
func_call: NAME { $$ = $1; }
	| NAME LBRACE NAME RBRACE 
	{ 
		if ($1 == "len") {
			$$ = $3 + ".length";
		} else if ( $1 == "range" ){
			$$ = $3;
		} else {
			$$ = $1 + "(" + $3 + ")";
		}
	}
;

/* if */
if_stmt: IF test COLON suite
	{
		$$ = "if (" + $2 + ")" + $4;
	}
;
test: or_test { $$ = $1; }
;
or_test: and_test { $$ = $1; }
	| or_test OR and_test { $$ = $1 + " || " + $3;}
;
and_test: not_test { $$ = $1; }
	| and_test AND not_test { $$ = $1 + " && " + $3; }
;
not_test: NOT not_test { $$ = "!" + $2; }
	| comparison { $$ = $1; }
;
comparison: expr { $$ = $1; }
	| comparison OPERA expr { $$ = $1 + $2 + $3; }
;
expr: func_call { $$ = $1; }
	| array_call { $$ = $1; }
;
array_call: NAME LBRACKET arith_expr RBRACKET 
	{ 
		$$ = $1 + "[" + $3 + "]";
	}
;	
arith_expr: variable { $$ = $1;}
	| arith_expr ADD variable { $$ = $1 + "+" + $3; }
	| arith_expr SUB variable { $$ = $1 + "-" + $3; }
;
variable: NAME { $$ = $1; }
	| INTEGER { $$ = $1; }
;

/* suite */
suite: NEWLINE INDENT stmt_plus DEDENT
	{
		$$ = $1 + "{" + $1 + $3 + "}" + $1;
	}
;
stmt_plus: stmt { $$ = $1; }
	| stmt_plus stmt { $$ = $1 + $2; }
;
%%
extern void yyerror(char* msg) {
    noerror=0;
    if(strcmp(msg,"syntax error"))
        printf(" Syntax Error in Line : %d : %s\n",yylineno,msg);
}
