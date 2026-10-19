"""A C host compiles against the header --header writes, and calls the exports."""
from pathlib import Path

import toolchain as tc


def check_export_header(exe, cc, base, *, runtime, extra=()):
    base = (Path(base) / "export-header").resolve()
    base.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).parent / "codegen" / "export.goose"
    cfile, header = base / "export.c", base / "export.h"
    code, out, err = tc.run_capture([exe, "-o", cfile, "--header", header, source])
    if code:
        raise RuntimeError(out + err)
    host = base / "host.c"
    # The header's slice types and the exports' parameters spell their
    # pointers with the gs_ua_ types, which the header declares itself.
    tc.write_text(host, '''#include <stdio.h>
#include "export.h"
int main(int argc, char **argv) {
    goose_init(argc, argv);
    int64_t xs[4] = { 3, 1, 4, 1 };
    sl_i64 s = { xs, 4 };
    printf("%d %lld\\n", (int)c_add(20, 22), (long long)c_weigh(s, 1));
    return 0;
}
''')
    binary = base / ("host" + tc.EXE_SUFFIX)
    ok, log = cc.compile([host, cfile], binary, opt=1, extra=extra, strict_decls=True,
                         runtime=runtime)
    if not ok:
        raise RuntimeError(log)
    code, out, err = tc.run_capture([binary])
    # goose_init runs the program's main first.
    if code or out.strip().splitlines()[-1:] != ["42 21"]:
        raise RuntimeError(out + err)
