
%{
    #include "y.tab.h"
    int countn=0;
%}

%option yylineno

upperAlpha [A-Z]
alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"

%%

"printf"                    { return PRINTFF; }
"scanf"                     { return SCANFF; }
"int"                       { return INT; }
"float"                     { return FLOAT; }
"char"                      { return CHAR; }
"void"                      { return VOID; }
"return"                    { return RETURN; }
"while"	                    { return WHILE; }
"if"	                    { return IF; }
"else"	                    { return ELSE; }
^"#include"[ ]*<.+\.h>      { return INCLUDE; }
"true"                      { return TRUE; }
"false"                     { return FALSE; }
"main"                      { return MAIN; }
"class"                     { return CLASS; }

[-]?{digit}+                { return NUMBER; }
{digit}+					{ return VET_TAM;}
[-]?{digit}+\.{digit}{1,6}  { return FLOAT_NUM; }
{upperAlpha}({alpha}|{digit})*   { return TK_CLASS; }
{alpha}({alpha}|{digit})*   { return ID; }
{unary}                     { return UNARY; }
["].*["]                    { return STRING; }
['].[']                     { return CHARACTER; }

"<="                        { return LE; }
">="                        { return GE; }
"=="                        { return EQ; }
"!="                        { return NE; }
">"	                        { return GT; }
"<"	                        { return LT; }
"&&"	                    { return AND; }
"||"	                    { return OR; }
"+"                         { return ADD; }
"-"                         { return SUBTRACT; }
"/"                         { return DIVIDE; }
"*"                         { return MULTIPLY; }

\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { return *yytext; }

%%

int yywrap() {
    return 1;
}
