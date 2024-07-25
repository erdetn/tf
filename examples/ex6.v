module main

import tf

const num_inputs = 1
const num_outputs = 1


// ------------------ TensorArrayF32 ------------------- //
struct TensorArrayF32 {
mut:
	buff []f32
}

fn (t &TensorArrayF32)data() voidptr {
	return unsafe {
		voidptr(&(t.buff[0]))
	}
}

fn (t &TensorArrayF32)len() usize {
	return sizeof(t.buff[0])*usize(t.buff.len)
}

fn (t &TensorArrayF32)dtype() tf.DataType {
	return .float
}

fn (t &TensorArrayF32)shape() tf.Shape {
	return tf.shape(1, t.buff.len)
}
// -------------------------------------------------- //

fn main() {
	mut graph := tf.new_graph()
	mut status := tf.new_status()

	mut session_opt := tf.new_session_options()
	mut run_opts := &tf.Buffer(tf.null)

	saved_model_dir := "tmpf32/"
	tags := ["serve"]

	session := tf.new_session_from_model(session_opt,
	                                     run_opts,
										 saved_model_dir,
										 tags,
										 graph,
										 &tf.Buffer(0),
										 status)

	defer {
		graph.delete()
		session_opt.delete()
		session.delete(status)
	}

	if status.code() == .ok {
		println('Loading of model is successfuly executed.')
	} else {
		println('Failed to load model:')
		println('\t[${status.code()}] ${status.message()}}')
		return
	}
	dump(status) 

	mut input := []tf.Output{len: num_inputs}
	input[0] = tf.Output{
		oper: graph.get_operation_by_name("serving_default_input_1")
		index: 0
	}

	if input[0].oper == tf.null {
		println('ERROR: failed to get output node <serving_default_input_1>')
		return
	} else {
		println('<serving_default_input_1> output node is loaded.')
	}

	mut output := []tf.Output{len: num_outputs}
	output[0] = tf.Output{
		oper: graph.get_operation_by_name("StatefulPartitionedCall")
		index: 0
	}

	if output[0].oper == tf.null {
		println('ERROR: failed to get output node <StatefulPartitionedCall>')
		return
	} else {
		println('<StatefulPartitionedCall> output node is loaded.')
	}

	mut in_values := []&tf.Tensor{len: num_inputs, init: &tf.Tensor(0)}
	mut out_values := []&tf.Tensor{len: num_outputs, init: &tf.Tensor(0)}

	mut data := &TensorArrayF32{}
	for i in 0..30 {
		data.buff << f32(i)
	}
	
	int_tensor := tf.new_tensor(data) 

	dump(int_tensor)

	in_values[0] = int_tensor
	dump(in_values[0])

	session.run(&tf.Buffer(tf.null), 
                input, in_values,
				output, out_values,
				[],
				&tf.Buffer(tf.null),
				status)
	
	if status.code() == .ok {
		println('Session run okay.')
	} else {
		println('Session failed to run.')
	}

	out_data_ptr := &f32(out_values[0].ptr())

	for i in 0..10 {
		fvalue := unsafe {
			*(out_data_ptr + i)
		}
		println('${i} ${fvalue}')
	}

	out_tensor := out_values[0]

	println("bytesize:   ${out_tensor.bytesize()}")
	println("shape:      ${out_tensor.shape()} ")
	println("data_type:  ${out_tensor.dtype()} ")
	println("elem_count: ${out_tensor.elements_count()} ")
}