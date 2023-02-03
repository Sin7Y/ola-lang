// SPDX-License-Identifier: Apache-2.0

#![cfg(test)]
use crate::sema::ast::{Expression, Parameter, Statement, Type};
use crate::{parse_and_resolve, sema::ast, FileResolver};
use ola_parser::program::Loc;
use std::ffi::OsStr;

pub(crate) fn parse(src: &'static str) -> ast::Namespace {
    let mut cache = FileResolver::new();
    cache.set_file_contents("test.ola", src.to_string());

    let ns = parse_and_resolve(OsStr::new("test.ola"), &mut cache);
    ns
}

#[test]
fn test_statement_reachable() {
    let loc = Loc::File(0, 1, 2);
    let test_cases: Vec<(Statement, bool)> = vec![
        (Statement::Underscore(loc), true),
        (
            Statement::VariableDecl(
                loc,
                0,
                Parameter {
                    loc,
                    id: None,
                    ty: Type::Bool,
                    ty_loc: None,
                    recursive: false,
                },
                None,
            ),
            true,
        ),
        (Statement::Continue(loc), false),
        (Statement::Break(loc), false),
        (Statement::Return(loc, None), false),
        (
            Statement::If(
                loc,
                false,
                Expression::BoolLiteral(loc, false),
                vec![],
                vec![],
            ),
            false,
        ),
        (
            Statement::Expression(loc, true, Expression::BoolLiteral(loc, false)),
            true,
        ),
        (
            Statement::For {
                loc,
                reachable: false,
                init: vec![],
                cond: None,
                next: vec![],
                body: vec![],
            },
            false,
        ),
    ];

    for (test_case, expected) in test_cases {
        assert_eq!(test_case.reachable(), expected);
    }
}

