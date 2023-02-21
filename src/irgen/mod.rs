use std::str;

pub mod binary;
mod expression;
mod functions;
mod statements;
use crate::sema::ast;

impl ast::Contract {
    /// Generate the binary. This can be used to generate llvm text, object file
    /// or final linked binary.
    pub fn binary<'a>(
        &'a self,
        ns: &'a ast::Namespace,
        context: &'a inkwell::context::Context,
        filename: &'a str,
    ) -> binary::Binary {
        binary::Binary::build(context, self, ns, filename)
    }
}

#[cfg(test)]
mod test {
    use crate::file_resolver::FileResolver;
    use std::ffi::OsStr;

    #[test]
    fn gen_ir_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
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

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            assert_eq!(
                r#"; ModuleID = 'Fibonacci'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @fib_recursive(i32 10)
  ret void
}

define i32 @fib_recursive(i32 %0) {
entry:
  %1 = icmp eq i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 1

enif:                                             ; preds = %entry
  %2 = icmp eq i32 %0, 2
  br i1 %2, label %then1, label %enif2

then1:                                            ; preds = %enif
  ret i32 1

enif2:                                            ; preds = %enif
  %3 = sub i32 %0, 1
  %4 = call i32 @fib_recursive(i32 %3)
  %5 = sub i32 %0, 2
  %6 = call i32 @fib_recursive(i32 %5)
  %7 = add i32 %4, %6
  ret i32 %7
}
"#,
                ir
            );
        }
    }

    #[test]
    fn gen_ir_eq_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
        contract condCmp {

    fn main() {
       eq(1);
    }

    fn eq(u32 n) -> (u32) {
      if (n == 1) {
        return 2;
      }
      return 3;
    }

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            assert_eq!(
                r#"; ModuleID = 'condCmp'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @eq(i32 1)
  ret void
}

define i32 @eq(i32 %0) {
entry:
  %1 = icmp eq i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}
"#,
                ir
            );
        }
    }

    #[test]
    fn gen_ir_ne_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
        contract condCmp {

    fn main() {
       ne(1);
    }

    fn ne(u32 n) -> (u32) {
      if (n != 1) {
        return 2;
      }
      return 3;
    }

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            assert_eq!(
                r#"; ModuleID = 'condCmp'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @ne(i32 1)
  ret void
}

define i32 @ne(i32 %0) {
entry:
  %1 = icmp eq i32 %0, 1
  %2 = icmp eq i1 %1, false
  br i1 %2, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}
"#,
                ir
            );
        }
    }

    #[test]
    fn gen_ir_ge_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
      contract condCmp {

  fn main() {
     ge(1);
  }

  fn ge(u32 n) -> (u32) {
    if (n >= 1) {
      return 2;
    }
    return 3;
  }

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            assert_eq!(
                r#"; ModuleID = 'condCmp'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @ge(i32 1)
  ret void
}

define i32 @ge(i32 %0) {
entry:
  %1 = icmp uge i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}
"#,
                ir
            );
        }
    }

    #[test]
    fn gen_ir_gt_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
      contract condCmp {

  fn main() {
     gt(1);
  }

  fn gt(u32 n) -> (u32) {
    if (n > 1) {
      return 2;
    }
    return 3;
  }

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            assert_eq!(
                r#"; ModuleID = 'condCmp'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @gt(i32 1)
  ret void
}

define i32 @gt(i32 %0) {
entry:
  %1 = icmp ugt i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}
"#,
                ir
            );
        }
    }

    #[test]
    fn gen_ir_lt_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
      contract condCmp {

  fn main() {
    lt(1);
  }

  fn lt(u32 n) -> (u32) {
    if (n < 1) {
      return 2;
    }
    return 3;
  }

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            println!("ir:{}", ir);
            assert_eq!(
                r#"; ModuleID = 'condCmp'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @lt(i32 1)
  ret void
}

define i32 @lt(i32 %0) {
entry:
  %1 = icmp ult i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}
"#,
                ir
            );
        }
    }

    #[test]
    fn gen_ir_le_test() {
        let mut resolver = FileResolver::new();
        let source = r#"
      contract condCmp {

  fn main() {
     le(1);
  }

  fn le(u32 n) -> (u32) {
    if (n <= 1) {
      return 2;
    }
    return 3;
  }

}"#;
        resolver.set_file_contents("test.ola", source.to_string());

        let file_name = OsStr::new("test.ola");
        // resolve phase
        let ns = crate::parse_and_resolve(file_name, &mut resolver);

        for contract_no in 0..ns.contracts.len() {
            let resolved_contract = &ns.contracts[contract_no];
            let context = inkwell::context::Context::create();
            let filename_string = file_name.to_string_lossy();

            let binary = resolved_contract.binary(&ns, &context, &filename_string);
            let ir = binary.module.to_string();
            println!("ir:{}", ir);
            assert_eq!(
                r#"; ModuleID = 'condCmp'
source_filename = "test.ola"

define void @main() {
entry:
  %0 = call i32 @le(i32 1)
  ret void
}

define i32 @le(i32 %0) {
entry:
  %1 = icmp ule i32 %0, 1
  br i1 %1, label %then, label %enif

then:                                             ; preds = %entry
  ret i32 2

enif:                                             ; preds = %entry
  ret i32 3
}
"#,
                ir
            );
        }
    }
}
