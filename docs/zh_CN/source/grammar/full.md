# Ola Grammar

## Rule SourceUnit


![SourceUnit](svg/sourceunit.svg)

```ebnf
rule SourceUnit ::=
    SourceUnitPart *  
  ;

```



## Rule SourceUnitPart

![SourceUnitPart](svg/sourceunitpart.svg)

```ebnf
rule SourceUnitPart ::=
    ContractDefinition 
  | ImportDirective 
  ;

```



## Rule ImportDirective

![ImportDirective](svg/importdirective.svg)

```ebnf
rule ImportDirective ::=
     'import' StringLiteral  ';' 
  |  'import' StringLiteral  'as' Identifier  ';' 
  ;

```



## Rule Type

![Type](svg/type.svg)

```ebnf
rule Type ::=
     'bool' 
  |  'field' 
  |  'u32' 
  |  'u64' 
  |  'u256' 
  ;

```



## Rule IdentifierOrError

![IdentifierOrError](svg/identifierorerror.svg)

```ebnf
rule IdentifierOrError ::=
    Identifier 
  | 
  ;

```



## Rule VariableDeclaration

![VariableDeclaration](svg/variabledeclaration.svg)

```ebnf
rule VariableDeclaration ::=
    Precedence0 IdentifierOrError 
  ;

```



## Rule StructDefinition

![StructDefinition](svg/structdefinition.svg)

```ebnf
rule StructDefinition ::=
     'struct' IdentifierOrError  '{' ( VariableDeclaration  ';' ) *   '}' 
  ;

```



## Rule ContractPart

![ContractPart](svg/contractpart.svg)

```ebnf
rule ContractPart ::=
    StructDefinition 
  | EnumDefinition 
  | VariableDefinition 
  | FunctionDefinition 
  | TypeDefinition 
  |  ';' 
  ;

```



## Rule ContractDefinition

![ContractDefinition](svg/contractdefinition.svg)

```ebnf
rule ContractDefinition ::=
     'contract' IdentifierOrError  '{' ( ContractPart ) *   '}' 
  ;

```



## Rule EnumDefinition

![EnumDefinition](svg/enumdefinition.svg)

```ebnf
rule EnumDefinition ::=
     'enum' IdentifierOrError  '{' Comma!(IdentifierOrError)  '}' 
  ;

```



## Rule VariableDefinition

![VariableDefinition](svg/variabledefinition.svg)

```ebnf
rule VariableDefinition ::=
    Precedence0 VariableAttribute *  IdentifierOrError (  '=' Expression ) ?   ';' 
  | Precedence0 VariableAttribute *  Identifier  ';' 
  ;

```



## Rule TypeDefinition

![TypeDefinition](svg/typedefinition.svg)

```ebnf
rule TypeDefinition ::=
     'type' Identifier  '=' Precedence0  ';' 
  ;

```



## Rule VariableAttribute

![VariableAttribute](svg/variableattribute.svg)

```ebnf
rule VariableAttribute ::=
     'const' 
  |  'mut' 
  ;

```



## Rule Expression

![Expression](svg/expression.svg)

```ebnf
rule Expression ::=
    Precedence14 
  ;

```



## Rule Precedence14

![Precedence14](svg/precedence14.svg)

```ebnf
rule Precedence14 ::=
    Precedence13  '=' Precedence14 
  | Precedence13  '|=' Precedence14 
  | Precedence13  '^=' Precedence14 
  | Precedence13  '&=' Precedence14 
  | Precedence13  '<<=' Precedence14 
  | Precedence13  '>>=' Precedence14 
  | Precedence13  '+=' Precedence14 
  | Precedence13  '-=' Precedence14 
  | Precedence13  '*=' Precedence14 
  | Precedence13  '/=' Precedence14 
  | Precedence13  '%=' Precedence14 
  | Precedence13  '?' Precedence14  ':' Precedence14 
  | Precedence13 
  ;

```



## Rule Precedence13

![Precedence13](svg/precedence13.svg)

