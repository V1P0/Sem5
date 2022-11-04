%{
    #include <stdio.h>
    #include <math.h>
    #include <stdbool.h>

    #define STACK_SIZE 1000

    int yylex();
    int yywrap();


    int len = 0;
    int stack[STACK_SIZE];
    int a, b;
    bool error = false;

    void push(int n){
        len++;
        if(len > STACK_SIZE){
            error = true;
        }else{
            stack[len-1] = n;
        }
    }

    int pop(){
        if(len>0){
            len--;
            return stack[len];
        }else{
            error = true;
            return 0;
        }
    }


%}

%x ERROR 

%%
-?[0-9]+  push(atoi(yytext));

\+  {
    a = pop();
    b = pop();
    push(a+b);
}

\-  {
    a = pop();
    b = pop();
    push(a-b);
}

\*  {
    a = pop();
    b = pop();
    push(a*b);
}

[ \t]   ;

\n  {
    if(len==1){
        if(error){
            printf("za mala liczba argumentow\n");
            len = 0;
            error = false;
        }else{
            int res = pop();
            printf("= %d\n", res);
            len = 0;
        }
    }else{
        printf("za mala liczba operatorow\n");
        len = 0;
        error = false;
    }
}

%%

int yywrap() {
    return 1;
}

int main() {
    return yylex();
}