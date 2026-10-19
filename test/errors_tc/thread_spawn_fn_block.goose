// error: thread_fn each's F must name a top-level function
// A block bound through a generic is no worker's function value (§11.2).
thread_fn each<F>(n: i64) { F(n); }
fn spawn<G>(n: i64) -> i64 { thread_spawn(each, n, G) }
fn main() { thread_wait(spawn(1) { print(it); }); }
