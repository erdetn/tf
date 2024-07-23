module tf

pub enum AttributeType {
	str         = C.TF_ATTR_STRING
	integer     = C.TF_ATTR_INT
	float       = C.TF_ATTR_FLOAT
	boolean     = C.TF_ATTR_BOOL
	@type       = C.TF_ATTR_TYPE
	shape       = C.TF_ATTR_SHAPE
	tensor      = C.TF_ATTR_TENSOR
	placeholder = C.TF_ATTR_PLACEHOLDER
	func        = C.TF_ATTR_FUNC
}

pub fn (at AttributeType) str() string {
	return match at {
		.str { 'string' }
		.integer { 'integer' }
		.float { 'float' }
		.boolean { 'boolean' }
		.@type { 'type' }
		.shape { 'shape' }
		.tensor { 'tensor' }
		.placeholder { 'placeholder' }
		.func { 'func' }
	}
}
