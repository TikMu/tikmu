The live server
===============


> **We're missing a proper SSL setup and other security enhancements.  Don't
> reuse a password from somewhere else and don't post any private or valuable
> data.**


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


The old setup
-------------

A rudimentary CI deployment used to live at ~~[https://maxikali.com]~~.

It responded automatically to push events from the upstream repository on
GitHub, and builded the head commit of the pushed branch in roughly 10 seconds.

Rebuilds used the script `Build.hx` from the desired tree to automatically set
up dependencies and do the actual build.  This Haxe `--run` script downloaded
and installed the necessary libraries on a local haxelib repository.

When viewing ~~[https://104.236.51.222]~~ on a web browser, the default ('master')
branch was showed.  Other branches were available as subdomains.  Alternatively,
it was possible to send with all requests a `X-Dev-Branch` header set to the
desired branch name.

It was also possible to request tags (instead of branches) and to avoid ambiguity
by supplying the `X-Dev-Ref` header with a `$refType/$refName` string (example:
`heads/master` or `tags/alpha`).  Specifying a ref superseded specifying
a branch.

(To manipulate the request headers in the browser it's probably more convenient
to use a specialized extension; on Firefox we have been using [Modify Headers])

Finally, auxiliary information (such as the commit or branch of the current
build) was available from: ~~[https://104.236.51.222/infos.json]~~, and the `#robot`
Slack channel was used for notifications.

[Modify Headers]: https://addons.mozilla.org/en-US/firefox/addon/modify-headers/

