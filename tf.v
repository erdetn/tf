module tf

#flag -L /usr/local/lib
#flag -I /usr/local/include
#flag -l tensorflow

#include <tensorflow/c/c_api.h>

pub const null = unsafe { nil }

pub const null_buffer = &Buffer(unsafe { nil })

fn C.TF_Version() &char
pub fn version() string {
	unsafe {
		return cstring_to_vstring(C.TF_Version())
	}
}

pub fn is_null[T](ptr &T) bool {
	unsafe {
		if ptr == voidptr(0) {
			return true
		}
	}
	return false
}