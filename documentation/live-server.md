The live server
===============


> **We're missing a proper SSL setup and other security enhancements.  Don't
> reuse a password from somewhere else and don't post any private or valuable
> data.**


The old setup
-------------

A rudimentary CI deployment lives at [https://maxikali.com].

It responds automatically to push events from the upstream repository on
GitHub, and builds the head commit of the pushed branch in roughly 10 seconds.

Rebuilds use the script `Build.hx` from the desired tree to automatically set
up dependencies and do the actual build.  This Haxe `--run` script downloads
and installs the necessary libraries on a local haxelib repository.

When viewing [https://104.236.51.222] on a web browser, the default ('master')
branch is showed.  Other branches are available as subdomains.  Alternatively,
it is possible to send with all requests a `X-Dev-Branch` header set to the
desired branch name.

It's also possible to request tags (instead of branches) and to avoid ambiguity
by supplying the `X-Dev-Ref` header with a `$refType/$refName` string (example:
`heads/master` or `tags/alpha`).  Note: specifying a ref supersedes specifying
a branch.

To manipulate the request headers in your browser it's probably more convenient
to use a specialized extension; on Firefox we have been using [Modify Headers].

Finally, auxiliary information (such as the commit or branch of the current
build) is available from: [https://104.236.51.222/infos.json], and the `#robot`
Slack channel is used for notifications.

[Modify Headers]: https://addons.mozilla.org/en-US/firefox/addon/modify-headers/


The new setup
-------------

The new build system is built on top of Robrt – itself built on Haxe, Node.js
and Docker – and aims to be much more general and, consequently, reliable.

These new builds are available at [https://new.maxikali.com], with branches other
than 'master' accessible as subdomains.

This new setup can also handle pull requests – accessible through
`pr-<number>.` subdomains – and for them adds commit statuses on GitHub.

As with the old setup, build notifications are sent to the `#robots` channel on
Slack.

