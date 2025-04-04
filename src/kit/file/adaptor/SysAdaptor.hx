package kit.file.adaptor;

import haxe.io.Bytes;
import sys.io.*;

using Kit;
using haxe.io.Path;
using sys.FileSystem;
using sys.io.File;

class SysAdaptor implements Adaptor {
	final root:String;

	public function new(root) {
		this.root = root;
	}

	public function getMeta(path:String):Task<FileMeta> {
		var fullPath = resolvePath(path);

		if (!fullPath.exists()) return new Error(NotFound, 'No file exists for $path');

		var info = fullPath.stat();

		return Task.ok({
			path: path,
			name: path.withoutDirectory().withoutExtension(),
			fullPath: fullPath,
			created: info.ctime,
			updated: info.mtime,
			size: info.size
		});
	}

	public function listFiles(path:String):Task<Array<FileMeta>> {
		var fullPath = resolvePath(path);
		if (!fullPath.exists()) {
			return new Error(NotFound, 'No directory exists at $path');
		}
		var paths = try fullPath.readDirectory() catch (e) return new Error(InternalError, e.message);
		return paths
			.filter(name -> !Path.join([fullPath, name]).isDirectory())
			.map(name -> getMeta(Path.join([path, name])))
			.inParallel();
	}

	public function listDirectories(path:String):Task<Array<String>> {
		var fullPath = resolvePath(path);
		var paths = try fullPath.readDirectory() catch (e) return new Error(InternalError, e.message);
		return paths
			.filter(name -> Path.join([fullPath, name]).isDirectory())
			.map(name -> Path.join([path, name]));
	}

	public function createDirectory(path:String):Task<Bool> {
		var fullPath = resolvePath(path);
		if (fullPath.exists()) return false;
		try {
			fullPath.createDirectory();
		} catch (e) {
			return new Error(InternalError, e.message);
		}
		return true;
	}

	public function exists(path:String):Future<Bool> {
		return Future.immediate(resolvePath(path).exists());
	}

	public function read(path:String):Task<String> {
		var fullPath = resolvePath(path);
		if (!fullPath.exists()) return new Error(NotFound, 'The file $path does not exist');
		return try fullPath.getContent() catch (e) return new Error(InternalError, e.message);
	}

	public function readBytes(path:String):Task<Bytes> {
		var fullPath = resolvePath(path);
		if (!fullPath.exists()) return new Error(NotFound, 'The file $path does not exist');
		return try fullPath.getBytes() catch (e) return new Error(InternalError, e.message);
	}

	public function copy(source:String, dest:String):Task<Bool> {
		var fullSource = resolvePath(source); // @todo: Should we do this?
		var fullDest = resolvePath(dest);

		if (!fullSource.exists()) {
			return new Error(NotFound, 'The file $fullSource cannot be copied as it does not exist');
		}

		return ensureDir(fullDest.directory()).then(_ -> {
			try {
				fullSource.copy(dest);
			} catch (e) {
				return new Error(InternalError, e.message);
			}

			return true;
		});
	}

	public function write(path:String, data:String):Task<Bool> {
		var fullPath = resolvePath(path);
		return ensureDir(fullPath.directory()).then(_ -> {
			try {
				fullPath.saveContent(data);
			} catch (e) {
				return new Error(InternalError, e.message);
			}
			return true;
		});
	}

	public function remove(path:String):Task<Bool> {
		var fullPath = resolvePath(path);
		if (!fullPath.exists() || fullPath.isDirectory()) return false;
		fullPath.deleteFile();
		return true;
	}

	public function open(path:String, handle:(input:FileInput) -> Void) {
		handle(File.read(path));
	}

	function resolvePath(path:String) {
		if (path.isAbsolute()) return path;
		return Path.join([root, path]).normalize();
	}

	function ensureDir(dir:String):Task<Nothing> {
		if (dir == '') return Task.nothing();
		if (!dir.isDirectory()) {
			if (dir.exists()) {
				return new Error(NotAcceptable, '$dir is not a valid directory');
			}
			dir.createDirectory();
		}
		return Task.nothing();
	}
}
