%{
	#include <stdio.h>
    #include <string.h>
    #include <iostream>

    #define YYSTYPE string  
    using namespace std;
    #include "y.tab.h"
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
defined         "and"|"elif"|"global"|"or"|"assert"|"else"|"if"|"except"|"pass"|"break"|"print"|"exec"|"in"|"raise"|"continue"|"finally"|"is"|"return"|"for"|"lambda"|"try"|"del"|"not"|"while"|"yield"
quote1          "\'"[^'\\]*"\'"
quote2          "\""[^"\\]*"\""

%%
\n\r|\r\n|\n|\r {
                    /* skip empty line */
                    //strcpy(yylval.stval, yytext);
                    yylval = yytext;
                    return NEWLINE;
                }
"#"             {
                    /* skip comment */
                }
{defined}       {
                    //strcpy(yylval.stval, yytext);
                    yylval = yytext;
                    return DEFINED;
                }
class           {
                    return CLASS;
                }
def             {
                    return DEF;
                }

":"             return COLON;
"."             return DOT;
","             return COMMA;
"("             return LBRACE;
")"             return RBRACE;
"*"             return STAR;

{identifier}    {
                    //strcpy(yylval.stval, yytext);
                    yylval = yytext;
                    return ID;
                }
{quote1}        {
                    //strcpy(yylval.stval, yytext);
                    yylval = yytext;
                    return MESSAGE;
                }
{quote2}        {
                    //strcpy(yylval.stval, yytext);
                    yylval = yytext;
                    return MESSAGE;
                }

[ \t]+          /* skip whitespaces */{}
.               {
                    //strcpy(yylval.stval, yytext);
                    yylval = yytext;
                    return OTHER;
                }
%%
int yywrap(void) {
	return 1;
}
