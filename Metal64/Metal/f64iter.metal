//
//  f64iter.metal
//  Metal64
//
//  Created by Dirk Braner on 11.04.25.
//

#include <metal_stdlib>

#include "f64fnc.h"

using namespace metal;

// Constants for CORDIC algorithms
// To get accurate results for trigonomical functions, number of iterations should be >= 40
constant int CORDIC_ANGLES_LENGTH     = 60;
constant int CORDIC_KPROD_LENGTH      = 33;
constant int CORDIC_TRIG_ITERATIONS   = 50;
constant int CORDIC_LOGEXP_ITERATIONS = 50;
constant int CORDIC_LOGEXP_LENGTH     = 30;

constant float2 trig_angles[CORDIC_ANGLES_LENGTH] = {
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

constant float2 trig_kprod[CORDIC_KPROD_LENGTH] = {
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

constant float2 logexp[CORDIC_LOGEXP_LENGTH] = {
    float2(1.6487212, 5.2590998e-08),
    float2(1.2840254, -1.39915795e-08),
    float2(1.1331484, 2.1288873e-08),
    float2(1.0644945, -3.1705614e-08),
    float2(1.0317434, 2.4965208e-10),
    float2(1.0157477, 4.222774e-08),
    float2(1.0078431, -3.9580968e-08),
    float2(1.0039139, 9.943816e-09),
    float2(1.001955, 1.24237e-09),
    float2(1.000977, 1.5525825e-10),
    float2(1.0004884, 1.9404922e-11),
    float2(1.0002441, 2.980475e-08),
    float2(1.0001221, 7.4508835e-09),
    float2(1.000061, 1.8626831e-09),
    float2(1.0000305, 4.6566595e-10),
    float2(1.0000153, 1.1641599e-10),
    float2(1.0000076, 2.910383e-11),
    float2(1.0000038, 7.275958e-12),
    float2(1.0000019, 1.8189894e-12),
    float2(1.000001, 4.5474735e-13),
    float2(1.0000005, 1.1368684e-13),
    float2(1.0000002, 2.842171e-14),
    float2(1.0000001, 7.1054274e-15),
    float2(1.0000001, -5.9604645e-08),
    float2(1.0, 2.9802322e-08),
    float2(1.0, 1.4901161e-08),
    float2(1.0, 7.450581e-09),
    float2(1.0, 3.7252903e-09),
    float2(1.0, 1.8626451e-09)
};

// Shift angle of sine/cosine iteration
float2 angle_shift(float2 alpha, float2 beta) {
    float2 gamma;

    if (lt(alpha, beta)) {
        gamma = add_f64(sub_f64(beta, fmod_f64(sub_f64(beta, alpha), F2_2_PI)), F2_2_PI);
    }
    else {
        gamma = add_f64(beta, fmod_f64(sub_f64(alpha, beta), F2_2_PI));
    }

    return gamma;
}

// Sine/Cosine by CORDIC algorithm
float4 sincos_iterate(float2 a) {
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
    theta = angle_shift(a, -F2_PI);
    
    // Shift angle to interval [-pi/2,pi/2] and account for signs.
    if (lt(theta, -F2_PI_2)) {
        theta = add_f64(theta, F2_PI);
        sign_factor = -1.0;
    }
    else if (lt(F2_PI_2, theta)) {
        theta = sub_f64(theta, F2_PI_2);
        sign_factor = -1.0;
    }
    else {
        sign_factor = 1.0;
    }
    
    angle = trig_angles[0];

    // Iterate
    for (j=1; j<=CORDIC_TRIG_ITERATIONS; j++) {
        sigma = ltZero(theta) ? -1.0 : 1.0;

        factor = mulds(poweroftwo, sigma);

        c2 = sub_f64(c, mul_f64(factor, s));
        s2 = add_f64(mul_f64(factor, c), s);

        c = c2;
        s = s2;

        // Update the remaining angle
        theta = sub_f64(theta, mulds(angle, sigma));

        poweroftwo = mulds(poweroftwo, 0.5);

        // Update the angle from table, or eventually by just dividing by two
        angle = CORDIC_ANGLES_LENGTH < j+1 ? mulds(angle, 0.5) : trig_angles[j];
    }

    // Adjust length of output vector to be [cos(beta), sin(beta)]

    // KPROD is essentially constant after a certain point, so if N is
    // large, just take the last available value.
    if (0 < CORDIC_TRIG_ITERATIONS) {
        c = mul_f64(c, trig_kprod[ min(CORDIC_TRIG_ITERATIONS, CORDIC_KPROD_LENGTH) - 1 ]);
        s = mul_f64(s, trig_kprod[ min(CORDIC_TRIG_ITERATIONS, CORDIC_KPROD_LENGTH) - 1 ]);
    }
    
    //  Adjust for possible sign change because angle was originally not in quadrant 1 or 4.
    c = mulds(c, sign_factor);
    s = mulds(s, sign_factor);

    return float4(s, c);
}

// Arc tangent iteration
float2 atan2_iterate(float2 y, float2 x) {
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

    if (ltZero(x1) && ltZero(y1)) {
        x1 = -x1;
        y1 = -y1;
    }

    if (ltZero(x1)) {
        x1 = -x1;
        sign_factor = -1.0;
    }
    else if (ltZero(y1)) {
        y1 = -y1;
        sign_factor = -1.0;
    }
    else {
        sign_factor = 1.0;
    }

    for (j=1; j<=CORDIC_TRIG_ITERATIONS; j++) {
         sigma = le(y1, F2_ZERO) ? 1.0 : -1.0;

         angle = j <= CORDIC_ANGLES_LENGTH ? trig_angles[j-1] : mulds(angle, 0.5);

         x2 = sub_f64(x1, mulds(mul_f64(poweroftwo, y1), sigma));
         y2 = add_f64(y1, mulds(mul_f64(poweroftwo, x1), sigma));
         theta = sub_f64(theta, mulds(angle, sigma));

         x1 = x2;
         y1 = y2;

         poweroftwo = mulds(poweroftwo, 0.5);
     }

     return mulds(theta, sign_factor);
}

float2 exp_iterate2(float2 a) {
    float2 r = F2_ONE;
    float2 f = F2_ONE;
    int i;
    
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        f = mul_f64(f, div_f64(a, flt2(i + 1)));
        r = add_f64(r, f);
    }
    
    return r;
}

// Exponential function iteration
float2 exp_iterate(float2 a) {
    float2 ai;
    float2 fx = F2_ONE;
    int i;
    float2 poweroftwo = flt2(0.5);
    float2 w[CORDIC_LOGEXP_ITERATIONS];
    int x_int;
    float2 z;
    
    x_int = (int) floor(a.x);
    
    // Determine the weights.
    z = sub_f64(a, flt2(x_int));
    
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        w[i] = 0.0;
        if (lt(poweroftwo, z)) {
            w[i] = F2_ONE;
            z = sub_f64(z, poweroftwo);
        }
        poweroftwo = mulds(poweroftwo, 0.5);
    }
    
    // Calculate products
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        ai = i < CORDIC_LOGEXP_LENGTH ? a[i] : add_f64(F2_ONE, mulds(sub_f64(ai, F2_ONE), 0.5));
        
        if (gtZero(w[i])) {
            fx = mul_f64(fx, ai);
        }
    }
    
    // Perform residual multiplication
    float2 z12 = mulds(z, 0.5);
    float2 z13 = mul_f64(z, F2_1_3);
    float2 z14 = mulds(z, 0.25);
    // fx = fx * ( 1.0 + z * ( 1.0 + z / 2.0 * ( 1.0 + z / 3.0 * ( 1.0 + z / 4.0 ))));
    fx = mul_f64(fx, add_f64(F2_ONE, mul_f64(z, add_f64(F2_ONE, mul_f64(z12, add_f64(F2_ONE, mul_f64(z13, add_f64(F2_ONE, z14))))))));

    // Account for factor EXP(X_INT).
    if (x_int < 0) {
        for (i=1; i<=-x_int; i++) {
            fx = mul_f64(fx, F2_1_E);
        }
    }
    else {
        for (i=1; i<=x_int; i++) {
            fx = mul_f64(fx, F2_E);
        }
    }
    
    return fx;
}

