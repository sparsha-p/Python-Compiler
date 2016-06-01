%{
	#include <stdio.h>
    #include <string.h>
    #include <iostream>

	#define YYSTYPE string
    using namespace std;
    #include "y.tab.h"
	/* globals to track current indentation */
	int current_line_indent = 0;
	extern int indent_level;
	
	#define YY_USER_INIT { \
    	BEGIN(normal); \
	}
%}

%x indent
%s normal

identifier      [_a-zA-Z][_a-zA-Z0-9]*
integer			[0-9]*
defined         "elif"|"global"|"assert"|"else"|"except"|"pass"|"exec"|"raise"|"finally"|"is"|"lambda"|"try"|"del"|"yield"
operator "<"|">"|"=="|">="|"<="|"!="|"="
quote1          "\'"[^'\\]*"\'"
quote2          "\""[^"\\]*"\""

%%
<indent>" "      		{ current_line_indent++; }
<indent>"\t"     		{ current_line_indent = current_line_indent + 4; }

<indent>\n\r|\r\n|\n|\r { current_line_indent = 0; }
<indent><<EOF>>  		{  
							unput(*yytext);
							if (current_line_indent == 0 && current_line_indent < indent_level) {
								indent_level -= 4;
								BEGIN indent;
								return DEDENT;
							}
							else{ return 0;}
						}
<indent>.		        {
				           unput(*yytext);
				           if (current_line_indent > indent_level) {
				               indent_level = current_line_indent;
				               return INDENT;
				           } else if (current_line_indent < indent_level) {
				               indent_level -= 4;
				               BEGIN indent;
				               return DEDENT;
				           } else {
				               BEGIN normal;
				           }
				         }

<normal>\n\r|\r\n|\n|\r {
				            yylval = yytext;
				            current_line_indent = 0; 
				            BEGIN indent;
				            return NEWLINE;
				        }
<normal>"#"     		{}

<normal>{defined}       {
				            //strcpy(yylval.stval, yytext);
				            yylval = yytext;
				            return DEFINED;
				        }
<normal>{operator}		{	
							yylval = yytext;
							return OPERA;	
						}
<normal>{integer} 		{	
							yylval = yytext;
							return INTEGER;	
						}

<normal>def             {   return DEF; 	}
<normal>for             {	return FOR; 	}
<normal>if              {	return IF;		}
<normal>in				{	return IN;		}
<normal>return 			{	return RETURN;	}
<normal>not				return NOT;
<normal>and				return AND;
<normal>or				return OR;
<normal>True			return TRUE;
<normal>False			return FALSE;

<normal>":"             return COLON;
<normal>"."             return DOT;
<normal>","             return COMMA;
<normal>"("             return LBRACE;
<normal>")"             return RBRACE;
<normal>"["				return LBRACKET;
<normal>"]"				return RBRACKET;
<normal>"+"				return ADD;
<normal>"-"				return SUB;
<normal>"*"             return STAR;

<normal>{identifier}    {
				            //strcpy(yylval.stval, yytext);
				            yylval = yytext;
				            return NAME;
				        }
<normal>{quote1}        {
				            //strcpy(yylval.stval, yytext);
				            yylval = yytext;
				            return MESSAGE;
				        }
<normal>{quote2}        {
				            //strcpy(yylval.stval, yytext);
				            yylval = yytext;
				            return MESSAGE;
				        }
<normal>[ \t]+          /* skip whitespaces */{}

<normal><<EOF>>         { return 0; }
%%
int yywrap(void) {
	return 1;
}
