#pragma once

#include <map>
#include "utils.hpp"


class CodeGen{
    std::map<std::string, Procedure*> procedures;
    std::unordered_map<std::string, unsigned long long> numbers;
    unsigned long long currentNumber = 7;
    std::vector<std::string> code;
    std::vector<std::string> procedure_order;
    int* line_number;

public:
    void addProcedure(Procedure* procedure, std::string name);
    void setLineNumber(int* n);
    int getLineNumber();
    Procedure* getProcedure(std::string name);
    void addNumber(std::string number);
    bool isNumber(std::string number);
    unsigned long long getNumber(std::string number);
    void generateNumbers();
    void generateCode();
    void showCode();
    void showProcedures();
    void showNumbers();
    int getCodeSize();
    std::vector<std::string> getCode();

};