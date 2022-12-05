import ply.yacc as yacc
import ply.lex as lex
from sys import stdin

Zp = 1234577
Z2 = Zp-1

def flatten(x: int) -> int:
    return ((x % Zp) + Zp) % Zp

def flatten2(x: int) -> int:
    return ((x % Z2) + Z2) % Z2



def multiply(x: int, y: int) -> int:
    output = flatten(x)
    for i in range(1, y):
        output += x
        output = flatten(output)
    return output


def multiply2(x: int, y: int) -> int:
    output = flatten2(x)
    for i in range(1, y):
        output += x
        output = flatten2(output)
    return output


def inverse(a: int) -> int:
    m = Zp
    x = 1
    y = 0

    while a > 1:
        quotient = a // m
        t = m

        m = a % m
        a = t
        t = y

        y = x - quotient * y
        x = t

    if x < 0:
        x += Zp

    return x


def inverse2(a: int) -> int:
    m = Z2
    x = 1
    y = 0

    while a > 1:
        if m == 0:
            return -1
        quotient = a // m
        t = m
        m = a % m
        a = t
        t = y

        y = x - quotient * y
        x = t

    if x < 0:
        x += Z2

    return x

onp = ""
def print_(*x) -> None:
    global onp
    onp += ''.join(map(str, x))

tokens = (
    'ADD', 'SUB', 'MUL', 'DIV', 'MOD', 'POW',
    'LPR', 'RPR',
    'NUM',
    'COM'
)

# tokens
t_COM = r'\#.*'

t_ADD = r'\+'
t_MUL = r'\*'
t_DIV = r'\/'
t_MOD = r'%'
t_POW = r'\^'
t_LPR = r'\('
t_RPR = r'\)'

t_SUB = r'-'


def t_NUM(t):
    r'[0-9]+'
    t.value = int(t.value)
    return t


t_ignore = ' \t'


def t_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count('\n')


def t_error(t):
    print(f'\ninvalid character: {t.value[0]!r}')
    t.lexer.skip(1)


lex.lex()

precedence = (
    ('left', 'ADD', 'SUB'),
    ('left', 'MUL', 'DIV', 'MOD'),
    ('right', 'NEG', 'POW')
)


def p_STAR_EXPR(p):
    'STAR : EXPR'
    print()
    print('ans =', p[1])


def p_STAR_COM(p):
    'STAR : COM'
    pass


def p_NUMR(p):
    'NUMR : NUM'
    p[0] = flatten(p[1])
    print_(p[0], ' ')


def p_NUMR_NEG(p):
    'NUMR : SUB NUM %prec NEG'
    p[0] = flatten(0 - flatten(p[2]))
    print_(p[0], ' ')


def p_EXPR_ADD(p):
    'EXPR : EXPR ADD EXPR'
    p[0] = flatten(flatten(p[1]) + flatten(p[3]))
    print_('+ ')


def p_EXPR_SUB(p):
    'EXPR : EXPR SUB EXPR'
    p[0] = flatten(flatten(p[1]) - flatten(p[3]))
    print_('- ')


def p_EXPR_MUL(p):
    'EXPR : EXPR MUL EXPR'
    p[0] = multiply(p[1], p[3])
    print_('* ')


def p_EXPR_DIV(p):
    'EXPR : EXPR DIV EXPR'
    x = p[1]
    y = p[3]
    if y == 0:
        raise Exception('division by zero')

    p[0] = flatten(multiply(x, inverse(y)))
    print_('/ ')


def p_EXPR_MOD(p):
    'EXPR : EXPR MOD EXPR'
    x = p[1]
    y = p[3]
    if y == 0:
        raise Exception('mod by zero')
    p[0] = flatten(flatten(x) % flatten(y))
    print_('% ')


def p_EXPR_POW(p):
    'EXPR : EXPR POW EXPR2'
    x = p[1]
    y = p[3]
    output = 1
    for i in range(0, y):
        output *= x
        output = flatten(output)
    p[0] = output
    print_('^ ')


def p_EXPR_PRS(p):
    'EXPR : LPR EXPR RPR'
    p[0] = p[2]


def p_EXPR_NUM(p):
    'EXPR : NUMR'
    p[0] = p[1]

def p_EXPR_NEG_PRS(p):
    'EXPR : SUB LPR EXPR RPR %prec NEG'
    p[0] = flatten(0-p[3])
    print_("0 -")

#power

def p_NUMR2(p):
    'NUMR2 : NUM'
    p[0] = flatten2(p[1])
    print_(p[0], ' ')


def p_NUMR2_NEG(p):
    'NUMR2 : SUB NUM %prec NEG'
    p[0] = flatten2(0 - flatten(p[2]))
    print_(p[0], ' ')


def p_EXPR2_ADD(p):
    'EXPR2 : EXPR2 ADD EXPR2'
    p[0] = flatten2(flatten2(p[1]) + flatten2(p[3]))
    print_('+ ')


def p_EXPR2_SUB(p):
    'EXPR2 : EXPR2 SUB EXPR2'
    p[0] = flatten2(flatten2(p[1]) - flatten2(p[3]))
    print_('- ')


def p_EXPR2_MUL(p):
    'EXPR2 : EXPR2 MUL EXPR2'
    p[0] = multiply2(p[1], p[3])
    print_('* ')

def p_EXPR2_DIV(p):
    'EXPR2 : EXPR2 DIV EXPR2'
    x = p[1]
    y = p[3]
    if y == 0:
        raise Exception('division by zero')
    a = inverse2(y)
    if a == -1:
        raise Exception('inverse does not exist')
    p[0] = flatten2(multiply2(x, a))
    print_('/ ')


def p_EXPR2_MOD(p):
    'EXPR2 : EXPR2 MOD EXPR2'
    x = p[1]
    y = p[3]
    if y == 0:
        raise Exception('mod by zero')
    p[0] = flatten2(flatten2(x) % flatten2(y))
    print_('% ')



def p_EXPR2_PRS(p):
    'EXPR2 : LPR EXPR2 RPR'
    p[0] = p[2]


def p_EXPR2_NUM(p):
    'EXPR2 : NUMR2'
    p[0] = p[1]


def p_EXPR2_NEG_PRS(p):
    'EXPR2 : SUB LPR EXPR2 RPR %prec NEG'
    p[0] = flatten2(0-p[3])
    print_("0 -")

def p_error(p):
    if p != None:
        print(f'\nsyntax error: ‘{p.value}’')
    else:
        print(f'syntax error')


yacc.yacc()

acc = ''
for line in stdin:
    if line == "\n":
        continue
    try:
        if line[-2] == '\\':
            acc += line[:-2]
        elif acc != '':
            acc += line
            yacc.parse(acc)
            print(onp)
            onp = ''
            acc = ''
        else:
            yacc.parse(line)
            print(onp)
            onp = ''
    except Exception as e:
        print("error", e)
        acc = ''
        onp = ''
