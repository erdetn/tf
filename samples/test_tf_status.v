module main

import tf

fn main() {
	status := tf.new_status()

	status.set(tf.Code.out_of_range, 'This is OUT OF RANGE!')

	println(status.code())
	println(status.message())


	status.set(tf.Code.ok, 'This is OKAY :) !')

	println(status.code())
	println(status.message()) // An empty string.

	status.delete()
}
