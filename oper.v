module tf

struct C.TF_OperationDescription {}

pub type OperationDescription = C.TF_OperationDescription

struct C.TF_Operation {}

pub type Operation = C.TF_Operation

fn C.TF_NewOperation(g &C.TF_Graph, op_type charptr, op_name charptr) &C.TF_OperationDescription
pub fn (g &Graph) new_operation(op_type string, op_name string) &OperationDescription {
	return unsafe {
		&OperationDescription(C.TF_NewOperation(g, &char(op_type.str), &char(op_name.str)))
	}
}

fn C.TF_NewOperationLocked(g &C.TF_Graph, op_type &char, oper_name &char) &C.TF_OperationDescription
pub fn (g &Graph) new_operation_locked(op_type string, op_name string) &OperationDescription {
	return unsafe {
		&OperationDescription(C.TF_NewOperationLocked(g, &char(op_type.str), &char(op_name.str)))
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

fn C.TF_FinishOperationLocked(desc &C.TF_OperationDescription, status &C.TF_Status) &C.TF_Operation
pub fn (od &OperationDescription) finished_operation_locked(status &Status) &Operation {
	return unsafe {
		&Operation(C.TF_FinishOperationLocked(od, status))
	}
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

fn C.TF_OperationOutputListLength(oper &C.TF_Operation, arg_name &char, status &C.TF_Status) int
pub fn (op &Operation) output_list_length(arg_name string, status &Status) int {
	return C.TF_OperationOutputListLength(op, &char(arg_name.str), status)
}

fn C.TF_OperationInputListLength(oper &C.TF_Operation, arg_name &char, status &C.TF_Status) int
pub fn (op &Operation) input_list_length(arg_name string, status &Status) int {
	return C.TF_OperationInputListLength(op, &char(arg_name.str), status)
}

struct C.TF_Input {
pub:
	oper &C.TF_Operation
	// The index of the input within oper
	index int
}

pub type Input = C.TF_Input

fn C.TF_OperationInputType(oper_in C.TF_Input) int
pub fn (inp &Input) dtype() DataType {
	return unsafe {
		DataType(C.TF_OperationInputType(*inp))
	}
}

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

fn C.TF_OperationOutputType(oper_out C.TF_Output) int
pub fn (out &Output) dtype() DataType {
	return unsafe {
		DataType(C.TF_OperationOutputType(*out))
	}
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
