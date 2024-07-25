module tf

struct C.TF_Tensor {
}

pub type Tensor = C.TF_Tensor

fn no_op_deallocator(data voidptr, a u32, b voidptr) {}

fn C.TF_NewTensor(data_type int, dims &i64, num_dims int, data voidptr, len u32, deallocator fn (voidptr, u32, voidptr), arg voidptr) &C.TF_Tensor
pub fn new_tensor(t &ITensor) &Tensor {
	shape := (*t).shape()
	println(t)
	return unsafe {
		&Tensor(C.TF_NewTensor(int((*t).dtype()), &i64(shape.ptr()), shape.len(),
			(*t).data(), (*t).len(), no_op_deallocator, nil))
	}
}

fn C.TF_AllocateTensor(int, &i64, int, u32) &C.TF_Tensor
pub fn allocate_tensor(data_type DataType, shape Shape) &Tensor {
	mut data_len := u32(data_type.size())
	mut num_elements := u32(1)
	for i := 0; i < shape.len(); i++ {
		u := shape.get(i) or { 1 }
		num_elements *= u32(u)
	}
	data_len *= num_elements
	return unsafe {
		&Tensor(C.TF_AllocateTensor(int(data_type), &i64(shape.ptr()), shape.len(), data_len))
	}
}

fn C.TF_TensorMaybeMove(&C.TF_Tensor) &C.TF_Tensor
pub fn (t &Tensor) move() &Tensor {
	return unsafe { &Tensor(C.TF_TensorMaybeMove(t)) }
}

fn C.TF_DeleteTensor(&C.TF_Tensor)
pub fn (t &Tensor) delete() {
	C.TF_DeleteTensor(t)
}

fn C.TF_TensorIsAligned(&C.TF_Tensor) bool
pub fn (t &Tensor) is_aligned() bool {
	return C.TF_TensorIsAligned(t)
}

fn C.TF_TensorType(&C.TF_Tensor) int
pub fn (t &Tensor) data_type() DataType {
	return unsafe {
		DataType(C.TF_TensorType(t))
	}
}

fn C.TF_NumDims(&C.TF_Tensor) int
fn (t &Tensor) num_dims() int {
	return int(C.TF_NumDims(t))
}

fn C.TF_Dim(&C.TF_Tensor, int) i64
fn (t &Tensor) dim(index int) i64 {
	return i64(C.TF_Dim(t, index))
}

fn C.TF_SetShape(t &C.TF_Tensor, dims &C.i64, num_dims int)
pub fn (t &Tensor) set_shape(shape Shape) {
	unsafe {
		C.TF_SetShape(t, &C.i64(shape.ptr()), int(shape.len()))
	}
}

pub fn (t &Tensor) shape() Shape {
	mut shape := Shape{}
	num_dims := t.num_dims()

	if num_dims == 0 {
		return shape
	}

	for i := 0; i < num_dims; i++ {
		shape.add(int(t.dim(i)))
	}
	return shape
}

pub fn (t &Tensor) data_len() usize {
	unit_sz := t.data_type().size()
	shape := t.shape()
	mut dl := usize(1)
	for i := 0; i < shape.len(); i++ {
		u := shape.get(i) or { 1 }
		dl *= usize(u)
	}
	dl *= unit_sz
	return dl
}

fn C.TF_TensorByteSize(&C.TF_Tensor) u32
pub fn (t &Tensor) bytesize() u32 {
	return u32(C.TF_TensorByteSize(t))
}

fn C.TF_TensorData(&C.TF_Tensor) voidptr
pub fn (t &Tensor) ptr() voidptr {
	return C.TF_TensorData(t)
}

fn C.TF_TensorElementCount(&C.TF_Tensor) i64
pub fn (t &Tensor) elements_count() i64 {
	return C.TF_TensorElementCount(t)
}
