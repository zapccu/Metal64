//
//  test_metal64.cpp
//
//  Part of Metal64
//
//  CPU regression tests for the Metal headers. The headers are compiled unchanged
//  against the float32 emulation in ./metal_stdlib and compared with long double
//  reference values. Run ./run.sh (requires clang++ or g++).
//

#include "c64.h"
#include "c32.h"

#include <cstdio>
#include <random>

typedef long double LD;

static int failures = 0;

static LD ld(float2 a) { return (LD)a.x + (LD)a.y; }

// Round a long double to the nearest f64 (hi + lo)
static float2 mk(LD v) {
    float hi = (float)v;
    if (!std::isfinite(hi)) return float2(hi, 0.0f);
    return float2(hi, (float)(v - (LD)hi));
}

static std::mt19937_64 rng(20261021);
static LD uni(LD a, LD b) { return a + (b - a) * (LD)std::uniform_real_distribution<double>(0.0, 1.0)(rng); }

static void check(const char* name, bool ok, const char* detail = "") {
    printf("  %-4s %s %s\n", ok ? "ok" : "FAIL", name, detail);
    if (!ok) failures++;
}

static bool near(LD value, LD expected, LD tol = 1e-13L) {
    return std::fabs(value - expected) <= tol * std::max((LD)1.0L, std::fabs(expected));
}

// Random accuracy test. f: f64 function, ref: long double reference, limit: max allowed error.
// absolute = true: absolute error, otherwise relative error.
template <typename G, typename F, typename R>
static void accuracy(const char* name, G gen, F f, R ref, LD limit, bool absolute = false, int n = 100000) {
    LD worst = 0, worstx = 0;
    int nan = 0;
    for (int i = 0; i < n; i++) {
        float2 x = mk(gen());
        LD r = ld(f(x));
        LD e = ref(ld(x));
        if (std::isnan((double)r)) { nan++; continue; }
        LD err = std::fabs(r - e) / (absolute ? 1.0L : std::fabs(e));
        if (err > worst) { worst = err; worstx = ld(x); }
    }
    char detail[160];
    snprintf(detail, sizeof detail, "(max %s err %.2Le at x=%.10Lg, limit %.0Le, NaN %d)",
             absolute ? "abs" : "rel", worst, worstx, limit, nan);
    check(name, worst <= limit && nan == 0, detail);
}

static void testArithmetic() {
    printf("Arithmetic\n");

    // Two-Sum: |b| > |a.x| must not lose the low part
    float2 a = mk(1.0e-3L);
    LD exact = ld(a) + (LD)12345.678f;
    check("add_ds with |b| > |a|", near(ld(add_ds(a, 12345.678f)), exact, 1e-16L));
    check("add_sd with |a| > |b|", near(ld(add_sd(12345.678f, a)), exact, 1e-16L));
    check("sub_sd(a, b) = a - b", near(ld(sub_sd(1.0f, mk(0.25L))), 0.75L, 0.0L));

    check("float / f64", near(ld((2.0f / f64(4.0f)).v), 0.5L, 0.0L));
    check("f64 / float", near(ld((f64(2.0f) / 4.0f).v), 0.5L, 0.0L));
    check("float - f64", near(ld((1.0f - f64(4.0f)).v), -3.0L, 0.0L));

    check("f64(int) exact above 2^24", ld(f64(16777217).v) == 16777217.0L);
    check("f64(int) INT_MAX", ld(f64(2147483647).v) == 2147483647.0L);
    check("f64(int) INT_MIN", ld(f64((int)0x80000000).v) == -2147483648.0L);
    check("f64(int) -123456789", ld(f64(-123456789).v) == -123456789.0L);

    check("sqrt(0) = 0", ld(sqrt_f64(F2_ZERO)) == 0.0L);
    check("sqrt(-1) = NaN", std::isnan((double)ld(sqrt_f64(flt2(-1.0f)))));

    LD fa = 16777216.0L * 3.0L - 1e-6L;
    check("fmod with hi part integer, lo negative", near(ld(fmod_f64(mk(fa), flt2(3.0f))), fmodl(ld(mk(fa)), 3.0L), 1e-12L));
    check("fmod(-1, 3) = 2 (floor based)", near(ld(fmod_f64(flt2(-1.0f), flt2(3.0f))), 2.0L, 1e-14L));

    accuracy("add_f64", [] { return uni(-1e3, 1e3); }, [](float2 x) { return add_f64(x, mk(0.3L)); },
             [](LD x) { return x + ld(mk(0.3L)); }, 2e-14L);
    accuracy("mul_f64", [] { return uni(-1e3, 1e3); }, [](float2 x) { return mul_f64(x, mk(0.3L)); },
             [](LD x) { return x * ld(mk(0.3L)); }, 3e-14L);
    accuracy("div_f64", [] { return uni(-1e3, 1e3); }, [](float2 x) { return div_f64(F2_ONE, x); },
             [](LD x) { return 1.0L / x; }, 3e-14L);
    accuracy("sqrt_f64", [] { return uni(1e-6, 1e6); }, [](float2 x) { return sqrt_f64(x); },
             [](LD x) { return sqrtl(x); }, 5e-14L);
    accuracy("fmod_f64", [] { return uni(-1e3, 1e3); }, [](float2 x) { return fmod_f64(x, mk(0.7L)); },
             [](LD x) { LD b = ld(mk(0.7L)); return x - b * floorl(x / b); }, 5e-12L, true);  // ulp(512) ~ 2e-12
    accuracy("mul_f64 large values (no overflow)", [] { return uni(1e35, 1e36); },
             [](float2 x) { return mul_f64(x, mk(0.3L)); }, [](LD x) { return x * ld(mk(0.3L)); }, 3e-14L);
}

