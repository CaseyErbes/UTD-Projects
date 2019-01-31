%{
#include <stdio.h>
#include "bison_headers.h"
#include "bison.tab.h"
void yyerror(char *);
%}
%%
[1-9][0-9]*|0		{yylval.lval=strtol(yytext, NULL, 10); return NUMBER;}
false|true		{yylval.sval=strdup(yytext); return BOOL_LITERAL;}
[A-Z][A-Z0-9]*		{yylval.sval=strdup(yytext); return IDENTIFIER;}
\(                      {yylval.sval=strdup(yytext); return LEFT_PAREN;}
\)                      {yylval.sval=strdup(yytext); return RIGHT_PAREN;}
:=			{yylval.sval=strdup(yytext); return ASSIGN;}
;			{yylval.sval=strdup(yytext); return SEMICOLON;}
\*|div|mod		{yylval.sval=strdup(yytext); return OPERATION_2;}
\+|\-			{yylval.sval=strdup(yytext); return OPERATION_3;}
=|!=|<|>|<=|>=		{yylval.sval=strdup(yytext); return OPERATION_4;}
			/* Keywords: IF, THEN, ELSE, BEGIN, END, WHILE, DO, PROGRAM, VAR, AS, INT, BOOL */
if			{yylval.sval=strdup(yytext); return KEYWORD_IF;}
then			{yylval.sval=strdup(yytext); return KEYWORD_THEN;}
else			{yylval.sval=strdup(yytext); return KEYWORD_ELSE;}
begin			{yylval.sval=strdup(yytext); return KEYWORD_BEGIN;}
end			{yylval.sval=strdup(yytext); return KEYWORD_END;}
while			{yylval.sval=strdup(yytext); return KEYWORD_WHILE;}
do			{yylval.sval=strdup(yytext); return KEYWORD_DO;}
program			{yylval.sval=strdup(yytext); return KEYWORD_PROGRAM;}
var			{yylval.sval=strdup(yytext); return KEYWORD_VAR;}
as			{yylval.sval=strdup(yytext); return KEYWORD_AS;}
int			{yylval.sval=strdup(yytext); return KEYWORD_INT;}
bool			{yylval.sval=strdup(yytext); return KEYWORD_BOOL;}
			/* Built-in Procudeures: WRITEINT, READINT */
writeInt		{yylval.sval=strdup(yytext); return BUILTIN_WRITEINT;}
readInt			{yylval.sval=strdup(yytext); return BUILTIN_READINT;}
[ \t\n]+          	/* ignore whitespace */;
.			printf("ERROR: URECOGNIZED TOKEN CONTAINING CHARACTER: %s\n", yytext);
%%
