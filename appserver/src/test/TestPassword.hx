package test;

import utest.Assert;
import crypto.Password;

class TestPassword {
	public function new() {}

	public function testBasic()
	{
		// the default level of security
		var p = Password.create("hello!!!");
		var r = ~/^([a-z0-9]+?)\$(\d+?)\$([a-z0-9]+?)\$[a-z0-9]+$/;
		Assert.isTrue(r.match(p));
		Assert.equals("sha256", r.matched(1));  // algorithm
		Assert.equals("42", r.matched(2));  // iterations
		Assert.equals(5, r.matched(3).length/2);  // bytes of salt

		// plain
		var p = Password.create("hello!!!", SPlain);
		Assert.equals("plain$hello!!!", p);
		Assert.isTrue(p.matches("hello!!!"));
		Assert.isFalse(p.matches("hello!!"));
		Assert.isTrue(( "plain$hello!!!":Password ).matches("hello!!!"));

		// sha256
		var p = Password.create("hello!!!");
		var q = Password.create("hello!!!");
		Assert.notEquals(p.hash, q.hash);
		Assert.match(~/^sha256\$\d+\$[a-z0-9]+\$[a-z0-9]+$/, p);
		var p = Password.create("hello!!!", SSha256(2, "some salt"));
		Assert.isTrue(p.matches("hello!!!"));
		Assert.isFalse(p.matches("hello!!"));
		Assert.isTrue(("sha256$2$6a6f66$a92e6695aff51167d8148a73d2ba0c8875fb582a13db27bc5059404708de9e62":Password).matches("hello!!!"));
	}
}

