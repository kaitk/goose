#include <stdint.h>
#pragma pack(push, 1)
typedef struct { const int32_t *data; int64_t len; } cmath2_ints;
#pragma pack(pop)
int32_t cmath2_square(int32_t x);
int64_t cmath2_dot(cmath2_ints a, cmath2_ints b);
