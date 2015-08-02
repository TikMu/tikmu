TikMu existing documentation
============================


Repository index
----------------

 /
 ├── appserver          all actual code running: application server + client side
 │   ├── src            haxe sources and direct assets such as templates
 │   ├── www            output directory including static assets
 │   ├── build.hxml     app server build recipe
 │   └── test.hxml      unit tests execution recipe
 ├── documentation      (this directory)
 ├── experiments        an assortment of experiments
 ├── tools              helper tools
 │   ├── rescore        resets and recomputes all reputations
 ├── Build.hx           autonomous build script (used by the CI server)
 └── README.md          welcome file


Documentation index
-------------------

Simplified directory of existing documentation:

 /documentation
 ├── local-setup
 │   └── pre-commit         shell script git hook to prevent broken commits
 ├── server-setup
 │   ├── github-listener    (dir) webhook to github push events for rebuilding the server
 │   ├── nginx-config       (dir) settings for the CI server
 │   ├── iptables.v4        simple firewall configuration for the CI server
 │   └── tora.service       systemd service file for tora
 ├── live-server.md         live and self updating development server
 └── README.txt             (this file)


Commit and issue tags
---------------------

Commit and issue tags are used to roughly indicate the scope of a change.  The
following tags are currently being used:

     Api:  application programming interface; includes routes, for now
    Auth:  authorization and authentication system (register, login, session, ...)
 Cleanup:  clean or remove old/bad code
    Docs:  documentation
  Effect:  reputation and notification systems
     Fix:  fix of a bug or issue (official or not)
    Impl:  implementation change that should not have visible side effects for users or the db
   Minor:  changes that have little or no effect on the code execution
  Server:  self updating server, its build script and its GitHub listener
    Tool:  auxiliary tool
      UI:  user interface

Older or deprecated tags:

      CI:  self updating server
    Hook:  GitHub event listener
  Notify:  notification system
     Rep:  reputation system
  Voting:  changes required to implement answer up and downvoting

