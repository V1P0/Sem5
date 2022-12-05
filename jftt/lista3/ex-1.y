%{
#define YYSTYPE int
#include<stdio.h>
#include<math.h>
#include<string.h>
#include <stdlib.h>
#define Z 1234577
#define expression_max_length 4096

int yylex();
int yyerror(char*);

char RPN_acc[expression_max_length];

void empty_RPN_acc() {
    RPN_acc[0] = '\0';
}

int flatten(int x) {
    return ((x % Z) + Z) % Z;
}

int flatten_pow(int x){
    return ((x%(Z-1))+(Z-1))%(Z-1);
}

//normal
int add(int x, int y) {
    return flatten(flatten(x) + flatten(y));
}

int subtract(int x, int y) {
    return flatten(flatten(x) - flatten(y));
}

int multiply(int x, int y) {
    int output = 0;
    for(int i = 0; i < y; i++) {
        output += x;
        output = flatten(output);
    }
    return output;
}

int gcd(int x, int y){
    if(x==0){
        return y;
    }
    return gcd(y%x,x);
}


int inverse(int a) {
    int m = Z;
    int x = 1;
    int y = 0;

    while( a > 1) {
        int quotient = a / m;
        int t = m;

        m = a % m;
        a = t;
        t = y;

        y = x - quotient * y;
        x = t;
    }

    if(x < 0)
        x += Z;

    return x;
}



int divide(int x, int y) {
    if(y == 0) {
        yyerror("division by zero");
        return -1;
    } else {
        int inv = inverse(y);
        if (inv == -1) {
            yyerror("Inverse does not exist");
            return -1;
        }
        return flatten(multiply(x, inv));
    }
}

int mod(int x, int y) {
    if(y == 0) {
        yyerror("mod by zero");
        return -1;
    } else {
        return flatten(flatten(x) % flatten(y));
    }
}

int power(int x, int y) {
    printf("%d", y);
    int output = 1;
    for (int i = 0; i < y; i++) {
        output = multiply(output, x);
    }
    return output;
}

//power
int add_pow(int x, int y) {
    return flatten_pow(flatten_pow(x) + flatten_pow(y));
}

int subtract_pow(int x, int y) {
    return flatten_pow(flatten_pow(x) - flatten_pow(y));
}

int multiply_pow(int x, int y) {
    int output = 0;
    for(int i = 0; i < y; i++) {
        output += x;
        output = flatten_pow(output);
    }
    return output;
}

int inverse_pow(int a) {
    int m = Z-1;
    int x = 1;
    int y = 0;

    while( a > 1) {
        if(m==0){
            return -1;
        }
        int quotient = a / m;
        int t = m;
        
        m = a % m;
        a = t;
        t = y;
        
        y = x - quotient * y;
        x = t;
    }

    if(x < 0)
        x += (Z-1);

    return x;
}

int divide_pow(int x, int y) {
    if(y == 0) {
        yyerror("division by zero");
        return -1;
    } else {
        int inv = inverse_pow(y);
        if (inv == -1) {
            yyerror("Inverse does not exist");
            return -1;
        }
        return flatten_pow(multiply_pow(x, inv));
    }
}

int mod_pow(int x, int y) {
    if(y == 0) {
        yyerror("mod by zero");
        return -1;
    } else {
        return flatten_pow(flatten_pow(x) % flatten_pow(y));
    }
}


%}

%token NUM

%token ADD
%token SUB
%token MUL
%token DIV
%token MOD
%token POW
%token LPR
%token RPR
%token TRM
%token ERR
%token COM
%token COT

%left ADD SUB
%left MUL DIV MOD
%right POW
%precedence NEG

%%

INPT: %empty
    | INPT STAR TRM
;

STAR: EXPR {printf("\n%s\nans = %d\n", RPN_acc, $1);empty_RPN_acc();}
    | EXPR error
    | error
    | COM
;

NUMR: NUM {$$ = flatten($1); sprintf(RPN_acc + strlen(RPN_acc), "%d ", $$);}
    | SUB NUM %prec NEG {$$ = subtract(0, $2); sprintf(RPN_acc + strlen(RPN_acc), "%d ", $$);}
;

NUMR2: NUM {$$ = flatten_pow($1); sprintf(RPN_acc + strlen(RPN_acc), "%d ", $$);}
    | SUB NUM %prec NEG {$$ = flatten_pow(0 - $2); sprintf(RPN_acc + strlen(RPN_acc), "%d ", $$);}
;

EXPR: EXPR ADD EXPR {sprintf(RPN_acc + strlen(RPN_acc), "+ "); $$ = add($1, $3);}
    | EXPR SUB EXPR {sprintf(RPN_acc + strlen(RPN_acc), "- "); $$ = subtract($1, $3);}
    | EXPR MUL EXPR {sprintf(RPN_acc + strlen(RPN_acc), "* "); $$ = multiply($1, $3);}
    | EXPR DIV EXPR {sprintf(RPN_acc + strlen(RPN_acc), "/ "); $$ = divide($1, $3); if($$ == -1) YYERROR;}
    | EXPR MOD EXPR {sprintf(RPN_acc + strlen(RPN_acc), "%% "); $$ = mod($1, $3); if($$ == -1) YYERROR;}
    | EXPR POW EXPR2 {sprintf(RPN_acc + strlen(RPN_acc), "^ "); $$ = power($1, $3);}
    | LPR EXPR RPR {$$ = $2;}
    | SUB LPR EXPR RPR %prec NEG {sprintf(RPN_acc + strlen(RPN_acc), "%d * ", Z-1);$$ = subtract(0, $3);}
    | NUMR
;

EXPR2: EXPR2 ADD EXPR2 {sprintf(RPN_acc + strlen(RPN_acc), "+ "); $$ = add_pow($1, $3);}
    | EXPR2 SUB EXPR2 {sprintf(RPN_acc + strlen(RPN_acc), "- "); $$ = subtract_pow($1, $3);}
    | EXPR2 MUL EXPR2 {sprintf(RPN_acc + strlen(RPN_acc), "* "); $$ = multiply_pow($1, $3);}
    | EXPR2 DIV EXPR2 {sprintf(RPN_acc + strlen(RPN_acc), "/ "); $$ = divide_pow($1, $3); if($$ == -1) YYERROR;}
    | EXPR2 MOD EXPR2 {sprintf(RPN_acc + strlen(RPN_acc), "%% "); $$ = mod_pow($1, $3); if($$ == -1) YYERROR;}
    | LPR EXPR2 RPR {$$ = $2;}
    | SUB LPR EXPR2 RPR %prec NEG {sprintf(RPN_acc + strlen(RPN_acc), "%d * ", Z-2); $$ = flatten_pow(0 - $3);}
    | NUMR2
;

%%
int yyerror(char *s)
{
    printf("Fatal error: %s\n",s);
    empty_RPN_acc();
}

int main()
{
    yyparse();
    return 0;
}