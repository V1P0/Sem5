%{
#include <iostream>
#include <fstream>
#include <string>
#include <memory>
#include <vector>
#include <set>
#include <unordered_map>

#include "utils.hpp"
#include "code_gen.hpp"

int yylex();
int yyparse();
void yyerror(char const *s);
extern FILE *yyin;
extern int yylineno;

CodeGen cg;
Procedure *currentProcedure = new Procedure(&cg);
std::vector<std::string>* callArgs = new std::vector<std::string>();
std::set<std::string>* uninitializedVariables = new std::set<std::string>();


void insertMultiply(std::string x, std::string y){
    if(x==std::string("2")){
        currentProcedure->addInstruction(Instruction(I_LOAD, y));
        currentProcedure->addInstruction(Instruction(I_ADD, y));
        return;
    }
    if(y==std::string("2")){
        currentProcedure->addInstruction(Instruction(I_LOAD, x));
        currentProcedure->addInstruction(Instruction(I_ADD, x));
        return;
    }
    cg.addNumber(std::string("0"));
    cg.addNumber(std::string("1"));
    currentProcedure->addInstruction(Instruction(I_IF, "0"));
    currentProcedure->addCondition(Condition(C_LT, y, x));
    currentProcedure->addInstruction(Instruction(I_LOAD, y));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_LOAD, x));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r2")));
    currentProcedure->addInstruction(Instruction(I_ELSE, "0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, x));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_LOAD, y));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r2")));
    currentProcedure->addInstruction(Instruction(I_ENDIF,"0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("0")));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r3")));
    currentProcedure->addInstruction(Instruction(I_WHILE,"0"));
    currentProcedure->addCondition(Condition(C_LT, std::string("0"), std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_HALF, "0"));
    currentProcedure->addInstruction(Instruction(I_ADD, std::string("r0")));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r4")));
    currentProcedure->addInstruction(Instruction(I_IF, "0"));
    currentProcedure->addCondition(Condition(C_EQ, std::string("r4"),std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("r2")));
    currentProcedure->addInstruction(Instruction(I_ADD, std::string("r2")));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r2")));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("r1"))); 
    currentProcedure->addInstruction(Instruction(I_HALF, "0"));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_ELSE, "0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("r3")));
    currentProcedure->addInstruction(Instruction(I_ADD, std::string("r2")));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r3")));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_SUB, std::string("1")));
    currentProcedure->addInstruction(Instruction(I_STORE, std::string("r1")));
    currentProcedure->addInstruction(Instruction(I_ENDIF, "0"));
    currentProcedure->addInstruction(Instruction(I_ENDWHILE, "0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("r3")));
}

void insertDivision(std::string x, std::string y){
    std::string r0 = std::string("r0");
    std::string r1 = std::string("r1");
    std::string r2 = std::string("r2");
    std::string r3 = std::string("r3");
    std::string r4 = std::string("r4");
    std::string r5 = std::string("r5");
    cg.addNumber(std::string("0"));
    cg.addNumber(std::string("1"));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("0")));
    currentProcedure->addInstruction(Instruction(I_STORE, r3));
    currentProcedure->addInstruction(Instruction(I_IF, "0"));
    currentProcedure->addCondition(Condition(C_LT, std::string("0"), y));
    currentProcedure->addInstruction(Instruction(I_LOAD, y));
    currentProcedure->addInstruction(Instruction(I_STORE, r2));
    currentProcedure->addInstruction(Instruction(I_LOAD, x));
    currentProcedure->addInstruction(Instruction(I_STORE, r1));
    currentProcedure->addInstruction(Instruction(I_WHILE, "0"));
    currentProcedure->addCondition(Condition(C_LEQ, r2, r1));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("1")));
    currentProcedure->addInstruction(Instruction(I_STORE, r4));
    currentProcedure->addInstruction(Instruction(I_LOAD, r2));
    currentProcedure->addInstruction(Instruction(I_STORE, r5));
    currentProcedure->addInstruction(Instruction(I_WHILE, "0"));
    currentProcedure->addCondition(Condition(C_LEQ, r5, r1));
    currentProcedure->addInstruction(Instruction(I_LOAD, r5));
    currentProcedure->addInstruction(Instruction(I_ADD, r5));
    currentProcedure->addInstruction(Instruction(I_STORE, r5));
    currentProcedure->addInstruction(Instruction(I_LOAD, r4));
    currentProcedure->addInstruction(Instruction(I_ADD, r4));
    currentProcedure->addInstruction(Instruction(I_STORE, r4));
    currentProcedure->addInstruction(Instruction(I_ENDWHILE, "0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, r4));
    currentProcedure->addInstruction(Instruction(I_HALF, "0"));
    currentProcedure->addInstruction(Instruction(I_STORE, r4));
    currentProcedure->addInstruction(Instruction(I_LOAD, r5));
    currentProcedure->addInstruction(Instruction(I_HALF, "0"));
    currentProcedure->addInstruction(Instruction(I_STORE, r5));
    currentProcedure->addInstruction(Instruction(I_LOAD, r3));
    currentProcedure->addInstruction(Instruction(I_ADD, r4));
    currentProcedure->addInstruction(Instruction(I_STORE, r3));
    currentProcedure->addInstruction(Instruction(I_LOAD, r1));
    currentProcedure->addInstruction(Instruction(I_SUB, r5));
    currentProcedure->addInstruction(Instruction(I_STORE, r1));
    currentProcedure->addInstruction(Instruction(I_ENDWHILE, "0"));
    currentProcedure->addInstruction(Instruction(I_ENDIF, r3));
    currentProcedure->addInstruction(Instruction(I_LOAD, r3));
}

void insertModulo(std::string x, std::string y){
    std::string r0 = std::string("r0");
    std::string r1 = std::string("r1"); //m
    std::string r2 = std::string("r2"); //n
    std::string r3 = std::string("r3"); //q
    std::string r4 = std::string("r4"); //sum
    std::string r5 = std::string("r5");

    cg.addNumber(std::string("0"));
    
    currentProcedure->addInstruction(Instruction(I_LOAD, x));
    currentProcedure->addInstruction(Instruction(I_STORE, r1));
    currentProcedure->addInstruction(Instruction(I_LOAD, std::string("0")));
    currentProcedure->addInstruction(Instruction(I_STORE, r4));
    currentProcedure->addInstruction(Instruction(I_WHILE, "0"));
    currentProcedure->addCondition(Condition(C_LEQ, y, r1));
    currentProcedure->addInstruction(Instruction(I_LOAD, y));
    currentProcedure->addInstruction(Instruction(I_STORE, r3));
    currentProcedure->addInstruction(Instruction(I_WHILE, "0"));
    currentProcedure->addCondition(Condition(C_LEQ, r3, r1));
    currentProcedure->addInstruction(Instruction(I_LOAD, r3));
    currentProcedure->addInstruction(Instruction(I_ADD, r3));
    currentProcedure->addInstruction(Instruction(I_STORE, r3));
    currentProcedure->addInstruction(Instruction(I_ENDWHILE, "0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, r3));
    currentProcedure->addInstruction(Instruction(I_HALF, "0"));
    currentProcedure->addInstruction(Instruction(I_STORE, r3));
    currentProcedure->addInstruction(Instruction(I_LOAD, r1));
    currentProcedure->addInstruction(Instruction(I_SUB, r3));
    currentProcedure->addInstruction(Instruction(I_STORE, r1));
    currentProcedure->addInstruction(Instruction(I_LOAD, r4));
    currentProcedure->addInstruction(Instruction(I_ADD, r3));
    currentProcedure->addInstruction(Instruction(I_STORE, r4));
    currentProcedure->addInstruction(Instruction(I_ENDWHILE, "0"));
    currentProcedure->addInstruction(Instruction(I_LOAD, x));
    currentProcedure->addInstruction(Instruction(I_SUB, r4));
}

%}
%union sem_rec {
    std::string* str;
    long long num;
    unsigned long long addr;
}

%start PROGRAM_ALL

%token <str> NUM
%token <str> IDENTIFIER

%token ADD SUB MUL DIV MOD LPR RPR
%token EQ NEQ GT LT LEQ GEQ

%token PROCEDURE IS VAR X_BEGIN END PROGRAM
%token ASSIGN
%token IF THEN ELSE ENDIF WHILE DO ENDWHILE REPEAT UNTIL
%token READ WRITE
%token COMMA SEMICOLON

%token ERROR

%type <str> VALUE EXPRESSION CONDITION
%type <str> PROC_HEAD

%left ADD SUB
%left MUL DIV MOD

%%
PROGRAM_ALL: PROCEDURES MAIN
;

PROCEDURES: PROCEDURES PROCEDURE PROC_HEAD IS VAR DECLARATIONS X_BEGIN COMMANDS END {cg.addProcedure(currentProcedure, *($3)); currentProcedure = new Procedure(&cg); uninitializedVariables = new std::set<std::string>();}
          | PROCEDURES PROCEDURE PROC_HEAD IS X_BEGIN COMMANDS END {cg.addProcedure(currentProcedure, *($3)); currentProcedure = new Procedure(&cg); uninitializedVariables = new std::set<std::string>();}
          |
;

MAIN: PROGRAM IS VAR DECLARATIONS X_BEGIN COMMANDS END {cg.addProcedure(currentProcedure, "MAIN");}
    | PROGRAM IS X_BEGIN COMMANDS END {cg.addProcedure(currentProcedure, "MAIN");}
;

COMMANDS: COMMANDS COMMAND
        | COMMAND 
;

COMMAND: IDENTIFIER ASSIGN EXPRESSION SEMICOLON {
    if(!currentProcedure->isExtern(*($1))){
        if(uninitializedVariables->find(*($1))==uninitializedVariables->end()){
            currentProcedure->getVariable(*($1));
        }else{
            uninitializedVariables->erase(*($1));
        }
        }currentProcedure->addInstruction(Instruction(I_STORE, *($1)));
        }
        | S_IF CONDITION THEN COMMANDS S_ELSE COMMANDS ENDIF {currentProcedure->addInstruction(Instruction(I_ENDIF, "0"));}
        | S_IF CONDITION THEN COMMANDS ENDIF {currentProcedure->addInstruction(Instruction(I_ENDIF, "0"));}
        | S_WHILE CONDITION DO COMMANDS ENDWHILE {currentProcedure->addInstruction(Instruction(I_ENDWHILE, "0"));}
        | S_REPEAT COMMANDS UNTIL CONDITION SEMICOLON {currentProcedure->addInstruction(Instruction(I_UNTIL, "0"));}
        | IN_PROC_HEAD SEMICOLON {}
        | READ IDENTIFIER SEMICOLON {
            if(uninitializedVariables->find(*($2))!=uninitializedVariables->end()){
            uninitializedVariables->erase(*($2));
        }
            currentProcedure->addInstruction(Instruction(I_GET, *($2)));}
        | WRITE VALUE SEMICOLON {
            if(!currentProcedure->isExtern(*($2)) && uninitializedVariables->find(*($2))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($2) << " is not initialized" << std::endl;
                    exit(1);
                }
            currentProcedure->addInstruction(Instruction(I_PUT, *($2)));}
;

S_IF: IF {currentProcedure->addInstruction(Instruction(I_IF, "0"));}
;

S_ELSE: ELSE {currentProcedure->addInstruction(Instruction(I_ELSE, "0"));}
;
S_WHILE: WHILE {currentProcedure->addInstruction(Instruction(I_WHILE, "0"));}
;
S_REPEAT: REPEAT {currentProcedure->addInstruction(Instruction(I_REPEAT, "0"));}
;
PROC_HEAD: IDENTIFIER LPR E_DECLARATIONS RPR {$$ = $1;}
;

IN_PROC_HEAD: IDENTIFIER LPR IN_DECLARATIONS RPR {
    cg.getProcedure(*($1));
    currentProcedure->addInstruction(Instruction(I_CALL, *($1)));
    currentProcedure->addProcedureCall(ProcedureCall(*($1), *callArgs));
    callArgs = new std::vector<std::string>();
}
;

DECLARATIONS: DECLARATIONS COMMA IDENTIFIER {currentProcedure->addVariable(*($3));uninitializedVariables->insert(*($3));}
            | IDENTIFIER {currentProcedure->addVariable(*($1));uninitializedVariables->insert(*($1));}
;

E_DECLARATIONS: E_DECLARATIONS COMMA IDENTIFIER {currentProcedure->addExternVariable(*($3));}
            | IDENTIFIER {currentProcedure->addExternVariable(*($1));}
;

IN_DECLARATIONS: IN_DECLARATIONS COMMA IDENTIFIER {
    callArgs->push_back(*($3));
    if(uninitializedVariables->find(*($3))!=uninitializedVariables->end()){
            uninitializedVariables->erase(*($3));
        }}
            | IDENTIFIER {callArgs->push_back(*($1));
            if(uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
            uninitializedVariables->erase(*($1));
        }}
;

EXPRESSION: VALUE {
    if(!currentProcedure->isExtern(*($1)) && uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
        std::cout <<"Line: "<<yylineno<< " Variable " << *($1) << " is not initialized" << std::endl;
        exit(1);
    }
    currentProcedure->addInstruction(Instruction(I_LOAD, *($1)));}
            | VALUE ADD VALUE {
                if(!currentProcedure->isExtern(*($1)) && uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($1) << " is not initialized" << std::endl;
                    exit(1);
                }
                if(!currentProcedure->isExtern(*($3)) && uninitializedVariables->find(*($3))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($3) << " is not initialized" << std::endl;
                    exit(1);
                }
                currentProcedure->addInstruction(Instruction(I_LOAD, *($1))); currentProcedure->addInstruction(Instruction(I_ADD, *($3)));}
            | VALUE SUB VALUE {
                if(!currentProcedure->isExtern(*($1)) && uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($1) << " is not initialized" << std::endl;
                    exit(1);
                }
                if(!currentProcedure->isExtern(*($3)) && uninitializedVariables->find(*($3))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($3) << " is not initialized" << std::endl;
                    exit(1);
                }
                currentProcedure->addInstruction(Instruction(I_LOAD, *($1))); currentProcedure->addInstruction(Instruction(I_SUB, *($3)));}
            | VALUE MUL VALUE {
                if(!currentProcedure->isExtern(*($1)) && uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($1) << " is not initialized" << std::endl;
                    exit(1);
                }
                if(!currentProcedure->isExtern(*($3)) && uninitializedVariables->find(*($3))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($3) << " is not initialized" << std::endl;
                    exit(1);
                }
                insertMultiply(*($1),*($3));}
            | VALUE DIV VALUE {
                if(!currentProcedure->isExtern(*($1)) && uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($1) << " is not initialized" << std::endl;
                    exit(1);
                }
                if(!currentProcedure->isExtern(*($3)) && uninitializedVariables->find(*($3))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($3) << " is not initialized" << std::endl;
                    exit(1);
                }
                if(*($3)!=std::string("2")){insertDivision(*($1),*($3));}else{currentProcedure->addInstruction(Instruction(I_LOAD, *($1))); currentProcedure->addInstruction(Instruction(I_HALF, *($3)));}}
            | VALUE MOD VALUE {
                if(!currentProcedure->isExtern(*($1)) && uninitializedVariables->find(*($1))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($1) << " is not initialized" << std::endl;
                    exit(1);
                }
                if(!currentProcedure->isExtern(*($3)) && uninitializedVariables->find(*($3))!=uninitializedVariables->end()){
                    std::cout <<"Line: "<<yylineno<< " Variable " << *($3) << " is not initialized" << std::endl;
                    exit(1);
                }
                insertModulo(*($1),*($3));}
;

CONDITION: VALUE EQ VALUE {
    if(*($1)==std::string("0")){
        currentProcedure->addCondition(Condition(C_ZERO, *($3), *($1)));
    }else if(*($3)==std::string("0")){
        currentProcedure->addCondition(Condition(C_ZERO, *($1), *($3)));
    }else{
    currentProcedure->addCondition(Condition(C_EQ, *($1), *($3)));
    }
    }
            | VALUE NEQ VALUE {
    if(*($1)==std::string("0")){
        currentProcedure->addCondition(Condition(C_NZERO, *($3), *($1)));
    }else if(*($3)==std::string("0")){
        currentProcedure->addCondition(Condition(C_NZERO, *($1), *($3)));
    }else{
    currentProcedure->addCondition(Condition(C_NEQ, *($1), *($3)));
    }            
    }
            | VALUE GT VALUE {
                if(*($3)==std::string("0")){
                    currentProcedure->addCondition(Condition(C_NZERO, *($1), *($3)));
                }else{
                    currentProcedure->addCondition(Condition(C_LT, *($3), *($1)));
                }
            }
            | VALUE LT VALUE {
                if(*($1)==std::string("0")){
                    currentProcedure->addCondition(Condition(C_NZERO, *($3), *($1)));
                }else{
                    currentProcedure->addCondition(Condition(C_LT, *($1), *($3)));
                }
                }
            | VALUE LEQ VALUE {currentProcedure->addCondition(Condition(C_LEQ, *($1), *($3)));}
            | VALUE GEQ VALUE {currentProcedure->addCondition(Condition(C_LEQ, *($3), *($1)));}
;

VALUE: NUM {cg.addNumber(*($1)); $$ = $1;}
    | IDENTIFIER {$$ = $1; if(!currentProcedure->isExtern(*($1))){currentProcedure->getVariable(*($1));}}
;

%%

void yyerror(char const *s) {
        std::cerr << "LINE: " << yylineno << " unrecognized token - " << s << std::endl;
        exit(1);
}

int main(int argc, char** argv) {

    if(argc != 3) {
        std::cerr << "invalid number of arguments" << std::endl;
        exit(1);
    }

    FILE *fin = fopen(argv[1], "r");

    if(!fin) {
        std::cerr << "can't open file: " << argv[1] << std::endl;
        exit(1);
    }
    yyin = fin;

    
    
    cg.setLineNumber(&yylineno);
    yyparse();
    cg.generateCode();

    std::ofstream fout(argv[2]);
    
    for(auto& line:cg.getCode()) {
        fout << line << std::endl;
    }

    fout.close();
    return 0;
}