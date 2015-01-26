package test;

import utest.Assert;
import crypto.Password;

class TestPassword
{
	public function new()
	{
		// NOOP
	}

	public function testBasic()
	{
		// the default level of security
		Assert.match(~/^sha256/, Password.create("hello!!!"));

		// plain
		Assert.equals("plain$hello!!!", Password.create("hello!!!", SPlain));
		Assert.isTrue(Password.create("hello!!!", SPlain).matches("hello!!!"));
		Assert.isFalse(Password.create("hello!!!", SPlain).matches("hello!!"));
		Assert.isTrue(( "plain$hello!!!":Password ).matches("hello!!!"));

		// sha256
		// FIXME check salt size and other info
		// ideally, check againt other impl or manual checking
		Assert.match(~/^sha256\$\d+\$[a-z0-9]+\$[a-z0-9]+$/, Password.create("hello!!!"));
		Assert.isTrue(Password.create("hello!!!").matches("hello!!!"));
		Assert.isFalse(Password.create("hello!!!").matches("hello!!"));
	}
}

