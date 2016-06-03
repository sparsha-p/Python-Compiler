%{
	#include "dstruct.h"

	#define YYSTYPE line
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
integer			[0-9]+
defined         "global"|"assert"|"except"|"pass"|"exec"|"raise"|"finally"|"is"|"lambda"|"try"|"del"|"yield"
operator "<"|">"|"=="|">="|"<="|"!="
augassign "+="|"-="|"*="|"/="
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
<indent>#[^(\n\r)|^(\r\n)|^\n|^\r]+(\n\r|\r\n|\n|\r) 							{
							current_line_indent = 0;
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
				            yylval.s = yytext;
				            current_line_indent = 0; 
				            BEGIN indent;
				            return NEWLINE;
				        }
<normal>#[^(\n\r)|^(\r\n)|^\n|^\r]+(\n\r|\r\n|\n|\r)     							{
							current_line_indent = 0; 
							BEGIN indent;
						}						
<normal>def             {   
							yylval.i = indent_level/4;
							return DEF; 	
						}
<normal>for             {	
							yylval.i = indent_level/4;
							return FOR; 	
						}
<normal>if              {	
							yylval.i = indent_level/4;
							return IF;
						}
<normal>else            {
                            yylval.i = indent_level/4;
                            return ELSE;    
                        }
<normal>elif            {
                            yylval.i = indent_level/4;
                            return ELIF;                        
                        }       
<normal>while           {	
							yylval.i = indent_level/4;
							return WHILE;
						}
<normal>print           {	
							yylval.i = indent_level/4;
							return PRINT;
						}					
<normal>in				{	return IN;		}
<normal>return 			{
							yylval.i = indent_level/4;	
							return RETURN;	
						}
<normal>continue        {
                            yylval.i = indent_level/4;
                            return CONTINUE;
                        }
<normal>not				return NOT;
<normal>and				return AND;
<normal>or				return OR;
<normal>True			return TRUE;
<normal>False			return FALSE;
<normal>":"             return COLON;
<normal>"."             {
							yylval.s = yytext;
							return DOT;
						}
<normal>","             {
							yylval.s = yytext;
							return COMMA;
						}
<normal>"("             {
							yylval.s = yytext;
							return LBRACE;
						}
<normal>")"             {
							yylval.s = yytext;
							return RBRACE;
						}
<normal>"["				{
							yylval.s = yytext;
							return LBRACKET;
						}
<normal>"]"				{
							yylval.s = yytext;
							return RBRACKET;
						}
<normal>"="				{
							yylval.s = yytext;
							return EQ;
						}
<normal>"+"				{
							yylval.s = yytext;
							return ADD;
						}
<normal>"-"				{
							yylval.s = yytext;
							return SUB;
						}
<normal>"*"             {
							yylval.s = yytext;
							return STAR;
						}
<normal>"/"             {
                            yylval.s = yytext;
                            return DIVIDE;
                        }
<normal>{defined}       {
				            yylval.s = yytext;
				            return DEFINED;
				        }
<normal>{operator}		{	
							yylval.s = yytext;
							return OPERA;	
						}
<normal>{integer} 		{	
							yylval.s = yytext;
							return INTEGER;	
						}
<normal>{identifier}    {
							yylval.i = indent_level/4;
				            yylval.s = yytext;
				            return NAME;
				        }
<normal>{augassign}	    {
				            yylval.s = yytext;
				            return AUGASSIGN;							
						}
<normal>{quote1}        {
				            yylval.s = yytext;
				            return QUOTED;
				        }
<normal>{quote2}        {
				            yylval.s = yytext;
				            return QUOTED;
				        }
<normal>[ \t]+          /* skip whitespaces */{}
<normal><<EOF>>         { return 0; }
%%
int yywrap(void) {
	return 1;
}
