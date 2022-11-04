%{
#include <stdio.h>

int yylex();
int yywrap();
%}

%x COMMENT1
%x COMMENT2

%%
\' {BEGIN(COMMENT1); ECHO;}
<COMMENT1>{
    \'  {ECHO; BEGIN(INITIAL);}
    .   ECHO;
}
\" {BEGIN(COMMENT2); ECHO;}
<COMMENT2>{
    \"  {ECHO; BEGIN(INITIAL);}
    .   ECHO;
}
#.*\n  printf("\n");
%%

int yywrap() {
    return 1;
}

int main() {
    return yylex();
}