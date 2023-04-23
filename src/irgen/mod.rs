use std::str;

pub mod binary;
mod corelib;
mod expression;
mod functions;
mod statements;
pub mod u32_op;
mod unused_variable;

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

// #[cfg(test)]
// mod test {
//     use crate::file_resolver::FileResolver;
//     use std::ffi::OsStr;
//
//     #[test]
//     fn gen_ir_fibo_test() {
//         let mut resolver = FileResolver::new();
//         let source = r#" contract Fibonacci {
//
//     fn main() {
//        fib_non_recursive(10);
//     }
//
//     fn fib_recursive(u32 n) -> (u32) {
//         if (n <= 2) {
//             return 1;
//         }
//         return fib_recursive(n -1) + fib_recursive(n -2);
//     }
//
//     fn fib_non_recursive(u32 n) -> (u32) {
//         u32 first = 0;
//         u32 second = 1;
//         u32 third = 1;
//         for (u32 i = 2; i <= n; i++) {
//              third = first + second;
//              first = second;
//              second = third;
//         }
//         return third;
//     }
//
// }
//
//     "#;
//         resolver.set_file_contents("test.ola", source.to_string());
//
//         let file_name = OsStr::new("test.ola");
//         // resolve phase
//         let ns = crate::parse_and_resolve(file_name, &mut resolver);
//
//         for contract_no in 0..ns.contracts.len() {
//             let resolved_contract = &ns.contracts[contract_no];
//             let context = inkwell::context::Context::create();
//             let filename_string = file_name.to_string_lossy();
//
//             let binary = resolved_contract.binary(&ns, &context,
// &filename_string);             let ir = binary.module.to_string();
//             assert_eq!(
//                 r#"; ModuleID = 'Fibonacci'
// source_filename = "test.ola"
//
// define void @main() {
// entry:
//   %0 = call i32 @fib_non_recursive(i32 10)
//   ret void
// }
//
// define i32 @fib_recursive(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp ule i32 %1, 2
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 1
//
// enif:                                             ; preds = %entry
//   %3 = load i32, i32* %n, align 4
//   %4 = sub i32 %3, 1
//   %5 = call i32 @fib_recursive(i32 %4)
//   %6 = load i32, i32* %n, align 4
//   %7 = sub i32 %6, 2
//   %8 = call i32 @fib_recursive(i32 %7)
//   %9 = add i32 %5, %8
//   ret i32 %9
// }
//
// define i32 @fib_non_recursive(i32 %0) {
// entry:
//   %i = alloca i32, align 4
//   %third = alloca i32, align 4
//   %second = alloca i32, align 4
//   %first = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 0, i32* %first, align 4
//   store i32 1, i32* %second, align 4
//   store i32 1, i32* %third, align 4
//   store i32 2, i32* %i, align 4
//   br label %cond
//
// cond:                                             ; preds = %next, %entry
//   %1 = load i32, i32* %i, align 4
//   %2 = load i32, i32* %n, align 4
//   %3 = icmp ule i32 %1, %2
//   br i1 %3, label %body, label %endfor
//
// body:                                             ; preds = %cond
//   %4 = load i32, i32* %first, align 4
//   %5 = load i32, i32* %second, align 4
//   %6 = add i32 %4, %5
//   store i32 %6, i32* %third, align 4
//   %7 = load i32, i32* %second, align 4
//   store i32 %7, i32* %first, align 4
//   %8 = load i32, i32* %third, align 4
//   store i32 %8, i32* %second, align 4
//   br label %next
//
// next:                                             ; preds = %body
//   %9 = load i32, i32* %i, align 4
//   %10 = add i32 %9, 1
//   store i32 %10, i32* %i, align 4
//   br label %cond
//
// endfor:                                           ; preds = %cond
//   %11 = load i32, i32* %third, align 4
//   ret i32 %11
// }
// "#,
//                 ir
//             );
//         }
//     }
//
//     #[test]
//     fn gen_ir_cond_br_test() {
//         let mut resolver = FileResolver::new();
//         let source = r#" contract condCmp {
//
//     fn main() {
//        eq_rr(1);
//     }
//
//     fn eq_ri(u32 n) -> (u32) {
//       if (n == 1) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn eq_rr(u32 n) -> (u32) {
//       u32 m = 1;
//       if (n == m) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn neq_ri(u32 n) -> (u32) {
//       if (n != 1) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn neq_rr(u32 n) -> (u32) {
//       u32 m = 1;
//       if (n != m) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn lt_ri(u32 n) -> (u32) {
//       if (n < 1) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn lt_rr(u32 n) -> (u32) {
//       u32 m = 1;
//       if (n < m) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn lte_ri(u32 n) -> (u32) {
//       if (n <= 1) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn lte_rr(u32 n) -> (u32) {
//       u32 m = 1;
//       if (n <= m) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn gt_ri(u32 n) -> (u32) {
//       if (n > 1) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn gt_rr(u32 n) -> (u32) {
//       u32 m = 1;
//       if (n > m) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn gte_ri(u32 n) -> (u32) {
//       if (n >= 1) {
//         return 2;
//       }
//       return 3;
//     }
//
//     fn gte_rr(u32 n) -> (u32) {
//       u32 m = 1;
//       if (n >= m) {
//         return 2;
//       }
//       return 3;
//     }
//
// }
//
//     "#;
//         resolver.set_file_contents("test.ola", source.to_string());
//
//         let file_name = OsStr::new("test.ola");
//         // resolve phase
//         let ns = crate::parse_and_resolve(file_name, &mut resolver);
//
//         for contract_no in 0..ns.contracts.len() {
//             let resolved_contract = &ns.contracts[contract_no];
//             let context = inkwell::context::Context::create();
//             let filename_string = file_name.to_string_lossy();
//
//             let binary = resolved_contract.binary(&ns, &context,
// &filename_string);             let ir = binary.module.to_string();
//             assert_eq!(
//                 r#"; ModuleID = 'condCmp'
// source_filename = "test.ola"
//
// define void @main() {
// entry:
//   %0 = call i32 @eq_rr(i32 1)
//   ret void
// }
//
// define i32 @eq_ri(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp eq i32 %1, 1
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @eq_rr(i32 %0) {
// entry:
//   %m = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 1, i32* %m, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = load i32, i32* %m, align 4
//   %3 = icmp eq i32 %1, %2
//   br i1 %3, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @neq_ri(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp ne i32 %1, 1
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @neq_rr(i32 %0) {
// entry:
//   %m = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 1, i32* %m, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = load i32, i32* %m, align 4
//   %3 = icmp ne i32 %1, %2
//   br i1 %3, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @lt_ri(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp ult i32 %1, 1
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @lt_rr(i32 %0) {
// entry:
//   %m = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 1, i32* %m, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = load i32, i32* %m, align 4
//   %3 = icmp ult i32 %1, %2
//   br i1 %3, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @lte_ri(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp ule i32 %1, 1
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @lte_rr(i32 %0) {
// entry:
//   %m = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 1, i32* %m, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = load i32, i32* %m, align 4
//   %3 = icmp ule i32 %1, %2
//   br i1 %3, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @gt_ri(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp ugt i32 %1, 1
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @gt_rr(i32 %0) {
// entry:
//   %m = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 1, i32* %m, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = load i32, i32* %m, align 4
//   %3 = icmp ugt i32 %1, %2
//   br i1 %3, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @gte_ri(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp uge i32 %1, 1
//   br i1 %2, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
//
// define i32 @gte_rr(i32 %0) {
// entry:
//   %m = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 1, i32* %m, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = load i32, i32* %m, align 4
//   %3 = icmp uge i32 %1, %2
//   br i1 %3, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 2
//
// enif:                                             ; preds = %entry
//   ret i32 3
// }
// "#,
//                 ir
//             );
//         }
//     }
//
//     #[test]
//     fn gen_sqrt_func_test() {
//         use crate::file_resolver::FileResolver;
//         use std::ffi::OsStr;
//         let mut resolver = FileResolver::new();
//         let source = r#"
//     contract SqrtContract {
//
//     fn main() {
//        sqrt_test(4);
//     }
//
//     fn sqrt_test(u32 a) -> (u32) {
//         u32 result = 0;
//         if (a > 3) {
//             result = a;
//             u32 x = a / 2 + 1;
//             // assume the maximum iteration is 100
//             for (u32 i = 0; i < 100; i++) {
//                 if (x >= result) break;
//                 result = x;
//                 x = (a / x + x) / 2;
//             }
//         } else if (a != 0) {
//             result = 1;
//         }
//         return result;
//     }
//
//
// }
//
//     "#;
//         resolver.set_file_contents("test.ola", source.to_string());
//
//         let file_name = OsStr::new("test.ola");
//         // resolve phase
//         let ns = crate::parse_and_resolve(file_name, &mut resolver);
//
//         for contract_no in 0..ns.contracts.len() {
//             let resolved_contract = &ns.contracts[contract_no];
//             let context = inkwell::context::Context::create();
//             let filename_string = file_name.to_string_lossy();
//
//             let binary = resolved_contract.binary(&ns, &context,
// &filename_string);             let ir = binary.module.to_string();
//             assert_eq!(
//                 r#"; ModuleID = 'Fibonacci'
// source_filename = "test.ola"
//
// define void @main() {
// entry:
//   %0 = call i32 @fib_non_recursive(i32 10)
//   ret void
// }
//
// define i32 @fib_recursive(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp eq i32 %1, 1
//   %3 = load i32, i32* %n, align 4
//   %4 = icmp eq i32 %3, 2
//   %5 = or i1 %2, %4
//   br i1 %5, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 1
//
// enif:                                             ; preds = %entry
//   %6 = load i32, i32* %n, align 4
//   %7 = sub i32 %6, 1
//   %8 = call i32 @fib_recursive(i32 %7)
//   %9 = load i32, i32* %n, align 4
//   %10 = sub i32 %9, 2
//   %11 = call i32 @fib_recursive(i32 %10)
//   %12 = add i32 %8, %11
//   ret i32 %12
// }
//
// define i32 @fib_non_recursive(i32 %0) {
// entry:
//   %i = alloca i32, align 4
//   %third = alloca i32, align 4
//   %second = alloca i32, align 4
//   %first = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 0, i32* %first, align 4
//   store i32 1, i32* %second, align 4
//   store i32 1, i32* %third, align 4
//   store i32 2, i32* %i, align 4
//   br label %cond
//
// cond:                                             ; preds = %next, %entry
//   %1 = load i32, i32* %i, align 4
//   %2 = load i32, i32* %n, align 4
//   %3 = icmp ule i32 %1, %2
//   br i1 %3, label %body, label %endfor
//
// body:                                             ; preds = %cond
//   %4 = load i32, i32* %first, align 4
//   %5 = load i32, i32* %second, align 4
//   %6 = add i32 %4, %5
//   store i32 %6, i32* %third, align 4
//   %7 = load i32, i32* %second, align 4
//   store i32 %7, i32* %first, align 4
//   %8 = load i32, i32* %third, align 4
//   store i32 %8, i32* %second, align 4
//   br label %next
//
// next:                                             ; preds = %body
//   %9 = load i32, i32* %i, align 4
//   %10 = add i32 %9, 1
//   store i32 %10, i32* %i, align 4
//   br label %cond
//
// endfor:                                           ; preds = %cond
//   %11 = load i32, i32* %third, align 4
//   ret i32 %11
// }
// "#,
//                 ir
//             );
//         }
//     }
//
//     #[test]
//     fn gen_lib_func_test() {
//         use crate::file_resolver::FileResolver;
//         use std::ffi::OsStr;
//         let mut resolver = FileResolver::new();
//         let source = r#"
//     contract SqrtContract {
//
//     fn sqrt_test(u32 n) -> (u32) {
//         u32 d = n << 2;
//         return d;
//     }
//
// }
//
//     "#;
//         resolver.set_file_contents("test.ola", source.to_string());
//
//         let file_name = OsStr::new("test.ola");
//         // resolve phase
//         let ns = crate::parse_and_resolve(file_name, &mut resolver);
//
//         for contract_no in 0..ns.contracts.len() {
//             let resolved_contract = &ns.contracts[contract_no];
//             let context = inkwell::context::Context::create();
//             let filename_string = file_name.to_string_lossy();
//
//             let binary = resolved_contract.binary(&ns, &context,
// &filename_string);             let ir = binary.module.to_string();
//             assert_eq!(
//                 r#"; ModuleID = 'Fibonacci'
// source_filename = "test.ola"
//
// define void @main() {
// entry:
//   %0 = call i32 @fib_non_recursive(i32 10)
//   ret void
// }
//
// define i32 @fib_recursive(i32 %0) {
// entry:
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   %1 = load i32, i32* %n, align 4
//   %2 = icmp eq i32 %1, 1
//   %3 = load i32, i32* %n, align 4
//   %4 = icmp eq i32 %3, 2
//   %5 = or i1 %2, %4
//   br i1 %5, label %then, label %enif
//
// then:                                             ; preds = %entry
//   ret i32 1
//
// enif:                                             ; preds = %entry
//   %6 = load i32, i32* %n, align 4
//   %7 = sub i32 %6, 1
//   %8 = call i32 @fib_recursive(i32 %7)
//   %9 = load i32, i32* %n, align 4
//   %10 = sub i32 %9, 2
//   %11 = call i32 @fib_recursive(i32 %10)
//   %12 = add i32 %8, %11
//   ret i32 %12
// }
//
// define i32 @fib_non_recursive(i32 %0) {
// entry:
//   %i = alloca i32, align 4
//   %third = alloca i32, align 4
//   %second = alloca i32, align 4
//   %first = alloca i32, align 4
//   %n = alloca i32, align 4
//   store i32 %0, i32* %n, align 4
//   store i32 0, i32* %first, align 4
//   store i32 1, i32* %second, align 4
//   store i32 1, i32* %third, align 4
//   store i32 2, i32* %i, align 4
//   br label %cond
//
// cond:                                             ; preds = %next, %entry
//   %1 = load i32, i32* %i, align 4
//   %2 = load i32, i32* %n, align 4
//   %3 = icmp ule i32 %1, %2
//   br i1 %3, label %body, label %endfor
//
// body:                                             ; preds = %cond
//   %4 = load i32, i32* %first, align 4
//   %5 = load i32, i32* %second, align 4
//   %6 = add i32 %4, %5
//   store i32 %6, i32* %third, align 4
//   %7 = load i32, i32* %second, align 4
//   store i32 %7, i32* %first, align 4
//   %8 = load i32, i32* %third, align 4
//   store i32 %8, i32* %second, align 4
//   br label %next
//
// next:                                             ; preds = %body
//   %9 = load i32, i32* %i, align 4
//   %10 = add i32 %9, 1
//   store i32 %10, i32* %i, align 4
//   br label %cond
//
// endfor:                                           ; preds = %cond
//   %11 = load i32, i32* %third, align 4
//   ret i32 %11
// }
// "#,
//                 ir
//             );
//         }
//     }
//
// }
