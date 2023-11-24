// SPDX-License-Identifier: Apache-2.0

use assert_cmd::Command;
use rayon::prelude::*;
use serde_json::Value;
use std::ffi::OsString;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::{fs, path::PathBuf};

#[test]
fn u32_testcases() {
    run_test_for_path("./tests/codegen/u32");
}

#[test]
fn bool_testcases() {
    run_test_for_path("./tests/codegen/bool");
}

fn run_test_for_path(path: &str) {
    let mut tests = Vec::new();

    let ext = OsString::from("ll");
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
    Check(usize, String),
    CheckAbsent(usize, String),
    NotCheck(usize, String),
    Rewind(usize),
}

fn testcase(path: PathBuf) {
    // find the args to run.
    println!("codegen testcase: {}", path.display());

    let file = File::open(&path).unwrap();
    let reader = BufReader::new(file);
    let mut checks = Vec::new();

    for (line_no, line) in reader.lines().enumerate() {
        let mut line = line.unwrap();
        line = line.trim().parse().unwrap();
        if let Some(check) = line.strip_prefix("; CHECK:") {
            checks.push(Test::Check(line_no, check.trim().to_string()));
            // Ensure that the following line in the input does not match
        } else if let Some(not_check) = line.strip_prefix("; NOT-CHECK:") {
            checks.push(Test::NotCheck(line_no, not_check.trim().to_string()));
        // Check the output from here until the end of the file does not contain
        // the needle
        } else if let Some(check_absent) = line.strip_prefix("; CHECK-ABSENT:") {
            checks.push(Test::CheckAbsent(line_no, check_absent.trim().to_string()));
        // Go back to the beginning and find the needle from there, like ;
        // CHECK: but from the beginning of the file.
        } else if let Some(check) = line.strip_prefix("; BEGIN-CHECK:") {
            checks.push(Test::Rewind(line_no));
            checks.push(Test::Check(line_no, check.trim().to_string()));
        }
    }

    assert_ne!(checks.len(), 0);

    let mut cmd = Command::cargo_bin("olac").unwrap();

    let assert = cmd
        .arg("compile-ir")
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

    let mut asm_path = PathBuf::from(path.parent().unwrap());
    let stem = path.file_stem().unwrap().to_str().unwrap().to_owned() + "_asm";
    asm_path.push(stem);
    asm_path.set_extension("json");
    let contents = fs::read_to_string(asm_path.clone()).unwrap();

    let mut current_check = 0;
    let mut current_line = 0;

    let asm_str: Value = serde_json::from_str(contents.as_str()).unwrap();
    let binding = asm_str["program"].to_string();
    let lines: Vec<&str> = binding.split("\\n").collect();

    while current_line < lines.len() {
        let line = lines[current_line];

        match checks.get(current_check) {
            Some(Test::Check(_, needle)) => {
                if line.contains(needle) {
                    current_check += 1;
                }
            }
            Some(Test::NotCheck(_, needle)) => {
                if !line.contains(needle) {
                    current_check += 1;
                    // We should not advance line during a not check
                    current_line -= 1;
                }
            }
            Some(Test::CheckAbsent(_, needle)) => {
                for line in lines.iter().skip(current_line) {
                    if line.contains(needle) {
                        panic!(
                            "FOUND CHECK-ABSENT: {:?}, {}",
                            checks[current_check],
                            path.display()
                        );
                    }
                }
                current_check += 1;
            }
            Some(Test::Rewind(_)) => {
                current_line = 0;
                current_check += 1;
                continue;
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
