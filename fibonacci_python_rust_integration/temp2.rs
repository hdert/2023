// rustimport:pyo3

//: [dependencies]
//: fibext = "0.2"

use fibext::Fibonacci;
use pyo3::prelude::*;

#[pyfunction]
fn fibonacci(number: u64) -> u64 {
    Fibonacci::new().nth(number as usize).unwrap()
}
