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

\< {BEGIN(INC);  ECHO;}
<INC>{   
    \\\\ |
    \\\n |
    \\\>    ECHO;
    \>  {ECHO; BEGIN(INITIAL);}
    .   ECHO;
}

\/(\\\r?\n)*\/(\\\r?\n)*(\/|\!)  {BEGIN(SLD); if(doc) ECHO;}
<SLD>{
    \\\r?\n |
    .   if(doc) ECHO;;      
    [^\\]\n {if(doc){ ECHO;}else{ printf("\n");}; BEGIN(INITIAL);}
}

\/(\\\r?\n)*\*(\\\r?\n)*(\*|\!)  {BEGIN(MLD); if(doc) ECHO;}
<MLD>{
    \*(\\\r?\n)*\/    {if(doc){ ECHO;}else{printf("\n");}; BEGIN(INITIAL);}
    .|\n    {if(doc) ECHO;}
}

\/(\\\r?\n)*\/    {BEGIN(SL);}
<SL>{
    \\\r?\n |
    .   ;      
    [^\\]\n {printf("\n"); BEGIN(INITIAL);}
}

\/(\\\r?\n)*\*    BEGIN(ML);
<ML>{
    \*(\\\r?\n)*\/    BEGIN(INITIAL);
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