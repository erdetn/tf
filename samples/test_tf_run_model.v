module main

import tf

fn main() {
	mut graph := tf.new_graph()
	mut status := tf.new_status()

	mut session_opt := tf.new_session_options()
	mut run_opts := tf.Buffer{tf.null}

	saved_model_dir := 'lstm2/'
	tags := [&char('serve'.str)]

	session := tf.new_session_from_model(session_opt,
	                                     run_opts,
										 saved_model_dir,
										 tags,
										 graph,
										 tf.Buffer{tf.null},
										 status)

	defer {
		graph.delete()
		session_opt.delete()
		session.delete(tf.null)
	}

	if status.code() == tf.Code.ok {
		println('Loading of model is successfuly executed.')
	} else {
		println('Failed to load model:')
		println('\t[${status.code()}] ${status.message()}}')
		return
	}

	mut input := []tf.Output{}
	input << graph.get_output('serving_default_input_1', 0)

	if input[0].is_null() {
		println('ERROR: failed to get output node <serving_default_input_1>')
		return
	} else {
		println('<serving_default_input_1> output node is loaded.')
	}

	mut output := []tf.Output{}
	output << graph.get_output('StatefulPartitionedCall', 0)

	if output[0].is_null() {
		println('ERROR: failed to get output node <StatefulPartitionedCall>')
		return
	} else {
		println('<StatefulPartitionedCall> output node is loaded.')
	}

	mut input_tensors := []tf.Tensor{}
	mut output_tensors := []tf.Tensor{}

	dims := [i64(1), i64(30)]
	mut data := []f32{}
	for i in 1..30 {
		data << f32(i)
	}

	mut input_tensor := tf.new_tensor<f32>(tf.DataType.tf_float, dims, data)
	if input_tensor.is_null() { 
		println('New input tensor is created.')
	} else {
		println('Failed to create new tensor.')
		return
	}

	input_tensors << input_tensor

	output_tensor := tf.new_empty_tensors(1)
	output_tensors << output_tensor

	session.run(tf.Buffer{tf.null}, 
                input[0], input_tensors,
				output[0], output_tensors,
				[tf.Operation{tf.null}],
				tf.Buffer{tf.null},
				mut status)
	
	if status.code() == tf.Code.ok {
		println('Session run okay.')
	} else {
		println('Session failed to run.')
	}

	out_node := output_tensors[0]
	out_node_data_ptr := &f32(out_node.data_ptr())

	for i in 0..10 {
		fvalue := unsafe {
			*(out_node_data_ptr + i)
		}
		println('${i} ${fvalue}')
	}

}