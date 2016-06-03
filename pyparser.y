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
%token QUOTED
%token DEFINED
%token NEWLINE
%token NAME
%token INDENT DEDENT
%token PRINT
%token DEF FOR WHILE IF ELSE ELIF
%token BREAK CONTINUE RETURN
%token OPERA IN NOT OR AND STAR DIVIDE EQ
%token AUGASSIGN
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
	| continue_stmt { $$ = $1; }
	| expr_stmt { $$ = $1; }
;

flow_stmt: return_stmt { $$ = $1; }
;
print_stmt: PRINT expr 
	{
		$$.i = $1.i; 
		$$.s = "console.log(" + $2.s + ")"; 
	}
;
continue_stmt: CONTINUE { 
        $$.i = $1.i;
        $$.s = "continue"; 
    }
;
expr_stmt: test_list AUGASSIGN test_list 
	{ 
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s;
	}
	| rightside { $$ = $1; }
;
rightside: test_list { $$ = $1; }
	| rightside EQ test_list
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s;
	}
;
return_stmt: RETURN flag 
	{
		$$.i = $1.i; 
		$$.s = "return " + $2.s; 
	}
	| RETURN variable
	{
	    $$.i = $1.i;
	    $$.s = "return " + $2.s;
	}
;
flag: TRUE { $$.s = "true"; }
	| FALSE { $$.s = "false"; }
;

compound_stmt: for_stmt { $$ = $1; }
    | if_elif_else_stmt { $$ = $1; }
    | if_elif_stmt { $$ = $1; }
    | if_else_stmt { $$ = $1; }
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
		$$.s = $1.s + $2.s + $3.s;
	}
;	
varargslist: /* empty */
	| NAME { $$.s = $1.s; }
	| varargslist COMMA NAME { 	$$.s = $1.s + $2.s + $3.s; }
;

/* for */
for_stmt: FOR exprlist IN test_list COLON suite
	{
		$$.i = $1.i;
		$$.s = "for (" + $2.s + "=0;" + $2.s + "<" + $4.s + ";" + $2.s + "++)" + $6.s; 
	}
;
exprlist: NAME { $$.s = $1.s; }
	| NAME COMMA NAME { $$.s = $1.s + $2.s + $3.s; }
;
/* if-elif-else */
if_elif_else_stmt: IF test COLON suite elif_stmt else_stmt
    {
        $$.i = $1.i;
        $$.s = "if (" + $2.s + ")" + $4.s + $5.s + $6.s;   
    }
;
elif_stmt: ELIF test COLON suite
    {
        string tmp;
		addTab(tmp, $1.i);
        $$.s = tmp + "else if (" + $2.s + ")" + $4.s;   
    }
    | elif_stmt ELIF test COLON suite 
    {
        string tmp;
		addTab(tmp, $2.i);
        $$.s = $1.s + tmp + "else if (" + $3.s + ")" + $5.s;
    }
;
else_stmt: ELSE COLON suite
    {
        string tmp;
		addTab(tmp, $1.i);
        $$.s = tmp + "else" + $3.s;    
    }
;
/* if-elif */
if_elif_stmt: IF test COLON suite elif_stmt
    {
        $$.i = $1.i;
        $$.s = "if (" + $2.s + ")" + $4.s + $5.s;   
    }
;
/* if-else */
if_else_stmt: IF test COLON suite else_stmt
    {
        $$.i = $1.i;
        $$.s = "if (" + $2.s + ")" + $4.s + $5.s;   
    }
;
/* if */
if_stmt: IF test COLON suite
	{
		$$.i = $1.i;
		$$.s = "if (" + $2.s + ")" + $4.s;
	}
;

/* expression */
test_list: test { $$ = $1; }
	| test_list COMMA test 
	{
		$$.i = $1.i;
		$$.s = $1.s + $2.s + $3.s;
	}
;
test: or_test { $$ = $1; }
;
or_test: and_test { $$ = $1; }
	| or_test OR and_test 
	{ 
		$$.i = $1.i;
		$$.s = $1.s + " || " + $3.s;
	}
;
and_test: not_test { $$ = $1; }
	| and_test AND not_test 
	{ 
		$$.i = $1.i;
		$$.s = $1.s + " && " + $3.s; 
	}
;
not_test: NOT not_test { $$.s = "!" + $2.s; }
	| comparison { $$ = $1; }
;
comparison: expr { $$ = $1; }
	| expr comp_op comparison
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s; 
	}
;
comp_op: OPERA { $$ = $1; }
;
expr: term { $$ = $1; }
	| term ADD expr
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s; 	
	}
	| term SUB expr
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s;
	}
	| term STAR expr
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s;
	}
	| term DIVIDE expr
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s;
	}
;
term: factor { $$ = $1; }
	| factor STAR term
	{
		$$.i = $1.i; 
		$$.s = $1.s + $2.s + $3.s;
	}
;	
factor: atom { $$ = $1; }
;
atom: LBRACE test RBRACE
    {
        $$.s = $1.s + $2.s + $3.s;
    }
    | LBRACE expr RBRACE
	{
		$$.s = $1.s + $2.s + $3.s;
	}
	| LBRACKET RBRACKET
	{
	    $$.s = $1.s + $2.s;
	}
	| LBRACKET expr RBRACKET
	{
		$$.s = $1.s + $2.s + $3.s;
	}
	| expr DOT NAME LBRACE RBRACE
	{
	    if ($3.s == "isdigit") {
	        $$.i = $1.i;
	        $$.s = "!isNaN(" + $1.s + ")";
	    } else if ($1.s == "pop") {
			$$.s = $1.s + $2.s + "pop" + $4.s + $5.s;
		} else {
		    $$.s = $1.s + $2.s + $3.s + $4.s + $5.s;
		}
	}
	| expr DOT expr 
	{
		$$.i = $1.i;
		$$.s = $1.s + $2.s + $3.s;
	}
	| func_call { $$ = $1; }
	| array_call { $$ = $1; }
	| variable { $$ = $1; }
;
func_call: NAME LBRACE expr RBRACE 
	{ 
		$$.i = $1.i;
		if ($1.s == "len") {
			$$.s = $3.s + ".length";
		} else if ( $1.s == "range" ) {
			$$.s = $3.s;
		} else if ( $1.s == "list") {
			$$.s = $3.s;
		} else if ($1.s == "append") {
			$$.s = "push" + $2.s + $3.s + $4.s;
		} else if ($1.s == "ord") {
		    $$.s = $3.s + ".charCodeAt" + $2.s + $4.s; 
		} else if ($1.s == "float") {
		    $$.s = "parseFloat" + $2.s + $3.s + $4.s; 
		} else if ($1.s == "str") {
		    $$.s = $3.s + ".toString" + $2.s + $4.s; 
		} else {
			$$.s = $1.s + $2.s + $3.s + $4.s;
		}
	}
;
array_call: NAME LBRACKET expr RBRACKET
	{
		$$.i = $1.i;
		$$.s = $1.s + $2.s + $3.s + $4.s;
	}
	| NAME LBRACKET expr COLON expr RBRACKET
	{
	    $$.i = $1.i;
	    $$.s = $1.s + ".slice(" + $3.s + "," + $5.s + ")"; 
	}
;
variable: NAME { $$ = $1; }
	| INTEGER { $$ = $1; }
	| QUOTED { $$ = $1; }
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
