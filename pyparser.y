%{  

    #include<stdio.h>
    #include <string.h>
    #include <iostream>
    using namespace std;
    #ifndef YYSTYPE
    #define YYSTYPE string  
    #endif
    extern int  yylineno;
    extern char yytext[];
    extern FILE* outFile_p;
    int noerror=1;
    int yylex(void);
    void yyerror(char* msg);
%}
%token CLASS DEFINED COLON DOT LBRACE RBRACE 
%token ID OTHER DEF COMMA STAR MESSAGE NEWLINE



%start input
%%
input: /* empty */
     | input func_def
     | input error
;
/* FUNCTION */
func_def: DEF funcname LBRACE func_args_list RBRACE COLON other
	{
		fprintf(outFile_p, "function %s(%s)", $2.c_str(), $4.c_str());
	}
;
funcname: ID
	{
		//strcpy($$, $1);
		$$ = $1;
	}
;
func_args_list: /* empty */
	{
		$$ = "";
	}
	| func_arg
	{
		$$ = $1;
	}
;
func_arg:ID
	{
		$$ = $1;
	}
	| func_arg COMMA ID
	{
		$$ = $1 + ',' + $3;
	}
other: 
;
%%
extern void yyerror(char* msg) {
    noerror=0;
    if(strcmp(msg,"syntax error"))
        printf(" Syntax Error in Line : %d : %s\n",yylineno,msg);
}
