TikMu existing documentation
============================


Repository index
----------------

/
├── appserver        all actual code running (application server + client side code)
│   ├── src          haxe sources and direct assets, such as templates (stored with routes)
│   ├── www          output directory that will be served over http, including static assets
│   ├── build.hxml   app server build recipe
│   └── test.hxml    unit tests execution recipe
├── documentation    (this directory)
├── experiments      an assortment of experiments
├── tools            helper tools
│   ├── rescore      tool: resets and recomputes all reputations (user, answer and question)
├── Build.hx         autonomous build script (used by the CI – continuous integration – server)
└── README.md


Documentation index
-------------------

Simplified directory of existing documentation:

/documentation
├── local-setup
│   └── pre-commit       shell script git hook to prevent broken commits
├── server-setup
│   ├── github-listener  (dir) webhook to github push events that rebuilds the CI server
│   ├── nginx-config     (dir) for the CI server
│   ├── iptables.v4      simple firewall configuration
│   └── tora.service     systemd service file for tora
├── live-server.md       live and self updating development server
└── README.txt           (this file)


Commit and issue tags
---------------------

Commit and issue tags are used to roughly indicate the scope of a change.  The
following tags are currently being used:

     API:  application programming interface; includes routes, for now
    Auth:  authorization and authentication system (register, login, session, ...)
      CI:  self updating server, its build script and its GitHub listener
 Cleanup:  clean or remove old/bad code
    Docs:  documentation
  Effect:  reputation and notification systems
     Fix:  fix of a bug or issue (official or not)
    Impl:  implementation change that should not have visible side effects for users or the db
   Minor:  changes that have little or no effect on the code execution
    Tool:  auxiliary tool
      UI:  user interface

Older or deprecated tags:

  Notify:  notification system
     Rep:  reputation system
  Voting:  changes required to implement answer up and downvoting

