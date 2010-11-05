#!/bin/bash

# Purpose: Simple wrapper to use Debian package manager as pacman
# Author : Anh K. Huynh
# License: Public domain
# Source : http://github.com/icy/pacapt/

_POPT=""
_SOPT=""
_PKG=""
_VERBOSE=""
_FORCE=""

_error() {
  echo >&2 ":: $*"
}

_help() {
  cat <<\EOF
Pacman-liked program for Debian users.

Syntax
  $0 <operator> <option> <packages>

Operators

  Query
    -Ql <package>   list package's files
    -Qi <package>   print package status

  Synchronize
    -S <package>    install packages
    -Su             upgrade the system
    -Sy             update package database

Options
  -f                force yes
  -v                be verbose

This program is written by Anh K. Huynh. You can find the original source
and other information at project's home
                http://github.com/icy/pacapt/.
EOF
}

_exec() {
  _error "Going to execute: $* $_VERBOSE $_FORCE"
  exec $* $_VERBOSE $_FORCE
}

while getopts "QShfvlisq" opt; do
  case "$opt" in
    Q|S)
      if [ "$_POPT" != "" -a "$_POPT" != "$opt" ]; then
        _error "Only one operation may be used at a time"
        exit 1
      fi
      _POPT="$opt"
      ;;
    l|i|q|y)  _SOPT="$opt" ;;
    f)        _FORCE="-f --force-yes" ;;
    v)        _VERBOSE="-v" ;;
    h)        _help; exit 0 ;;
  esac
done
shift $((OPTIND - 1))

_PKG="$*"

if [ -z "$_POPT" ]; then
  _error "No operation specified (use -h for help)"
  exit 1
fi

case "$_POPT$_SOPT" in
  "Qi") _exec "dpkg-query -s $_PKG" ;;
  "Ql") _exec "dpkg-query -l $_PKG" ;;
  "Su") _exec "apt-get upgrade" ;;
  "Sv") _exec "apt-get" ;;
  "S" )
    if [ -z "$_PKG" ]; then
      _error "You must specify a package"
      exit 1
    else
      _exec "apt-get install $_PKG"
    fi
  ;;
esac