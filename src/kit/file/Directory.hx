package kit.file;

using kit.file.Path;

class Directory {
	final path:String;
	final adaptor:Adaptor;

	public function new(path, adaptor) {
		this.path = path;
		this.adaptor = adaptor;
	}

	public function getMeta() {
		return adaptor.getMeta(path);
	}

	public function exists():Future<Bool> {
		return adaptor.exists(path);
	}

	public function create():Task<Directory> {
		return exists().flatMap(exists -> switch exists {
			case false:
				adaptor.createDirectory(path).then(created -> switch created {
					case true: this;
					case false: new Error(InternalError, 'Could not create directory');
				});
			case true: Task.ofResult(Ok(this));
		});
	}

	public function file(file:String):File {
		return new File(Path.join([path, file]), adaptor);
	}

	public function directory(path:String) {
		return new Directory(Path.join([this.path, path]), adaptor);
	}

	public function listFiles():Task<Array<File>> {
		return adaptor.listFiles(path).then(metas -> [for (meta in metas) new File(meta.path, adaptor, meta)]);
	}

	public function openDirectory(name:String) {
		return new Directory(Path.join([path, name]), adaptor);
	}

	public function openDirectoryIfExists(name:String):Task<Directory> {
		return Task.ofFuture(adaptor.exists(name)).then(exists -> switch exists {
			case true: new Directory(Path.join([path, name]), adaptor);
			case false: new Error(NotFound, 'Directory not found');
		});
	}

	public function listDirectories() {
		return adaptor.listDirectories(path).then(paths -> [for (path in paths) new Directory(path, adaptor)]);
	}

	public function remove() {
		return adaptor.remove(path);
	}
}
