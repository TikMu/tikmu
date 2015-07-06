package test;

import utest.Runner;
import utest.ui.Report;

class TestAll {
	public static function main()
	{
		var r = new Runner();
		
		r.addCase(new TestPassword());
		r.addCase(new TestSessionCache());

		Report.create(r);

		r.run();
	}
}

