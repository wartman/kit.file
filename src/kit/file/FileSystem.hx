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

	public function openDirectory(path:String):Directory {
		return new Directory(path, adaptor);
	}

	public function fileExists(path:String):Task<Bool> {
		return adaptor.exists(path);
	}

	public function getFile(path:String):Task<File> {
		return adaptor.getMeta(path).next(meta -> new File(meta, adaptor));
	}

	public function createFile(path:String):File {
		return new File({
			path: path,
			name: path.withoutDirectory().withoutExtension(),
			created: Date.now(),
			updated: Date.now(),
			size: 0
		}, adaptor);
	}
}
