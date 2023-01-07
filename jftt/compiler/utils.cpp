#include "utils.hpp"
#include <iostream>
#include "code_gen.hpp"


Procedure::Procedure(CodeGen* cg){
    code_gen = cg;
}

std::unordered_map<std::string, unsigned long long> Procedure::getVars(){
    return vars;
}

std::map<std::string, unsigned long long> Procedure::getExternVars(){
    return extern_vars;
}

void Procedure::addVariable(std::string var){
    if(isExtern(var)){
        std::cout << "Line: " << code_gen->getLineNumber() << " Variable " << var << " already defined as function argument" << std::endl;
        exit(1);
    }
    if(vars.find(var) == vars.end()){
        vars[var] = currentNumber;
        
        currentNumber++;
    }else{
        std::cout << "Line: " << code_gen->getLineNumber() << " Variable " << var << " already defined" << std::endl;
        exit(1);
    }
}

void Procedure::addExternVariable(std::string var){
    if(extern_vars.find(var) == extern_vars.end()){
        extern_vars[var] = currentNumber;
        extern_vars_order.push_back(var);
        currentNumber++;
    }
    else{
        std::cout << "Line: " << code_gen->getLineNumber() << " Variable " << var << " already defined" << std::endl;
        exit(1);
    }
}

void Procedure::addInstruction(struct Instruction instruction){
    instructions.push_back(instruction);
}

void Procedure::addCondition(struct Condition condition){
    conditions.push_back(condition);
}
unsigned long long Procedure::getVariable(std::string var){
    if(var == std::string("r0")){
        return 0;
    }
    if(var == std::string("r1")){
        return 2;
    }
    if(var == std::string("r2")){
        return 3;
    }
    if(var == std::string("r3")){
        return 4;
    }
    if(var == std::string("r4")){
        return 5;
    }   
    if(var == std::string("r5")){
        return 6;
    } 
    if(vars.find(var) == vars.end()){
        std::cout << "Line: " << code_gen->getLineNumber() << " Variable " << var << " not found" << std::endl;
        exit(1);
    }
    return vars[var];
}

unsigned long long Procedure::getExternVariable(std::string var){
    if(extern_vars.find(var) == extern_vars.end()){
        std::cout << "Line: " << code_gen->getLineNumber() << " Variable " << var << " not found" << std::endl;
        exit(1);
    }
    return extern_vars[var];
}

bool Procedure::isExtern(std::string var){
    return extern_vars.find(var) != extern_vars.end();
}

void Procedure::addOffset(unsigned long long start){
    offset += start;
    for(auto& var : vars){
        var.second += offset;
    }
    for(auto& var : extern_vars){
        var.second += offset;
    }
}

std::vector<std::string> Procedure::getCode(){
    filterInstructions();
    std::vector<std::string> code;
    long unsigned int instr_num = 0;
    while(instr_num < instructions.size()){
        struct Instruction instruction = instructions[instr_num];
        instr_num++;
        if(instruction.command == I_CALL){
            std::vector<std::string> proc_code = getProcedureCode(code.size());
            code.insert(code.end(), proc_code.begin(), proc_code.end());
            continue;
        }
        if(instruction.command == I_IF){
            std::vector<std::string> if_code = getIfCode(&instr_num, code.size());
            code.insert(code.end(), if_code.begin(), if_code.end());
            continue;
        }
        if(instruction.command == I_WHILE){
            std::vector<std::string> while_code = getWhileCode(&instr_num, code.size());
            code.insert(code.end(), while_code.begin(), while_code.end());
            continue;
        }
        if(instruction.command == I_REPEAT){
            std::vector<std::string> repeat_code = getRepeatCode(&instr_num, code.size());
            code.insert(code.end(), repeat_code.begin(), repeat_code.end());
            continue;
        }
        if(instruction.command == I_HALF){
            code.push_back("HALF");
            continue;
        }
        if(code_gen->isNumber(instruction.address)){
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(code_gen->getNumber(instruction.address)));
            continue;
        }
        if(isExtern(instruction.address)){
            if(instruction.command == I_PUT){
                code.push_back("LOADI " + std::to_string(getExternVariable(instruction.address)));
                code.push_back("PUT 0");
                continue;
            }
            if(instruction.command == I_GET){
                code.push_back("GET 0");
                code.push_back("STOREI " + std::to_string(getExternVariable(instruction.address)));
                continue;
            }
            code.push_back(extern_instructions[instruction.command] + " " + std::to_string(getExternVariable(instruction.address)));
            continue;
        }
        code.push_back(instruction_names[instruction.command] + " " + std::to_string(getVariable(instruction.address)));
    
    }
    return code;
}

