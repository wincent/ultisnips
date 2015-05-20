#!/usr/bin/env bash

# Installs a known version of vim in the travis test runner.
set -ex

build_vanilla_vim () {
   local URL=$1; shift;

   mkdir vim_build
   pushd vim_build

   until curl $URL -o vim.tar.bz2; do sleep 10; done
   tar xjf vim.tar.bz2
   cd vim${VIM_VERSION}

   local PYTHON_CONFIG_DIR=$(dirname $(find /opt -iname 'config.c' | grep $TRAVIS_PYTHON_VERSION))
   local PYTHON_BUILD_CONFIG=""
   if [[ $TRAVIS_PYTHON_VERSION =~ "2." ]]; then
      PYTHON_BUILD_CONFIG="--enable-pythoninterp --with-python-config-dir=${PYTHON_CONFIG_DIR}"
   else
      PYTHON_BUILD_CONFIG="--enable-python3interp --with-python3-config-dir=${PYTHON_CONFIG_DIR}"
   fi
   ./configure \
      --prefix=${HOME} \
      --disable-nls \
      --disable-sysmouse \
      --disable-gpm \
      --enable-gui=no \
      --enable-multibyte \
      --with-features=huge \
      --with-tlib=ncurses \
      --without-x \
      ${PYTHON_BUILD_CONFIG}

   make install
   popd

   rm -rf vim_build
}

if [[ $VIM_VERSION == "74" ]]; then
   build_vanilla_vim ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2
elif [[ $VIM_VERSION == "NEOVIM" ]]; then
   pip install neovim
else
   echo "Unknown VIM_VERSION: $VIM_VERSION"
   exit 1
fi

printf "py3 import sys;print(sys.version);\nquit" | /home/travis/bin/vim  -e -V9myVimLog

cat myVimLog

exit 1

# Clone the dependent plugins we want to use.
./test_all.py --clone-plugins
