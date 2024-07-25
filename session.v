module tf

struct C.TF_SessionOptions {}

pub type SessionOptions = C.TF_SessionOptions

fn C.TF_NewSessionOptions() &C.TF_SessionOptions
pub fn new_session_options() &SessionOptions {
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

fn C.TF_CloseSession(&C.TF_Session, &C.TF_Status)

fn C.TF_DeleteSession(&C.TF_Session, &C.TF_Status)

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

pub fn (ss &Session) close(status &Status) {
	C.TF_CloseSession(ss, status)
}

pub fn (ss &Session) delete(status &Status) {
	C.TF_DeleteSession(ss, status)
}
