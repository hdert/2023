// rustimport:pyo3

use pyo3::prelude::*;

#[pyfunction]
fn fibonacci(number: u64) -> u64 {
    if number == 0 {
        return 0;
    }
    if number == 1 {
        return 1;
    }
    let mut prevprev = 0;
    let mut prev = 1;
    let mut current = 1;
    for _ in 0..(number - 1) {
        current = prevprev + prev;
        prevprev = prev;
        prev = current;
    }
    current
}