std::vector<std::string> Procedure::getProcedureCode(int code_size_so_far){
    std::vector<std::string> code;
    ProcedureCall pc = procedure_calls[0];
    procedure_calls.erase(procedure_calls.begin());
    std::string proc_name = pc.name;
    Procedure* proc = code_gen->getProcedure(proc_name);
    if(proc->getExternVars().size() != pc.args.size()){
        std::cout << "Line: " << code_gen->getLineNumber()  << " wrong number of arguments in procedure call " << pc.name << std::endl;
        exit(1);
    }
    unsigned long long jmp = proc->getStart();
    long a = 0;
    for(auto& var: proc->extern_vars_order){
        if(isExtern(pc.args[a])){
            code.push_back("LOAD " + std::to_string(getExternVariable(pc.args[a])));
            code.push_back("STORE " + std::to_string(proc->getExternVariable(var)));
        }else{
            code.push_back("SET " + std::to_string(getVariable(pc.args[a])));
            code.push_back("STORE " + std::to_string(proc->getExternVariable(var)));
        }
        a++;
    }
    code.push_back("SET "+std::to_string((code_size_so_far+code.size()+code_gen->getCodeSize()+3)));
    code.push_back("STORE "+std::to_string(proc->getOffset()));
    code.push_back("JUMP "+std::to_string(jmp));
    return code;
}

std::vector<std::string> Procedure::getIfCode(long unsigned int* instr_num, int code_size_so_far){
    std::vector<std::string> code;
    struct Instruction instruction = instructions[*instr_num];
    if(*instr_num>0)
    *instr_num = (*instr_num)+1;
    struct Condition condition = conditions[0];
    conditions.erase(conditions.begin());
    std::string a_str, b_str;
    a_str = condition.value1;
    b_str = condition.value2;
    bool non_zero;
    int holder;
    
    switch(condition.type){
        case C_LT:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_LEQ:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_EQ:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        code.push_back("STORE 1");
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        code.push_back("ADD 1");
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_NEQ:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        code.push_back("STORE 1");
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        code.push_back("ADD 1");
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_ZERO:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_NZERO:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        default:
        break;
    }
    while(instruction.command != I_ELSE && instruction.command != I_ENDIF){
        if(instruction.command == I_CALL){
            std::vector<std::string> proc_code = getProcedureCode(code.size()+code_size_so_far);
            code.insert(code.end(), proc_code.begin(), proc_code.end());
        }else if(instruction.command == I_IF){
            std::vector<std::string> if_code = getIfCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), if_code.begin(), if_code.end());
        }
        else if(instruction.command == I_WHILE){
            std::vector<std::string> while_code = getWhileCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), while_code.begin(), while_code.end());
        }
        else if(instruction.command == I_REPEAT){
            std::vector<std::string> repeat_code = getRepeatCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), repeat_code.begin(), repeat_code.end());
        }else if(instruction.command == I_HALF){
            code.push_back("HALF");
        }else if(code_gen->isNumber(instruction.address)){
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(code_gen->getNumber(instruction.address)));
        }else if(isExtern(instruction.address)){
            if(instruction.command == I_PUT){
                code.push_back("LOADI " + std::to_string(getExternVariable(instruction.address)));
                code.push_back("PUT 0");
            }else if(instruction.command == I_GET){
                code.push_back("GET 0");
                code.push_back("STOREI " + std::to_string(getExternVariable(instruction.address)));
            }else{
                code.push_back(extern_instructions[instruction.command] + " " + std::to_string(getExternVariable(instruction.address)));
            }
        }else {
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(getVariable(instruction.address)));
        }
        instruction = instructions[*instr_num];
        (*instr_num)++;
    }
    if(instruction.command == I_ENDIF){
        if(non_zero){
            code[holder] = "JZERO "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
        }else{
            code[holder] = "JPOS "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
        }
        return code;
    }
    int holder2 = code.size();
    code.push_back("holder");
    if(non_zero){
        code[holder] = "JZERO "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
    }else{
        code[holder] = "JPOS "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
    }
    instruction = instructions[*instr_num];
    (*instr_num)++;
    while(instruction.command != I_ENDIF){
        if(instruction.command == I_CALL){
            std::vector<std::string> proc_code = getProcedureCode(code.size()+code_size_so_far);
            code.insert(code.end(), proc_code.begin(), proc_code.end());
        }else if(instruction.command == I_IF){
            std::vector<std::string> if_code = getIfCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), if_code.begin(), if_code.end());
        }
        else if(instruction.command == I_WHILE){
            std::vector<std::string> while_code = getWhileCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), while_code.begin(), while_code.end());
        }
        else if(instruction.command == I_REPEAT){
            std::vector<std::string> repeat_code = getRepeatCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), repeat_code.begin(), repeat_code.end());
        }else if(instruction.command == I_HALF){
            code.push_back("HALF");
        }else if(code_gen->isNumber(instruction.address)){
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(code_gen->getNumber(instruction.address)));
        }else if(isExtern(instruction.address)){
            if(instruction.command == I_PUT){
                code.push_back("LOADI " + std::to_string(getExternVariable(instruction.address)));
                code.push_back("PUT 0");
            }else if(instruction.command == I_GET){
                code.push_back("GET 0");
                code.push_back("STOREI " + std::to_string(getExternVariable(instruction.address)));
            }else{
                code.push_back(extern_instructions[instruction.command] + " " + std::to_string(getExternVariable(instruction.address)));
            }        }else{
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(getVariable(instruction.address)));
        }
        instruction = instructions[*instr_num];
        (*instr_num)++;
    }
    code[holder2] = "JUMP "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
    


    return code;
}

