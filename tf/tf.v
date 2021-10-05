module tf

#flag -I /usr/include/
#flag -l tensorflow

#include <tensorflow/c/c_api.h>

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
	status &C.TF_Status
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
	C.TF_DeleteStatus(this.status)
}

pub fn (this Status)set(code Code, message string) {
	C.TF_SetStatus(this.status, int(code), &char(message.str))
}

pub fn (this Status)set_from_io_error(error_code int, context string) {
	C.TF_SetStatusFromIOError(this.status, error_code, &char(context.str))
}

pub fn (this Status)code() Code {
	rc := C.TF_GetCode(this.status)

	return Code(rc)
}

// message: return an empty string if code is <ok>,
//          otherwise, it returns the message 
//          associated with that error.
pub fn (this Status)message() string {
	unsafe {
		msg := &char(C.TF_Message(this.status))
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
	buffer &C.TF_Buffer
}

pub fn new_buffer() Buffer {
	return Buffer{ C.TF_NewBuffer() }
}

pub fn new_buffer_from_string(buffer string) Buffer {
	return Buffer{ C.TF_NewBufferFromString(&char(buffer.str), buffer.len) }
}

pub fn (this Buffer)delete() {
	C.TF_DeleteBuffer(this.buffer)
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
	session_option &C.TF_SessionOptions
}

pub fn new_session_options() SessionOptions {
	return SessionOptions {
		C.TF_NewSessionOptions()
	}
}

pub fn (this SessionOptions)set_target(target string) {
	C.TF_SetTarget(this.session_option, &char(target.str))
}

pub fn (this SessionOptions)delete() {
	C.TF_DeleteSessionOptions(this.session_option)
}

///
/// TF_Graph
///

struct C.TF_Graph {}
fn C.TF_NewGraph() &C.TF_Graph
fn C.TF_DeleteGraph(&C.TF_Graph)

pub struct Graph {
	graph &C.TF_Graph
}

pub fn new_graph() Graph {
	return Graph{C.TF_NewGraph()}
}

pub fn (this Graph)delete() {
	C.TF_DeleteGraph(this.graph)
}

///
/// Input, Output, Function and Operation structs
///

struct C.TF_OperationDescription{}
struct C.TF_Operation{}
struct C.TF_Input{}
struct C.TF_Output{}
struct C.TF_Function{}
struct C.TF_FunctionOptions{}

