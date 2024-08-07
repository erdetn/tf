module tf

struct C.TF_Buffer {
pub mut:
	data             voidptr
	length           usize
	data_deallocator fn (data voidptr, length usize)
}

pub type Buffer = C.TF_Buffer

fn C.TF_NewBuffer() &C.TF_Buffer
fn C.TF_NewBufferFromString(&char, u64) &C.TF_Buffer
fn C.TF_DeleteBuffer(&C.TF_Buffer)
fn C.TF_GetBuffer(&C.TF_Buffer) C.TF_Buffer

pub fn new_buffer() &Buffer {
	return unsafe {
		&Buffer(C.TF_NewBuffer())
	}
}

pub fn Buffer.new() &Buffer {
	return unsafe {
		&Buffer(C.TF_NewBuffer())
	}
}

pub fn new_buffer_from_string(buffer string) &Buffer {
	return unsafe {
		&Buffer(C.TF_NewBufferFromString(&char(buffer.str), buffer.len))
	}
}

pub fn Buffer.new_from_string(buffer string) &Buffer {
	return new_buffer_from_string(buffer)
}

pub fn (b &Buffer) delete() {
	C.TF_DeleteBuffer(b)
}

// Parsing a serialized TensorProto into a TF_Tensor.
fn C.TF_TensorFromProto(from &C.TF_Buffer, to &C.TF_Tensor, s &C.TF_Status)
pub fn (b &Buffer) tensor(status &Status) &Tensor {
	mut t := allocate_tensor(.str, shape(int(b.length)))
	C.TF_TensorFromProto(b, t, status)
	return t
}
