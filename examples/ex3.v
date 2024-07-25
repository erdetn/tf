module main

import tf

fn print_status(status &tf.Status) {
	if status.code() != .ok {
		print('ERROR: ${status.message()}\n')
	} else {
		print('SUCCESS: ${status.message()}\n')
	}
}

fn create_tensor_from_proto() {
	tensor_proto_data := 'YourSerializedTensorProtoData'

	buff := tf.new_buffer_from_string(tensor_proto_data)

	st := tf.new_status()

	tensor := buff.tensor(st)

	print_status(st)
	dump(tensor)
	dump(tensor.ptr())

	unsafe {
		s1 := cstring_to_vstring(&char(tensor.ptr()))
		println(s1)
	}
	// Use the tensor as needed
	if st.code() == .ok && tensor != tf.null {
		print('Tensor created successfully\n')
	}

	// Clean up
	unsafe {
		if tensor != tf.null {
			tensor.delete()
		}
	}
	buff.delete()
	st.delete()
}

fn main() {
	create_tensor_from_proto()
}
