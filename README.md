<img src="docs/en/source/images/ola.jpg" alt="Ola Logo" width = "400" height = "300" style="align:center" />



 [![CI](https://img.shields.io/github/actions/workflow/status/Sin7y/ola-lang/rust.yml)](https://github.com/Sin7Y/ola-lang/actions)
 [![Documentation Status](https://img.shields.io/readthedocs/olang)](https://solang.readthedocs.io/en/latest/?badge=latest)
 [![Project license](https://img.shields.io/github/license/Sin7y/ola-lang)](LICENSE)
 [![LoC](https://tokei.rs/b1/github/Sin7y/ola-lang?category=lines)](https://github.com/Sin7y/ola-lang)
 [![Twitter](https://img.shields.io/twitter/follow/Sin7y_Labs?style=social)](https://twitter.com/Sin7y_Labs)

## Introduction

Ola is a high-level language for implementing smart contracts. From the outset, it is designed to be a zk-friendly programming language.

Ola is influenced by Solidity and Rust, and is very easy for developers familiar with these languages to get started. It is statically typed and supports complex user-defined types among other features. With Ola, you can create contracts for a variety of uses.

The current Ola Language is unstable, with many features that need to be improved. Keep an eye on our progress!

## Simple Example

The following shows a simple contract for calculating the Fibonacci function

```
contract Fibonacci {

    fn main() {
       fib_recursive(10);
    }

    fn fib_recursive(u32 n) -> (u32) {
        if (n == 1) {
            return 1;
        }
        if (n == 2) {
            return 1;
        }

        return fib_recursive(n -1) + fib_recursive(n -2);
    }

}
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

## Uasge

The Solang compiler is run on the command line. The solidity source file names are provided as command line arguments; the output is an optimized wasm or bpf file which is ready for deployment on a chain, and an metadata file (also known as the abi).

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

### Compile Ola to Ola's Opcode

```
olac compile ./examples/fib.ola --gen asm
```

## Visual Studio Code Extension

Ola supports writing on vscode, we have developed an extension to vscode to support ola syntax highlighting, and we will continue to improve the plugin in the future.

The extension can be found on the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=Sin7y.ola).

## Docs

[Chinese Version](./README_zh_CN.md) | English Version

| Code Repo                                          | Doc Entry                                      | Current Status                                               |
| :------------------------------------------------- | :--------------------------------------------- | :----------------------------------------------------------- |
| [Code Repo](https://github.com/Sin7Y/ola-lang.git) | [Doc](https://olang.readthedocs.io/en/latest/) | [![Documentation Status](https://img.shields.io/readthedocs/olang)](https://solang.readthedocs.io/en/latest/?badge=latest) |

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
