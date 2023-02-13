use clap::{builder::ValueParser, Arg, ArgMatches, Command};

use ola_lang::file_resolver::FileResolver;
use ola_lang::sema::ast::Namespace;
use std::{
    ffi::{OsStr, OsString},
    fs::{create_dir_all, File},
    io::prelude::*,
    path::{Path, PathBuf},
    process::exit,
};

fn main() {
    let app = || {
        Command::new("olac")
            .version("v0.1.0")
            .author(env!("CARGO_PKG_AUTHORS"))
            .about(env!("CARGO_PKG_DESCRIPTION"))
            .subcommand_required(true)
            .subcommand(
                Command::new("compile")
                    .about("Compile ola source files")
                    .arg(
                        Arg::new("INPUT")
                            .help("Ola input files")
                            .required(true)
                            .value_parser(ValueParser::os_string())
                            .num_args(1..),
                    )
                    .arg(
                        Arg::new("Generate")
                            .help("Show compile intermediate status results")
                            .long("gen")
                            .num_args(1)
                            .value_parser(["ast", "llvm-ir", "asm"]),
                    )
                    .arg(
                        Arg::new("OUTPUT")
                            .help("output directory")
                            .short('o')
                            .long("output")
                            .num_args(1)
                            .value_parser(ValueParser::os_string()),
                    ),
            )
    };
    let matches = app().get_matches();

    match matches.subcommand() {
        Some(("compile", matches)) => compile(matches),
        _ => unreachable!(),
    }
}

fn compile(matches: &ArgMatches) {
    let mut namespaces = Vec::new();

    let mut errors = false;

    for filename in matches.get_many::<OsString>("INPUT").unwrap() {
        match process_file(filename, matches) {
            Ok(ns) => namespaces.push(ns),
            Err(_) => {
                errors = true;
            }
        }
    }

    if errors {
        eprintln!("error: not all contracts are valid");
        exit(1);
    }
}

fn process_file(filename: &OsStr, matches: &ArgMatches) -> Result<Namespace, ()> {
    let mut resolver = FileResolver::new();

    for filename in matches.get_many::<OsString>("INPUT").unwrap() {
        if let Ok(path) = PathBuf::from(filename).canonicalize() {
            let _ = resolver.add_import_path(path.parent().unwrap());
        }
    }
    if let Err(e) = resolver.add_import_path(&PathBuf::from(".")) {
        eprintln!("error: cannot add current directory to import path: {e}");
        exit(1);
    }

    // resolve phase
    let ns = ola_lang::parse_and_resolve(filename, &mut resolver);

    // gen ast
    if let Some("ast") = matches.get_one::<String>("Generate").map(|v| v.as_str()) {
        let filepath = PathBuf::from(filename);
        let stem = filepath.file_stem().unwrap().to_string_lossy();
        let dot_filename = output_file(matches, &stem, "dot");

        let dot = ns.dotgraphviz();

        let mut file = create_file(&dot_filename);

        if let Err(err) = file.write_all(dot.as_bytes()) {
            eprintln!("{}: error: {}", dot_filename.display(), err);
            exit(1);
        }

        return Ok(ns);
    }

    if ns.contracts.is_empty() || ns.diagnostics.any_errors() {
        return Err(());
    }

    // gen llvm ir、asm
    for contract_no in 0..ns.contracts.len() {
        let resolved_contract = &ns.contracts[contract_no];

        let context = inkwell::context::Context::create();
        let filename_string = filename.to_string_lossy();

        let binary = resolved_contract.binary(&ns, &context, &filename_string);

        match matches.get_one::<String>("Generate").map(|v| v.as_str()) {
            Some("llvm-ir") => {
                let llvm_filename = output_file(matches, &binary.name, "ll");

                binary.dump_llvm(&llvm_filename).unwrap();
            }

            Some("asm") => {
                // let obj = match binary.code(Generate::Assembly) {
                //     Ok(o) => o,
                //     Err(s) => {
                //         println!("error: {s}");
                //         exit(1);
                //     }
                // };
                //
                // let obj_filename = output_file(matches, &binary.name, "asm");
                //
                // let mut file = create_file(&obj_filename);
                // file.write_all(&obj).unwrap();
            }
            _ => {}
        }
    }

    Ok(ns)
}

fn output_file(matches: &ArgMatches, stem: &str, ext: &str) -> PathBuf {
    Path::new(
        matches
            .get_one::<OsString>("OUTPUT")
            .unwrap_or(&OsString::from(".")),
    )
    .join(format!("{stem}.{ext}"))
}

fn create_file(path: &Path) -> File {
    if let Some(parent) = path.parent() {
        if let Err(err) = create_dir_all(parent) {
            eprintln!(
                "error: cannot create output directory '{}': {}",
                parent.display(),
                err
            );
            exit(1);
        }
    }

    match File::create(path) {
        Ok(file) => file,
        Err(err) => {
            eprintln!("error: cannot create file '{}': {}", path.display(), err,);
            exit(1);
        }
    }
}

#[test]
fn gen_ir_test() {
    use ola_lang::file_resolver::FileResolver;
    use std::ffi::OsStr;
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
    let ns = ola_lang::parse_and_resolve(file_name, &mut resolver);

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
