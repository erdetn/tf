module tf

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
pub fn new_status() &Status {
	return unsafe { &Status(C.TF_NewStatus()) }
}

fn C.TF_DeleteStatus(&C.TF_Status)
pub fn (s &Status) delete() {
	C.TF_DeleteStatus(s)
}

fn C.TF_SetStatus(&C.TF_Status, int, &char)
pub fn (s &Status) set(code Code, message string) {
	C.TF_SetStatus(s, int(code), &char(message.str))
}

fn C.TF_SetStatusFromIOError(&C.TF_Status, int, &char)
pub fn (s &Status) set_from_io_error(error_code int, context string) {
	C.TF_SetStatusFromIOError(s, error_code, &char(context.str))
}

fn C.TF_GetCode(&C.TF_Status) int
pub fn (s &Status) code() Code {
	rc := C.TF_GetCode(s)

	return unsafe { Code(rc) }
}

// message: return an empty string if code is <ok>,
//          otherwise, it returns the message
//          associated with that error.
fn C.TF_Message(&C.TF_Status) &char
pub fn (s &Status) message() string {
	return unsafe {
		cstring_to_vstring(C.TF_Message(s))
	}
}

fn C.TF_SetPayload(s &C.TF_Status, key &char, value &char)
pub fn (s &Status) payload(key string, value string) {
	unsafe {
		C.TF_SetPayload(s, &char(key.str), &char(value.str))
	}
}

pub fn (s &Status) okay() bool {
	return s.code() == .ok
}
