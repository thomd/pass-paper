#!/usr/bin/env bash

readonly VERSION="1.2"
readonly LINE_WIDTH=72
SEPARATOR="="

_die() { printf '  Error: %s\n' "$*" >&2 && exit 1; }

cmd_paper_version() {
  cat >&1 <<-_EOF

  $PROGRAM paper $VERSION - a pass extension that prints your password to paper.
_EOF
}

cmd_paper_usage() {
  cmd_paper_version
  cat >&1 <<-_EOF

  USAGE:

    $PROGRAM paper [-s SEPARATOR] pass-name

  OPTIONS:

    -s, --sep SEPARATOR          Use SEPARATOR char to separate non-printable content (default is 7 '${SEPARATOR}')
    -V, --version                Show version information
    -h, --help                   Print this help message and exit

  EXAMPLES:

    pass paper | lp                                       Print all passwords
    pass paper | pr | lp                                  Print all passwords in a printer-friendly format
    pass paper | pr | lp -o media=A4 -o number-up=4       Print all passwords with 4 pages per sheet
    pass paper folder | lp                                Print all password from 'folder'
    pass paper folder/password | lp                       Print password 'folder/password'
    pass paper -s '<' | lp                                Print all passwords with content above separator '<<<<<<<' (7 chars minimim)
_EOF
}

_yesno() {
  echo
  read -r -p "  do you really want to print your passwords to stdout? [y/N] " response
  [[ $response == "y" || $response == "Y" ]] || exit 1
  echo
}

_title() {
  local pad
  # shellcheck disable=SC2046
  pad=$(printf '%0.1s' $(eval echo "-{1..$LINE_WIDTH}"))
  local title="${1/$PREFIX/}"
  title="${title/\//}"
  printf "\n%*.*s" 0 4 "$pad"
  printf " %s " "${title%.*}"
  printf "%*.*s\n" 0 $((${#pad} - ${#title} )) "$pad"
}

_show() {
  if [ -f "$1" ]; then
    #  1. decode
    #  2. quit on line with separator
    #  3. remove line with separator
    #  4. remove empty lines
    #  5. word wrap long lines
    #  6. indent and add an extra empty line
    $GPG -d "${GPG_OPTS[@]}" "$1" \
      | sed "/^${SEPARATOR}\{7\}/q" \
      | sed "/^${SEPARATOR}\{7\}/d" \
      | sed /^$/d \
      | fold -s -w "$LINE_WIDTH" \
      | awk '{print "  " $0}END{print " "}' \
    || exit $?
  fi
}

cmd_paper() {
  local passfile
  if [ -z "$1" ]; then
    while read -r passfile
    do
      _title "${passfile#./}"
      _show "${passfile#./}"
    done < <(find $PREFIX -type f -name "*.gpg")
    exit 0
  fi

  local path="${1%/}"
  passfile="$PREFIX/$path.gpg"
  local passfolder="$PREFIX/$path"
  if [ -f "$passfile" ]; then
    _title "$passfile"
    _show "$passfile"
  elif [ -d "$passfolder" ]; then
    for pf in "$passfolder"/*.gpg; do
      _title "$pf"
      _show "$pf"
    done
  fi
}

small_arg="hs:V"
long_arg="help,sep:,version"
opts="$($GETOPT -o $small_arg -l $long_arg -n "$PROGRAM $COMMAND" -- "$@")"
err=$?
eval set -- "$opts"
while true; do case $1 in
  -h|--help) shift; cmd_paper_usage; exit 0 ;;
  -V|--version) shift; cmd_paper_version; exit 0 ;;
  -s|--sep) SEPARATOR="$2"; shift 2 ;;
  --) shift; break ;;
esac done

if [ $err -ne 0 ]; then
  cmd_paper_usage
  exit 1
fi

if [ "$COMMAND" == "paper" ]; then
  if [ -t 1 ]; then
    _yesno
  fi
  cmd_paper "$@"
fi

exit 0
