%{
#include <stdio.h>
#include <stdbool.h>

int yywrap();
int yylex();

bool doc = false;
%}

%x SL
%x ML
%x SLD
%x MLD
%x STRING
%x INC

%%
\"  {BEGIN(STRING);  ECHO;}
<STRING>{   
    \\\\ |
    \\\n |
    \\\"    ECHO;
    \"  {ECHO; BEGIN(INITIAL);}
    .   ECHO;
}

\>  {BEGIN(INC);  ECHO;}
<INC>{   
    \\\\ |
    \\\n |
    \\\>    ECHO;
    \>  {ECHO; BEGIN(INITIAL);}
    .   ECHO;
}

\/(\\|\n)*\/(\\|\n)*(\/|\!)  {BEGIN(SLD); if(doc) ECHO;}
<SLD>{
    .?\n    {if(doc) printf("\n"); BEGIN(INITIAL);}
    . |
    .*\\\n  {if(doc) ECHO;}
}

\/(\\|\n)*\*(\\|\n)*(\*|\!)  {BEGIN(MLD); if(doc) ECHO;}
<MLD>{
    \*(\\|\n)*\/    {if(doc){ ECHO;}else{printf("\n");}; BEGIN(INITIAL);}
    .|\n    {if(doc) ECHO;}
}

\/(\\|\n)*\/    {BEGIN(SL);}
<SL>{
    .*\\\n |
    .   ;      
    [^\\]\n {printf("\n"); BEGIN(INITIAL);}
}

\/(\\|\n)*\*    BEGIN(ML);
<ML>{
    \*(\\|\n)*\/    BEGIN(INITIAL);
    .|\n    ;
}

%%

int yywrap() {
    return 1;
}

int main(int argc, char *argv[]) {
    if(argc > 1){
        doc = true;
    }
    return yylex();
}