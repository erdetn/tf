module tf

#flag -I /usr/include/
#flag -l tensorflow

#include <memory.h>
#include <string.h>
#include <stdlib.h>
#include <tensorflow/c/c_api.h>

pub const null = voidptr(0)

fn C.TF_Version() &char
pub fn version() string {
	unsafe {
		return C.TF_Version().vstring()
	}
}

///
/// Status
///
struct C.TF_Status {}

/// TF_Code
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

pub struct Status {
	status_ptr &C.TF_Status
}

fn C.TF_NewStatus() &C.TF_Status
fn C.TF_DeleteStatus(&C.TF_Status)
fn C.TF_SetStatus(&C.TF_Status, int, &char)
fn C.TF_SetStatusFromIOError(&C.TF_Status, int, &char)
fn C.TF_GetCode(&C.TF_Status) int
fn C.TF_Message(&C.TF_Status) &char

pub fn new_status() Status {
	return Status {C.TF_NewStatus()}
}

pub fn (this Status)delete() {
	C.TF_DeleteStatus(this.status_ptr)
}

pub fn (this Status)set(code Code, message string) {
	C.TF_SetStatus(this.status_ptr, int(code), &char(message.str))
}

pub fn (this Status)set_from_io_error(error_code int, context string) {
	C.TF_SetStatusFromIOError(this.status_ptr, error_code, &char(context.str))
}

pub fn (this Status)code() Code {
	rc := C.TF_GetCode(this.status_ptr)

	return Code(rc)
}

// message: return an empty string if code is <ok>,
//          otherwise, it returns the message 
//          associated with that error.
pub fn (this Status)message() string {
	unsafe {
		msg := &char(C.TF_Message(this.status_ptr))
		return msg.vstring_literal()
	}
}

///
/// Buffer
///

struct C.TF_Buffer {}
fn C.TF_NewBuffer() &C.TF_Buffer
fn C.TF_NewBufferFromString(&char, u64) &C.TF_Buffer
fn C.TF_DeleteBuffer(&C.TF_Buffer)
fn C.TF_GetBuffer(&C.TF_Buffer)C.TF_Buffer

struct Buffer {
	buffer_ptr &C.TF_Buffer
}

pub fn new_buffer() Buffer {
	return Buffer{ C.TF_NewBuffer() }
}

pub fn new_buffer_from_string(buffer string) Buffer {
	return Buffer{ C.TF_NewBufferFromString(&char(buffer.str), buffer.len) }
}

pub fn (this Buffer)delete() {
	C.TF_DeleteBuffer(this.buffer_ptr)
}

///
/// SessionOptions
///
struct C.TF_SessionOptions{}
fn C.TF_NewSessionOptions() &C.TF_SessionOptions
fn C.TF_SetTarget(&C.TF_SessionOptions, &char)
fn C.TF_SetConfig(&C.TF_SessionOptions, voidptr, u64, &C.TF_Status)
fn C.TF_DeleteSessionOptions(&C.TF_SessionOptions)

pub struct SessionOptions {
	session_options_ptr &C.TF_SessionOptions
}

pub fn new_session_options() SessionOptions {
	return SessionOptions {
		C.TF_NewSessionOptions()
	}
}

pub fn (this SessionOptions)set_target(target string) {
	C.TF_SetTarget(this.session_options_ptr, &char(target.str))
}

pub fn (this SessionOptions)delete() {
	C.TF_DeleteSessionOptions(this.session_options_ptr)
}

///
/// Input, Output, Function and Operation structs
///

struct C.TF_OperationDescription{}
struct C.TF_Operation{}
struct C.TF_Input{}

struct C.TF_Output{
	oper  &C.TF_Operation
	index  int
}

pub struct Output {
	out_ptr &C.TF_Output
}

pub fn new_output() &Output {
	return &Output{
		unsafe {
			&C.TF_Output(C.malloc(int(sizeof(C.TF_Output))))
		}
	}
}

struct C.TF_Function{}
struct C.TF_FunctionOptions{}

pub struct Operation {
	operation_ptr &C.TF_Operation
}

pub fn (this Operation)output(index int) &Output {
	ret_out := &Output {
		&C.TF_Output {
			this.operation_ptr,
			index
		}
	}
	return ret_out
}