static void testFunctions() {
    printf("Functions\n");

    accuracy("exp [-20, 20]", [] { return uni(-20, 20); }, [](float2 x) { return exp(f64(x)).v; },
             [](LD x) { return expl(x); }, 2e-13L);
    accuracy("exp [60, 88]", [] { return uni(60, 88); }, [](float2 x) { return exp(f64(x)).v; },
             [](LD x) { return expl(x); }, 4e-13L);
    check("exp(1000) = inf", std::isinf(exp(f64(1000.0f)).v.x));
    check("exp(-1000) = 0", ld(exp(f64(-1000.0f)).v) == 0.0L);

    accuracy("log [e^-23, e^23]", [] { return expl(uni(-23, 23)); }, [](float2 x) { return log(f64(x)).v; },
             [](LD x) { return logl(x); }, 2e-13L, true);
    accuracy("pow(x, 2.5)", [] { return uni(0.1, 10); }, [](float2 x) { return pow(f64(x), f64(2.5f)).v; },
             [](LD x) { return powl(x, 2.5L); }, 2e-12L);
    accuracy("pow(x, -7)", [] { return uni(0.1, 10); }, [](float2 x) { return pow(f64(x), -7).v; },
             [](LD x) { return powl(x, -7.0L); }, 1e-13L);

    accuracy("sin [-10, 10]", [] { return uni(-10, 10); }, [](float2 x) { return sin(f64(x)).v; },
             [](LD x) { return sinl(x); }, 1e-13L, true);
    accuracy("cos [-10, 10]", [] { return uni(-10, 10); }, [](float2 x) { return cos(f64(x)).v; },
             [](LD x) { return cosl(x); }, 1e-13L, true);
    accuracy("tan [-1.5, 1.5]", [] { return uni(-1.5, 1.5); }, [](float2 x) { return tan(f64(x)).v; },
             [](LD x) { return tanl(x); }, 1e-11L, true);   // |tan| up to 14 in this range
    accuracy("atan [-50, 50]", [] { return uni(-50, 50); }, [](float2 x) { return atan(f64(x)).v; },
             [](LD x) { return atanl(x); }, 1e-13L, true);
    accuracy("asin [-1, 1]", [] { return uni(-1, 1); }, [](float2 x) { return asin(f64(x)).v; },
             [](LD x) { return asinl(x); }, 1e-13L, true);
    accuracy("asin [0.99, 1]", [] { return uni(0.99, 1); }, [](float2 x) { return asin(f64(x)).v; },
             [](LD x) { return asinl(x); }, 1e-13L, true);
    accuracy("acos [-1, 1]", [] { return uni(-1, 1); }, [](float2 x) { return acos(f64(x)).v; },
             [](LD x) { return acosl(x); }, 1e-13L, true);

    float2 nearOne = mk(0.9999999999L);   // hi = 1.0, lo < 0
    check("asin(0.9999999999) not NaN", near(ld(asin(f64(nearOne)).v), asinl(ld(nearOne)), 1e-13L));
    check("acos(-0.9999999999) not NaN", near(ld(acos(f64(-nearOne)).v), acosl(-ld(nearOne)), 1e-13L));
    check("asin(1.5) = NaN", std::isnan(asin(f64(1.5f)).v.x));

    // atan2 in all four quadrants and on the axes
    LD worst = 0;
    for (int i = 0; i < 100000; i++) {
        float2 y = mk(uni(-5, 5)), x = mk(uni(-5, 5));
        worst = std::max(worst, std::fabs(ld(atan2(f64(y), f64(x)).v) - atan2l(ld(y), ld(x))));
    }
    char detail[64];
    snprintf(detail, sizeof detail, "(max abs err %.2Le)", worst);
    check("atan2 all quadrants", worst < 1e-13L, detail);
    const float axes[][2] = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}, {0, 0}};
    for (auto& p : axes) {
        LD r = ld(atan2(f64(p[0]), f64(p[1])).v);
        snprintf(detail, sizeof detail, "atan2(%g, %g) = %.15Lg", p[0], p[1], r);
        check(detail, near(r, atan2l(p[0], p[1]), 1e-13L));
    }
}