// Natural logarithm iteration
float2 log_iterate(float2 a) {
    float2 x = a;
    float2 ai;
    int i;
    int k = 0;
    float2 poweroftwo = flt2(0.5);
    float2 w[CORDIC_LOGEXP_ITERATIONS];
    
    if (le(x, 0.0)) return NAN;
    
    while (le(F2_E, x)) {
        k++;
        x = mul_f64(x, F2_1_E);
    }
    
    while (lt(x, F2_ONE)) {
        k--;
        x = mul_f64(x, F2_E);
    }
    
    // Determine the weights.
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        w[i] = 0.0;
        
        if (i < CORDIC_LOGEXP_LENGTH) {
            ai = logexp[i];
        }
        else {
            ai = add_f64(mulds(sub_f64(ai, F2_ONE), 0.5), F2_ONE);
        }
        
        if (lt(ai, x)) {
            w[i] = F2_ONE;
            x = div_f64(x, ai);
        }
    }
    
    sub_f64(x, F2_ONE);
    
    float2 x12 = mulds(x, 0.5);
    float2 x13 = mul_f64(x, F2_1_3);
    float2 x14 = mulds(x, 0.25);
    // x = x * ( 1.0 - ( x / 2.0 ) * ( 1.0 + ( x / 3.0 ) * ( 1.0 -   x / 4.0 )));
    x = mul_f64(x, sub_f64(1.0, mul_f64(x12, add_f64(F2_ONE, mul_f64(x13, sub_f64(F2_ONE, x14))))));

    // Assemble
    for (i=0; i<CORDIC_LOGEXP_ITERATIONS; i++) {
        x = add_f64(x, mul_f64(w[i], poweroftwo));
        poweroftwo = mulds(poweroftwo, 0.5);
    }
    
    return add_f64(x, flt2(k));
}

