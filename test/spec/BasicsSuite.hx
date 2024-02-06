package spec;

class BasicsSuite extends Suite {
	function execute() {
		var adaptor = new SysAdaptor(Sys.getCwd());
		var dir = new Directory('test/fixture', adaptor);

		describe('kit.file.Directory', () -> {
			it('should list files in a directory', spec -> {
				spec.expect(1);

				dir.listFiles().next(files -> {
					files.length.should().be(2);
					true;
				});
			});

			it('should have information about the directory', () -> {
				dir.meta.name.should().be('fixture');
				dir.meta.path.should().be('test/fixture');
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
