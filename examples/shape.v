module main 

import tf

fn main() {
	mut sh1 := tf.Shape{}

	println(sh1)

	sh1.add(1,3,5)
	println(sh1)

	sh2 := tf.shape(2, 3, 4)
	println(sh2)
	i3 := sh2.get(2) or {
		0
	}
	dump(i3)
}