// error: thread_spawn(each, ...) takes 1 worker argument(s) and 1 function value(s)
thread_fn each<F>(n: i64) { F(n); }
fn main() { thread_wait(thread_spawn(each, 1)); }
