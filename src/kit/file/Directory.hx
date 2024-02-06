package kit.file;

using kit.file.Path;

class Directory {
	public final meta:DirectoryMeta;

	final adaptor:Adaptor;

	public function new(path, adaptor) {
		this.meta = {
			path: path,
			name: Path.withoutDirectory(path)
		};
		this.adaptor = adaptor;
	}

	public function exists():Future<Bool> {
		return adaptor.exists(meta.path);
	}

	public function getFile(file:String):Task<File> {
		return adaptor.getMeta(Path.join([meta.path, file])).next(meta -> new File(meta, adaptor));
	}

	public function createFile(file:String) {
		return new File({
			path: Path.join([meta.path, file]),
			name: file.withoutDirectory().withoutExtension(),
			created: Date.now(),
			updated: Date.now(),
			size: 0
		}, adaptor);
	}

	public function createDirectory(path:String) {
		return adaptor.createDirectory(Path.join([meta.path, path])).next(created -> switch created {
			case true: new Directory(meta.path, adaptor);
			case false: new Error(InternalError, 'Could not create directory');
		});
	}

	public function listFiles():Task<Array<File>> {
		return adaptor.listFiles(meta.path).next(metas -> [for (meta in metas) new File(meta, adaptor)]);
	}

	public function openDirectory(name:String) {
		return new Directory(Path.join([meta.path, name]), adaptor);
	}

	public function openDirectoryIfExists(name:String):Task<Directory> {
		return Task.ofFuture(adaptor.exists(name)).next(exists -> switch exists {
			case true: new Directory(Path.join([meta.path, name]), adaptor);
			case false: new Error(NotFound, 'Directory not found');
		});
	}

	public function listDirectories() {
		return adaptor.listDirectories(meta.path).next(paths -> [for (path in paths) new Directory(path, adaptor)]);
	}

	public function remove() {
		return adaptor.remove(meta.path);
	}
}
