#![feature(path_file_prefix)]

use clap::{builder::ValueParser, Arg, ArgMatches, Command};

use num_bigint::BigInt;
use num_traits::Zero;
use ola_lang::codegen::isa::ola::Ola;
use ola_lang::codegen::lower::compile_module;
use ola_lang::file_resolver::FileResolver;
use ola_lang::sema::ast::Namespace;
use ola_lang::{codegen::core::ir::module::Module, sema::ast::Layout};
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

    let mut resolver = imports_arg(matches);

    let mut errors = false;

    for filename in matches.get_many::<OsString>("INPUT").unwrap() {
        let ns = process_file(filename, &mut resolver, matches);
        namespaces.push(ns);
    }

    for ns in &namespaces {
        ns.print_diagnostics(&resolver, true);
        if ns.diagnostics.any_errors() {
            errors = true;
        }
    }
    if errors {
        exit(1);
    }
}

fn process_file(filename: &OsStr, resolver: &mut FileResolver, matches: &ArgMatches) -> Namespace {
    // resolve phase
    let mut ns = ola_lang::parse_and_resolve(filename, resolver);

    if ns.diagnostics.any_errors() {
        return ns;
    }

    for contract_no in 0..ns.contracts.len() {
        layout(contract_no, &mut ns);
    }

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

        return ns;
    }

    // gen llvm ir、asm
    for contract_no in 0..ns.contracts.len() {
        let resolved_contract = &ns.contracts[contract_no];

        let context = inkwell::context::Context::create();
        let filename_lossy = filename.to_string_lossy().clone();
        let filename_string = String::from(filename_lossy);
        let filename_stem = Path::new(&filename_string).file_prefix().unwrap();

        let binary = resolved_contract.binary(&ns, &context, &filename_string);

        match matches.get_one::<String>("Generate").map(|v| v.as_str()) {
            Some("llvm-ir") => {
                let llvm_filename = output_file(matches, filename_stem.to_str().unwrap(), "ll");

                binary.dump_llvm(&llvm_filename).unwrap();
            }

            Some("asm") => {
                // Parse the assembly and get a module
                let module = Module::try_from(binary.module.to_string().as_str())
                    .expect("failed to parse LLVM IR");
                // Compile the module for Ola and get a machine module
                let isa = Ola::default();
                let code = compile_module(&isa, &module).expect("failed to compile");
                let asm_path = output_file(matches, filename_stem.to_str().unwrap(), "asm");
                let mut asm_file = create_file(&asm_path);

                if let Err(err) = asm_file.write_all(format!("{}", code.display_asm()).as_bytes()) {
                    eprintln!("{}: error: {}", asm_path.display(), err);
                    exit(1);
                }
            }
            _ => {}
        }
    }

    ns
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

fn imports_arg(matches: &ArgMatches) -> FileResolver {
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

    resolver
}

/// Layout the contract. We determine the layout of variables and deal with
/// overriding variables
fn layout(contract_no: usize, ns: &mut Namespace) {
    let mut slot = BigInt::zero();

    for var_no in 0..ns.contracts[contract_no].variables.len() {
        if !ns.contracts[contract_no].variables[var_no].constant {
            let ty = ns.contracts[contract_no].variables[var_no].ty.clone();

            ns.contracts[contract_no].layout.push(Layout {
                slot: slot.clone(),
                contract_no,
                var_no,
                ty: ty.clone(),
            });

            slot += ty.storage_slots(ns);
        }
    }

    ns.contracts[contract_no].fixed_layout_size = slot;
}
