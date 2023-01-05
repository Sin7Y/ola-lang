.. Olang documentation master file, created by
   sphinx-quickstart on Sun Nov 27 11:45:39 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Ola Language
==================================
Olang is a high-level language for implementing smart contracts. From the outset it is designed to be a zk-friendly programming language.

olang is compiled into ola ir, which is then optimized and compiled into ola opcode, which is executed by the Ola VM.

olang is influenced by solidity and rust and very easy for developers familiar with solidity and rust to get started, It is statically typed, supports complex user-defined types among other features.
With Ola you can create contracts for a variety of uses

The current ola language is unstable and has many features that need to be improved, so keep an eye on our progress!


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
   ola-codegen

.. toctree::
   :maxdepth: 2
   :caption: Appendix

   ola-libs
   appendix
