FROM ubuntu:15.10
ENV PS1="# "
RUN apt-get update
RUN apt-get install -y git build-essential && mkdir -p /var/git
RUN apt-get install -y ocaml libgc-dev zlib1g-dev libsqlite3-dev libpcre3-dev
RUN git clone --recursive --branch master --depth 1 https://github.com/HaxeFoundation/neko /var/git/neko && cd /var/git/neko && make && make install
RUN git clone --recursive --branch development --depth 1 https://github.com/HaxeFoundation/haxe /var/git/haxe && cd /var/git/haxe && make libs haxe tools install
RUN haxelib setup /usr/share/haxe/lib
RUN apt-get install -y mongodb && mkdir -p /data/db
RUN haxelib install hscript && haxelib install croxit-1 && haxelib install tink_core && haxelib install utest
RUN git clone --recursive --branch master --depth 1 https://github.com/waneck/geotools.git /var/git/geotools && haxelib dev geotools /var/git/geotools
RUN git clone --recursive --branch master --depth 1 https://github.com/waneck/mweb.git /var/git/mweb && haxelib dev mweb /var/git/mweb
RUN git clone --recursive --branch fix-constant-expression-expected --depth 1 https://github.com/jonasmalacofilho/erazor.git /var/git/erazor && haxelib dev erazor /var/git/erazor
RUN git clone --recursive --branch managers --depth 1 https://github.com/jonasmalacofilho/mongo-haxe-driver.git /var/git/mongo-haxe-driver && haxelib dev mongodb /var/git/mongo-haxe-driver
RUN git clone --recursive --branch master --depth 1 https://github.com/jonasmalacofilho/mongo-haxe-managers.git /var/git/mongo-haxe-managers && haxelib dev mongodb-managers /var/git/mongo-haxe-managers/lib

