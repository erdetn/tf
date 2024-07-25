module tf

struct C.TF_OperationDescription {}

pub type OperationDescription = C.TF_OperationDescription

fn C.TF_NewOperation(g &C.TF_Graph, op_type charptr, op_name charptr) &C.TF_OperationDescription
pub fn (g &Graph) new_operation(op_type string, op_name string) &OperationDescription {
	return unsafe {
		&OperationDescription(C.TF_NewOperation(g, &char(op_type.str), &char(op_name.str)))
	}
}

fn C.TF_SetDevice(desc &C.TF_OperationDescription, device charptr)
pub fn (op &OperationDescription) set_device(device string) {
	unsafe {
		C.TF_SetDevice(op, charptr(device.str))
	}
}

fn C.TF_AddInput(desc &C.TF_OperationDescription, input C.TF_Output)
pub fn (op &OperationDescription) add_input(input Output) {
	unsafe {
		C.TF_AddInput(op, input)
	}
}

fn C.TF_AddInputList(desc &C.TF_OperationDescription, inputs &C.TF_Output, num_inputs int)
pub fn (op &OperationDescription) add_inputs(inputs []Output) {
	unsafe {
		C.TF_AddInputList(op, &inputs[0], inputs.len)
	}
}

fn C.TF_AddControlInput(desc &C.TF_OperationDescription, input &C.TF_Operation)
pub fn (op &OperationDescription) add_control_input(input &Operation) {
	C.TF_AddControlInput(op, input)
}

fn C.TF_ColocateWith(desc &C.TF_OperationDescription, op &C.TF_Operation)
pub fn (op &OperationDescription) co_locate_with(operation &Operation) {
	C.TF_ColocateWith(op, operation)
}

fn C.TF_FinishOperation(desc &C.TF_OperationDescription, status &C.TF_Status) &C.TF_Operation
pub fn (od &OperationDescription) finish_operation(status &Status) &Operation {
	return unsafe { &Operation(C.TF_FinishOperation(od, status)) }
}

fn C.TF_SetAttrTensor(desc &C.TF_OperationDescription, attr_name &char, value &C.TF_Tensor, status &C.TF_Status)
pub fn (od &OperationDescription) set_attr_tensor(attr_name string, value &Tensor, status &Status) {
	unsafe {
		C.TF_SetAttrTensor(od, &char(attr_name.str), value, status)
	}
}

fn C.TF_SetAttrType(desc &C.TF_OperationDescription, attr_name charptr, value C.TF_DataType)
pub fn (od &OperationDescription) set_type(value DataType) {
	attr_name := 'dtype'
	unsafe {
		C.TF_SetAttrType(od, charptr(attr_name.str), C.TF_DataType(value))
	}
}

fn C.TF_OperationName(oper &C.TF_Operation) &char
pub fn (op &Operation) name() string {
	return unsafe {
		cstring_to_vstring(C.TF_OperationName(op))
	}
}

fn C.TF_OperationOpType(oper &C.TF_Operation) &char
pub fn (op &Operation) optype() string {
	return unsafe {
		cstring_to_vstring(C.TF_OperationOpType(op))
	}
}

fn C.TF_OperationDevice(oper &C.TF_Operation) &char
pub fn (op &Operation) device() string {
	return unsafe {
		cstring_to_vstring(C.TF_OperationDevice(op))
	}
}

fn C.TF_OperationNumOutputs(oper &C.TF_Operation) int
pub fn (op &Operation) num_outputs() int {
	return unsafe {
		(C.TF_OperationNumOutputs(op))
	}
}

struct C.TF_Operation {}

pub type Operation = C.TF_Operation

struct C.TF_Input {
pub:
	oper &C.TF_Operation
	// The index of the input within oper
	index int
}

pub type Input = C.TF_Input

pub struct C.TF_Output {
pub:
	oper &C.TF_Operation
	// The index of the input within oper
	index int
}

pub type Output = C.TF_Output

pub fn (out &Output) operation() &Operation {
	return (*out).oper
}

pub fn new_output() &Output {
	return unsafe { &Output(malloc(sizeof(Output))) }
}

struct C.TF_Function {}

pub type Function = C.TF_Function

struct C.TF_FunctionOptions {}

pub type FunctionOptions = C.TF_FunctionOptions

pub fn (op &Operation) output(index int) &Output {
	return unsafe {
		&Output{
			oper: op
			index: index
		}
	}
}

pub fn (op &Operation) input(index int) &Input {
	return unsafe {
		&Input{
			oper: op
			index: index
		}
	}
}
