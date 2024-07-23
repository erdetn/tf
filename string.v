module tf 


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

fn C.TF_StringCopy(dst &C.TF_TString, str &char, size isize)
pub fn string_from(source string) &String {
	mut s := &String{}
	C.TF_StringCopy(s, source.str, source.len)
	return s
}

fn C.TF_StringAssignView(dst &C.TF_TString, src &char, size isize)

// assign_to:  is used in contexts where you need to assign string data
// to a TensorFlow tensor without copying the actual string data.
// This is particularly useful in performance-critical applications
// where minimizing memory allocations and copies is important.
pub fn string_assign_to(str &char, size isize) !&String {
	if str == unsafe { nil } {
		return error('Failed trying to assign to a NULL pointer.')
	}
	mut s := &String{}
	C.TF_StringAssignView(s, str, size)
	return s
}

fn C.TF_StringGetDataPointer(ptr &C.TF_TString) &char
pub fn (s &String) ptr() &char {
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

pub fn (s &String)str() string {
	return unsafe { 
		cstring_to_vstring(s.ptr())
	}
}