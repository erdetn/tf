module tf

struct C.TF_Graph {}

pub type Graph = C.TF_Graph

fn C.TF_NewGraph() &C.TF_Graph
fn C.TF_DeleteGraph(&C.TF_Graph)

pub fn new_graph() &Graph {
	return unsafe { &Graph(C.TF_NewGraph()) }
}

pub fn (g &Graph) delete() {
	C.TF_DeleteGraph(g)
}

fn C.TF_GraphOperationByName(&C.TF_Graph, &char) &C.TF_Operation

pub fn (g &Graph) get_operation_by_name(operation_name string) &Operation {
	return unsafe { &Operation(C.TF_GraphOperationByName(g, &char(operation_name.str))) }
}

pub fn (g &Graph) get_output(operation_name string, index int) &Output {
	return unsafe {
		&Output{
			oper: C.TF_GraphOperationByName(g, &char(operation_name.str))
			index: index
		}
	}
}

fn C.TF_GraphNextOperation(g &C.TF_Graph, pos &usize) &C.TF_Operation
pub fn (g &Graph) next_operation() (&Operation, usize) {
	mut pos := usize(0)
	unsafe {
		op := C.TF_GraphNextOperation(g, &pos)
		return op, pos
	}
}

fn C.TF_GraphSetTensorShape(g &C.TF_Graph, output C.TF_Output, dims &i64, num_dims int, status &C.TF_Status)
pub fn (g &Graph) set_tensor_shape(output Output, shape Shape, status &Status) {
	unsafe {
		C.TF_GraphSetTensorShape(g, output, &i64(shape.ptr()), shape.len(), status)
	}
}

fn C.TF_GraphGetTensorNumDims(g &C.TF_Graph, out C.TF_Output, s &C.TF_Status) int
pub fn (g &Graph) get_tensor_num_dims(output Output, status &Status) int {
	return unsafe {
		int(C.TF_GraphGetTensorNumDims(g, output, status))
	}
}

fn C.TF_GraphGetTensorShape(g &C.TF_Graph, out C.TF_Output, dims &i64, num_dims int, status &C.TF_Status)
pub fn (g &Graph) get_tensor_shape(output Output, status &Status) Shape {
	mut n := g.get_tensor_num_dims(output, status)
	if n < 1 {
		return Shape{}
	}

	mut shape := Shape{}
	mut dim := i64(0)
	for i := 0; i < n; i++ {
		C.TF_GraphGetTensorShape(g, output, &dim, i, status)
		shape.shape << dim
	}
	return shape
}
