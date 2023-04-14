// SPDX-License-Identifier: Apache-2.0

use crate::diagnostics::{Diagnostic, ErrorType::ParserError, Level::Error};
use crate::ola;
use crate::program::*;
use crate::Loc::File;
use pretty_assertions::assert_eq;
use std::sync::mpsc;
use std::time::Duration;
use std::{fs, path::Path, thread};
use walkdir::WalkDir;

#[test]
fn parse_function() {
    let src = r#"
contract C{
    fn a() {
        u64 _a = 2ll;
        u64 b = 200;
        u32 c = 2u;
        u32 d = 2l;
        u32 e = 2;
        field e = 2;
        /**
         * 12
         *
         * */
        // 3242

        //
        u128 b = 2;  //q3e32
        field e = 0x1;
        field e = 0x1u;
        field e = 0x1l;
        field e = 0x1ll;
    }
}
    "#;

    let actual_parse_tree = crate::parse(src, 0).unwrap();
    assert_eq!(actual_parse_tree.0.len(), 1);
}

#[test]
fn parser_struct() {
    let src = r#"import "./keccak.ola"; 
    import "filename" as symbolName;

 contract 9c {
     u256 0sesa_glb = 90;
     9u256sesa_glb = 90;
     u256 sesa_glb = 90id;

    struct 2sesa_struct {
        u256 3sesa_struct_mem;
    }

     fn 4sesa_func() {
        u32 3sesa_var = 3sesa_id + id;
        9uint sesa= 4b;
        if (false) {}
        if (true)
     }
 }
"#;

    if let Err(errors) = crate::parse(src, 0) {
        assert_eq!(
            errors,
            vec![
                Diagnostic {
                    loc: File(0, 72, 73),
                    level: Error,
                    ty: ParserError,
                    message: "unrecognised token '9', expected r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#"
                        .to_string(),
                    notes: vec![]
                },
                Diagnostic { loc: File(0, 87, 88), level: Error, ty: ParserError, message: "unrecognised token '0', expected \"!=\", \"%\", \"%=\", \"&\", \"&&\", \"&=\", \"(\", \")\", \"*\", \"**\", \"*=\", \"+\", \"++\", \"+=\", \",\", \"-\", \"--\", \"-=\", \".\", \"/\", \"/=\", \":\", \";\", \"<\", \"<<\", \"<<=\", \"<=\", \"=\", \"==\", \">\", \">=\", \">>\", \">>=\", \"?\", \"[\", \"]\", \"^\", \"^=\", \"const\", \"mut\", \"|\", \"|=\", \"||\", \"}\", r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 110, 113), level: Error, ty: ParserError, message: "unrecognised token '256', expected \"!=\", \"%\", \"%=\", \"&\", \"&&\", \"&=\", \"(\", \")\", \"*\", \"**\", \"*=\", \"+\", \"++\", \"+=\", \",\", \"-\", \"--\", \"-=\", \".\", \"/\", \"/=\", \":\", \";\", \"<\", \"<<\", \"<<=\", \"<=\", \"=\", \"==\", \">\", \">=\", \">>\", \">>=\", \"?\", \"[\", \"]\", \"^\", \"^=\", \"const\", \"mut\", \"|\", \"|=\", \"||\", \"}\", r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 151, 153), level: Error, ty: ParserError, message: r#"unrecognised token 'id', expected ";""#.to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 167, 168), level: Error, ty: ParserError, message: "unrecognised token '2', expected r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 195, 196), level: Error, ty: ParserError, message: "unrecognised token '3', expected \"!=\", \"%\", \"%=\", \"&\", \"&&\", \"&=\", \"(\", \")\", \"*\", \"**\", \"*=\", \"+\", \"++\", \"+=\", \",\", \"-\", \"--\", \"-=\", \".\", \"/\", \"/=\", \":\", \";\", \"<\", \"<<\", \"<<=\", \"<=\", \"=\", \"==\", \">\", \">=\", \">>\", \">>=\", \"?\", \"[\", \"]\", \"^\", \"^=\", \"const\", \"mut\", \"|\", \"|=\", \"||\", \"}\", r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 228, 229), level: Error, ty: ParserError, message: "unrecognised token '4', expected r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 255, 256), level: Error, ty: ParserError, message: "unrecognised token '3', expected \"!=\", \"%\", \"%=\", \"&\", \"&&\", \"&=\", \"(\", \")\", \"*\", \"**\", \"*=\", \"+\", \"++\", \"+=\", \",\", \"-\", \"--\", \"-=\", \".\", \"/\", \"/=\", \":\", \";\", \"<\", \"<<\", \"<<=\", \"<=\", \"=\", \"==\", \">\", \">=\", \">>\", \">>=\", \"?\", \"[\", \"]\", \"^\", \"^=\", \"const\", \"mut\", \"|\", \"|=\", \"||\", \"}\", r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 268, 275), level: Error, ty: ParserError, message: r#"unrecognised token 'sesa_id', expected ")", ";""#.to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 296, 300), level: Error, ty: ParserError, message: "unrecognised token 'sesa', expected \"(\", \")\", \",\", \";\", \"=\", \"{\", \"}\"".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 303, 304), level: Error, ty: ParserError, message: "unrecognised token 'b', expected \")\", \";\"".to_string(), notes: vec![] },
                Diagnostic { loc: File(0, 351, 352), level: Error, ty: ParserError, message: "unrecognised token '}', expected \"!\", \"(\", \"[\", \"bool\", \"break\", \"continue\", \"delete\", \"do\", \"false\", \"for\", \"if\", \"new\", \"return\", \"true\", \"u256\", \"u32\", \"u64\", \"while\", \"{\", \"~\", r#\"([1-9][0-9]*|0)(u|ll|l)?\"#, r#\"0x[0-9A-Fa-f]*(u|ll|l)?\"#, r#\"[$_]*[a-zA-Z][a-zA-Z$_0-9]*\"#".to_string(), notes: vec![] },
            ]
        )
    }
}

