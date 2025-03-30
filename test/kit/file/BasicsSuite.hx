package kit.file;

import kit.file.adaptor.*;

using kit.Testing;

class BasicsSuite extends Suite {
	final dir = new Directory('test/fixture', new SysAdaptor(Sys.getCwd()));

	@:test(expects = 1)
	function shouldListFilesInADirectory() {
		return dir.listFiles().then(files -> {
			files.length.equals(2);
			true;
		});
	}

	@:test(expects = 2)
	function shouldHaveInformationAboutTheDirectory() {
		return dir.getMeta().then(meta -> {
			meta.name.equals('fixture');
			meta.path.equals('test/fixture');
			true;
		});
	}

	@:test(expects = 1)
	function shouldGiveAccessToFiles() {
		return dir.file('a.txt').read().then(content -> {
			content.equals('This is file a.');
			true;
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
	// 	return dir.directory('foo').create().then(sub -> {
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
