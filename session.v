module tf

struct C.TF_SessionOptions {}

pub type SessionOptions = C.TF_SessionOptions

fn C.TF_NewSessionOptions() &C.TF_SessionOptions
pub fn new_session_options() &SessionOptions {
	return unsafe { &SessionOptions(C.TF_NewSessionOptions()) }
}
pub fn SessionOptions.new() &SessionOptions {
	return unsafe { &SessionOptions(C.TF_NewSessionOptions()) }
}

fn C.TF_SetTarget(&C.TF_SessionOptions, &char)
pub fn (so &SessionOptions) set_target(target string) {
	C.TF_SetTarget(so, &char(target.str))
}

fn C.TF_DeleteSessionOptions(&C.TF_SessionOptions)
pub fn (so &SessionOptions) delete() {
	C.TF_DeleteSessionOptions(so)
}

fn C.TF_SetConfig(&C.TF_SessionOptions, voidptr, u64, &C.TF_Status)
pub fn (so &SessionOptions) set_config(proto voidptr, proto_len u64, status &Status) {
	C.TF_SetConfig(so, proto, isize(proto_len), status)
}

struct C.TF_Session {}

pub type Session = C.TF_Session

fn C.TF_NewSession(&C.TF_Graph, &C.TF_SessionOptions, &C.TF_Status) &C.TF_Session

pub fn new_session(graph &Graph, session_options &SessionOptions, status &Status) &Session {
	return unsafe {
		&Session(C.TF_NewSession(graph, session_options, status))
	}
}

pub fn (g &Graph) new_session(sess_opts &SessionOptions, status &Status) &Session {
	return new_session(g, sess_opts, status)
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
			output_tensors.len, &&Operation(opers.data), opers.len, run_metadata, status)
	}
}

fn C.TF_CloseSession(&C.TF_Session, &C.TF_Status)
pub fn (ss &Session) close(status &Status) {
	C.TF_CloseSession(ss, status)
}

fn C.TF_DeleteSession(&C.TF_Session, &C.TF_Status)
pub fn (ss &Session) delete(status &Status) {
	C.TF_DeleteSession(ss, status)
}

struct C.TF_DeviceList {}

pub type DeviceList = C.TF_DeviceList

fn C.TF_SessionListDevices(session &C.TF_Session, status &C.TF_Status) &C.TF_DeviceList
pub fn (ss &Session) device_list(status &Status) &DeviceList {
	return C.TF_SessionListDevices(ss, status)
}

fn C.TF_DeleteDeviceList(list &C.TF_DeviceList)
pub fn (list &DeviceList) delete() {
	C.TF_DeleteDeviceList(list)
}

fn C.TF_DeviceListCount(list &C.TF_DeviceList) int
pub fn (list &DeviceList) count() int {
	return C.TF_DeviceListCount(list)
}

fn C.TF_DeviceListName(list &C.TF_DeviceList, index int, status &C.TF_Status) &char
pub fn (list &DeviceList) name_of(index int, status &Status) string {
	unsafe {
		ptr := C.TF_DeviceListName(list, index, status)
		if ptr == nil {
			return ''
		}
		return cstring_to_vstring(ptr)
	}
}

fn C.TF_DeviceListType(list &C.TF_DeviceList, index int, status &C.TF_Status) &char
pub fn (list &DeviceList) type_of(index int, status &Status) string {
	unsafe {
		ptr := C.TF_DeviceListType(list, index, status)
		if ptr == nil {
			return ''
		}
		return cstring_to_vstring(ptr)
	}
}

fn C.TF_DeviceListMemoryBytes(list &C.TF_DeviceList, index int, status &C.TF_Status) i64
pub fn (list &DeviceList) memory_bytes_of(index int, status &Status) i64 {
	return C.TF_DeviceListMemoryBytes(list, index, status)
}

pub struct Device {
	name         string
	dtype        string
	memory_bytes i64
}

pub fn (list &DeviceList) devices(status &Status) []Device {
	mut devs := []Device{}
	count := list.count()

	for i := 0; i < count; i++ {
		devs << Device{
			name: list.name_of(i, status)
			dtype: list.type_of(i, status)
			memory_bytes: list.memory_bytes_of(i, status)
		}
	}
	return devs
}
