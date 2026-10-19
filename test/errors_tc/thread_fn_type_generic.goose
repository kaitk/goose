// error: thread_fn worker cannot be generic over a type (T)
// A thread_fn's generic parameters take function values only (§11.2).
thread_fn worker<T>(x: T) { print(x); }
fn main() {}
