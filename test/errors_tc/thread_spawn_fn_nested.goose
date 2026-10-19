// error: thread_fn each's F must name a top-level function
// A nested function reaches the spawner's locals (§11.2).
thread_fn each<F>(n: i64) { F(n); }
fn main() {
    fn show(n: i64) { print(n); }
    thread_wait(thread_spawn(each, 1, show));
}
