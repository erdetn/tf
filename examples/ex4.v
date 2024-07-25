module main 

import tf 

// ------------------ TensorI32 ------------------- //
// TensorI32 should match with ITensor
struct TensorI32 {
mut:
	value i32  
}

fn (t TensorI32)data() voidptr {
	return unsafe {
		voidptr(&(t.value))
	}
}

fn (t TensorI32)len() usize {
	return sizeof(t.value)
}

fn (t TensorI32)dtype() tf.DataType {
	return .int32
}

fn (t TensorI32)shape() tf.Shape {
	return tf.shape(1)
}
// -------------------------------------------------- //

fn main() {
	status := tf.new_status()
	graph := tf.new_graph()

	shape := tf.shape(1)

	a_val := TensorI32{value: 10}
	b_val := TensorI32{value: 20}

	a := tf.new_tensor(.int32, shape, [a_val])!
	b := tf.new_tensor(.int32, shape, [b_val])!
	input_tensors := [a, b]!

	desc_a := graph.new_operation("Placeholder", "a")
	desc_a.set_type(.int32)
	op_a := desc_a.finish_operation(status)

	desc_b := graph.new_operation("Placeholder", "b")
	desc_b.set_type( .int32)
	op_b := desc_b.finish_operation(status)
	
	in_a := *op_a.output(0)
	in_b := *op_b.output(0)

	inputs := [in_a, in_b]

	desc_add := graph.new_operation("Add", "d")
	desc_add.set_type(.int32)
	desc_add.add_input(in_a)
	desc_add.add_input(in_b)
	op_add := desc_add.finish_operation(status)
	output := *op_add.output(0)

    sess_opts := tf.new_session_options()
	session := graph.new_session(sess_opts, status)

	
	output_value := []&tf.Tensor{len: 1, init: &tf.Tensor(voidptr(0))}

	session.run(tf.null, 
				inputs, input_tensors[..],
				[output], output_value,
				[], tf.null, status)

	if !tf.is_null(output_value[0]) {
		result := *(&i32(output_value[0].ptr()))
		print("Result: ${result}\n")
	} else {
		print("Output tensor is null.\n")
	}
				
    a.delete() 
    b.delete()
    output_value[0].delete() 
    graph.delete() 
    session.delete(status) 
    sess_opts.delete() 
    status.delete()
}