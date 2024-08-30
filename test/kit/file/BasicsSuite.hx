package kit.file;

import kit.file.adaptor.*;

using kit.Testing;

class BasicsSuite extends Suite {
	final dir = new Directory('test/fixture', new SysAdaptor(Sys.getCwd()));

	@:test(expects = 1)
	function shouldListFilesInADirectory() {
		return dir.listFiles().next(files -> {
			files.length.equals(2);
			true;
		});
	}

	@:test(expects = 2)
	function shouldHaveInformationAboutTheDirectory() {
		return dir.getMeta().next(meta -> {
			meta.name.equals('fixture');
			meta.path.equals('test/fixture');
			true;
		});
	}

	@:test(expects = 1)
	function shouldGiveAccessToFiles() {
		return dir.file('a.txt').read().next(content -> {
			content.equals('This is file a.');
			true;
		});
	}

	@:test(expects = 1)
	function shouldLetYouStreamBytesFromFiles() {
		return dir.file('a.txt')
			.stream(6)
			.reduce(new StringBuf(), (accumulator, item) -> {
				accumulator.add(item.toString());
				accumulator;
			})
			.next(buf -> {
				buf.toString().equals('This is file a.');
				Task.nothing();
			});
	}

	@:test(expects = 1)
	function shouldErrorWhenReadingNonExistentFile() {
		return dir.file('bip.text').read().recover(err -> {
			err.code.equals(InternalError);
			Future.immediate('ok');
		});
	}

	// @:test(expects = 1)
	// function shouldLetYouCreateSubdirectories() {
	// 	return dir.directory('foo').create().next(sub -> {
	// 		sub.exists().flatMap(exists -> {
	// 			exists.equals(true);
	// 			Task.nothing();
	// 			// @todo: not implemented yet for directories
	// 			// sub.remove().flatMap(_ -> sub.exists()).flatMap(exists -> {
	// 			// 	exists.should().be(false);
	// 			// 	Task.nothing();
	// 			// });
	// 		});
	// 	});
	// }
}
