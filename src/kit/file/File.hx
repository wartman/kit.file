package kit.file;

class File {
	final path:String;
	final adaptor:Adaptor;

	var meta:Null<FileMeta> = null;

	public function new(path, adaptor, ?meta) {
		this.path = path;
		this.adaptor = adaptor;
		this.meta = meta;
	}

	public function getMeta():Task<FileMeta> {
		if (meta != null) return meta;
		return adaptor.getMeta(path).then(meta -> this.meta = meta);
	}

	public function exists() {
		return adaptor.exists(path);
	}

	public function read() {
		return adaptor.read(path);
	}

	public function readBytes() {
		return adaptor.readBytes(path);
	}

	public function write(data:String) {
		return adaptor.write(path, data);
	}

	public function copy(dest:String) {
		return adaptor.copy(path, dest);
	}

	public function remove() {
		return adaptor.remove(path);
	}
}
