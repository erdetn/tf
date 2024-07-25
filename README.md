# TensorFlow V Binding
V language binding for TensorFlow

This README provides an overview of how to use the TensorFlow V binding to perform a simple addition operation. The example code demonstrates creating tensors, defining a computation graph, and executing a session to obtain the result.

## Prerequisites
Ensure you have the following installed:
* V programming language
* TensorFlow library. Check this [LINK](https://www.tensorflow.org/install/lang_c)

## Code overview
The following code exanmple initializes TensorFlow components, creates tensors, defines operations, and executes a session to perform the addition of two integers.

1. Initialize Status and Graph:
```v
status := tf.Status.new()
graph := tf.Graph.new()
```

2. Create Tensor Values:
```v
a_val := &TensorI32{
    value: 10
}
b_val := &TensorI32{
    value: 20
}
```
3. Create Tensors from Values:
```v
a := tf.Tensor.new(a_val)
b := tf.Tensor.new(b_val)
```

4. Print Tensor Values:
```v
ai := *(&i32(a.ptr()))
bi := *(&i32(b.ptr()))
println('${ai} ${bi}')
```

5. Define Placeholders in the Graph:
```v
desc_a := graph.new_operation('Placeholder', 'a')
desc_a.set_type(.int32)
op_a := desc_a.finish_operation(status)

desc_b := graph.new_operation('Placeholder', 'b')
desc_b.set_type(.int32)
op_b := desc_b.finish_operation(status)
```

6. Define Addition Operation:
```v
desc_add := graph.new_operation('Add', 'd')
desc_add.set_type(.int32)
desc_add.add_input(in_a)
desc_add.add_input(in_b)
op_add := desc_add.finish_operation(status)
output := *op_add.output(0)
```

7.Create and Run the Session:
```v
sess_opts := tf.SessionOptions.new()
session := graph.new_session(sess_opts, status)

output_value := []&tf.Tensor{len: 1, init: &tf.Tensor(unsafe { nil })}

session.run(tf.null, inputs, input_tensors[..], [output], output_value, [], tf.null, status)
```

8.Print the Result:
```v
if !tf.is_null(output_value[0]) {
    result := *(&i32(output_value[0].ptr()))
    print('Result: ${result}\n')
} else {
    print('Output tensor is null.\n')
}
```

9. Clean Up Resources:
```v
a.delete()
b.delete()
output_value[0].delete()
graph.delete()
session.delete(status)
sess_opts.delete()
status.delete()
```
10. Running the Code

To run the code, compile and execute it using the V compiler:
```sh
v run main.v
```
This will output the result of the addition operation, demonstrating the basic usage of TensorFlow with the V language.

Check example `ex4.v` by running
```sh
v run examples/ex4.v
```

-----------

The `TensorI32` struct is an implementation of the `ITensor` interface, designed to encapsulate a 32-bit integer tensor. This documentation provides an overview of its fields and methods, detailing how to interact with and use the `TensorI32` struct in the V programming language.

#### Struct definition
```v
struct TensorI32 {
mut:
    value i32
}
```
* `value` (i32): The integer value that the tensor encapsulates. This field is mutable, allowing it to be modified after initialization.

#### Method `data() voidptr`
```v
fn (t &TensorI32) data() voidptr {
    return unsafe {
        voidptr(&(t.value))
    }
}
```
* Returns: A pointer to the tensor's data.
* Description: This method provides access to the raw data of the tensor. It returns a void pointer to the memory location of the tensor's value.

#### Method `len() usize`
```v
fn (t &TensorI32) len() usize {
    return sizeof(t.value)
}
```
* Returns: The size of the tensor's data in bytes.
* Description: This method returns the size of the tensor's data, which is equivalent to the size of a 32-bit integer.

#### Method `dtype() tf.DataType`
```v
fn (t &TensorI32) dtype() tf.DataType {
    return .int32
}
```
* Returns: The data type of the tensor.
* Description: This method returns the data type of the tensor, which is `tf.DataType.int32` for `TensorI32`.

#### Method `shape() tf.Shape`
```v
fn (t &TensorI32) shape() tf.Shape {
    return tf.shape(1)
}
```
* Returns: The shape of the tensor.
* Description: This method returns the shape of the tensor. For `TensorI32`, it returns a shape with a single dimension of size 1.

#### method `str() string`
```v
fn (t &TensorI32) str() string {
    val := *(&i32(t.data()))
    mut str := '{'
    str += 'value: ${t.value}, '
    str += 'data: ${t.data()} [${val}], '
    str += 'len: ${t.len()}, '
    str += 'dtype: ${t.dtype()}, '
    str += 'shape: ${t.shape()}}'
    return str
}
```
* Returns: A string representation of the tensor.
* Description: This method returns a string representation of the tensor, including its value, data pointer, length, data type, and shape. It provides a comprehensive view of the tensor's properties for debugging and logging purposes.

### Example of using `TensorI32`
```v
fn main() {
    tensor := &TensorI32{
        value: 10
    }

    println('Tensor Data Pointer: ${tensor.data()}')
    println('Tensor Length: ${tensor.len()}')
    println('Tensor Data Type: ${tensor.dtype()}')
    println('Tensor Shape: ${tensor.shape()}')
    println('Tensor String Representation: ${tensor.str()}')
}
```


-------------
WARNING: The API defined in this package is not stable and can change without notice.
The API is subject to change and may break at any time. 

Note: This is test using TF version "2.15.0"
