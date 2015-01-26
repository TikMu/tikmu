package test;

import utest.Assert;
import crypto.Password;

class TestPassword {
	public function new()
	{
		// NOOP
	}

	public function testBasic()
	{
		// the default level of security
		// FIXME check salt size and number of iterations
		Assert.match(~/^sha256/, Password.create("hello!!!"));

		// plain
		Assert.equals("plain$hello!!!", Password.create("hello!!!", SPlain));
		Assert.isTrue(Password.create("hello!!!", SPlain).matches("hello!!!"));
		Assert.isFalse(Password.create("hello!!!", SPlain).matches("hello!!"));
		Assert.isTrue(( "plain$hello!!!":Password ).matches("hello!!!"));

		// sha256
		Assert.match(~/^sha256\$\d+\$[a-z0-9]+\$[a-z0-9]+$/, Password.create("hello!!!"));
		Assert.isTrue(Password.create("hello!!!").matches("hello!!!"));
		Assert.isFalse(Password.create("hello!!!").matches("hello!!"));
		Assert.isTrue(Password.fromString("sha256$2$6a6f66$a92e6695aff51167d8148a73d2ba0c8875fb582a13db27bc5059404708de9e62").matches("hello!!!"));
		var p1 = Password.create("hello!!!");
		var p2 = Password.create("hello!!!");
		Assert.notEquals(p1.hash, p2.hash);
	}
}