fn C.TF_GraphOperationByName(&C.TF_Graph, &char) &C.TF_Operation

///
/// TF_Graph
///

struct C.TF_Graph {}
fn C.TF_NewGraph() &C.TF_Graph
fn C.TF_DeleteGraph(&C.TF_Graph)

pub struct Graph {
	graph_ptr &C.TF_Graph
}

pub fn new_graph() Graph {
	return Graph{C.TF_NewGraph()}
}

pub fn (this Graph)delete() {
	C.TF_DeleteGraph(this.graph_ptr)
}

pub fn (this Graph)get_operation_by_name(operation_name string) Operation {
	ret_op := Operation{
		C.TF_GraphOperationByName(this.graph_ptr, &char(operation_name.str))
	}
	return ret_op
}

///
/// Session
///
struct C.TF_Session{}

fn C.TF_NewSession(&C.TF_Graph, &C.TF_SessionOptions, &C.TF_Status) &C.TF_Session

fn C.TF_LoadSessionFromSavedModel(&C.TF_SessionOptions,
								  &C.TF_Buffer,
								  &char, &&char, int
								  &C.TF_Graph,
								  &C.TF_Buffer,
								  &C.TF_Status) &C.TF_Session

fn C.TF_CloseSession(&C.TF_Session, &C.TF_Status)

fn C.TF_DeleteSession(&C.TF_Session, &C.TF_Status)

pub struct Session {
	session_ptr &C.TF_Session
}

pub fn new_session(graph &Graph, session_options &SessionOptions, status &Status) Session {
	return Session {
		C.TF_NewSession(
			graph.graph_ptr, 
			session_options.session_options_ptr,
			status.status_ptr
		)
	}
} 

pub fn new_session_from_model(session_options &SessionOptions,
							   run_options     &Buffer,
							   export_dir       string,
							   tags           &&char,
							   tags_len        u32,
							   graph           &Graph,
							   meta_graph_def  &Buffer,
							   status          &Status) Session {
	return Session {C.TF_LoadSessionFromSavedModel(
		session_options.session_options_ptr,
		run_options.buffer_ptr,
		&char(export_dir.str),
		tags, int(tags_len),
		graph.graph_ptr,
		meta_graph_def.buffer_ptr,
		status.status_ptr)
	}
}

fn C.TF_SessionRun(&C.TF_Session, 
                   // RunOptions
                   &C.TF_Buffer, 
                   // Input tensors
                   &C.TF_Output, &&C.TF_Tensor, int,
                   // Output tensors
                   &C.TF_Output, &&C.TF_Tensor, int,
                   // Target operations
                   &&C.TF_Operation, int,
                   // RunMetadata
                   &C.TF_Buffer,
                   // Output status
                   &C.TF_Status)

pub fn (this Session)run(buffer Buffer,
                         input  Output,
                         input_tensors []Tensor, // len = input_tensors.len
                         output Output
                         output_tensors []Tensor, // len = output_tensors.len
                         opers []Operation, //len = opers.len
                         run_metadata Buffer,
                         mut status Status) {
	C.TF_SessionRun(this.session_ptr,
                    input.out_ptr,
                    &input_tensors[0].tensor_ptr, input_tensors.len,
                    output.out_ptr,
                    &output_tensors[0].tensor_ptr, output_tensors.len,
                    &opers[0].operation_ptr, opers.len,
                    run_metadata.buffer_ptr,
                    status.status_ptr)
}

pub fn (this Session)close(status &Status) {
	C.TF_CloseSession(this.session_ptr, status.status_ptr)
}

pub fn (this Session)delete(status &Status) {
	C.TF_DeleteSession(this.session_ptr, status.status_ptr)
}

