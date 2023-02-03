fn main() {}
//
// fn process_file(filename: &OsStr) {
//     let mut resolver = FileResolver::new();
//     // resolve phase
//     let mut ns = ola_lang::parse_and_resolve(filename, &mut resolver);
//
//     for contract_no in 0..ns.contracts.len() {
//         let resolved_contract = &ns.contracts[contract_no];
//
//         let context = inkwell::context::Context::create();
//         let filename_string = filename.to_string_lossy();
//
//         resolved_contract.binary(&ns, &context, &filename_string);
//     }
// }

#[test]
fn gen_ir_test() {
    use ola_lang::file_resolver::FileResolver;
    use std::ffi::OsStr;
    let mut resolver = FileResolver::new();
    let source = r#"
      contract Fibonacci {
            fn fib_recursive(u32 n) -> (u32) {
                u32 x = 88;
                x = n + 1;
                if (n == 0 || n == 1) {
                    return 1;
                }
                return fib_recursive(n -1) + fib_recursive(n -2) + x;
            }

        }
        "#;
    resolver.set_file_contents("test.ola", source.to_string());
    let file_name = OsStr::new("test.ola");
    // resolve phase
    let ns = ola_lang::parse_and_resolve(file_name, &mut resolver);

    for contract_no in 0..ns.contracts.len() {
        let resolved_contract = &ns.contracts[contract_no];
        let context = inkwell::context::Context::create();
        let filename_string = file_name.to_string_lossy();

        let binary = resolved_contract.binary(&ns, &context, &filename_string);
        // binary
        //     .dump_llvm(
        //         &Path::new(&OsString::from(".")).join(format!("{}.{}", filename_string, "ll")),
        //     )
        //     .expect("TODO: panic message");
        assert!(binary.module.verify().is_ok());
    }
}