static void testComplex() {
    printf("Complex c64\n");

    c64 a = c64(f64(2.0f));
    check("c64(f64) clears imaginary part", ld(a.v.zw) == 0.0L);
    c64 b = c64(float2(2.0f, 0.0f));
    check("c64(float2) clears imaginary part", ld(b.v.zw) == 0.0L);

    c64 s = f64(1.0f) - c64(f64(2.0f), f64(3.0f));
    check("f64 - c64", ld(s.v.xy) == -1.0L && ld(s.v.zw) == -3.0L);
    s = 1.0f - c64(f64(2.0f), f64(3.0f));
    check("float - c64", ld(s.v.xy) == -1.0L && ld(s.v.zw) == -3.0L);

    c64 d = f64(2.0f) / c64(f64(1.0f), f64(1.0f));
    check("f64 / c64", near(ld(d.v.xy), 1.0L) && near(ld(d.v.zw), -1.0L));
    d = 1.0f / c64(f64(0.0f), f64(1.0f));
    check("float / c64 (1/i = -i)", near(ld(d.v.xy), 0.0L) && near(ld(d.v.zw), -1.0L));

    c64 r = sqrt(c64(f64(4.0f), f64(0.0f)));
    check("sqrt(4 + 0i) = 2", near(ld(r.v.xy), 2.0L) && ld(r.v.zw) == 0.0L);
    r = sqrt(c64(f64(-4.0f), f64(0.0f)));
    check("sqrt(-4 + 0i) = 2i", near(ld(r.v.xy), 0.0L) && near(ld(r.v.zw), 2.0L));

    LD worst = 0;
    for (int i = 0; i < 20000; i++) {
        LD re = uni(-5, 5), im = uni(-5, 5);
        LD res = ld(arg(c64(f64(mk(re)), f64(mk(im)))).v);
        worst = std::max(worst, std::fabs(res - atan2l(ld(mk(im)), ld(mk(re)))));
    }
    char detail[64];
    snprintf(detail, sizeof detail, "(max abs err %.2Le)", worst);
    check("arg(c64) all quadrants", worst < 1e-13L, detail);

    c64 e = exp(c64(f64(1.0f), f64(2.0f)));
    check("exp(1 + 2i)", near(ld(e.v.xy), expl(1) * cosl(2)) && near(ld(e.v.zw), expl(1) * sinl(2)));
}

static void testComplex32() {
    printf("Complex c32\n");
    c32 a(3.0f, 4.0f), b(1.0f, -2.0f);
    c32 r = a - 1.0f;
    check("c32 - float", r.v.x == 2.0f && r.v.y == 4.0f);
    r = 1.0f - a;
    check("float - c32", r.v.x == -2.0f && r.v.y == -4.0f);
    r = a / 2.0f;
    check("c32 / float", r.v.x == 1.5f && r.v.y == 2.0f);
    r = 1.0f / c32(0.0f, 1.0f);
    check("float / c32 (1/i = -i)", r.v.x == 0.0f && r.v.y == -1.0f);
    r = a / b;   // (3+4i)/(1-2i) = -1 + 2i
    check("c32 / c32", std::fabs(r.v.x + 1.0f) < 1e-6f && std::fabs(r.v.y - 2.0f) < 1e-6f);
    r = sqr(a);
    check("sqr(c32)", r.v.x == -7.0f && r.v.y == 24.0f);
    check("abs(c32)", abs(a) == 5.0f);
    r = sqrt(c32(-4.0f, 0.0f));
    check("sqrt(c32)", std::fabs(r.v.x) < 1e-6f && std::fabs(r.v.y - 2.0f) < 1e-6f);
    check("arg(c32)", std::fabs(arg(c32(-1.0f, 0.0f)) - (float)M_PI) < 1e-6f);
}

int main() {
    testArithmetic();
    testFunctions();
    testComplex();
    testComplex32();
    printf("\n%s: %d failure(s)\n", failures ? "FAILED" : "PASSED", failures);
    return failures ? 1 : 0;
}
