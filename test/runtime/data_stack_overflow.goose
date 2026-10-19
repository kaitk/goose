// runtime-define: GS_STACK_RESERVE=4194304
// A value that grows past its data stack's reservation runs into the guard
// gap behind it, which the runtime reports as an overflow (§9.3) naming the
// reservation. Only a fault in the gap is one.
fn main() {
    var a: u8[>..] = [];
    print("growing");
    for i in 8 << 20 { a.push(1); }
    print(a.len);
}
