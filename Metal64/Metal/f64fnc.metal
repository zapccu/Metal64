//
//  f64fnc.h
//
//  Functions for 64 bit floating point GPU/Metal calculations
//
//  Created by Dirk Braner on 13.12.24.
//
//  64 bit real float:
//
//    A 64 bit float value is represented by float2 data type.
//    The corresponding Swift data types are SIMD2<Float32> and Float2.
//      .x = Hight value part
//      .y = Low value part
//
//  64 bit complex float:
//
//    A 64 bit complex value is represented by float4 data type.
//    The corresponding Swift data type is SIMD4<Float32> and Complex2.
//      .xy = float2 with real part high, low
//      .zw = float2 with imaginary part high, low
//

#include <metal_stdlib>

#include "f64fnc.h"

using namespace metal;

constant int ANGLES_LENGTH = 60;
constant int KPROD_LENGTH  = 33;

constant float2 F2_ZERO = 0.0f;
constant float2 F2_ONE  = float2(1.0f, 0.0f);

constant float2 angles[ANGLES_LENGTH] = {
    float2(0.7853982, -2.1855694e-08),
    float2(0.4636476, 5.0121587e-09),
    float2(0.24497867, -3.1786778e-09),
    float2(0.124354996, -1.2403822e-09),
    float2(0.06241881, -1.0272779e-09),
    float2(0.031239834, -2.525072e-10),
    float2(0.015623729, -1.2420882e-10),
    float2(0.007812341, -1.4939992e-10),
    float2(0.0039062302, -7.742832e-11),
    float2(0.0019531226, -3.8799422e-11),
    float2(0.0009765622, -1.9402376e-11),
    float2(0.00048828122, -9.701271e-12),
    float2(0.00024414062, -4.850638e-12),
    float2(0.00012207031, -6.0632977e-13),
    float2(6.1035156e-05, -7.579123e-14),
    float2(3.0517578e-05, -9.473904e-15),
    float2(1.5258789e-05, -1.1842385e-15),
    float2(7.6293945e-06, -1.4803002e-16),
    float2(3.8146973e-06, -1.8503858e-17),
    float2(1.9073486e-06, -2.3130352e-18),
    float2(9.536743e-07, -2.8915587e-19),
    float2(4.7683716e-07, -3.615772e-20),
    float2(2.3841858e-07, -4.5263323e-21),
    float2(1.1920929e-07, -5.6910026e-22),
    float2(5.9604645e-08, -7.2791894e-23),
    float2(2.9802322e-08, -9.926167e-24),
    float2(1.4901161e-08, -1.6543612e-24),
    float2(7.450581e-09, 0.0),
    float2(3.7252903e-09, 0.0),
    float2(1.8626451e-09, 0.0),
    float2(9.313226e-10, 0.0),
    float2(4.656613e-10, 0.0),
    float2(2.3283064e-10, 0.0),
    float2(1.1641532e-10, 0.0),
    float2(5.820766e-11, 0.0),
    float2(2.910383e-11, 0.0),
    float2(1.4551915e-11, 0.0),
    float2(7.275958e-12, 0.0),
    float2(3.637979e-12, 0.0),
    float2(1.8189894e-12, 0.0),
    float2(9.094947e-13, 0.0),
    float2(4.5474735e-13, 0.0),
    float2(2.2737368e-13, 0.0),
    float2(1.1368684e-13, 0.0),
    float2(5.684342e-14, 0.0),
    float2(2.842171e-14, 0.0),
    float2(1.4210855e-14, 0.0),
    float2(7.1054274e-15, 0.0),
    float2(3.5527137e-15, 0.0),
    float2(1.7763568e-15, 0.0),
    float2(8.881784e-16, 0.0),
    float2(4.440892e-16, 0.0),
    float2(2.220446e-16, 0.0),
    float2(1.110223e-16, 0.0),
    float2(5.551115e-17, 0.0),
    float2(2.7755576e-17, 0.0),
    float2(1.3877788e-17, 0.0),
    float2(6.938894e-18, 0.0),
    float2(3.469447e-18, 0.0),
    float2(1.7347235e-18, 0.0)
};

