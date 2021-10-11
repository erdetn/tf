module main

import tf

fn main() {
	buff := tf.new_buffer()

	buff.delete()

	buff1 := tf.new_buffer_from_string('Hello world')
	buff1.delete()
}