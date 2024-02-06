package spec;

class BasicsSuite extends Suite {
	function execute() {
		var root = Sys.getCwd();
		var adaptor = new SysAdaptor(Path.join([root, 'test']));
		var dir = new Directory('fixture', adaptor);

		describe('kit.file.Directory', () -> {
			it('should list files in a directory', spec -> {
				spec.expect(1);

				dir.listFiles().next(files -> {
					files.length.should().be(2);
					true;
				});
			});

			it('should give access to files', spec -> {
				spec.expect(1);

				dir.getFile('a.txt').next(file -> file.read()).next(content -> {
					content.should().be('This is file a.');
					true;
				});
			});
		});
	}
}
