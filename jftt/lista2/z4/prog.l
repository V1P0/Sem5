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
    bool stack_error = false;

    void push(int n){
        len++;
        if(len > STACK_SIZE){
            stack_error = true;
        }else{
            stack[len-1] = n;
        }
    }

    int pop(){
        if(len>0){
            len--;
            return stack[len];
        }else{
            stack_error = true;
            return 0;
        }
    }


%}

%x MATH_ERROR 

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
    push(b-a);
}

\*  {
    a = pop();
    b = pop();
    push(a*b);
}

\/ {
    a = pop();
    b = pop();
    if(a==0){
        printf("Błąd: dzielenie przez 0\n");
        BEGIN(MATH_ERROR);
    }else{
        push(b/a);
    }
}

\% {
    a = pop();
    b = pop();
    if(a==0){
        printf("Błąd: dzielenie przez 0\n");
        BEGIN(MATH_ERROR);
    }else{
        push(b%a);
    }
}

\^ {
    a = pop();
    b = pop();
    push((int) pow(b, a));
}

[ \t]   ;

\n  {
    if(len==1){
        if(stack_error){
            printf("za mala liczba argumentow\n");
            len = 0;
            stack_error = false;
        }else{
            int res = pop();
            printf("= %d\n", res);
            len = 0;
        }
    }else{
        printf("za mala liczba operatorow\n");
        len = 0;
        stack_error = false;
    }
}

<MATH_ERROR>{
    .   ;
    \n  {
        len = 0;
        BEGIN(INITIAL);
    }
}

%%

int yywrap() {
    return 1;
}

int main() {
    return yylex();
}