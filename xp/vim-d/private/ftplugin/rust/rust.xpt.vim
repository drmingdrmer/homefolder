XPTemplate priority=lang

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common

XPT sb " rust as script shebang
#!/bin/sh
#![allow(unused_attributes)] /*
OUT=/tmp/tmp && rustc "$0" -o ${OUT} && exec ${OUT} $@ || exit $? #*/

// use std::process::Command;
// use std::io::Result;
// use std::path::PathBuf;
// use std::fs;
//
// fn mkdir(dir_name: &str) -> Result<()> {
//     fs::create_dir(dir_name)
// }

fn main() {
    `cursor^
}

XPT main " fn main
fn main() {
    `cursor^
}

XPT mod " mod {
mod `^ {
    `cursor^
}


XPT impl " impl trait for
impl `trait^ for `struct^ {
    fn `func^(&self`, `a?^)` -> `r?^ {
        `cursor^
    }
}

XPT fn " fn xxx\()
fn `f^(`args?^)` -> `r?^ {
    `cursor^
}

XPT lmut " let mul x: i32 = 1
let mut `a^`: `i32?^ = `^

XPT if " if {
if `^ {
    `cursor^
}

XPT iflet " if let {
if let `some^ = `v^ {
    `cursor^
}

XPT elif " else if {
else if `^ {
    `cursor^
}

XPT else " else {
else {
    `cursor^
}

XPT while " while {
while `^ {

}


XPT println " println!\()
println!("`fmt^"`, `x?^)

XPT #derive " #[derive\(...)]
#[derive(`x^)]

XPT #dbg " #[derive\(Debug)]
#[derive(Debug)]

XPT #dead " #[allow\(dead_code)]
#[allow(dead_code)]

XPT #over " #![allow\(overflowing_literals)]
#![allow(overflowing_literals)]

XPT #nocamel " #[allow\(non_camel_case_types)]
#[allow(non_camel_case_types)]
