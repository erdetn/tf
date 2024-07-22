// 
module tf

#flag -L /usr/local/lib
#flag -I /usr/local/include
#flag -l tensorflow

#include <tensorflow/c/c_api.h>

pub const null = unsafe { nil }

fn C.TF_Version() &char
pub fn version() string {
	unsafe {
		return C.TF_Version().vstring()
	}
}

/// --------------------------------------------- ///
/// ------------------ Tensor ------------------- ///
/// --------------------------------------------- ///

struct C.TF_Tensor {
}

pub type Tensor = C.TF_Tensor

fn no_op_deallocator(data voidptr, a u32, b voidptr) {}

fn C.TF_NewTensor(data_type int, dims &i64, num_dims int, data voidptr, len u32, deallocator fn (voidptr, u32, voidptr), arg voidptr) &C.TF_Tensor
pub fn new_tensor[T](data_type DataType, dims []i64, buffer []T) !&Tensor {
	if data_type.size() != sizeof(T) {
		return error('data_type.size() is not matching with data type of buffer')
	}
	buff_len := u32((buffer.len) * sizeof(data_type.size()))
	return unsafe {
		&Tensor(C.TF_NewTensor(int(data_type), &i64(dims.data), dims.len, buffer.data,
			buff_len, no_op_deallocator, voidptr(0)))
	}
}

