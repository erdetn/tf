module main

import tf

fn main() {
	status := tf.new_status()
	gr := tf.new_graph()
	sops := tf.new_session_options()

	session := tf.new_session(gr, sops, status)

	session.close(status)
	println(status.message())

	session.delete(status)
	println(status.message())
}