```ebnf
rule Precedence13 ::=
    Precedence13  '||' Precedence12 
  | Precedence12 
  ;

```



## Rule Precedence12

![Precedence12](svg/precedence12.svg)

```ebnf
rule Precedence12 ::=
    Precedence12  '&&' Precedence11 
  | Precedence11 
  ;

```



## Rule Precedence11

![Precedence11](svg/precedence11.svg)

```ebnf
rule Precedence11 ::=
    Precedence11  '==' Precedence10 
  | Precedence11  '!=' Precedence10 
  | Precedence10 
  ;

```



## Rule Precedence10

![Precedence10](svg/precedence10.svg)

```ebnf
rule Precedence10 ::=
    Precedence10  '<' Precedence9 
  | Precedence10  '>' Precedence9 
  | Precedence10  '<=' Precedence9 
  | Precedence10  '>=' Precedence9 
  | Precedence9 
  ;

```



## Rule Precedence9

![Precedence9](svg/precedence9.svg)

```ebnf
rule Precedence9 ::=
    Precedence9  '|' Precedence8 
  | Precedence8 
  ;

```



## Rule Precedence8

![Precedence8](svg/precedence8.svg)

```ebnf
rule Precedence8 ::=
    Precedence8  '^' Precedence7 
  | Precedence7 
  ;

```



## Rule Precedence7

![Precedence7](svg/precedence7.svg)

```ebnf
rule Precedence7 ::=
    Precedence7  '&' Precedence6 
  | Precedence6 
  ;

```



## Rule Precedence6

![Precedence6](svg/precedence6.svg)

```ebnf
rule Precedence6 ::=
    Precedence6  '<<' Precedence5 
  | Precedence6  '>>' Precedence5 
  | Precedence5 
  ;

```



## Rule Precedence5

![Precedence5](svg/precedence5.svg)

```ebnf
rule Precedence5 ::=
    Precedence5  '+' Precedence4 
  | Precedence5  '-' Precedence4 
  | Precedence4 
  ;

```



## Rule Precedence4

![Precedence4](svg/precedence4.svg)

```ebnf
rule Precedence4 ::=
    Precedence4  '*' Precedence3 
  | Precedence4  '/' Precedence3 
  | Precedence4  '%' Precedence3 
  | Precedence3 
  ;

```



## Rule Precedence3

![Precedence3](svg/precedence3.svg)

```ebnf
rule Precedence3 ::=
    Precedence2  '**' Precedence3 
  | Precedence2 
  ;

```



## Rule Precedence2

![Precedence2](svg/precedence2.svg)

```ebnf
rule Precedence2 ::=
     '!' Precedence2 
  |  '~' Precedence2 
  | Precedence0 
  ;

```



## Rule NamedArgument

![NamedArgument](svg/namedargument.svg)

```ebnf
rule NamedArgument ::=
    Identifier  ':' Expression 
  ;

```



## Rule FunctionCall

![FunctionCall](svg/functioncall.svg)

```ebnf
rule FunctionCall ::=
    Precedence0  '(' Comma!(Expression)  ')' 
  | Precedence0  '('  '{' Comma!(NamedArgument)  '}'  ')' 
  ;

```



## Rule Precedence0

![Precedence0](svg/precedence0.svg)

```ebnf
rule Precedence0 ::=
    Precedence0  '++' 
  | Precedence0  '--' 
  | FunctionCall 
  | Precedence0  '[' Expression ?   ']' 
  | Precedence0  '[' Expression ?   ':' Expression ?   ']' 
  | Precedence0  '.' Identifier 
  | Type 
  |  '[' CommaOne!(Expression)  ']' 
  | Identifier 
  | ParameterList 
  | LiteralExpression 
  ;

```



## Rule LiteralExpression

![LiteralExpression](svg/literalexpression.svg)

```ebnf
rule LiteralExpression ::=
     'true' 
  |  'false' 
  | Number 
  ;

```



## Rule Parameter

![Parameter](svg/parameter.svg)

```ebnf
rule Parameter ::=
    Expression Identifier ?  
  ;

```