constant float2 kprod[KPROD_LENGTH] = {
    float2(0.70710677, 1.21016175e-08),
    float2(0.6324555, 4.251236e-09),
    float2(0.613572, -1.0379318e-08),
    float2(0.6088339, 3.4830234e-09),
    float2(0.60764825, 2.8153113e-09),
    float2(0.6073518, -9.796448e-09),
    float2(0.60727763, 1.2333882e-08),
    float2(0.6072591, 1.7583774e-08),
    float2(0.6072545, -2.5824908e-08),
    float2(0.6072533, 8.0252995e-09),
    float2(0.607253, 1.6487784e-08),
    float2(0.60725296, 3.7022383e-09),
    float2(0.60725296, -1.439531e-08),
    float2(0.60725296, -1.8919696e-08),
    float2(0.60725296, -2.0050793e-08),
    float2(0.60725296, -2.0333568e-08),
    float2(0.60725296, -2.0404261e-08),
    float2(0.60725296, -2.0421934e-08),
    float2(0.60725296, -2.0426352e-08),
    float2(0.60725296, -2.0427457e-08),
    float2(0.60725296, -2.0427734e-08),
    float2(0.60725296, -2.0427802e-08),
    float2(0.60725296, -2.042782e-08),
    float2(0.60725296, -2.0427823e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08),
    float2(0.60725296, -2.0427825e-08)
};

// ----------------------------------------------------------------------------
//  Helper functions
// ----------------------------------------------------------------------------

// Add hi and lo
float2 sumq(float a, float b) {
    float s = a + b;
    float e = b - (s - a);
    return float2(s, e);
}

float2 sumq(float2 a) {
    float s = a.x + a.y;
    float e = a.y - (s - a.x);
    return float2(s, e);
}

float4 sump(float2 a_ri, float2 b_ri) {
    float2 s = a_ri + b_ri;
    float2 v = s - a_ri;
    float2 e = (a_ri - (s - v)) + (b_ri - v);
    return float4(s.x, e.x, s.y, e.y);
}

// Split two 32 bit floats into four 16 bit floats
float4 split4(float2 c) {
    // const float split = 4097;
    float2 t = c * 4097.0;
    float2 c_hi = t - (t - c);
    float2 c_lo = c - c_hi;
    return float4(c_hi.x, c_lo.x, c_hi.y, c_lo.y);
}

float2 prod(float a, float b) {
    float p = a * b;
    float4 s = split4(float2(a, b));
    float e = ((s.x * s.z - p) + s.x * s.w + s.y * s.z) + s.y * s.w;
    return float2(p, e);
}

// ----------------------------------------------------------------------------
//  Real operations
// ----------------------------------------------------------------------------

// Add 2 64 bit floating point values
float2 add_f64(float2 a, float2 b) {
    float4 st = sump(a, b);
    st.y += st.z;
    st.xy = sumq(st.xy);
    st.y += st.w;
    return sumq(st.xy);
}

// Subtract 2 64 bit floating point values
float2 sub_f64(float2 a, float2 b) {
    return add_f64(a, -b);
}

// Multiplication: f64 * f64
float2 mul_f64(float2 a, float2 b) {
    float2 p = prod(a.x, b.x);
    p.y += a.x * b.y + a.y * b.x;
    return sumq(p);
}

// Square of f64
float2 sqr_f64(float2 a) {
    float2 p = prod(a.x, a.x);
    p.y += 2.0f * a.x * a.y;
    return sumq(p);
}

// f64 square of float
float2 sqr_f64(float a) {
    return sumq(prod(a, a));
}

// Multiplication: f64 * f32
float2 mulds(float2 a, float b) {
    float2 p = prod(a.x, b);
    p.y += a.y * b;
    return sumq(p);
}

// Division: f64 / f64
float2 div_f64(float2 b, float2 a) {
    float xn = 1.0f / a.x;
    float yn = b.x * xn;
    float2 ayn = mulds(a, yn);
    float diff = sub_f64(b, ayn).x;
    float2 p = prod(xn, diff);
    return add_f64(float2(yn, 0.0), p);
}

// ----------------------------------------------------------------------------
// Compare two 64 bit floating point values
// ----------------------------------------------------------------------------

// Check for zero
bool isZero_f64(float2 a) {
    return all(a == 0.0);
}

// Return sign of value: -1, 0, 1
int sign_f64(float2 a) {
    if (all(a == 0.0)) {
        return 0;
    }
    else if (a.x < 0.0 || (a.x == 0.0 && a.y < 0.0)) {
        return -1;
    }
    else {
        return 1;
    }
}

// Equal
bool eq(float2 a, float2 b) {
    return all(a == b);
}

// Not equal
bool ne(float2 a, float2 b) {
    return any(a != b);
}

