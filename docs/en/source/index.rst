.. Ola Language documentation master file, created by
   sphinx-quickstart on Sun Nov 27 11:45:39 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Ola Language
==================================
Ola is a high-level language for implementing smart contracts. From the outset, it is designed to be a zk-friendly programming language.

Ola is compiled into ola ir, which is then optimized and compiled into ola opcode, which is executed by the OlaVM.

Ola is influenced by Solidity and Rust, and is very easy for developers familiar with these languages to get started. It is statically typed and supports complex user-defined types among other features. With Ola, you can create contracts for a variety of uses.

The current Ola Language is unstable, with many features that need to be improved. Keep an eye on our progress!


Contents
========
.. toctree::
   :maxdepth: 2
   :caption: Introduction

   introduction

.. toctree::
   :maxdepth: 2
   :caption: Quick Start

   quick-start
   smart-contract


.. toctree::
   :maxdepth: 2
   :caption: Ola Syntax

   grammar/full
   ola-syntax

.. toctree::
   :maxdepth: 2
   :caption: Compiler

   ola-abi
   ola-ir

.. toctree::
   :maxdepth: 2
   :caption: Appendix

   ola-libs
   appendix