std::vector<std::string> Procedure::getWhileCode(long unsigned int* instr_num, int code_size_so_far){
    std::vector<std::string> code;
    struct Instruction instruction = instructions[*instr_num];
    *instr_num = (*instr_num)+1;
    struct Condition condition = conditions[0];
    conditions.erase(conditions.begin());
    std::string a_str, b_str;
    a_str = condition.value1;
    b_str = condition.value2;
    bool non_zero;
    int holder;
    switch(condition.type){
        case C_LT:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_LEQ:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_EQ:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        code.push_back("STORE 1");
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        code.push_back("ADD 1");
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_NEQ:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        code.push_back("STORE 1");
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        code.push_back("ADD 1");
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_ZERO:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_NZERO:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        default:
        break;
    }
    while(instruction.command != I_ENDWHILE){
        if(instruction.command == I_CALL){
            std::vector<std::string> proc_code = getProcedureCode(code.size()+code_size_so_far);
            code.insert(code.end(), proc_code.begin(), proc_code.end());
        }else if(instruction.command == I_IF){
            std::vector<std::string> if_code = getIfCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), if_code.begin(), if_code.end());
        }
        else if(instruction.command == I_WHILE){
            std::vector<std::string> while_code = getWhileCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), while_code.begin(), while_code.end());
        }
        else if(instruction.command == I_REPEAT){
            std::vector<std::string> repeat_code = getRepeatCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), repeat_code.begin(), repeat_code.end());
        }else if(instruction.command == I_HALF){
            code.push_back("HALF");
        }else if(code_gen->isNumber(instruction.address)){
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(code_gen->getNumber(instruction.address)));
        }else if(isExtern(instruction.address)){
            if(instruction.command == I_PUT){
                code.push_back("LOADI " + std::to_string(getExternVariable(instruction.address)));
                code.push_back("PUT 0");
            }else if(instruction.command == I_GET){
                code.push_back("GET 0");
                code.push_back("STOREI " + std::to_string(getExternVariable(instruction.address)));
            }else{
                code.push_back(extern_instructions[instruction.command] + " " + std::to_string(getExternVariable(instruction.address)));
            }
        }else{
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(getVariable(instruction.address)));
        }
        instruction = instructions[*instr_num];
        (*instr_num)++;
    }
    code.push_back("JUMP "+std::to_string(code_size_so_far+code_gen->getCodeSize()));

    if(non_zero){
        code[holder] = "JZERO "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
    }else{
        code[holder] = "JPOS "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far);
    }


    return code;
}

