// SPDX-License-Identifier: Apache-2.0

use assert_cmd::Command;
use rayon::prelude::*;
use std::ffi::OsString;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::{fs, path::PathBuf};

#[test]
fn u32_testcases() {
    run_test_for_path("./tests/irgen_testcases/u32");
}

#[test]
fn bool_testcases() {
    run_test_for_path("./tests/irgen_testcases/bool");
}

#[test]
fn field_testcases() {
    run_test_for_path("./tests/irgen_testcases/field");
}

#[test]
fn struct_testcases() {
    run_test_for_path("./tests/irgen_testcases/struct");
}

#[test]
fn static_array_testcases() {
    run_test_for_path("./tests/irgen_testcases/static_array");
}

#[test]
fn dynamic_array_testcases() {
    run_test_for_path("./tests/irgen_testcases/dynamic_array");
}

fn run_test_for_path(path: &str) {
    let mut tests = Vec::new();

    let ext = OsString::from("ola");
    for entry in fs::read_dir(path).unwrap() {
        let path: PathBuf = entry.unwrap().path();

        if path.is_file() && path.extension() == Some(&ext) {
            tests.push(path);
        }
    }

    tests.into_par_iter().for_each(testcase);
}

#[derive(Debug)]
enum Test {
    BeginCheck(usize, String),
    Check(String, usize, String),
    CheckAbsent(String, usize, String),
    NotCheck(String, usize, String),
}

fn testcase(path: PathBuf) {
    // find the args to run.
    println!("testcase: {}", path.display());

    let file = File::open(&path).unwrap();
    let reader = BufReader::new(file);
    let mut checks = Vec::new();

    let mut current_function = String::new();
    for (line_no, line) in reader.lines().enumerate() {
        // make line numbers 1-based
        let line_no = line_no + 1;
        let mut line = line.unwrap();
        line = line.trim().parse().unwrap();

        if let Some(func_name) = line.strip_prefix("// BEGIN-CHECK:") {
            current_function = func_name.trim().to_string();
            checks.push(Test::BeginCheck(line_no, func_name.trim().to_string()));
        } else if let Some(check) = line.strip_prefix("// CHECK:") {
            checks.push(Test::Check(
                current_function.clone(),
                line_no,
                check.trim().to_string(),
            ));
            // Ensure that the following line in the input does not match
        } else if let Some(not_check) = line.strip_prefix("// NOT-CHECK:") {
            checks.push(Test::NotCheck(
                current_function.clone(),
                line_no,
                not_check.trim().to_string(),
            ));
        // Check the output from here until the end of the file does not contain
        // the needle
        } else if let Some(check_absent) = line.strip_prefix("// CHECK-ABSENT:") {
            checks.push(Test::CheckAbsent(
                current_function.clone(),
                line_no,
                check_absent.trim().to_string(),
            ));
        }
    }

    assert_ne!(checks.len(), 0);

    let mut cmd = Command::cargo_bin("olac").unwrap();

    let assert = cmd
        .arg("compile")
        .arg("--gen=llvm-ir")
        .arg(format!("-o={}", path.parent().unwrap().display()))
        .arg(format!("{}", path.canonicalize().unwrap().display()))
        .assert();
    let output = assert.get_output();
    if !output.status.success() {
        panic!(
            "FAILED TO COMPILE: {}, ERROR:\n{}",
            path.display(),
            String::from_utf8_lossy(&output.stderr),
        );
    }

    let mut llvm_path = path.clone();
    llvm_path.set_extension("ll");
    let contents = fs::read_to_string(llvm_path).unwrap();

    let mut current_check = 0;
    let mut current_line = 0;

    let lines: Vec<&str> = contents.split('\n').collect();

    while current_line < lines.len() {
        let line = lines[current_line];

        if line.trim().starts_with("define") {
            current_function = line.to_string().clone();
        }

        if line.trim().starts_with("}") {
            current_function = String::new();
        }
        match checks.get(current_check) {
            Some(Test::BeginCheck(_, func_name)) => {
                if current_function.contains(func_name) {
                    current_check += 1;
                }
            }
            Some(Test::Check(func_name, _, needle)) => {
                if current_function.contains(func_name) && line.contains(needle) {
                    current_check += 1;
                }
            }
            Some(Test::NotCheck(func_name, _, needle)) => {
                if !line.contains(needle) && current_function.contains(func_name) {
                    current_check += 1;
                    // We should not advance line during a not check
                    current_line -= 1;
                }
            }
            Some(Test::CheckAbsent(func_name, _, needle)) => {
                for line in lines.iter().skip(current_line) {
                    if line.contains(needle) && current_function.contains(func_name) {
                        panic!(
                            "FOUND CHECK-ABSENT: {:?}, {}",
                            checks[current_check],
                            path.display()
                        );
                    }
                }
                current_check += 1;
            }
            _ => (),
        }

        current_line += 1;
    }

    if current_check < checks.len() {
        panic!(
            "NOT FOUND CHECK: {:?}, {}",
            checks[current_check],
            path.display()
        );
    }
}