#[test]
fn parse_contract() {
    let src = r#"/// @title Foo
                /// @description Foo
                /// Bar
                contract foo {
                    /**
                    @title Jurisdiction
                    */
                    /// @author Anon
                    /**
                    @description Data for
                    jurisdiction
                    @dev It's a struct
                    */
                    struct Jurisdiction {
                        bool exists;
                        u256 keyIdx;
                        u32 country;
                        u32 region;
                    }
                    u64 __abba_$;
                    u64 $thing_102;
                }"#;

    let my_errs = &mut Vec::new();
    let actual_parse_tree = ola::SourceUnitParser::new().parse(0, my_errs, src).unwrap();
    let expected_parse_tree = SourceUnit(vec![SourceUnitPart::ContractDefinition(Box::new(
        ContractDefinition {
            loc: Loc::File(0, 92, 690),
            name: Some(Identifier {
                loc: Loc::File(0, 101, 104),
                name: "foo".to_string(),
            }),
            parts: vec![
                ContractPart::StructDefinition(Box::new(StructDefinition {
                    name: Some(Identifier {
                        loc: Loc::File(0, 419, 431),
                        name: "Jurisdiction".to_string(),
                    }),
                    loc: Loc::File(0, 412, 602),
                    fields: vec![
                        VariableDeclaration {
                            loc: Loc::File(0, 458, 469),
                            ty: Expression::Type(Loc::File(0, 458, 462), Type::Bool),
                            name: Some(Identifier {
                                loc: Loc::File(0, 463, 469),
                                name: "exists".to_string(),
                            }),
                        },
                        VariableDeclaration {
                            loc: Loc::File(0, 495, 506),
                            ty: Expression::Type(Loc::File(0, 495, 499), Type::Uint(256)),
                            name: Some(Identifier {
                                loc: Loc::File(0, 500, 506),
                                name: "keyIdx".to_string(),
                            }),
                        },
                        VariableDeclaration {
                            loc: Loc::File(0, 532, 543),
                            ty: Expression::Type(Loc::File(0, 532, 535), Type::Uint(32)),
                            name: Some(Identifier {
                                loc: Loc::File(0, 536, 543),
                                name: "country".to_string(),
                            }),
                        },
                        VariableDeclaration {
                            loc: Loc::File(0, 569, 579),
                            ty: Expression::Type(Loc::File(0, 569, 572), Type::Uint(32)),
                            name: Some(Identifier {
                                loc: Loc::File(0, 573, 579),
                                name: "region".to_string(),
                            }),
                        },
                    ],
                })),
                ContractPart::VariableDefinition(Box::new(VariableDefinition {
                    ty: Expression::Type(Loc::File(0, 623, 626), Type::Uint(64)),
                    name: Some(Identifier {
                        loc: Loc::File(0, 627, 635),
                        name: "__abba_$".to_string(),
                    }),
                    attrs: vec![],
                    loc: Loc::File(0, 623, 635),
                    initializer: None,
                })),
                ContractPart::VariableDefinition(Box::new(VariableDefinition {
                    ty: Expression::Type(Loc::File(0, 657, 660), Type::Uint(64)),
                    attrs: vec![],
                    name: Some(Identifier {
                        loc: Loc::File(0, 661, 671),
                        name: "$thing_102".to_string(),
                    }),
                    loc: Loc::File(0, 657, 671),
                    initializer: None,
                })),
            ],
        },
    ))]);

    assert_eq!(actual_parse_tree, expected_parse_tree);
}