// Less than
bool lt(float2 a, float2 b) {
    return (a.x < b.x || (a.x == b.x && a.y < b.y));
}

// Greater than
bool gt(float2 a, float2 b) {
    return (a.x > b.x || (a.x == b.x && a.y > b.y));
}

// Less or equal
bool le(float2 a, float2 b) {
    return lt(a, b) || eq(a, b);
}

// Greater or equal
bool ge(float2 a, float2 b) {
    return gt(a, b) || eq(a, b);
}

// ----------------------------------------------------------------------------
//  Square root, exponential, logarithm and trigonomical functions
// ----------------------------------------------------------------------------

// Square root
float2 sqrt_f64(float2 a) {
    float xn = rsqrt(a.x);
    float yn = a.x * xn;
    float diff = (sub_f64(a, sqr_f64(yn))).x;
    float2 p = prod(xn, diff) / 2.0f;
    return add_f64(float2(yn, 0.0f), p);
}

// Exponential
float2 exp_f64(float2 a) {
    float2 s = add_f64(a, float2(1.0f, 0.0f));
    float2 t = a;
    float2 d = a;
    int m = 2;
    
    while (abs(t.x) > 1e-20) {
        d = div_f64(a, float2(m, 0.0f));
        t = mul_f64(t, d);
        s = add_f64(s, t);
        m++;
    }

    return s;
}

// Natural logarithm
float2 log_f64(float2 a) {
    float2 xi = 0.0f;
    
    if (eq(a, float2(1.0f, 0.0f))) return xi;
    if (le(a, float2(0.0f, 0.0f))) return NAN;

    xi.x = log(a.x);
    return add_f64(add_f64(xi, mul_f64(exp_f64(-xi), a)), float2(-1.0f, 0.0f));
}

// Power f64, f64
float2 pow_f64(float2 a, float2 b) {
    return exp_f64(mul_f64(b, log_f64(a)));
}

// Power f64, int
float2 pow_f64(float2 a, int b) {
    float2 r = 1.0f;
    int i;
    
    for (i=0; i<b; i++) {
        r = mul_f64(r, a);
    }
    
    return r;
}

// Floating point modulo division
float2 fmod_f64(float2 a, float2 b) {
    float2 d = div_f64(a, b);
    float i = float(int(d.x));
    return sub_f64(a, mulds(b, i));
}

float2 angle_shift(float2 alpha, float2 beta) {
    float2 gamma;

    if (lt(alpha, beta)) {
        // gamma = beta - fmod ( beta - alpha, 2.0 * pi_f2 ) + 2.0 * pi_f2;
        gamma = add_f64(sub_f64(beta, fmod_f64(sub_f64(beta, alpha), pix2_f2)), pix2_f2);
    }
    else {
        // gamma = beta + fmod ( alpha - beta, 2.0 * pi_f2 );
        gamma = add_f64(beta, fmod_f64(sub_f64(alpha, beta), pix2_f2));
    }

    return gamma;
}

// Sine/Cosine by CORDIC algorithm
// Taken from: https://people.sc.fsu.edu/~jburkardt/c_src/cordic/cordic.html
float4 sincos_f64(float2 a, int n) {
    float2 angle;
    float2 c2;
    float2 factor;
    int j;
    float2 poweroftwo = F2_ONE;
    float2 s2;
    float sigma = 0.0;
    float sign_factor = 0.0;
    float2 theta = 0.0;
    float2 c = F2_ONE, s = 0.0f;
    
    // Shift angle to interval [-pi,pi].
    theta = angle_shift(a, -pi_f2);
    
    // Shift angle to interval [-pi/2,pi/2] and account for signs.
    if (lt(theta, -pi2_f2)) {
        theta = add_f64(theta, pi_f2);
        sign_factor = -1.0;
    }
    else if (lt(pi2_f2, theta)) {
        theta = sub_f64(theta, pi2_f2);
        sign_factor = -1.0;
    }
    else {
        sign_factor = 1.0;
    }
    
    angle = angles[0];

    // Iterate
    for (j=1; j<=n; j++) {
        sigma = lt(theta, F2_ZERO) ? -1.0 : 1.0;

        factor = mulds(poweroftwo, sigma);

        c2 = sub_f64(c, mul_f64(factor, s));
        s2 = add_f64(mul_f64(factor, c), s);

        c = c2;
        s = s2;

        // Update the remaining angle
        theta = sub_f64(theta, mulds(angle, sigma));

        poweroftwo = mulds(poweroftwo, 0.5);
        // poweroftwo = div_f64(poweroftwo, float2(2.0, 0.0));

        // Update the angle from table, or eventually by just dividing by two
        angle = ANGLES_LENGTH < j+1 ? mulds(angle, 0.5) : angles[j];
        // angle = ANGLES_LENGTH < j+1 ? div_f64(angle, float2(2.0, 0.0)) : angles[j];
    }

    // Adjust length of output vector to be [cos(beta), sin(beta)]

    // KPROD is essentially constant after a certain point, so if N is
    // large, just take the last available value.
    if (0 < n) {
        c = mul_f64(c, kprod[ min(n, KPROD_LENGTH) - 1 ]);
        s = mul_f64(s, kprod[ min(n, KPROD_LENGTH) - 1 ]);
    }
    
    //  Adjust for possible sign change because angle was originally not in quadrant 1 or 4.
    c = mulds(c, sign_factor);
    s = mulds(s, sign_factor);
    //c = sqrt_f64(add_f64(float2(1.0f, 0.0f), -sqr_f64(s)));

    return float4(s, c);
}

