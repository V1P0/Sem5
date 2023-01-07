%option noyywrap
%option yylineno
     
%{
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <cstring>
#include "parser.tab.h"
#include "utils.hpp"
%}


IDENTIFIER              [_a-z]
DIGIT                   [0-9]

%x COMMENT

%%
"PROCEDURE"             { return PROCEDURE; }
"IS"                    { return IS; }
"VAR"                   { return VAR; }
"BEGIN"                 { return X_BEGIN; }
"END"                   { return END; }
"PROGRAM"               { return PROGRAM; }

"IF"                    { return IF; }
"THEN"                  { return THEN; }
"ELSE"                  { return ELSE; }
"ENDIF"                 { return ENDIF; }

"WHILE"                 { return WHILE; }
"DO"                    { return DO; }
"ENDWHILE"              { return ENDWHILE; }

"REPEAT"                { return REPEAT; }
"UNTIL"                 { return UNTIL; }

"READ"                  { return READ; }
"WRITE"                 { return WRITE; }

"("                     { return LPR; }
")"                     { return RPR; }

":="                    { return ASSIGN; }
","                     { return COMMA; }
";"                     { return SEMICOLON; }

"="                     { return EQ; }
"!="                    { return NEQ; }
"<"                     { return LT; }
">"                     { return GT; }
"<="                    { return LEQ; }
">="                    { return GEQ; }

"+"                     { return ADD; }
"-"                     { return SUB; }
"*"                     { return MUL; }
"/"                     { return DIV; }
"%"                     { return MOD; }
{IDENTIFIER}+           { 
                            yylval.str = new std::string(yytext);
                            return IDENTIFIER;
                        }
{DIGIT}+                { yylval.str = new std::string(yytext); return NUM; }
"["                     { BEGIN(COMMENT); }
<COMMENT>{
    [^\]]               ;
    "]"                 BEGIN(INITIAL);
}

[ \t\r\n]+                { /*ignore whitespaces*/ }
.                       { return ERROR; }
%%