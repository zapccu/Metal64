
The Swift class MetalCompute provides an easy to use interface for passing calculations to a Metal
compute kernel.

# Swift part
## Create a MetalCompute object

`let mc = MetalCompute("myKernelFnc")`

The only parameter of the MetalCompute constructor is the name of the Metal compute kernel function.

## Pass parameters to Metal compute kernel function

```
// Create an array of 64 bit floating point values as input to the compute function
let cnt: Int = 10000
let arr: [Float2] = Array(repeating: Float2(Double.pi), cnt)

// A Float2 value to be added to the array by the compute function
let x: Float2 = 2.0

// Create an array of 64 bit floating point values to store the results
var result: [Float2] = Array(repeating: Float2(0.0), cnt)

// Add parameters to MetalCompute object
do {
   try mc.AddBuffer(arr);
   mc.AddValue(x)

   // Execute compute kernel
   if let result = mc.compute(Float2()) {
      print("Success")
   }
   else {
      print("Calculation failed")
   }
}
catch {
   print("Error")
}
```

# Metal part