// Sine
float2 sin_f64(float2 a) {
    return sincos_f64(a, 50).xy;
}

// Cosine
float2 cos_f64(float2 a) {
    return sincos_f64(a, 50).zw;
}

// Tangent
float2 tan_f64(float2 a) {
    float4 sc = sincos_f64(a, 50);
    return div_f64(sc.xy, sc.zw);
}

// Arc tangent iteration
// Should be substituted by CORDIC algorithm because n must be >100 to get accurate results
/*
float2 atan_iterate(float2 a, int n) {
    float2 a2 = mul_f64(a, a);
    float2 d = float2(n + n + 1, 0.0f);
    float2 f;
    int k;
    float2 k2;
    
    for (k=n; k>0; k--) {
        f = float2(k + k - 1, 0.0f);
        k2 = float2(k * k, 0.0f);
        d = add_f64(f, div_f64(mul_f64(k2, a2), d));
    }
    
    return div_f64(a, d);
}
*/

float2 atan2_iterate(float2 y, float2 x, int n) {
    float2 angle;
    int j;
    float2 poweroftwo = F2_ONE;
    float sigma;
    float sign_factor;
    float2 theta = 0.0f;
    float2 x1 = x;
    float2 x2;
    float2 y1 = y;
    float2 y2;

     if (lt(x1, F2_ZERO) && lt(y1, F2_ZERO)) {
         x1 = -x1;
         y1 = -y1;
     }

     if (lt(x1, F2_ZERO)) {
         x1 = -x1;
         sign_factor = -1.0;
     }
     else if (lt(y1, F2_ZERO)) {
         y1 = -y1;
         sign_factor = -1.0;
     }
     else {
         sign_factor = 1.0;
     }

     for (j=1; j<=n; j++) {
         sigma = le(y1, F2_ZERO) ? 1.0 : -1.0;

         angle = j <= ANGLES_LENGTH ? angles[j-1] : mulds(angle, 0.5);

         x2 = sub_f64(x1, mulds(mul_f64(poweroftwo, y1), sigma));
         y2 = add_f64(y1, mulds(mul_f64(poweroftwo, x1), sigma));
         theta = sub_f64(theta, mulds(angle, sigma));

         x1 = x2;
         y1 = y2;

         poweroftwo = mulds(poweroftwo, 0.5);
     }

     return mulds(theta, sign_factor);
}

// Inverse tangent
float2 atan_f64(float2 a) {
    return atan2_iterate(a, F2_ONE, 40);
    
    /*
    if (all(a == 0.0)) {
        return float2(0.0f, 0.0f);
    }
    else if (gt(a, float2(1.0f, 0.0f))) {
        return sub_f64(pi2_f2, atan_iterate(div_f64(float2(1.0f, 0.0f), a), 21));
    }
    else {
        return atan_iterate(a, 100);
    }
     */
}

// Inverse tangent2
float2 atan2_f64(float2 y, float2 x) {
    return atan2_iterate(y, x, 40);
    
    /*
    int sy = sign_f64(y);
    int sx = sign_f64(x);
    
    if (sx == 1) {
        // x > 0
        return atan_f64(div_f64(y, x));
    }
    else if (sx == -1 && sy == 1) {
        // x < 0 AND y >= 0
        return add_f64(atan_f64(div_f64(y, x)), pi_f2);
    }
    else if (sx == -1 && sy == -1) {
        // x < 0 AND y < 0
        return sub_f64(atan_f64(div_f64(y, x)), pi_f2);
    }
    else if (sx == 0 && sy == 1) {
        // x = 0 AND y > 0
        return pi2_f2;
    }
    else if (sx == 0 && sy == -1) {
        // x = 0 AND y < 0
        return -pi2_f2;
    }
    else {
        // x = 0 AND y = 0
        return NAN;
    }
     */
}

