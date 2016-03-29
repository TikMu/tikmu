TikMu
=====

This is the central repository for the TikMu app.

A self-updating server exists, and it posts build statuses on Slack.  It
defaults to the master branch, but branches other than that can be request via
subdomains. More information about that resides at
[`documentation/live-server.md`](documentation/live-server.md).

[![The new Robrt based server](https://img.shields.io/badge/live%20at-new.maxikali.com-brightgreen.svg)](https://new.maxikali.com/)
[![Our slack](https://img.shields.io/badge/slack-join %20chat-red.svg)](https://tikmu.slack.com)


## Building and running

To build TikMu, it is necessary a recent development branch version of
HaxeFoundation/haxe and some haxelibs.  The full list can be seen at
[`.robrt.Dockerfile`](.robrt.Dockerfile), which is directly used by our _new_
live build system.

Additionally, Mongodb and Tora are required at runtime.


## Copyright

Copyright 2014-2015, TikMu.  All rigths reserved.

All intellectual property rights in this repository are owned by, or have been
licensed to, TikMu.  All such rights are reserved.

TikMu is a partnership between Arthur Szász, Cauê Waneck, Flávio Fraschetti,
Gabriel Gorski and Jonas Malaco.

