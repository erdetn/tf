module tf

pub enum DataType {
	float      = C.TF_FLOAT
	double     = C.TF_DOUBLE
	int32      = C.TF_INT32
	uint8      = C.TF_UINT8
	int16      = C.TF_INT16
	int8       = C.TF_INT8
	str        = C.TF_STRING
	complex64  = C.TF_COMPLEX64
	// complex    = C.TF_COMPLEX
	int64      = C.TF_INT64
	boolean    = C.TF_BOOL
	qint8      = C.TF_QINT8
	quint8     = C.TF_QUINT8
	qint32     = C.TF_QINT32
	bfloat16   = C.TF_BFLOAT16
	qint16     = C.TF_QINT16
	quint16    = C.TF_QUINT16
	uint16     = C.TF_UINT16
	complex128 = C.TF_COMPLEX128
	half       = C.TF_HALF
	resource   = C.TF_RESOURCE
	variant    = C.TF_VARIANT
	uint32     = C.TF_UINT32
	uint64     = C.TF_UINT64
	f8_e5m2    = C.TF_FLOAT8_E5M2
	f8_e4m3fn  = C.TF_FLOAT8_E4M3FN
	int4       = C.TF_INT4
	uint4      = C.TF_UINT4
}

pub fn (dt DataType) str() string {
	return match dt {
		.float { 'float' }
		.double { 'double' }
		.int32 { 'int32' }
		.uint8 { 'uint8' }
		.int16 { 'int16' }
		.int8 { 'int8' }
		.str { 'string' }
		.complex64 { 'complex64' }
		// .complex    { "comlpex" }
		.int64 { 'int64' }
		.boolean { 'boolean' }
		.qint8 { 'qint8' }
		.quint8 { 'quint8' }
		.qint32 { 'qint32' }
		.bfloat16 { 'bfloat16' }
		.qint16 { 'qint16' }
		.quint16 { 'quint16' }
		.uint16 { 'uint16' }
		.complex128 { 'complex128' }
		.half { 'half' }
		.resource { 'resource' }
		.variant { 'variant' }
		.uint32 { 'uint32' }
		.uint64 { 'uint64' }
		.f8_e5m2 { 'float8_e5m2' }
		.f8_e4m3fn { 'float8 e4m3fn' }
		.int4 { 'int4' }
		.uint4 { 'uint4' }
	}
}

fn C.TF_DataTypeSize(C.TF_DataType) isize
pub fn (dt DataType) size() u64 {
	return unsafe {
		u64(C.TF_DataTypeSize(C.TF_DataType(dt)))
	}
}