std::vector<std::string> Procedure::getRepeatCode(long unsigned int* instr_num, int code_size_so_far){
    std::vector<std::string> code;
    struct Instruction instruction = instructions[*instr_num];
    *instr_num = (*instr_num)+1;

    while(instruction.command != I_UNTIL){
        if(instruction.command == I_CALL){
            std::vector<std::string> proc_code = getProcedureCode(code.size()+code_size_so_far);
            code.insert(code.end(), proc_code.begin(), proc_code.end());
        }else if(instruction.command == I_IF){
            std::vector<std::string> if_code = getIfCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), if_code.begin(), if_code.end());
        }
        else if(instruction.command == I_WHILE){
            std::vector<std::string> while_code = getWhileCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), while_code.begin(), while_code.end());
        }
        else if(instruction.command == I_REPEAT){
            std::vector<std::string> repeat_code = getRepeatCode(instr_num, code.size()+code_size_so_far);
            code.insert(code.end(), repeat_code.begin(), repeat_code.end());
        }else if(instruction.command == I_HALF){
            code.push_back("HALF");
        }else if(code_gen->isNumber(instruction.address)){
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(code_gen->getNumber(instruction.address)));
        }else if(isExtern(instruction.address)){
            if(instruction.command == I_PUT){
                code.push_back("LOADI " + std::to_string(getExternVariable(instruction.address)));
                code.push_back("PUT 0");
            }else if(instruction.command == I_GET){
                code.push_back("GET 0");
                code.push_back("STOREI " + std::to_string(getExternVariable(instruction.address)));
            }else{
                code.push_back(extern_instructions[instruction.command] + " " + std::to_string(getExternVariable(instruction.address)));
            }
        }else{
            code.push_back(instruction_names[instruction.command] + " " + std::to_string(getVariable(instruction.address)));
        }
        instruction = instructions[*instr_num];
        (*instr_num)++;
    }
    struct Condition condition = conditions[0];
    conditions.erase(conditions.begin());
    std::string a_str, b_str;
    a_str = condition.value1;
    b_str = condition.value2;
    bool non_zero;
    int holder;
    switch(condition.type){
        case C_LT:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_LEQ:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_EQ:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        code.push_back("STORE 1");
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        code.push_back("ADD 1");
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_NEQ:
        if(code_gen->isNumber(b_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(b_str)));
        }
        if(code_gen->isNumber(a_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(a_str)));
        }
        code.push_back("STORE 1");
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        if(code_gen->isNumber(b_str)){
            code.push_back("SUB "+std::to_string(code_gen->getNumber(b_str)));
        }else if(isExtern(b_str)){
            code.push_back("SUBI "+std::to_string(getExternVariable(b_str)));
        }else{
            code.push_back("SUB "+std::to_string(getVariable(b_str)));
        }
        code.push_back("ADD 1");
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        case C_ZERO:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = true;
        break;
        case C_NZERO:
        if(code_gen->isNumber(a_str)){
            code.push_back("LOAD "+std::to_string(code_gen->getNumber(a_str)));
        }else if(isExtern(a_str)){
            code.push_back("LOADI "+std::to_string(getExternVariable(a_str)));
        }else{
            code.push_back("LOAD "+std::to_string(getVariable(a_str)));
        }
        holder = code.size();
        code.push_back("hold");
        non_zero = false;
        break;
        default:
        break;
    }
    if(non_zero){
        code[holder] = "JZERO "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far+1);
    }else{
        code[holder] = "JPOS "+std::to_string(code.size()+code_gen->getCodeSize()+code_size_so_far+1);
    }
    code.push_back("JUMP "+std::to_string(code_size_so_far+code_gen->getCodeSize()));



    return code;
}

void Procedure::show(){
    std::cerr << "Variables: " << std::endl;
    for(auto& var : vars){
        std::cerr << var.first << " " << var.second << std::endl;
    }
    std::cerr << "Extern Variables: " << std::endl;
    for(auto& var : extern_vars){
        std::cerr << var.first << " " << var.second << std::endl;
    }
    for(auto& cond: conditions){
        std::cerr << "Condition: " << cond.value1 << " " << cond.type << " " << cond.value2 << std::endl;
    }
    std::cerr << "Instructions: " << std::endl;
    for(auto& instruction : instructions){
        std::cerr << instruction_names[instruction.command] << " " << instruction.address << std::endl;
    }
}

void Procedure::setStart(unsigned long long start){
    this->start = start;
}

unsigned long long Procedure::getStart(){
    return start;
}

unsigned long long Procedure::getOffset(){
    return offset;
}

void Procedure::addProcedureCall(ProcedureCall call){
    procedure_calls.push_back(call);
}

void Procedure::filterInstructions(){
    long unsigned int i = 0;
    while(i+1<instructions.size()){
        if(instructions[i].command == I_STORE
        && instructions[i+1].command == I_LOAD
        && instructions[i].address == instructions[i+1].address){
            instructions.erase(instructions.begin()+i+1);
        }else{
            i++;
        }
    }
}