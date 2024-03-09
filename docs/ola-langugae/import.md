# Import

In order to use the code from other files, we can import them into our program using the keyword `import` and `as`with the corresponding file name. Using `import` makes it easier for us to import some modular ibs, eliminating the need for repeated development. The basic syntax is as follow,`path-spec`can be absolute path(the full path of source file) or relative path (file path starts with`./` or `../`).

```rust
import "path-spec"
```

e.g.:

```rust
import "./math/u256.ola";
import "crypto/sha256.ola"
import "erc20.ola"
```