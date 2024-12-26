
This project is emulating 64 bit floating point real and complex numbers in Metal.

# Xcode settings

The option **Math Mode** under *Metal Compiler - Build Options* must be set to **safe** to ensure
IEEE conformity of floating point numbers.

# Swift Part
## Construct 64 bit floating point numbers (Float2)

The Swift datatype **Float2** is an alias for the `SIMD2<Float32>` datatype. The following constructors are available:

> Float2()  
> Float2(Double)  
> Float2(Float)  

The assignment of literal numeric values is supported:

`let myFlt2: Float2 = 2.0`

## Convert a 64 bit floating point number to Double

The datatype Double is extended by a constructor to init a Double value with a Float2 value:

`let myDbl: Double = Double(myFlt2)`

## Construct 64 bit complex numbers (Complex2)

The Swift datatype **Complex2** is an alias for the `SIMD4<Float32>` datatype. The following constructors

> Complex2()                  // 0  
> Complex2(Double)            // Init real part. Imaginary part is set to 0  
> Complex2(Double, Double)    // Init real and imaginary part  
> Complex2(ComplexDouble)  
> Complex2(Float2)  
> Complex2(Int)  

The assignment of literal numeric values is supported:

`let myCplx2: Complex2 = 2.0`

## Convert a 64 bit complex number to ComplexDouble

The datatype ComplexDouble (an alias for Complex<Float64>) is extended by a constructor which accepts a Complex2 value:

`let myCplx: ComplexDouble = ComplexDouble(myCplx2)`


# Metal part
## 64 bit real floating point numbers

The class f64 is used to define 64 bit real floating point variables in Metal. A 64 bit floating point number is internally stored as
a float2 vector element "v" in a f64 object.

### Constructors

> f64()  
> f64(float)  
> f64(float2)  
> f64(float, float)    // Don't use this constructor, for internal use only  

### Initialize by assigning literal values

Assign a float value to a f64 variable:

`f64 x = 2.0;`

### Accessing / converting f64 objects

> f64 value = 2.0;
> float2 flt2val = value.v;

### Operators

The mathematical operators +, -, \*, / are overloaded to support any combination of f64 and float operands.
The comparison operators ==, !=, \<, \>, \<=, \>= are only supporting f64 operands.

### Mathematical functions

| Function     | Result |
|--------------|--------|
| sqrt(f64)    | Square root |
| pow(f64,int) | Power |
| pow(f64,f64) | Power |      
| exp(f64)     | Exponential |
| log(f64)     | Natural logarithm |
| sin(f64)     | Sine |
| cos(f64)     | Cosine |
| tan(f64)     | Tangent |
| asin(f64)    | Arc sine |
| acos(f64)    | Arc cosine |
| atan(f64)    | Arc tangent |
| atan2(f64,f64) | Arc tangent 2 |

### Other functions

* isZero(f64) - Check if value is zero

### Constants

| Constant | Value  |
|----------|--------|
| f64_pi   | pi     |
| f64_pi2  | pi / 2 |
| f64_log2 | log(2) |


## 64 bit complex floating point numbers

The class c64 is used to define 64 bit complex floating point variables in Metal. A 64 bit complex floating point number is internally stored as
a float4 vector element "v" in a c64 object.

### Constructors

> c64()  
> c64(float)  
> c64(float2)  
> c64(float2, float2)  
> c64(f64)  
> c64(f64, f64)  
> c64(float4)  

### Initialize by assigning literal values

`c64 x = 2.0;`

`c64 x = f64(3.0);`

### Accessing / converting c64 objects

> c64 complexvalue = c64(2.0, 3.0);  
> f64 realpart = complexvalue.real();  
> f64 imagpart = complexvalue.imaginary();  
> float2 real_part = complexvalue.v.xy  
> float2 imag_part = complexvalue.v.zw  
> float4 flt4value = complexvalue.v  

### Operators

The mathematical operators +, -, \*, / are overloaded to support any combination of c64 with f64 and float operands.
The comparison operators ==, != are only supporting c64 operands.

### Mathematical functions

| Function     | Result |
|--------------|--------|
| sqr(c64)     | Square |
| norm(c64)    | real \* real + imag \* imag |
| abs(c64)     | sqrt(norm(c64)) |

### Other functions

* isZero(c64) - Check if value is zero
* c64.real() - Return real part
* c64.imaginary() - Return imag part
