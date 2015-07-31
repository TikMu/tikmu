TikMu
=====

This is the central repository for the TikMu app.

A self-updating server lives, and branches other than the master one can be
requested through the `X-Dev-Branch` header.  More generally, any git 'ref' can
be requested by setting the `X-Dev-Ref` accordingly.  More details of the live
server are available on
[documentation/live-server.md](documentation/live-server.md).

[![Check out the live server](https://img.shields.io/badge/live%20at-maxikali.com-brightgreen.svg)](https://maxikali.com/)
[![Join the chat at https://gitter.im/jonasmalacofilho/tikmu](https://img.shields.io/badge/gitter-join %20chat-green.svg)](https://gitter.im/jonasmalacofilho/tikmu?utm_source=badge&utm_medium=badge&utm_content=badge)


## Building

HaxeFoundation/haxe:

 - minimum required tree: HaxeFoundation/haxe@1c17be9
 - currently tested tree: HaxeFoundation/haxe@a2de181

Other dependencies are listed on the build script: [Build.hx](Build.hx).


## Copyright

Copyright 2014-2015, TikMu.  All rigths reserved.

All intellectual property rights in this repository are owned by, or have been
licensed to, TikMu.  All such rights are reserved.

TikMu is a partnership between Arthur Szász, Cauê Waneck, Flávio Fraschetti,
Gabriel Gorski and Jonas Malaco.

