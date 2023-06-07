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
