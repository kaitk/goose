# arm32-layout on 32-bit Windows (MSVC x86): rerun report

Run on 2026-10-19, Windows 11 x64, MSVC 19.51 (VS 18 BuildTools) x64 and x86;
the test runner's own C backend was MSVC 19.29 x64 (VS 2019), as on master.

## Hashes tested

- goose `arm32-layout` = `34f94d78c8a1426aa1b57355c126f07afd9a2ded` (fork),
  merged locally (not pushed) with `msvc-x86-cmake` = `be55579ed54f227bf28fda81e93e9ee42d4a0ddf`
  -> local merge `9a2884c`.
- master baseline `fb5698125d6b366cff3b7aebc877fe0148c698a2`.
- goose-http `arm32-handles` = `ef06c6b77e53401c1ddc0c9afb0ac40c035eaa40` (fork).
- Fix: goose `arm32-windows-2` = `8ad57298112be191cae9a75f9a3ab6c90d167d0a`
  (one commit on arm32-layout `34f94d7`).

## Results

1. **x64 `python test/run_tests.py`: same as master.** One failure on both,
   `cgen-output-differs-by-O cycle_holder_unknown_store.goose` (MSVC 19.29;
   passes under clang-cl). Branch: 537 cgen ok vs master 535; the extra are the
   branch's own `data_stack_overflow`, `stdlib_byteset_fresh`, plus
   `export_header`; all pass.
2. **x86 repros and samples: pass.** slice_layout `2`, spawn_packet `8`,
   misaligned_f64 `10`/`2.0`, byteset_fresh `5 3`/`2`; samples 02, 14, 18
   (run from samples/), 23 identical to x64. Probe (cache cleared first) wrote
   `4` for the x86 toolchain (`msvc-19.51.36260-ab3dcda9`), `8` for x64.
   Binaries are PE32 Intel 80386.
3. **x86 vs x64 over 570 tests with a .out: 559 identical.** The rest:
   - `bce_place_flood`: x86 "cannot reserve data stack address space";
     passes with `--stack-reserve 4M` (expected).
   - `physics_*` (8): x86 link fails, `unresolved external symbol ___popcnt64`.
     Cause is in the goose_physics package: Box3D `third_party/box3d/src/ctz.h:75`
     calls `__popcnt64` under `_MSC_VER`, which x86 MSVC lacks. Not a Goose bug.
   - `thread_cap`: differs only because my comparison script ignores
     `// runtime-define:`; with `-DGS_STACK_BUDGET=67108864` x86 prints `1 6`.
   - `lexer_tokens`: parse-only fixture, builds on neither side.
   - `data_stack_overflow` with its define: x86 and x64 both print the overflow
     message and exit 1 (Windows fault handler OK on 32-bit).
   - gfx, audio, ui and pkg_cmake_lib all identical on x86 (needs msvc-x86-cmake).
5. **goose-http `scripts/test-examples.sh` with x86 builds: all passed.** No
   peak-memory numbers: the script reports RSS on Linux only.

- **`--stack-reserve 4G` on x86: fails to compile as intended**:
  `fatal error C1189: #error: "GS_STACK_RESERVE and GS_STACK_GAP exceed a 32-bit address space"`,
  no executable.

## Failure found and fixed (arm32-windows-2, `8ad5729`)

`--stacks` misreported a 32-bit Windows program's budget. runtime.h defined
`GS_STACK_BUDGET_32` twice (2 GB, then 1 GB on _WIN32) and StackConfigOf reads
the first, so on x86 Windows `--stacks` said "2 GB budget: 31 regions, thread
cap: 12 workers" while the program ran with 1 GB and 4 threads
(23_mandelbrot_threads). The fix names the Windows value
`GS_STACK_BUDGET_32_WINDOWS` and has StackConfigOf pick it on a Windows host;
now `--stacks` says "1 GB budget: 15 regions, thread cap: 4 workers", matching
the run. x64 suite on arm32-windows-2: same as master (the one failure above).

## Not run

- MinGW-w64 i686 (step 4): no i686-w64-mingw32-gcc on this machine.
