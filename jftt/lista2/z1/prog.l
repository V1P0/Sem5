%{
#include <stdio.h>

int yylex();
int yywrap();
int lines = 0;
int words = 0;
%}

%%
^[ \t]*\n*  ;
^[ \t]+/[^ \t\n]    ;
[ \t]+/[^ \t\n] {printf(" "); words++;}
[ \t] ;
\n  {printf("\n"); lines++; words++;}
%%

int yywrap() {
    printf("\nlines: %d\n", lines);
    printf("words: %d\n", words);
    return 1;
}

int main() {
    return yylex();
}
