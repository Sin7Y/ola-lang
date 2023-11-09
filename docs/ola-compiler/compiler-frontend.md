# Compiler Frontend

The processing of the Ola language compiler frontend is divided into the processes of lexical analysis, syntax parsing, abstract syntax tree (AST) generation, semantic analysis, and LLVM intermediate representation (IR) generation.

The processing flow of the compiler frontend is shown in the following figure

<figure><img src="../.gitbook/assets/ola-lang-frontend.png" alt=""><figcaption><p>ola compiler frontend</p></figcaption></figure>

## Ola Language Parser

Lexical analysis is the first stage of the compiler frontend. In this phase, the goal is to break down the source code into a series of tokens. The Ola language lexer will handle the following elements:

* Keywords
* Identifiers
* Operators
* Literals (such as strings, numbers, and boolean values)
* Comments
* Delimiters (such as parentheses and commas)

Additionally, the lexer will eliminate whitespace and comments, ensuring a clean token stream for the next phase.

## Syntax Parsing

Syntax parsing is the process of transforming the tokens generated in the lexical analysis phase into an Abstract Syntax Tree (AST). The Ola language compiler will implement a top-down parser, such as a Recursive Descent Parser, to support Ola language's grammar.

This section will also discuss the implementation of error handling and recovery mechanisms, ensuring that the parser can handle syntax errors gracefully and provide helpful error messages to the user.

## Abstract Syntax Tree (AST) Generation

During the syntax parsing phase, the parser will generate an AST representing the program's structure. This section will explain the design of the AST data structures and the process of constructing the AST during parsing. Additionally, it will cover the benefits of using an AST, such as enabling easier manipulation and analysis of the code's structure.

The Ola compiler seamlessly integrates the Lexical Analysis, Syntax Parsing, and Abstract Syntax Tree (AST) generation processes, forming a cohesive and efficient pipeline. By leveraging the LALRPOP framework, these phases work in harmony, transforming the Ola source code into an AST representation that is suitable for subsequent compiler phases. This unified approach not only simplifies the implementation but also enhances the performance and robustness of the Ola compiler.

By following these steps, the compiler can efficiently convert the Ola source code text into a sequence of tokens:

1. The first step in implementing the lexical analysis phase of the Ola compiler is to define lexer rules for various token categories, including keywords, identifiers, literals, and operators. These rules should be based on the provided EBNF grammar rules. We created a file named `ola.lalrpop` that describes Ola's EBNF grammar rules.
2. After defining the lexer rules, the next step is to integrate the lexer with the parser. This can be achieved by using the lexer attribute in LALRPOP grammar rules. The lexer attribute specifies which lexer rule should be used to recognize a particular grammar production.
3. Ola compiler provides error handling and reporting. If the lexer encounters an unexpected character or a malformed token, it generates an error with the corresponding position in the input text. This information can be used to provide helpful error messages to the user.

Once the lexical analysis phase is complete, the generated sequence of tokens can be passed to the parser, which will construct an abstract syntax tree (AST) based on the defined grammar rules. This AST can then be further processed by subsequent phases of the Ola compiler, such as semantic analysis, optimization, and code generation, ultimately producing executable code for the target platform.

By leveraging the powerful LALRPOP framework, the Ola compiler can efficiently perform lexical analysis and provide robust error handling, ensuring that the compiler is user-friendly and capable of handling complex Ola source code.

## Semantic Analysis

The Semantic Analysis phase of the Ola compiler is an extensive process that ensures the program's correctness and consistency. As previously mentioned, this phase consists of several sub-tasks. Here, we delve deeper into each sub-task, providing a more detailed and comprehensive explanation of the process.

## Symbol Resolution

The compiler analyzes the program's scope and context to resolve symbols accurately. It distinguishes between local and global variables, function declarations, and type definitions. The symbol table, which holds information about each symbol, is updated as the compiler traverses the AST. During this process, the compiler also checks for naming conflicts and multiple declarations, ensuring that the program adheres to Ola's scoping rules.

## LibFunction Identification

In the semantic analysis phase, we will identify all libFunction names that users call. We will also construct prototype code for these LibFunctions and verify whether the parameters used to call them match the parameter types and numbers in the prototype code. If there is a match, we will record them for easy processing of IR generation for Lib Functions in subsequent LLVM IR generation phases.

## Type Checking

The compiler ensures that each operation and expression in the program involves operands of compatible types. In this stage, the compiler also infers the types of expressions when necessary and enforces type constraints for function calls, assignments, and arithmetic operations.

## Control Flow Analysis

In addition to checking for unreachable code and infinite loops, the control flow analysis process verifies that:

* All code paths in a function that should return a value must end with a return statement.
* Break and continue statements appear only within loops.
* Variables are declared before they are used.

## Constant Expression Evaluation

During this step, the compiler performs the following tasks:

* Evaluates arithmetic and bitwise operations on constant expressions at compile-time, ensuring that the generated code is more efficient.
* Detects potential errors, such as array index out-of-bounds, by evaluating expressions that involve constants.
* Folds constant expressions, such as mathematical operations or string concatenations, reducing the code size and improving execution efficiency.

## Semantic Validation

The final step of the semantic analysis phase consists of several validation checks, including:

* Verifying that variables are initialized before they are used.
* Ensuring that variables, functions, and types are declared only once within a given scope.
* Checking that all required function arguments are provided and that excess arguments are not supplied.
* Validating that return statements are used correctly within functions.

The Semantic Analysis phase is crucial for the robustness and correctness of the Ola compiler. By performing these comprehensive checks, the compiler can guarantee that the generated code adheres to the language's semantic rules and is free from errors that might lead to unexpected behavior during execution. With a semantically verified AST, the Ola compiler proceeds to the subsequent phases of the compilation process, ensuring the efficient translation of the source code into executable code tailored for the OlaVM.

## LLVM IR Generation

The LLVM IR Generation phase is a crucial step in the Ola compiler, as it translates the Abstract Syntax Tree (AST) obtained from the semantic analysis into LLVM Intermediate Representation (IR). This phase leverages the Inkwell framework, a powerful and user-friendly library that simplifies the process of generating LLVM IR code in Rust.