// Inverse sine
float2 asin_f64(float2 a) {
    float2 d = sqrt_f64(sub_f64(float2(1.0f, 0.0f), mul_f64(a, a)));
    return atan_f64(div_f64(a, d));
}

// Inverse cosine
float2 acos_f64(float2 a) {
    float2 d = sqrt_f64(sub_f64(float2(1.0f, 0.0f), mul_f64(a, a)));
    return sub_f64(pi2_f2, atan_f64(div_f64(a, d)));
}

// ----------------------------------------------------------------------------
//  Complex operations
// ----------------------------------------------------------------------------

// Add 2 64 bit complex values
float4 add_c64(float4 a, float4 b) {
    return float4(add_f64(a.xy, b.xy), add_f64(a.zw, b.zw));
}

// Subtract 2 64 bit complex values
float4 sub_c64(float4 a, float4 b) {
    return float4(add_f64(a.xy, -b.xy), add_f64(a.zw, -b.zw));
}

// Multiply 2 64 bit complex values
float4 mul_c64(float4 a, float4 b) {
    float2 r1 = mul_f64(a.xy, b.xy);    // a.r * b.r
    float2 r2 = mul_f64(a.zw, b.zw);    // a.i * b.i
    float2 i1 = mul_f64(a.xy, b.zw);    // a.r * b.i
    float2 i2 = mul_f64(a.zw, b.xy);    // a.i * b.r
    return float4(sub_f64(r1, r2), add_f64(i1, i2));
}

// Square of 64 bit complex value
float4 sqr_c64(float4 a) {
    float2 r1 = mul_f64(a.xy, a.xy);
    float2 r2 = mul_f64(a.zw, a.zw);
    float2 i1 = mul_f64(a.xy, a.zw);
    return float4(sub_f64(r1, r2), add_f64(i1, i1));
}

// Divide 2 64 bit complex values
float4 div_c64(float4 a, float4 b) {
    float2 d = add_f64(mul_f64(b.xy, b.xy), mul_f64(b.zw, b.zw));
    float2 r = div_f64(add_f64(mul_f64(a.xy, b.xy), mul_f64(a.zw, b.zw)), d);
    float2 i = div_f64(sub_f64(mul_f64(a.zw, b.xy), mul_f64(a.xy, b.zw)), d);
    return float4(r, i);
}

// 64 bit complex square root
float4 sqrt_c64(float4 a) {
    float2 dc = abs_c64(a);
    float2 r = sqrt_f64(div_f64(add_f64(dc, a.xy), 2.0));
    float2 i = lt(a.zw, 0.0) ? -sqrt_f64(div_f64(sub_f64(dc, a.xy), 2.0)) : sqrt_f64(div_f64(sub_f64(dc, a.xy), 2.0));
    return float4(r, i);
}

// 64 bit complex exponential function
float4 exp_c64(float4 a) {
    float2 e = exp_f64(a.xy);
    return float4(mul_f64(e, cos_f64(a.zw)), mul_f64(e, sin_f64(a.zw)));
}

// Compare 64 bit complex values
bool eq(float4 a, float4 b) {
    return all(a == b);
}

bool ne(float4 a, float4 b) {
    return any(a != b);
}

float2 norm_c64(float4 c) {
    return add_f64(sqr_f64(c.xy), sqr_f64(c.zw));
}

float2 abs_c64(float4 c) {
    return sqrt_f64(norm_c64(c));
}

// ----------------------------------------------------------------------------
//  Special functions
// ----------------------------------------------------------------------------

// Calculate Z = Z^2 + C
float2x4 mandelbrot(float4 z, float4 c, float2 bailout) {
    float2 r1 = sqr_f64(z.xy);
    float2 r2 = sqr_f64(z.zw);
    float2 n = add_f64(r1, r2);
    float2 i1 = mul_f64(z.xy, z.zw);
    float4 z1 = float4(add_f64(sub_f64(r1, r2), c.xy), add_f64(add_f64(i1, i1), c.zw));
    return float2x4(z1, float4(n, float2(0.0)));
}


