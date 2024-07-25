module tf

pub interface ITensor {
	data() voidptr
	len() usize // in bytes data[0, len-1]
	dtype() DataType
	shape() Shape
}

// Example of implementation of ITensor
// (DO NOT UNCOMMENT BELOW CODE SNIPPETS)
// ------------------ TensorI32 ------------------- //
// TensorI32 should match with ITensor
// struct TensorI32 {
// mut:
// 	value i32
// }

// fn (t &TensorI32)data() voidptr {
// 	return unsafe {
// 		voidptr(&(t.value))
// 	}
// }

// fn (t &TensorI32)len() usize {
// 	return sizeof(t.value)
// }

// fn (t &TensorI32)dtype() tf.DataType {
// 	return .int32
// }

// fn (t &TensorI32)shape() tf.Shape {
// 	return tf.shape(1)
// }

// fn (t &TensorI32)str() string {
// 	val := *(&i32(t.data()))
// 	mut str := "{"
// 	str += "value: ${t.value}, "
// 	str += "data: ${t.data()} [${val}], "
// 	str += "len: ${t.len()}, "
// 	str += "dtype: ${t.dtype()}, "
// 	str += "shape: ${t.shape()}}"
// 	return str
// }
// -------------------------------------------------- //