## Rule OptParameter

![OptParameter](svg/optparameter.svg)

```ebnf
rule OptParameter ::=
    Parameter ?  
  ;

```



## Rule ParameterList

![ParameterList](svg/parameterlist.svg)

```ebnf
rule ParameterList ::=
     '('  ')' 
  |  '(' Parameter  ')' 
  |  '(' CommaTwo!(OptParameter)  ')' 
  |  '('  ')' 
  ;

```



## Rule BlockStatementOrSemiColon

![BlockStatementOrSemiColon](svg/blockstatementorsemicolon.svg)

```ebnf
rule BlockStatementOrSemiColon ::=
     ';' 
  | BlockStatement 
  ;

```



## Rule FunctionDefinition

![FunctionDefinition](svg/functiondefinition.svg)

```ebnf
rule FunctionDefinition ::=
     'fn' IdentifierOrError ParameterList (  '->' ParameterList ) ?  BlockStatementOrSemiColon 
  ;

```



## Rule BlockStatement

![BlockStatement](svg/blockstatement.svg)

```ebnf
rule BlockStatement ::=
     '{' Statement *   '}' 
  ;

```



## Rule OpenStatement

![OpenStatement](svg/openstatement.svg)

```ebnf
rule OpenStatement ::=
     'if'  '(' Expression  ')' Statement 
  |  'if'  '(' Expression  ')' ClosedStatement  'else' OpenStatement 
  |  'for'  '(' SimpleStatement ?   ';' Expression ?   ';' SimpleStatement ?   ')' OpenStatement 
  ;

```



## Rule ClosedStatement

![ClosedStatement](svg/closedstatement.svg)

```ebnf
rule ClosedStatement ::=
    NonIfStatement 
  |  'if'  '(' Expression  ')' ClosedStatement  'else' ClosedStatement 
  |  'for'  '(' SimpleStatement ?   ';' Expression ?   ';' SimpleStatement ?   ')' ClosedStatement 
  |  'for'  '(' SimpleStatement ?   ';' Expression ?   ';' SimpleStatement ?   ')'  ';' 
  ;

```



## Rule Statement

![Statement](svg/statement.svg)

```ebnf
rule Statement ::=
    OpenStatement 
  | ClosedStatement 
  | 
  ;

```



## Rule SimpleStatement

![SimpleStatement](svg/simplestatement.svg)

```ebnf
rule SimpleStatement ::=
    VariableDeclaration (  '=' Expression ) ?  
  | Expression 
  ;

```



## Rule NonIfStatement

![NonIfStatement](svg/nonifstatement.svg)

```ebnf
rule NonIfStatement ::=
    BlockStatement 
  | SimpleStatement  ';' 
  |  'continue'  ';' 
  |  'break'  ';' 
  |  'return'  ';' 
  |  'return' Expression  ';' 
  ;

```



## Rule Comma

![Comma](svg/comma.svg)

```ebnf
macro Comma<T> ::=
    
  | CommaOne!(T) 
  ;

```



## Rule CommaOne

![CommaOne](svg/commaone.svg)

```ebnf
macro CommaOne<T> ::=
    T (  ',' T ) *  
  ;

```



## Rule CommaTwo

![CommaTwo](svg/commatwo.svg)

```ebnf
macro CommaTwo<T> ::=
    T (  ',' T ) +  
  ;

```



## Rule Number

![Number](svg/number.svg)

```ebnf
rule Number ::=
     'r#([1-9][0-9]*|0)(u|ll|l)?#' 
  |  'r#0x[0-9A-Fa-f]*(u|ll|l)?#' 
  ;

```



## Rule Identifier

![Identifier](svg/identifier.svg)

```ebnf
rule Identifier ::=
     'r#[$_]*[a-zA-Z][a-zA-Z$_0-9]*#' 
  ;

```



## Rule StringLiteral

![StringLiteral](svg/stringliteral.svg)

```ebnf
rule StringLiteral ::=
     'r#\\[^\\]*\\#' 
  ;

```




