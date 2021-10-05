module tf

#flag -I /usr/include/
#flag -l tensorflow

#include <tensorflow/c/c_api.h>

fn C.TF_Version() &char
pub fn version() string {
	unsafe {
		return C.TF_Version().vstring()
	}
}

///
/// TF_Graph
///

struct C.TF_Graph {}
fn C.TF_NewGraph() &C.TF_Graph
fn C.TF_DeleteGraph(&C.TF_Graph)

pub struct Graph {
	graph &C.TF_Graph
}

pub fn new_graph() Graph {
	return Graph{C.TF_NewGraph()}
}

pub fn (this Graph)delete() {
	C.TF_DeleteGraph(this.graph)
}
