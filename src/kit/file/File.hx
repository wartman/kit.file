package kit.file;

import haxe.io.*;

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
		return adaptor.getMeta(path).next(meta -> this.meta = meta);
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

	public function stream(length:Int):Stream<Bytes> {
		return Stream.generator(yield -> {
			getMeta().handle(result -> switch result {
				case Ok(meta):
					adaptor.open(path, input -> handleStream(length, meta, input, yield));
				case Error(error):
					yield(Errored(error));
			});
		});
	}

	function handleStream(length:Int, meta:FileMeta, input:sys.io.FileInput, yield:(value:kit.Stream.StreamResult<Bytes, kit.Error>) -> Void) {
		switch input.eof() {
			case true:
				input.close();
				yield(Depleted);
			case false:
				var pos = input.tell();
				var remaining = meta.size - pos;

				if (length > remaining) length = remaining;

				yield(Streaming(input.read(length), Stream.generator(handleStream.bind(length, meta, input))));
		}
	}
}
