// SPDX-License-Identifier: Apache-2.0

use super::ast::{File, Namespace};
use ola_parser::program::Loc;
use std::{fmt, path};

impl File {
    pub fn new(path: path::PathBuf, contents: &str, cache_no: usize) -> Self {
        let mut line_starts = Vec::new();

        for (ind, c) in contents.char_indices() {
            if c == '\n' {
                line_starts.push(ind + 1);
            }
        }

        File {
            path,
            line_starts,
            cache_no: Some(cache_no),
        }
    }

    /// Give a position as a human readable position
    pub fn loc_to_string(&self, start: usize, end: usize) -> String {
        let (from_line, from_column) = self.offset_to_line_column(start);
        let (to_line, to_column) = self.offset_to_line_column(end);

        if from_line == to_line && from_column == to_column {
            format!("{}:{}:{}", self, from_line + 1, from_column + 1)
        } else if from_line == to_line {
            format!(
                "{}:{}:{}-{}",
                self,
                from_line + 1,
                from_column + 1,
                to_column + 1
            )
        } else {
            format!(
                "{}:{}:{}-{}:{}",
                self,
                from_line + 1,
                from_column + 1,
                to_line + 1,
                to_column + 1
            )
        }
    }

    /// Convert an offset to line and column number, based zero
    pub fn offset_to_line_column(&self, loc: usize) -> (usize, usize) {
        let line_no = self
            .line_starts
            .partition_point(|line_start| loc >= *line_start);

        let col_no = if line_no > 0 {
            loc - self.line_starts[line_no - 1]
        } else {
            loc
        };

        (line_no, col_no)
    }

    /// Convert line + char to offset
    pub fn get_offset(&self, line_no: usize, column_no: usize) -> usize {
        if line_no == 0 {
            column_no
        } else {
            self.line_starts[line_no - 1] + column_no
        }
    }
}

impl fmt::Display for File {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        #[cfg(not(windows))]
        let res = write!(f, "{}", self.path.display());

        res
    }
}

impl Namespace {
    /// Give a position as a human readable position
    pub fn loc_to_string(&self, loc: &Loc) -> String {
        match loc {
            Loc::File(file_no, start, end) => self.files[*file_no].loc_to_string(*start, *end),
            Loc::Builtin => String::from("builtin"),
            Loc::IRgen => String::from("codegen"),
            Loc::Implicit => String::from("implicit"),
            Loc::CommandLine => String::from("commandline"),
        }
    }

    /// File number of the top level source unit which was compiled
    pub fn top_file_no(&self) -> usize {
        self.files
            .iter()
            .position(|file| file.cache_no.is_some())
            .unwrap()
    }
}
