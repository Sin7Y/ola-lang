# Introduction 
Ola is a high-level programming language for developing OlaVM smart contracts. It is Turing complete and can be used to write arithmetic programs. The computing process is proven by the OlaVM back-end proof system, which verifies that the OlaVM processing is accurate. 
Most of the existing programming languages in the ZKP field require fundamental knowledge of the circuit field, which is not universal, or the execution process is difficult to be proven and verified by ZKP.

## Dev-friendly and ZK-friendly

From a developer's point of view, Ola’s syntax is close to that of C/C++ and Rust, which allows most developers to learn and develop various Dapps using Ola quickly. At the same time, the Ola language is also a ZK-friendly language, but we do not expose the ZK-friendly design directly to the developers. We try to make the Ola language as smooth to use as the traditional high-level languages such as Rust, leaving the ZK-friendly design support to be handled by the compiler and OlaVM.


## The Design Goal

Ola primary design goal:
- Security: The results of the programs executions are deterministic, declared at the language level / syntax, and guaranteed at the compiler level.
- Efficiency: The speed of execution and proof of the program is well balanced to be efficient.
- Universal: Easy to use and readable code, it is developer friendly with minimal learning thresholds for developers familiar with mainstream programming languages such as C++/Rust, to quickly get into writing arithmetic programs.
- Turing complete: Ola can be used for complex programs such as loops, recursion, etc.

## Documentation Updates

Ola language is currently iterating and developing rapidly, and the document will be updated continuously. We welcome all interested developers to build it with us. If you need Ola support, please send an email to contact@sin7y.com.
