enum instruction_type {
    I_GET, // pobraną liczbę zapisuje w komórce pamięci pi oraz k ← k + 1
    I_PUT, // wyświetla zawartość komórki pamięci pi oraz k ← k + 1 
    I_LOAD, // p0 ← pi oraz k ← k + 1 
    I_STORE, // pi ← p0 oraz k ← k + 1
    I_LOADI, // p0 ← ppi oraz k ← k + 1 
    I_STOREI, // ppi ← p0 oraz k ← k + 1
    I_ADD, // p0 ← p0 + pi oraz k ← k + 1
    I_SUB, // p0 ← max{p0 − pi, 0} oraz k ← k + 1
    I_ADDI, // p0 ← p0 + ppi oraz k ← k + 1
    I_SUBI, // p0 ← max{p0 − ppi, 0} oraz k ← k + 1
    I_SET, // p0 ← x oraz k ← k + 1 
    I_HALF, // p0 ← ⌊p0/2⌋ oraz k ← k + 1 
    I_JUMP, // k ← j

    I_JPOS, // jeśli p0 > 0 to k ← j, w p.p. k ← k + 1
    I_JZERO, // jeśli p0 = 0 to k ← j, w p.p. k ← k + 1

    I_JUMPI, // k ← pi
    I_HALT, // zatrzymuje działanie maszyny
//---------------------------------------------------------------------
    I_MUL,
    I_DIV,
    I_MOD,

    I_CALL,

    I_IF,
    I_ELSE,
    I_ENDIF,

    I_WHILE,
    I_ENDWHILE,

    I_REPEAT,
    I_UNTIL
};

enum condition_type{
    C_EQ,
    C_NEQ,
    C_GT,
    C_LT, //a<b = 0<b-a
    C_LEQ,
    C_ZERO,
    C_NZERO

};
