The live server
===============

> **We're missing SSL on both the live server and on the GitHub event listener.
> Don't reuse a password from somewhere else and don't post any private or
> valuable data.**

A rudimentary CI deployment has been set up: http://104.236.51.222

It responds automatically to push events from the upstream repository on
GitHub, and builds the head commit of the pushed branch in roughly 10 seconds.

Rebuilds use the script `Build.hx` from the desired tree to automatically set
up dependencies and do the actual build.  This Haxe `--run` script downloads
and installs the necessary libraries on a local haxelib repository.

When viewing http://104.236.51.222 on a web browser, the default ('master')
branch is showed.  To request branches other than 'master', it is necessary to
send with all requests a `X-Dev-Branch` header set to the desired branch name.

It's also possible to request tags (instead of branches) and to avoid ambiguity
by supplying the `X-Dev-Ref` header with a `$refType/$refName` string (example:
`heads/master` or `tags/alpha`).  Note: specifying a ref supersedes specifying
a branch.

To manipulate the request headers in your browser it's probably more convenient
to use a specialized extension; on Firefox we have been using [Modify Headers].

Finally, auxiliary information (such as the commit or branch of the current
build) is available from: http://104.236.51.222/infos.json

[Modify Headers]: https://addons.mozilla.org/en-US/firefox/addon/modify-headers/

