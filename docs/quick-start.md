# 🏃♂ Quick Start

## Installation

The Olac compiler is a single binary. It can be installed in different ways, listed below.

1. [Download from Homebrew (MacOS only)](quick-start.md#option-1-download-from-brew)
2. [Download binaries](quick-start.md#option-2-download-binaries)
3. [Build from source](quick-start.md#option-3-build-olac-from-source)

### Option 1: Download from Brew

Olac is available on Brew via a private tap. This works only for MacOS systems, both Intel and Apple Silicon. To install Olac via Brew, run the following command:

```shell
brew install sin7y/ola/olac
```

### Option 2: Download binaries

There are binaries available on[ github releases](https://github.com/Sin7Y/ola-lang/releases)

Download the file and save it somewhere in your `$PATH`, for example the bin directory in your home directory. If the path you use is not already in `$PATH`, then you need to add it yourself.

On MacOS, remember to give execution permission to the file and remove it from quarantine by executing the following commands:

```shell
chmod +x olac-mac-arm
xattr -d com.apple.quarantine olac-mac-arm
```

If you are using an Intel based Mac, please, exchange `olac-mac-arm` by `olac-mac-intel` in both of the above commands.

On Linux, permission to execute the binary is also necessary, so, please, run `chmod +x olac-linux-x86-64`.

### Option 3: Build Olac from source

In order to build Olac from source, you will need:

* Rust nightly version 1.72.0 or higher
* A pre-built LLVM Libraries, version 15.0.7

#### Step 1: Install Rust

If you do not have the correct version of rust installed, go to [rustup](https://rustup.rs/).

#### Step 2: Install the LLVM Libraries

Ola needs a build of LLVM Libraries, You can download the pre-built libraries from [github](https://github.com/llvm/llvm-project/releases/tag/llvmorg-15.0.7) After that, you need to add the `bin` of your LLVM directory to your path, so that the build system of O la c can find the correct version of LLVM to use.

**Linux(Ubuntu)**

A pre-built version of LLVM, is available at [https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.6/clang+llvm-15.0.6-x86\_64-linux-gnu-ubuntu-18.04.tar.xz](https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.6/clang+llvm-15.0.6-x86\_64-linux-gnu-ubuntu-18.04.tar.xz)

```shell
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.6/clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz
tar Jxf clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04.tar.xz
mv clang+llvm-15.0.6-x86_64-linux-gnu-ubuntu-18.04 llvm15.0
```

{% hint style="info" %}
You need to replace your llvm download directory here.
{% endhint %}

```bash
echo 'export PATH=~/llvm15.0/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

**Windows**

For Windows users, the official LLVM does not provide additional tools like `llvm-config`, which causes Olac to fail to build. Therefore, we provide pre-built versions for Windows. is available at [https://github.com/Sin7Y/ola-llvm/releases/download/llvm15-0/llvm15.0-win.zip](https://github.com/Sin7Y/ola-llvm/releases/download/llvm15-0/llvm15.0-win.zip)

After unzipping the file, add the bin directory to your path.

{% hint style="info" %}
You need to replace your llvm download directory here.
{% endhint %}

```bash
set PATH=%PATH%;C:\llvm15.0\bin
```

**Mac**

For macOS users, you can download the llvm official build package. A pre-built version of LLVM for intel macs, is available at [https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-x86\_64-apple-darwin21.0.tar.xz](https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-x86\_64-apple-darwin21.0.tar.xz). After downloading, untar the file in a terminal and add it to your path like so:

```bash
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz
tar Jxf clang+llvm-15.0.7-x86_64-apple-darwin21.0.tar.xz
mv clang+llvm-15.0.7-x86_64-apple-darwin21.0 llvm15.0
xattr -rd com.apple.quarantine llvm15.0 
```

arm macs there is [https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-arm64-apple-darwin22.0.tar.xz](https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-arm64-apple-darwin22.0.tar.xz) After downloading, untar the file in a terminal and add it to your path like so:

```bash
wget  https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/clang+llvm-15.0.7-arm64-apple-darwin22.0.tar.xz
tar Jxf clang+llvm-15.0.7-arm64-apple-darwin22.0.tar.xz
mv clang+llvm-15.0.7-arm64-apple-darwin22.0 llvm15.0
xattr -rd com.apple.quarantine llvm15.0 
```

{% hint style="info" %}
You need to replace your llvm download directory here.
{% endhint %}

```bash
echo 'export PATH=~/Downloads/llvm15.0/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
```

After you finish installing LLVM, you should try the llvm-config command to check if the output version is correct.

```bash
llvm-config --version
```

#### Step 3: Build Olac

Once you have the correct LLVM version in your path, simply run:

```bash
git clone https://github.com/Sin7Y/ola-lang
cd ola-lang
cargo build --release
```

If you encounter the following error message, then you need to check if llvm is installed correctly and if the llvm-config command can be executed correctly.

{% hint style="danger" %}
error: No suitable version of LLVM was found system-wide or pointed to by LLVM\_SYS\_150\_PREFIX.

```
          Consider using `llvmenv` to compile an appropriate copy of LLVM, and
          refer to the llvm-sys documentation for more information.
   
          llvm-sys: https://crates.io/crates/llvm-sys
          llvmenv: https://crates.io/crates/llvmenv
```
{% endhint %}

{% hint style="info" %}
After you ensure that the LLVM environment variable is configured, you can clean the cargo build cache and re-build.
{% endhint %}

```bash
cargo clean
cargo build --release
```

The executable will be in `target/release/olac`

#### Alternative step 3: Build Olac from crates.io

The latest Ola release is on [crates.io](https://crates.io/crates/ola-lang). Once you have the correct LLVM version in your path, ensure you have GNU make installed and simply run:

```bash
cargo install olac
```

## Using olac on the command line

The olac compiler is run on the command line. The ola source file names are provided as command line arguments; the output is an optimized asm file and anabi file (also known as the abi).

### Compiler Usage

olac compile \[OLA SOURCE FILE] ... \[OPTIONS]…

Assuming there is a Fibonacci sequence contract, the command to compile this contract is:

```bash
olac compile fib.ola
```

The above command will generate the files `fib_abi.json` and `fib_asm.json`.

Ola supports some debug mode options. This means that the command line is `olac compile` followed by any options described below, followed by one source file.

Options:

**--gen** _phase_

This option is can be used for debugging Olac itself. This is used to output early phases of compilation.

* **abi** Ouput Ola contract's ABI information
* **ast** Output Abstract Syntax Tree as a graphviz dot file. This can be viewed with xdot or any other tool that can visualize graphviz dot files.
* **llvm-ir** Output llvm IR as text.
* **asm** Output assembly text file.

## Write Ola using an IDE

Ola supports writing on vscode, we have developed an extension to vscode to support ola syntax highlighting, and we will continue to improve the plugin in the future.

The extension can be found on the [Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=Sin7y.ola).

## Hello Ola

After configuring the above environment, we can happily write Ola smart contracts named fib.ola on vscode with ola extension. The following is an example of a Fibonacci sequence.

```rust
contract Fibonacci {

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

Compile this contract next.

```shell
olac compile fib.ola
```

The above command will generate the files `fib_abi.json` and `fib_asm.json`. `fib_abi.json` is the ABI file of the contract, which will be used by ola-sdk to build contract request transactions. `fib_asm.json` is the assembly form of the contract source code, used for contract deployment and invocation.