#[test]
fn parse_user_defined_value_type() {
    let src = r#"
        contract TestToken {
            type uint256 = u256;
            type Bytes32 = u32;
        }
        "#;

    let actual_parse_tree = crate::parse(src, 0).unwrap();
    assert_eq!(actual_parse_tree.0.len(), 1);

    let expected_parse_tree = SourceUnit(vec![SourceUnitPart::ContractDefinition(Box::new(
        ContractDefinition {
            loc: Loc::File(0, 9, 104),
            name: Some(Identifier {
                loc: Loc::File(0, 18, 27),
                name: "TestToken".to_string(),
            }),
            parts: vec![
                ContractPart::TypeDefinition(Box::new(TypeDefinition {
                    loc: Loc::File(0, 42, 61),
                    name: Identifier {
                        loc: Loc::File(0, 47, 54),
                        name: "uint256".to_string(),
                    },
                    ty: Expression::Type(Loc::File(0, 57, 61), Type::Uint(256)),
                })),
                ContractPart::TypeDefinition(Box::new(TypeDefinition {
                    loc: Loc::File(0, 75, 93),
                    name: Identifier {
                        loc: Loc::File(0, 80, 87),
                        name: "Bytes32".to_string(),
                    },
                    ty: Expression::Type(Loc::File(0, 90, 93), Type::Uint(32)),
                })),
            ],
        },
    ))]);

    assert_eq!(actual_parse_tree, expected_parse_tree);
}

#[test]
fn parse_random_doccomment() {
    let src = r#" contract foo {
        fn a() -> () {
        /** x */ 
        /** x */ 
        /** dev:  */ 
         /** as */
          /** x */ 
           /** x */ 
           /** x */
        }
        fn b() {
            /** x */ 
            /** x */ 
            /** dev:  */ 
             /** as */
              /** x */ 
               /** x */ 
               /** x */
            }
    }
    "#;

    let actual_parse_tree = crate::parse(src, 0).unwrap();
    assert_eq!(actual_parse_tree.0.len(), 1);
}

#[test]
fn test_ext_source() {
    fn timeout_after<T, F>(d: Duration, f: F) -> Result<T, String>
    where
        T: Send + 'static,
        F: FnOnce() -> T,
        F: Send + 'static,
    {
        let (done_tx, done_rx) = mpsc::channel();
        let handle = thread::spawn(move || {
            let val = f();
            done_tx.send(()).expect("Unable to send completion signal");
            val
        });

        match done_rx.recv_timeout(d) {
            Ok(_) => Ok(handle.join().expect("Thread panicked")),
            Err(_) => Err(format!("Thread timeout-ed after {d:?}")),
        }
    }
    let source_delimiter = regex::Regex::new(r"====.*====").unwrap();

    let semantic_tests =
        WalkDir::new(Path::new(env!("CARGO_MANIFEST_DIR")).join("testdata/semanticTests"))
            .into_iter()
            .collect::<Result<Vec<_>, _>>()
            .unwrap()
            .into_iter();

    let errors = semantic_tests
        .map::<Result<_, String>, _>(|entry| {
            if entry.file_name().to_string_lossy().ends_with(".ola") {
                let source = match fs::read_to_string(entry.path()) {
                    Ok(source) => source,
                    Err(err) if matches!(err.kind(), std::io::ErrorKind::InvalidData) => {
                        return Ok(vec![])
                    }
                    Err(err) => return Err(err.to_string()),
                };
                Ok(source_delimiter
                    .split(&source)
                    .filter(|source_part| !source_part.is_empty())
                    .map(|part| (entry.path().to_string_lossy().to_string(), part.to_string()))
                    .collect::<Vec<_>>())
            } else {
                Ok(vec![])
            }
        })
        .collect::<Result<Vec<_>, _>>()
        .unwrap()
        .into_iter()
        .flatten()
        .filter_map(|(path, source_part)| {
            let result = match timeout_after(Duration::from_secs(5), move || {
                crate::parse(&source_part, 0)
            }) {
                Ok(result) => result,
                Err(err) => return Some(format!("{:?}: \n\t{}", path, err)),
            };

            if let Err(err) = result.map_err(|diags| {
                format!(
                    "{:?}:\n\t{}",
                    path,
                    diags
                        .iter()
                        .map(|diag| format!("{diag:?}"))
                        .collect::<Vec<_>>()
                        .join("\n\t")
                )
            }) {
                return Some(err);
            }

            None
        })
        .collect::<Vec<_>>();

    assert!(errors.is_empty(), "{}", errors.join("\n"));
}
