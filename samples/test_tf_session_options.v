module main

import tf 

fn main() {
	sops := tf.new_session_options()

	sops.set_target('local')

	sops.delete()
}