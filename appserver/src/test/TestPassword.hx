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
		Assert.match(~/^sha256/, new Password("hello!!!"));

		// plain
		Assert.equals("plain$hello!!!", new Password("hello!!!", SPlain));
		Assert.isTrue(new Password("hello!!!", SPlain).matches("hello!!!"));
		Assert.isFalse(new Password("hello!!!", SPlain).matches("hello!!"));

		// sha256
		// FIXME check salt size and other info
		// ideally, check againt other impl or manual checking
		Assert.match(~/^sha256\$\d+\$[a-z0-9]+\$[a-z0-9]+$/, new Password("hello!!!"));
		Assert.isTrue(new Password("hello!!!").matches("hello!!!"));
		Assert.isFalse(new Password("hello!!!").matches("hello!!"));
	}
}

