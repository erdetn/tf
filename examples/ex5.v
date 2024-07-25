module main

import tf

fn main() {
	status := tf.new_status()

	graph := tf.new_graph()

	op_desc := graph.new_operation('Const', 'my_const')
	op_desc.set_type(.float)
	dump(op_desc)
	tensor := tf.allocate_tensor(.float, tf.shape(2))
	dump(tensor)
	unsafe {
		ptr := &f32(tensor.ptr())
		*ptr = f32(3.14)
		*(ptr + 4) = f32(6.28)

		fptr := &f32(tensor.ptr())
		f1 := f32(*fptr)
		f2 := f32(*(fptr + 4))
		dump(f1)
		dump(f2)
	}
	op_desc.set_attr_tensor('value', tensor, status)
	if status.code() != .ok {
		println(status.message())
	} else {
		print('Tensor set successfully.\n')
	}

	op_desc.finish_operation(status)
	if status.code() != .ok {
		println(status.message())
	} else {
		print('Constant operation created successfully.\n')
	}

	tensor.delete()
	status.delete()
	graph.delete()
	println('done')
}
