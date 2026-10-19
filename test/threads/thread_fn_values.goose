// A thread_fn's generic parameters take function values, bound at the spawn
// by the last arguments as at a call (§11.2, §7.6). Each binding is a thread
// program of its own.

struct Job { n: i64 }

// Takes jobs until a zero; a negative one aborts.
thread_fn serve(lane: i64) {
    loop {
        let j = qget<Job>();
        if j.n == 0 { return; }
        if j.n < 0 { abort(str("lane ", lane, " cannot take ", j.n)); }
        print("lane ", lane, " job ", j.n);
    }
}

thread_fn tick(lane: i64) { print("tick ", lane); }

// Restarts the worker it is handed until it returns.
thread_fn watch<W>(lane: i64) {
    while !thread_wait(thread_spawn_contained(W, lane)) { print("restart lane ", lane); }
}

// The binding passes on through a generic, as a function parameter does.
fn lane_open<W>(lane: i64) -> i64 { thread_spawn(watch, lane, W) }

fn twice(n: i64) { print("twice ", n * 2); }
fn square(n: i64) { print("square ", n * n); }

// Two function parameters, which the body calls as functions.
thread_fn both<F, G>(n: i64) {
    F(n);
    G(n);
}

fn main() {
    let w = lane_open(1, serve);
    for n in [3, -1, 4, 0] { qput(Job { n }); }
    thread_wait(w);
    thread_wait(lane_open(2, tick));
    thread_wait(thread_spawn(watch, 3, tick));
    thread_wait(thread_spawn(both, 3, twice, square));
    thread_wait(thread_spawn(both, 4, square, twice));
}
