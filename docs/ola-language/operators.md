# Operators

Ola Provides operators such as arithmetic, logic, relational, bits, and so on. Except for the arithmetic operation acting on numerical values, which is Mod p, all others are standard semantics.

## Arithmetic operators

All arithmetic operators are Mod p.

Arithmetic operators can be combined with the assignment operator`=`to form new compound operators `+=`、`-=`、`*=`、`/=`、`%=`, with arithmetic operators having higher priority than compound operators.

| Operat | Example |                 Explanation                |
| :----: | :-----: | :----------------------------------------: |
|    +   |  a + b  |        Arithmetic addition modulo p        |
|    -   |   a-b   |       Arithmetic subtraction modulo p      |
|   \*   |  a \* b |     Arithmetic multiplication modulo p     |
|    /   |  a / b  | Arithmetic multiplication inverse modulo p |
|    %   |   a%b   |  The modulo of arithmetic integer division |
|  \*\*  |  a\*\*b |               Power modulo p               |

## Boolean operators

Support with AND(`&&`)as well as OR(`||`),with the latter having higher priority.

| Operator | Example  | Explanation                |
| -------- | -------- | -------------------------- |
| &&       | a && b   | Boolean operator and (AND) |
| \|\|     | a \|\| b | Boolean operator or (OR)   |
| !        | ! a      | Boolean operator NEGATION  |

## Relational operators

The return result of the relational operator is type`bool`

| Operator | Example | Explanation              |
| -------- | ------- | ------------------------ |
| ==       | a == b  | equal                    |
| !=       | a ！= b  | not equal                |
| <        | a < b   | less than                |
| >        | a >b    | greater than             |
| <=       | a <= b  | less than or equal to    |
| >=       | a >= b  | greater than or equal to |

## Bitwise operators

All bitwise operators are modulo p, containing bit or and non and shift operations.

| Operator | Example | Explanation        |
| -------- | ------- | ------------------ |
| &        | a & b   | bit and            |
| \|       | a \| b  | bit or             |
| ^        | a ^ b   | XOR 32 bits        |
| <<       | a << 3  | shift left         |
| >>       | a >> 3  | shift right        |
| \~       | \~a     | Complement 32 bits |

Bitwise operators can be combined with the assignment operator`=`to form the new compound operators`&=`、`|=`、`^=`、`<<=`、`>>=`, with bitwise operators taking precedence over compound operators.
