package kit.file;

class File {
	public final meta:FileMeta;

	final adaptor:Adaptor;

	public function new(meta, adaptor) {
		this.meta = meta;
		this.adaptor = adaptor;
	}

	public function exists() {
		return adaptor.exists(meta.path);
	}

	public function read() {
		return adaptor.read(meta.path);
	}

	public function readBytes() {
		return adaptor.readBytes(meta.path);
	}

	public function write(data:String) {
		return adaptor.write(meta.path, data);
	}

	public function copy(dest:String) {
		return adaptor.copy(meta.path, dest);
	}

	public function remove() {
		return adaptor.remove(meta.path);
	}
}