///
/// TF data types
///
pub enum DataType {
	tf_float      = C.TF_FLOAT      // [1]
	tf_double     = C.TF_DOUBLE     // [2]
	tf_int32      = C.TF_INT32      // [3] Int32 tensors are always in 'host' memory.
	tf_uint8      = C.TF_UINT8      // [4]
	tf_int16      = C.TF_INT16      // [5]
	tf_int8       = C.TF_INT8       // [6]
	tf_string     = C.TF_STRING     // [7]
	tf_complex64  = C.TF_COMPLEX64  // [8] Single-precision complex
	tf_complex    = C.TF_COMPLEX    // [8] Old identifier kept for API backwards compatibility
	tf_int64      = C.TF_INT64      // [9]
	tf_bool       = C.TF_BOOL       // [10]
	tf_qint8      = C.TF_QINT8      // [11] Quantized int8
	tf_quint8     = C.TF_QUINT8     // [12] Quantized uint8
	tf_qint32     = C.TF_QINT32     // [13] Quantized int32
	tf_bfloat16   = C.TF_BFLOAT16   // [14] Float32 truncated to 16 bits.  Only for cast ops.
	tf_qint16     = C.TF_QINT16     // [15] Quantized int16
	tf_quint16    = C.TF_QUINT16    // [16] Quantized uint16
	tf_uint16     = C.TF_UINT16     // [17]
	tf_complex128 = C.TF_COMPLEX128 // [18] Double-precision complex
	tf_half       = C.TF_HALF       // [19]
	tf_resource   = C.TF_RESOURCE   // [20]
	tf_variant    = C.TF_VARIANT    // [21]
	tf_uint32     = C.TF_UINT32     // [22]
	tf_uint64     = C.TF_UINT64     // [23]
}

fn C.TF_DataTypeSize(int) u32
pub fn sizeof_datatype(data_type DataType) u32 {
	return C.TF_DataTypeSize(int(data_type))
}

///
/// Tensor
///

struct C.TF_Tensor {}

pub struct Tensor {
	tensor_ptr &C.TF_Tensor
}

fn C.TF_NewTensor(int, &i64, int, voidptr, u32, voidptr, voidptr) &C.TF_Tensor

pub fn new_tensor<T>(data_type DataType, dimensions []i64, data []T) &Tensor{
	return &Tensor {
		C.TF_NewTensor(int(data_type), 
					&i64(dimensions[0]), dimensions.len, 
					voidptr(data[0]), data.len,
					null, null)
	}
}

fn C.TF_AllocateTensor(int, &i64, int, u32) &C.TF_Tensor
pub fn allocate_tensor(data_type DataType, dimensions []i64, data_len u32) &Tensor {
	return &Tensor{
		C.TF_AllocateTensor(int(data_type),
							&i64(dimensions[0]), dimensions.len,
							data_len)
	}
}

fn C.TF_TensorMaybeMove(&C.TF_Tensor) &C.TF_Tensor
pub fn (this Tensor)move() &Tensor {
	return &Tensor {
		C.TF_TensorMaybeMove(this.tensor_ptr)
	}
}

fn C.TF_DeleteTensor(&C.TF_Tensor)
pub fn (this Tensor)delete() {
	C.TF_DeleteTensor(this.tensor_ptr)
}

fn C.TF_TensorIsAligned(&C.TF_Tensor) bool
pub fn (this Tensor)is_aligned() bool {
	return C.TF_TensorIsAligned(this.tensor_ptr)
}

fn C.TF_TensorType(&C.TF_Tensor) int
pub fn (this Tensor)data_type() DataType {
	return DataType(C.TF_TensorType(this.tensor_ptr))
}

fn C.TF_NumDims(&C.TF_Tensor) int
pub fn (this Tensor)dimensions() int {
	return int(C.TF_NumDims(this.tensor_ptr))
}

fn C.TF_Dim(&C.TF_Tensor, int) i64
pub fn (this Tensor)tensor_dimension(index int) i64 {
	return i64(C.TF_Dim(this.tensor_ptr, index))
}

fn C.TF_TensorByteSize(&C.TF_Tensor) u32
pub fn (this Tensor)size_in_bytes() u32 {
	return u32(C.TF_TensorByteSize(this.tensor_ptr))
}

fn C.TF_TensorData(&C.TF_Tensor) voidptr
pub fn (this Tensor)data_ptr() voidptr {
	// TODO: supporting vectorize data of type <T>
	return C.TF_TensorData(this.tensor_ptr)
}

fn C.TF_TensorElementCount(&C.TF_Tensor) i64
pub fn (this Tensor)elements_count() i64 {
	return C.TF_TensorElementCount(this.tensor_ptr)
}
