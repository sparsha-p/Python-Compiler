%{  
    #include "dstruct.h"
    #ifndef YYSTYPE
	#define YYSTYPE line
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
%token NEWLINE
%token NAME
%token INDENT DEDENT
%token PRINT
%token DEF FOR WHILE IF
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
		$$.s = $1.s;
		fprintf(outFile_p, "%s", $$.s.c_str());
	}
;	
input: /* empty */ 
     | input NEWLINE { $$.s = $1.s + ";" + $2.s; }
     | input stmt    { $$.s = $1.s + $2.s; }
     | input error {}
;

stmt: simple_stmt 
	{ 
		addTab($$.s, $1.i);
		$$.s += $1.s;
	}
	| compound_stmt 
	{ 
		addTab($$.s, $1.i);
		$$.s += $1.s;
	}
;
simple_stmt: small_stmt NEWLINE 
	{
		$$.i = $1.i; 
		$$.s = $1.s + ";" + $2.s; 
	}
;
small_stmt: flow_stmt { $$ = $1; }
	| print_stmt { $$ = $1; }
	| expr_stmt { $$ = $1; }
;

flow_stmt: return_stmt { $$ = $1; }
;
print_stmt: PRINT NAME 
	{
		$$.i = $1.i; 
		$$.s = "print " + $2.s; 
	}
;
expr_stmt: comparison { $$ = $1; }
; 
return_stmt: RETURN flag 
	{
		$$.i = $1.i; 
		$$.s = "return " + $2.s; 
	}
;
flag: TRUE { $$.s = "true"; }
	| FALSE { $$.s = "false"; }
;

compound_stmt: for_stmt { $$ = $1; }
	| if_stmt { $$ = $1; }
	| funcdef { $$ = $1; }
	| while_stmt {$$ = $1; }
;

/* function */
funcdef: DEF NAME parameters COLON suite
	{
		$$.i = $1.i;
		$$.s = "function " + $2.s + $3.s + $5.s;
	}
;
parameters: LBRACE varargslist RBRACE
	{
		$$.s = "(" + $2.s + ")";
	}
;	
varargslist: /* empty */
	| NAME { $$.s = $1.s; }
	| varargslist COMMA NAME { $$.s = $1.s + "," + $3.s; }
;

/* for */
for_stmt: FOR exprlist IN func_call COLON suite
	{
		$$.i = $1.i;
		$$.s = "for (" + $2.s + "=0;" + $2.s + "<" + $4.s + ";" + $2.s + "++)" + $6.s; 
	}
;
exprlist: NAME { $$.s = $1.s; }
	| NAME COMMA NAME { $$.s = $1.s + "," + $3.s; }
;
func_call: variable { $$ = $1; }
	| NAME LBRACE NAME RBRACE 
	{ 
		$$.i = $1.i;
		if ($1.s == "len") {
			$$.s = $3.s + ".length";
		} else if ( $1.s == "range" ){
			$$.s = $3.s;
		} else {
			$$.s = $1.s + "(" + $3.s + ")";
		}
	}
;

/* if */
if_stmt: IF test COLON suite
	{
		$$.i = $1.i;
		$$.s = "if (" + $2.s + ")" + $4.s;
	}
;
test: or_test { $$.s = $1.s; }
;
or_test: and_test { $$.s = $1.s; }
	| or_test OR and_test { $$.s = $1.s + " || " + $3.s;}
;
and_test: not_test { $$.s = $1.s; }
	| and_test AND not_test { $$.s = $1.s + " && " + $3.s; }
;
not_test: NOT not_test { $$.s = "!" + $2.s; }
	| comparison { $$.s = $1.s; }
;
comparison: expr { $$ = $1; }
	| comparison OPERA expr 
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s; 
	}
;
expr: func_call { $$ = $1; }
	| array_call { $$ = $1; }
;
array_call: NAME LBRACKET arith_expr RBRACKET 
	{
		$$.i = $1.i; 
		$$.s = $1.s + "[" + $3.s + "]";
	}
;	
arith_expr: variable { $$.s = $1.s;}
	| arith_expr ADD variable { $$.s = $1.s + "+" + $3.s; }
	| arith_expr SUB variable { $$.s = $1.s + "-" + $3.s; }
;
variable: NAME { $$.s = $1.s; }
	| INTEGER { $$.s = $1.s; }
;

/* while */
while_stmt: WHILE test COLON suite
	{
		$$.i = $1.i;
		$$.s = "while (" + $2.s + ")" + $4.s;
	}
;	

/* suite */
suite: NEWLINE INDENT stmt_plus DEDENT
	{
		string tmp;
		addTab(tmp, $3.i-1);
		$$.s = " {" + $1.s + $3.s + tmp + "}" + $1.s;
	}
;
stmt_plus: stmt { $$ = $1; }
	| stmt_plus stmt 
	{ 
		$$.i = $1.i;
		$$.s = $1.s + $2.s; 
	}
;
%%
extern void yyerror(char* msg) {
    noerror=0;
    if(strcmp(msg,"syntax error"))
        printf(" Syntax Error in Line : %d : %s\n",yylineno,msg);
}
