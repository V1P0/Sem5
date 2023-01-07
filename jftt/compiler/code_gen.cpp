#include "code_gen.hpp"
#include <iostream>

void CodeGen::addProcedure(Procedure* procedure, std::string name){
    if(procedures.find(name) != procedures.end()){
        std::cout <<"Line: "<<getLineNumber()<< " Procedure " << name << " already exists" << std::endl;
        exit(1);
    }
    procedure_order.push_back(name);
    procedures[name] = procedure;
}

void CodeGen::setLineNumber(int* n){
    line_number = n;
}

int CodeGen::getLineNumber(){
    return *line_number;
}

Procedure* CodeGen::getProcedure(std::string name){
    if(procedures.find(name) == procedures.end()){
        std::cout <<"Line: "<<getLineNumber()<<" Procedure " << name << " doesn't exists" << std::endl;
        exit(1);
    }
    return procedures[name];
}

void CodeGen::addNumber(std::string number){
    if(numbers.find(number) == numbers.end()){
        numbers[number] = currentNumber;
        currentNumber++;
    }
}

bool CodeGen::isNumber(std::string number){
    return numbers.find(number) != numbers.end();
}

unsigned long long CodeGen::getNumber(std::string number){
    return numbers[number];
}

void CodeGen::generateNumbers(){
    for(auto& number : numbers){
        code.push_back("SET " + number.first);
        code.push_back("STORE " + std::to_string(number.second));
    }
}

void CodeGen::generateCode(){
    generateNumbers();
    int offset = currentNumber;
    int xd = code.size();
    if(procedures.size()>1){
    code.push_back("hold");
    }
    for(auto& name : procedure_order){
        Procedure* procedure = procedures[name];
        procedure->setStart(code.size());
        procedure->addOffset(offset);
        std::vector<std::string> procedure_code = procedure->getCode();
        procedure_code[0] = procedure_code[0] + std::string(" ["+name+"]");
        code.insert(code.end(), procedure_code.begin(), procedure_code.end());
        if(name == "MAIN"){
            continue;
        }
        offset += procedure->getVars().size()+procedure->getExternVars().size()+1;
        code.push_back("JUMPI " + std::to_string(procedure->getOffset()));
    }
    if(procedures.size()>1){
        code[xd] = "JUMP " + std::to_string(procedures["MAIN"]->getStart());
    }
    code.push_back("HALT");
}

void CodeGen::showCode(){
    for(auto& line : code){
        std::cout << line << std::endl;
    }
}

void CodeGen::showProcedures(){
    for(auto& name : procedure_order){
        procedures[name]->show();
    }
}

void CodeGen::showNumbers(){
        for(auto& number : numbers){
        std::cout << number.first << " " << number.second << std::endl;
    }
}

int CodeGen::getCodeSize(){
    return code.size();
}

std::vector<std::string> CodeGen::getCode(){
    return code;
}
