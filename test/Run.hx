import spec.BasicsSuite;
import kit.spec.*;
import kit.spec.reporter.*;

function main() {
	var reporter = new ConsoleReporter({
		title: 'Kit File Tests',
		verbose: true,
		trackProgress: true
	});
	var runner = new Runner();
	runner.addReporter(reporter);

	runner.add(BasicsSuite);

	runner.run();
}
