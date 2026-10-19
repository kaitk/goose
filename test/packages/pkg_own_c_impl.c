/* The C side of pkg_own_c.goose, compiled from its sidecar. A slice crosses
   as a data pointer and a length, packed (spec 7.10, C.2). */
#include <stdint.h>

#pragma pack(push, 1)
typedef struct { const uint8_t *data; int64_t len; } own_c_bytes;
#pragma pack(pop)

int32_t own_c_sum(int32_t a, int32_t b) { return (a + b) * OWN_C_SCALE; }

int64_t own_c_count(own_c_bytes s, uint8_t c) {
    int64_t n = 0;
    for (int64_t i = 0; i < s.len; i++) n += s.data[i] == c;
    return n;
}
