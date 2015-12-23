TikMu
=====

This is the central repository for the TikMu app.

Two self-updating servers exist, both posting build statuses on Slack.  They
default to the master branch, but branches other than that can be request via
subdomains. More information about that resides exists at
[documentation/live-server.md](documentation/live-server.md).

[![The stable server](https://img.shields.io/badge/live%20at-maxikali.com-yellowgreen.svg)](https://maxikali.com/)
[![The new Robrt based server](https://img.shields.io/badge/live%20at-new.maxikali.com-brightgreen.svg)](https://new.maxikali.com/)
[![Our slack](https://img.shields.io/badge/gitter-join %20chat-red.svg)](https://tikmu.slack.com)


## Building

We require a recent development branch version of HaxeFoundation/haxe and some
haxelibs.  The full list can be seen at [.robrt.Dockerfile](.robrt.Dockerfile),
which is the Dockerfile used by our (new) live build system.


## Copyright

Copyright 2014-2015, TikMu.  All rigths reserved.

All intellectual property rights in this repository are owned by, or have been
licensed to, TikMu.  All such rights are reserved.

TikMu is a partnership between Arthur Szász, Cauê Waneck, Flávio Fraschetti,
Gabriel Gorski and Jonas Malaco.

