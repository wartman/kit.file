package kit.file;

using kit.file.Path;

class FileSystem {
	final adaptor:Adaptor;

	public function new(adaptor) {
		this.adaptor = adaptor;
	}

	public function listDirectories() {
		return adaptor.listDirectories('').next(paths -> [for (path in paths) new Directory(path, adaptor)]);
	}

	public function directory(path:String):Directory {
		return new Directory(path, adaptor);
	}

	public function file(path:String):Task<File> {
		return new File(path, adaptor);
	}

	public function fileExists(path:String):Task<Bool> {
		return adaptor.exists(path);
	}
}