fn C.TF_AllocateTensor(int, &i64, int, u32) &C.TF_Tensor
pub fn allocate_tensor(data_type DataType, dimension []i64) &Tensor {
	mut data_len := u32(data_type.size())
	mut num_elements := u32(1)
	for i := 0; i < dimension.len; i++ {
		num_elements *= u32(dimension[i])
	}
	data_len *= num_elements
	return unsafe {
		&Tensor(C.TF_AllocateTensor(int(data_type), &i64(dimension.data), dimension.len, data_len))
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
pub fn (t &Tensor) num_dims() int {
	return int(C.TF_NumDims(t))
}

fn C.TF_Dim(&C.TF_Tensor, int) i64
fn (t &Tensor) dim(index int) i64 {
	return i64(C.TF_Dim(t, index))
}

pub fn (t &Tensor) dimension() []i64 {
	mut dims := []i64{}
	num_dims := t.num_dims()

	if num_dims == 0 {
		return []i64{}
	}

	for i := 0; i < num_dims; i++ {
		dims << t.dim(i)
	}
	return dims
}

pub fn (t &Tensor) data_len() usize {
	unit_sz := t.data_type().size()
	dims := t.dimension()
	mut dl := usize(1)
	for i := 0; i < dims.len; i++ {
		dl *= usize(dims[i])
	}
	dl *= unit_sz
	return dl
}

fn C.TF_TensorByteSize(&C.TF_Tensor) u32
pub fn (t &Tensor) bytesize() u32 {
	return u32(C.TF_TensorByteSize(t))
}

fn C.TF_TensorData(&C.TF_Tensor) voidptr
pub fn (t &Tensor) dataptr() voidptr {
	return C.TF_TensorData(t)
}

fn C.TF_TensorElementCount(&C.TF_Tensor) i64
pub fn (t &Tensor) elements_count() i64 {
	return C.TF_TensorElementCount(t)
}

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// ------------- SessionOptions ---------------- ///
/// --------------------------------------------- ///
struct C.TF_SessionOptions {}

pub type SessionOptions = C.TF_SessionOptions

fn C.TF_NewSessionOptions() &C.TF_SessionOptions
fn C.TF_SetTarget(&C.TF_SessionOptions, &char)
fn C.TF_SetConfig(&C.TF_SessionOptions, voidptr, u64, &C.TF_Status)
fn C.TF_DeleteSessionOptions(&C.TF_SessionOptions)


pub fn new_session_options() &SessionOptions {
	return unsafe { &SessionOptions(C.TF_NewSessionOptions()) }
}

pub fn (so &SessionOptions) set_target(target string) {
	C.TF_SetTarget(so, &char(target.str))
}

pub fn (so &SessionOptions) delete() {
	C.TF_DeleteSessionOptions(so)
}

pub fn (so &SessionOptions) set_config(proto voidptr, proto_len u64, status &Status) {
	C.TF_SetConfig(so, proto, isize(proto_len), status)
}

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// Input, Output, Function and Operation structs ///
/// --------------------------------------------- ///

struct C.TF_Operation {}

pub type Operation = C.TF_Operation

struct C.TF_Input {}

pub type Input = C.TF_Input

pub struct C.TF_Output {
pub:
	oper  &C.TF_Operation
	index int
}

pub type Output = C.TF_Output

pub fn (out &Output) operation() &Operation {
	return (*out).oper
}

//??
pub fn new_output() &Output {
	return unsafe { &Output(malloc(sizeof(Output))) }
}

//??
pub fn new_output_from_operation(operation &Operation) &Output {
	return unsafe {
		&Output{
			oper: operation
			index: 0
		}
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

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// ---------------- Session -------------------- ///
/// --------------------------------------------- ///
struct C.TF_Session {}

pub type Session = C.TF_Session

fn C.TF_NewSession(&C.TF_Graph, &C.TF_SessionOptions, &C.TF_Status) &C.TF_Session

fn C.TF_CloseSession(&C.TF_Session, &C.TF_Status)

fn C.TF_DeleteSession(&C.TF_Session, &C.TF_Status)


pub fn new_session(graph &Graph, session_options &SessionOptions, status &Status) &Session {
	return unsafe {
		&Session(C.TF_NewSession(graph, session_options, status))
	}
}

fn C.TF_LoadSessionFromSavedModel(&C.TF_SessionOptions, &C.TF_Buffer, &char, &charptr, int, &C.TF_Graph, &C.TF_Buffer, &C.TF_Status) &C.TF_Session
pub fn new_session_from_model(session_options &SessionOptions, run_options &Buffer, export_dir string, tags []string, graph &Graph, meta_graph_def &Buffer, status &Status) &Session {
	mut ctags := []charptr{len: tags.len, init: charptr(0)}

	for i, s in tags {
		ctags[i] = s.str
	}

	return unsafe {
		&Session(C.TF_LoadSessionFromSavedModel(session_options, run_options, &char(export_dir.str),
			charptr(ctags.data), tags.len, graph, meta_graph_def, status))
	}
}

fn C.TF_SessionRun(session &C.TF_Session, run_options &C.TF_Buffer, inputs &C.TF_Output, input_values &&C.TF_Tensor, ninputs int, outputs &C.TF_Output, output_values &&C.TF_Tensor, noutputs int, target_opers &&C.TF_Operation, ntargets int, run_metadata &C.TF_Buffer, status &C.TF_Status)

pub fn (ss &Session) run(buffer &Buffer, inputs []Output, input_tensors []&Tensor, outputs []Output, output_tensors []&Tensor, opers []&Operation, run_metadata &Buffer, status &Status) {
	unsafe {
		C.TF_SessionRun(ss, buffer, &Output(inputs.data), &&C.TF_Tensor(input_tensors.data),
			input_tensors.len, &Output(outputs.data), &&C.TF_Tensor(output_tensors.data),
			output_tensors.len, nil, 0, run_metadata, status)
	}
}

pub fn (ss &Session) close(status &Status) {
	C.TF_CloseSession(ss, status)
}

pub fn (ss &Session) delete(status &Status) {
	C.TF_DeleteSession(ss, status)
}

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
pub fn (od &OperationDescription) set_attr_type(attr_name string, value DataType) {
	unsafe {
		C.TF_SetAttrType(od, charptr(attr_name.str), C.TF_DataType(value))
	}
}

fn C.TF_OperationName(oper &C.TF_Operation) charptr
pub fn (op &Operation) name() string {
	return unsafe {
		(C.TF_OperationName(op)).vstring()
	}
}

fn C.TF_OperationOpType(oper &C.TF_Operation) charptr
pub fn (op &Operation) optype() string {
	return unsafe {
		(C.TF_OperationOpType(op)).vstring()
	}
}

fn C.TF_OperationDevice(oper &C.TF_Operation) charptr
pub fn (op &Operation) device() string {
	return unsafe {
		(C.TF_OperationDevice(op)).vstring()
	}
}

fn C.TF_OperationNumOutputs(oper &C.TF_Operation) int
pub fn (op &Operation) num_outputs() int {
	return unsafe {
		(C.TF_OperationNumOutputs(op))
	}
}

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// ----------------- Graph --------------------- ///
/// --------------------------------------------- ///
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

fn C.TF_GraphSetTensorShape(g &C.TF_Graph, output C.TF_Output, dims &i64, num_dims int, status &C.TF_Status)
pub fn (g &Graph) set_tensor_shape(output Output, dims []u64, status &Status) {
	unsafe {
		C.TF_GraphSetTensorShape(g, output, &i64(dims[0]), dims.len, status)
	}
}

fn C.TF_GraphGetTensorNumDims(g &C.TF_Graph, out C.TF_Output, s &C.TF_Status) int
pub fn (g &Graph) get_tensor_num_dims(output Output, status &Status) int {
	return unsafe {
		int(C.TF_GraphGetTensorNumDims(g, output, status))
	}
}

fn C.TF_GraphGetTensorShape(g &C.TF_Graph, out C.TF_Output, dims &i64, num_dims int, status &C.TF_Status)
pub fn (g &Graph) get_tensor_shape(output Output, status &Status) []i64 {
	mut n := g.get_tensor_num_dims(output, status)
	if n < 1 {
		return []i64{}
	}

	mut shape := []i64{}
	mut dim := i64(0)
	for i := 0; i < n; i++ {
		C.TF_GraphGetTensorShape(g, output, &dim, i, status)
		shape << dim
	}
	return shape
}

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// --------------- DataType ------------------- ///
/// --------------------------------------------- ///

pub enum DataType {
	float      = C.TF_FLOAT
	double     = C.TF_DOUBLE
	int32      = C.TF_INT32
	uint8      = C.TF_UINT8
	int16      = C.TF_INT16
	int8       = C.TF_INT8
	str        = C.TF_STRING
	complex64  = C.TF_COMPLEX64
	// complex    = C.TF_COMPLEX
	int64      = C.TF_INT64
	boolean    = C.TF_BOOL
	qint8      = C.TF_QINT8
	quint8     = C.TF_QUINT8
	qint32     = C.TF_QINT32
	bfloat16   = C.TF_BFLOAT16
	qint16     = C.TF_QINT16
	quint16    = C.TF_QUINT16
	uint16     = C.TF_UINT16
	complex128 = C.TF_COMPLEX128
	half       = C.TF_HALF
	resource   = C.TF_RESOURCE
	variant    = C.TF_VARIANT
	uint32     = C.TF_UINT32
	uint64     = C.TF_UINT64
}

pub fn (dt DataType)str() string {
	return match dt {
		.float      { "float" }
		.double     { "double" }
		.int32      { "int32" }
		.uint8      { "uint8" }
		.int16      { "int16" }
		.int8       { "int8" }
		.str        { "string" }
		.complex64  { "complex64" }
		// .complex    { "comlpex" }
		.int64      { "int64" }
		.boolean    { "boolean" }
		.qint8      { "qint8" }
		.quint8     { "quint8" }
		.qint32     { "qint32" }
		.bfloat16   { "bfloat16" }
		.qint16     { "qint16" }
		.quint16    { "quint16" }
		.uint16     { "uint16" }
		.complex128 { "complex128" }
		.half       { "half" }
		.resource   { "resource" }
		.variant    { "variant" }
		.uint32     { "uint32" }
		.uint64     { "uint64" }
	}
}

fn C.TF_DataTypeSize(C.TF_DataType) isize
pub fn (dt DataType) size() u64 {
	return unsafe {
		u64(C.TF_DataTypeSize(C.TF_DataType(dt)))
	}
}

pub enum AttrType {
	str         = C.TF_ATTR_STRING
	integer     = C.TF_ATTR_INT
	float       = C.TF_ATTR_FLOAT
	boolean     = C.TF_ATTR_BOOL
	@type       = C.TF_ATTR_TYPE
	shape       = C.TF_ATTR_SHAPE
	tensor      = C.TF_ATTR_TENSOR
	placeholder = C.TF_ATTR_PLACEHOLDER
	func        = C.TF_ATTR_FUNC
}

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// ----------------- Buffer -------------------- ///
/// --------------------------------------------- ///
struct C.TF_Buffer {}

pub type Buffer = C.TF_Buffer

fn C.TF_NewBuffer() &C.TF_Buffer
fn C.TF_NewBufferFromString(&char, u64) &C.TF_Buffer
fn C.TF_DeleteBuffer(&C.TF_Buffer)
fn C.TF_GetBuffer(&C.TF_Buffer) C.TF_Buffer

pub fn new_buffer() &Buffer {
	return unsafe { &Buffer(C.TF_NewBuffer()) }
}

pub fn new_buffer_from_string(buffer string) &Buffer {
	return unsafe { &Buffer(C.TF_NewBufferFromString(&char(buffer.str), buffer.len)) }
}

pub fn (b &Buffer) delete() {
	C.TF_DeleteBuffer(b)
}

/// --------------------------------------------- ///
/// --------------------------------------------- ///
/// --------------------------------------------- ///

/// --------------------------------------------- ///
/// ----------------- Status -------------------- ///
/// --------------------------------------------- ///
struct C.TF_Status {}

pub type Status = C.TF_Status

pub enum Code {
	ok                  = C.TF_OK // [0]
	cancelled           = C.TF_CANCELLED // [1]
	unknown             = C.TF_UNKNOWN // [2]
	invalid_argument    = C.TF_INVALID_ARGUMENT // [3]
	deadline_exceeded   = C.TF_DEADLINE_EXCEEDED // [4]
	not_found           = C.TF_NOT_FOUND // [5]
	already_exists      = C.TF_ALREADY_EXISTS // [6]
	permission_denied   = C.TF_PERMISSION_DENIED // [7]
	unaunthenticated    = C.TF_UNAUTHENTICATED // [16]
	resource_exhausted  = C.TF_RESOURCE_EXHAUSTED // [8]
	failed_precondition = C.TF_FAILED_PRECONDITION // [9]
	aborted             = C.TF_ABORTED // [10]
	out_of_range        = C.TF_OUT_OF_RANGE // [11]
	unimplemented       = C.TF_UNIMPLEMENTED // [12]
	internal            = C.TF_INTERNAL // [13]
	unavaiable          = C.TF_UNAVAILABLE // [14]
	data_loss           = C.TF_DATA_LOSS // [15]
}

fn C.TF_NewStatus() &C.TF_Status
fn C.TF_DeleteStatus(&C.TF_Status)
fn C.TF_SetStatus(&C.TF_Status, int, &char)
fn C.TF_SetStatusFromIOError(&C.TF_Status, int, &char)
fn C.TF_GetCode(&C.TF_Status) int
fn C.TF_Message(&C.TF_Status) &char

pub fn new_status() &Status {
	return unsafe { &Status(C.TF_NewStatus()) }
}

pub fn (s &Status) delete() {
	C.TF_DeleteStatus(s)
}

pub fn (s &Status) set(code Code, message string) {
	C.TF_SetStatus(s, int(code), &char(message.str))
}

pub fn (s &Status) set_from_io_error(error_code int, context string) {
	C.TF_SetStatusFromIOError(s, error_code, &char(context.str))
}

pub fn (s &Status) code() Code {
	rc := C.TF_GetCode(s)

	return unsafe { Code(rc) }
}

// message: return an empty string if code is <ok>,
//          otherwise, it returns the message
//          associated with that error.
pub fn (s &Status) message() string {
	unsafe {
		msg := &char(C.TF_Message(s))
		return msg.vstring_literal()
	}
}

struct C.TF_TString {}

pub type String = C.TF_TString

pub enum StringType {
	small  = 0x00
	large  = 0x01
	offset = 0x02
	view   = 0x03
}

fn C.TF_StringInit(t &C.TF_TString)

pub fn new_string() &String {
	mut s := &String{}

	C.TF_StringInit(s)

	return s
}

fn C.TF_StringCopy(dst &C.TF_TString, str charptr, size isize)
pub fn string_from(source string) &String {
	mut s := &String{}
	C.TF_StringCopy(s, source.str, source.len)
	return s
}

fn C.TF_StringAssignView(dst &C.TF_TString, src charptr, size isize)

// assign_to:  is used in contexts where you need to assign string data
// to a TensorFlow tensor without copying the actual string data.
// This is particularly useful in performance-critical applications
// where minimizing memory allocations and copies is important.
pub fn string_assign_to(str charptr, size isize) !&String {
	if str == unsafe { nil } {
		return error('Failed trying to assign to a NULL pointer.')
	}
	mut s := &String{}
	C.TF_StringAssignView(s, str, size)
	return s
}

fn C.TF_StringGetDataPointer(ptr &C.TF_TString) charptr
pub fn (s &String) pointer() charptr {
	return C.TF_StringGetDataPointer(s)
}

fn C.TF_StringGetType(ptr &C.TF_TString) int
pub fn (s &String) get_type() StringType {
	return unsafe {
		StringType(C.TF_StringGetType(s))
	}
}

fn C.TF_StringGetSize(ptr &C.TF_TString) isize
pub fn (s &String) size() u64 {
	return u64(C.TF_StringGetSize(s))
}

fn C.TF_StringGetCapacity(ptr &C.TF_TString) isize
pub fn (s &String) capacity() u64 {
	return u64(C.TF_StringGetCapacity(s))
}

fn C.TF_StringDealloc(ptr &C.TF_TString)
pub fn (s &String) delete() {
	C.TF_StringDealloc(s)
}
