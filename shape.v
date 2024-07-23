module tf 

pub struct Shape {
mut:
	shape []i64 
}

pub fn (sh Shape)str() string {
	if sh.shape.len == 0 {
		return "(empty)"
	}
	mut s := "[ "
	for i in sh.shape {
		s += "${i} "
	}
	s += "]"
	return s
}

pub fn shape(dims ...int)  Shape {
	mut sh := Shape{}
	for d in dims {
		sh.shape << i64(d)
	}
	return sh
}

pub fn (sh Shape)len() int {
	return int(sh.shape.len)
}

pub fn (mut sh Shape)set(index int, dim int)! {
	if index >= sh.shape.len {
		return error("Index outside the range.")
	}
	sh.shape[index] = i64(dim)
}

pub fn (sh Shape)get(index int) !int {
	if index >= sh.shape.len {
		return error("Index outside the range.")
	}
	return int(sh.shape[index])
}

pub fn (mut sh Shape)ptr() !voidptr {
	if sh.shape.len == 0 {
		return error("Trying to get pointer from empty shape array.")
	}
	return unsafe {
		voidptr(sh.shape[0])
	}
}

pub fn (mut sh Shape)add(dim ...int) {
	for d in dim {
		sh.shape << i64(d)
	}
}