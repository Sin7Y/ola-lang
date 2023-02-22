<img src="docs/en/source/images/ola.jpg" alt="Ola Logo" width = "400" height = "300" style="align:center" />



 [![CI](https://img.shields.io/github/actions/workflow/status/Sin7y/ola-lang/rust.yml)](https://github.com/Sin7Y/ola-lang/actions)
 [![Documentation Status](https://img.shields.io/readthedocs/olang)](https://olang.readthedocs.io/en/latest/?badge=latest)
 [![Project license](https://img.shields.io/github/license/Sin7y/ola-lang)](LICENSE)
 [![LoC](https://tokei.rs/b1/github/Sin7y/ola-lang?category=lines)](https://github.com/Sin7y/ola-lang)
 [![Twitter](https://img.shields.io/twitter/follow/Sin7y_Labs?style=social)](https://twitter.com/Sin7y_Labs)

## Introduction

Ola is a high-level language for implementing smart contracts. From the outset, it is designed to be a zk-friendly programming language.

Ola is influenced by Solidity and Rust, and is very easy for developers familiar with these languages to get started. It is statically typed and supports complex user-defined types among other features. With Ola, you can create contracts for a variety of uses.

The current Ola Language is unstable, with many features that need to be improved. Keep an eye on our progress!

## Simple Example

The following shows a simple contract for calculating the Fibonacci function

### Writing fibo case using Ola syntax

```
contract Fibonacci {

    fn main() {
       fib_non_recursive(10);
    }

    fn fib_recursive(u32 n) -> (u32) {
        if (n <= 2) {
            return 1;
        }
        return fib_recursive(n -1) + fib_recursive(n -2);
    }

    fn fib_non_recursive(u32 n) -> (u32) {
        u32 first = 0;
        u32 second = 1;
        u32 third = 1;
        for (u32 i = 2; i <= n; i++) {
             third = first + second;
             first = second;
             second = third;
        }
        return third;
    }

}
```

### Generating LLVM IR code using Ola compiler front-end

```
; ModuleID = 'Fibonacci'
source_filename = "fib.ola"

define void @main() {
entry:
  %0 = call i32 @fib_non_recursive(i32 10)
  ret void
}

define i32 @fib_recursive(i32 %0) {
entry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %1 = load i32, i32* %n, align 4
  %2 = icmp ule i32 %1, 2
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  %3 = load i32, i32* %n, align 4
  %4 = sub i32 %3, 1
  %5 = call i32 @fib_recursive(i32 %4)
  %6 = load i32, i32* %n, align 4
  %7 = sub i32 %6, 2
  %8 = call i32 @fib_recursive(i32 %7)
  %9 = add i32 %5, %8
  ret i32 %9
}

define i32 @fib_non_recursive(i32 %0) {
entry:
  %i = alloca i32, align 4
  %third = alloca i32, align 4
  %second = alloca i32, align 4
  %first = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  store i32 0, i32* %first, align 4
  store i32 1, i32* %second, align 4
  store i32 1, i32* %third, align 4
  store i32 2, i32* %i, align 4
  br label %cond

cond:                                             ; preds = %next, %entry
  %1 = load i32, i32* %i, align 4
  %2 = load i32, i32* %n, align 4
  %3 = icmp ule i32 %1, %2
  br i1 %3, label %body, label %endfor

body:                                             ; preds = %cond
  %4 = load i32, i32* %first, align 4
  %5 = load i32, i32* %second, align 4
  %6 = add i32 %4, %5
  store i32 %6, i32* %third, align 4
  %7 = load i32, i32* %second, align 4
  store i32 %7, i32* %first, align 4
  %8 = load i32, i32* %third, align 4
  store i32 %8, i32* %second, align 4
  br label %next

next:                                             ; preds = %body
  %9 = load i32, i32* %i, align 4
  %10 = add i32 %9, 1
  store i32 %10, i32* %i, align 4
  br label %cond

endfor:                                           ; preds = %cond
  %11 = load i32, i32* %third, align 4
  ret i32 %11
}
```

### Generating Ola assembly code using Ola compiler back-end

```
main:
.LBL0_0:
  add r8 r8 4
  mstore [r8,-2] r8
  mov r1 10
  call fib_non_recursive
  add r8 r8 -4
  end 
fib_recursive:
.LBL1_0:
  add r8 r8 9
  mstore [r8,-2] r8
  mov r0 r1
  mstore [r8,-7] r0
  mload r0 [r8,-7]
  mov r7 2
  gte r0 r7 r0
  cjmp r0 .LBL1_1
  jmp .LBL1_2
.LBL1_1:
  mov r0 1
  add r8 r8 -9
  ret 
.LBL1_2:
  mload r0 [r8,-7]
  not r7 1
  add r7 r7 1
  add r1 r0 r7
  call fib_recursive
  mstore [r8,-3] r0
  mload r0 [r8,-7]
  not r7 2
  add r7 r7 1
  add r0 r0 r7
  mstore [r8,-5] r0
  mload r1 [r8,-5]
  call fib_recursive
  mload r1 [r8,-3]
  add r0 r1 r0
  mstore [r8,-6] r0
  mload r0 [r8,-6]
  add r8 r8 -9
  ret 
fib_non_recursive:
.LBL2_0:
  add r8 r8 5
  mov r0 r1
  mstore [r8,-1] r0
  mov r0 0
  mstore [r8,-2] r0
  mov r0 1
  mstore [r8,-3] r0
  mov r0 1
  mstore [r8,-4] r0
  mov r0 2
  mstore [r8,-5] r0
  jmp .LBL2_1
.LBL2_1:
  mload r0 [r8,-5]
  mload r1 [r8,-1]
  gte r0 r1 r0
  cjmp r0 .LBL2_2
  jmp .LBL2_4
.LBL2_2:
  mload r1 [r8,-2]
  mload r2 [r8,-3]
  add r0 r1 r2
  mstore [r8,-4] r0
  mload r0 [r8,-3]
  mstore [r8,-2] r0
  mload r0 [r8,-4]
  mstore [r8,-3] r0
  jmp .LBL2_3
.LBL2_3:
  mload r1 [r8,-5]
  add r0 r1 1
  mstore [r8,-5] r0
  jmp .LBL2_1
.LBL2_4:
  mload r0 [r8,-4]
  add r8 r8 -5
  ret 
```

## Getting Started

### Prerequisites

#### [Rust](https://www.rust-lang.org/tools/install)

```bash
rustup toolchain install nightly
rustup default nightly
```

#### [LLVM](https://releases.llvm.org/)

In order to build the project, you need to have LLVM installed on your system.


For macos, installing llvm with brew is very easy.

```
brew install llvm@14
### add llvm path to bash.rc or .zshrc
echo 'export PATH="/usr/local/opt/llvm@14/bin:$PATH"' >> ~/.zshrc 
```

For other operating systems, please refer to the llvm installation guide.

### Installation

Once you have the correct LLVM version in your path, simply run:

```
git clone https://github.com/Sin7Y/ola-lang.git
cd ola-lang
cargo build --release 
```

The executable will be in `target/release/olac`

## Usage

The olac compiler is run on the command line. The ola source file names are provided as command line arguments; the output is an Ola asm.

### Command line interface

```
olac --help
Ola Language Compiler

Usage: olac <COMMAND>

Commands:
  compile  Compile ola source files
  help     Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

### Compile Ola Language to LLVM IR

Olac's compile command supports subcommands, using the  `--gen  llvm-ir` option to generate llvm-ir

```
olac compile examples/fib.ola --gen llvm-ir
```

### Compile Ola to Ola's Assembly code

using the `--gen  asm` option to generate Ola assembly code

```
olac compile ./examples/fib.ola --gen asm
```

## Visual Studio Code Extension

Ola supports writing on vscode, we have developed an extension to vscode to support ola syntax highlighting, and we will continue to improve the plugin in the future.

The extension can be found on the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=Sin7y.ola).

## Docs

[Chinese Version](./README_zh_CN.md) | English Version

| Code Repo                                          | Doc Entry                                      | Current Status                                                                                                            |
| :------------------------------------------------- | :--------------------------------------------- |:--------------------------------------------------------------------------------------------------------------------------|
| [Code Repo](https://github.com/Sin7Y/ola-lang.git) | [Doc](https://olang.readthedocs.io/en/latest/) | [![Documentation Status](https://img.shields.io/readthedocs/olang)](https://olang.readthedocs.io/en/latest/?badge=latest) |

## Roadmap


| Milestone                                                    | Status      | Difficulty                      |
| ------------------------------------------------------------ | ----------- | ------------------------------- |
| Support for simple calculations and function calls           | Completed   | Easy:grinning:                  |
| Better statement support and type system                     | Doing       | Medium:grin:                    |
| Smart Contract Storage Model Design                          | Doing       | Medium:grin:                    |
| Assembler, outputting better assembly format                 | Doing       | Easy:grinning:                  |
| Poseidon hash builtin function to reduce the complexity of proof systems | Not started | Medium :grin:                          |
| Prophet is designed to reduce the complexity of proof systems | Not started | Hard:upside_down_face: :muscle: |
| A more complete compilation back-end system, based on Ola opcode | Not started | Hard:upside_down_face::muscle:  |

In addition to the milestone design above， there are more details that need to be refined.

See the [open issues](https://github.com/Sin7Y/ola-lang/issues) for a list of proposed features (and known issues).

## Contact us

Email：<contact@sin7y.com>
*******************************

## License

[Apache 2.0](LICENSE)
