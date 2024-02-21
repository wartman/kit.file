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

			it('should have information about the directory', spec -> {
				spec.expect(2);

				dir.getMeta().next(meta -> {
					meta.name.should().be('fixture');
					meta.path.should().be('test/fixture');
					true;
				});
			});

			it('should give access to files', spec -> {
				spec.expect(1);

				dir.file('a.txt').read().next(content -> {
					content.should().be('This is file a.');
					true;
				});
			});

			it('should let you stream bytes from files', spec -> {
				spec.expect(1);

				dir.file('a.txt')
					.stream(6)
					.reduce(new StringBuf(), (accumulator, item) -> {
						accumulator.add(item.toString());
						accumulator;
					})
					.next(buf -> {
						buf.toString().should().be('This is file a.');
						true;
					});
			});

			it('should let you create subdirectories', spec -> {
				spec.expect(1);

				dir.directory('foo').create().next(sub -> {
					sub.exists().flatMap(exists -> {
						exists.should().be(true);
						Task.ofResult(Ok(true));
						// @todo: not implemented yet for directories

						// sub.remove().flatMap(_ -> sub.exists()).flatMap(exists -> {
						// 	exists.should().be(false);
						// 	Task.ofResult(Ok(true));
						// });
					});
				});
			});
		});
	}
}
