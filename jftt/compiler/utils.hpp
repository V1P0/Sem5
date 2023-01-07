#pragma once
#include <unordered_map>
#include <map>
#include <string>
#include <vector>
#include <iostream>
#include "instructions.hpp"

class CodeGen;
const std::string instruction_names[] = {
    "GET", "PUT", "LOAD", "STORE", "LOADI", "STOREI", "ADD", "SUB", "ADDI", "SUBI", "SET", "HALF", "JUMP", "JPOS", "JZERO", "JUMPI", "HALT", "MUL", "DIV", "MOD", "CALL", "IF", "ELSE", "ENDIF", "WHILE", "ENDWHILE", "REPEAT", "UNTIL"
};
const std::string extern_instructions[] = {
    "","","LOADI", "STOREI", "", "", "ADDI", "SUBI", "", "", "", "", "JUMPI", "", "", "", ""
};

struct Instruction{
    enum instruction_type command;
    std::string address;
    Instruction(enum instruction_type command, std::string address){
        this->command = command;
        this->address = address;
    }
};

struct Condition{
    enum condition_type type;
    std::string value1;
    std::string value2;
    Condition(enum condition_type type, std::string value1, std::string value2){
        this->type = type;
        this->value1 = value1;
        this->value2 = value2;
    }    
};

struct ProcedureCall{
    std::string name;
    std::vector<std::string> args;
    ProcedureCall(std::string name, std::vector<std::string> args){
        this->name = name;
        this->args = args;
    }
};

class Procedure{
    unsigned long long start;
    unsigned long long offset = 0;
    std::unordered_map<std::string, unsigned long long> vars;
    std::map<std::string, unsigned long long> extern_vars;
    std::vector<std::string> extern_vars_order;
    unsigned long long currentNumber = 1;
    std::vector<struct Instruction> instructions;
    std::vector<struct ProcedureCall> procedure_calls;
    std::vector<struct Condition> conditions;
    CodeGen *code_gen;

public:
    Procedure(CodeGen* cg);
    std::unordered_map<std::string, unsigned long long> getVars();
    std::map<std::string, unsigned long long> getExternVars();
    void addVariable(std::string var);
    void addExternVariable(std::string var);
    void addInstruction(struct Instruction instruction);
    void addCondition(struct Condition condition);
    unsigned long long getVariable(std::string var);
    unsigned long long getExternVariable(std::string var);
    void setStart(unsigned long long start);
    unsigned long long getStart();
    void addOffset(unsigned long long offset);
    void filterInstructions();
    std::vector<std::string> getCode();
    std::vector<std::string> getProcedureCode(int code_size_so_far);
    std::vector<std::string> getIfCode(long unsigned int* instr_num, int code_size_so_far);
    std::vector<std::string> getWhileCode(long unsigned int* instr_num, int code_size_so_far);
    std::vector<std::string> getRepeatCode(long unsigned int* instr_num, int code_size_so_far);   
    bool isExtern(std::string var);
    unsigned long long getOffset();
    void show();
    void addProcedureCall(struct ProcedureCall procedure_call);

};