#[test]
fn constant_overflow_checks() {
    let file = r#"



    contract test_contract {

        u32 global_a;
        u32 global_b = 4;
        u32 global_c = global_b;

        fn test_params(u32 usesa, u32 sesa) -> (u32) {
            return usesa + sesa;
        }

         fn test_add(u32 input) -> (u32) {
            // value 4294967297 does not fit into type u32.
            u32 add_ovf = 4294967295 + 2;

            // negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.
            u32 negative = 3 - 4;

            // value 4294967296 does not fit into type u32.
            u32 mixed = 4294967295 + 1 + input;

            // negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.
            return 1 - 2;
        }

        fn test_mul(u32 input)  {
            // value 4294967297 does not fit into type u32.
            u32 mul_ovf_u32 = 2147483647 * 2 + 3;
            // value 18446744073709551616 does not fit into type u64.
            u64 mul_ovf_u64 = 9223372036854775807 * 2 + 2;
        }

        fn test_shift(u32 input) {
            //value 4294967296 does not fit into type u32.
           u32 mul_ovf = 2147483648 << 1;

            // value 18446744073709551618 does not fit into type u64.
            u64 mixed = (9223372036854775809 << 1) + input;
        }

        fn test_call() {
            // negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.
            // value 4294967297 does not fit into type u32.
            test_params(1 - 2, 4294967297);

            // negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.
            // value 129 does not fit into type int8.
            test_params({usesa: 1 - 2, sesa: 4294967295 + 2});
        }


        fn test_for_loop () {
            for (u256 i = 125 + 5; i < 300 ; i++) {
            }
        }

        fn composite(u32 a) {

            u32 sesa = 500- 400 + test_params(100+200, 0);
            
            // value 4294967298 does not fit into type u32.
            // value 4294967299 does not fit into type u32.
            u32 seas = (4294967297 + 1) + a + (4294967297 + 2);

            // no diagnostic
            u32 b = 255 - 255/5 ;

            // value 4294967296 does not fit into type u32.
            u32 shift_r = (4 >> 2) + 4294967295;

            // value 4294967297 does not fit into type u32.
            u32 mod_test = 4294967295 + (36%17);

            // value 4294967297 does not fit into type u32.
            u32 bb = 4294967299 - (10/5) ;

            // left shift by 32 may overflow the final result
            u32 shift_warning = (1 << 32) - 300;

            u32 bitwise_or = (250 | 5) - 150;


            u32 bitwise_and = 1000 & 5 ;

            u32 bitwise_xor = 1000 ^ 256;

            // divide by zero
            u32 div_zero= 3 / (1-1);

            // divide by zero
            u32 div_zeroo = (300-50) % 0;


        }
    }
    
        "#;
    let ns = parse(file);
    let errors = ns.diagnostics.errors();
    let warnings = ns.diagnostics.warnings();

    assert_eq!(
        errors[0].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(errors[1].message, "negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.");
    assert_eq!(
        errors[2].message,
        "value 4294967296 does not fit into type u32."
    );
    assert_eq!(errors[3].message, "negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.");
    assert_eq!(
        errors[4].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(
        errors[5].message,
        "value 18446744073709551616 does not fit into type u64."
    );
    assert_eq!(
        errors[6].message,
        "value 4294967296 does not fit into type u32."
    );
    assert_eq!(
        errors[7].message,
        "value 18446744073709551618 does not fit into type u64."
    );
    assert_eq!(errors[8].message, "negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.");
    assert_eq!(
        errors[9].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(errors[10].message, "negative value -1 does not fit into type u32. Cannot implicitly convert signed literal to unsigned type.");
    assert_eq!(
        errors[11].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(
        errors[12].message,
        "value 4294967298 does not fit into type u32."
    );
    assert_eq!(
        errors[13].message,
        "value 4294967299 does not fit into type u32."
    );
    assert_eq!(
        errors[14].message,
        "value 4294967296 does not fit into type u32."
    );
    assert_eq!(
        errors[15].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(
        errors[16].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(errors[17].message, "divide by zero");
    assert_eq!(errors[18].message, "divide by zero");

    assert_eq!(errors.len(), 19);

    assert_eq!(
        warnings[0].message,
        "left shift by 32 may overflow the final result"
    );
    assert_eq!(warnings.len(), 1);
}

#[test]
fn test_types() {
    let file = r#"
    contract test_contract {

        fn test_array() {
            u32[] arr_u32;
            u64[] arr_u64;
            u256[] arr_u256;
            field[] arr_field;

        }

    
        fn foo()  {
            u32 x = 0;
            x += 4294967299;
    
            u32 y = 0;
            y *= 4294967296 + 3;
            y -= 4294967298;
            y /= 4294967297 + y;
        }
    }
    
        "#;
    let ns = parse(file);
    let errors = ns.diagnostics.errors();

    assert_eq!(
        errors[0].message,
        "value 4294967299 does not fit into type u32."
    );
    assert_eq!(
        errors[1].message,
        "value 4294967299 does not fit into type u32."
    );
    assert_eq!(
        errors[2].message,
        "value 4294967298 does not fit into type u32."
    );
    assert_eq!(
        errors[3].message,
        "value 4294967297 does not fit into type u32."
    );
    assert_eq!(errors.len(), 4);
}

#[test]
fn test_fib_contract() {
    let file = r#"
        contract Fibonacci {
            u32 num;
            fn fib_recursive(u32 n) -> (u32) {
                num += 1;
                if (n == 0 || n == 1) {
                    return 1;
                }
                return fib_recursive(n -1) + fib_recursive(n -2);
            }

            fn fib_non_recursive(u32 n) -> (u32) {
                num += 1;
                if (n == 0 || n == 1) {
                    return 1;
                }
                u32 a = 1; u32 b = 1;
                for (u32 i = 2; i < n - 1 ;i++) {
                    b = a + b;
                    a = b - a;
                }
                return a + b;
            }

        }

        "#;
    let ns = parse(file);
    let errors = ns.diagnostics.errors();
    assert_eq!(errors.len(), 0);
}

#[test]
fn test_person_contract() {
    let file = r#"
        contract Person {

            enum Sex {
                Man,
                Women
            }

            struct Person {
                Sex s;
                u32 age;
                u256 id;
            }

            Person p;

            fn newPerson(Sex s, u32 age, u256 id) {
                p = Person(s, age, id);
            }

            fn getPersonId() -> (u256) {
                return p.id;
            }

            fn getAge() -> (u32) {
                return p.age;
            }
    }

        "#;
    let ns = parse(file);
    let errors = ns.diagnostics.errors();

    assert_eq!(errors.len(), 0);
}
