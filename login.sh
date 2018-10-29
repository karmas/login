#! /bin/env bash

set -eu

function addHost()
{
 declare -n hostRef=$1
 local numPairs=${#hostRef[@]} pair sepIndex
 (( numPairs < 1 )) && return

 for pair in "${hostRef[@]}"; do
   key=${pair%%:*}
   key="${KEYPREFIX}${numHosts}_${key#* }"
   val=${pair#*:}
   val=${val#* }
   allHosts[$key]="$val"
 done
 ((++numHosts))
}

function readHosts()
{
  local line='' host=()
  while read line; do
    if [ ${line:0:1} = - ]; then
      addHost host
      unset host
      host=("${line#-}")
    else
      host+=("${line}")
    fi
  done < $hostsFile
  addHost host
}

function calcColWidthFor()
{
  local key=$1 index=$2 width=2 val valLen
  for (( i = 0; i < numHosts; ++i )) {
    val=${allHosts["${KEYPREFIX}${i}_$key"]:-}
    valLen=${#val}
    (( valLen > width )) && width=$valLen
  }
  colwidths[$index]=$width
}

function calcColWidths()
{
  calcColWidthFor name 1
  calcColWidthFor ip 2
  calcColWidthFor user 3
}

function printHosts()
{
  printf "%*s%s%-*s%s%-*s%s%-*s%s%s\n" \
    ${colwidths[0]} id "$COLSEP" \
    ${colwidths[1]} name "$COLSEP" \
    ${colwidths[2]} ip "$COLSEP" \
    ${colwidths[3]} user "$COLSEP" \
    detail
  local i prefix
  for ((i = 0; i < numHosts; ++i)) {
    prefix="${KEYPREFIX}${i}_"
    printf "%*s%s%-*s%s%-*s%s%-*s%s%s" \
      ${colwidths[0]} $i "$COLSEP" \
      ${colwidths[1]} "${allHosts["${prefix}name"]:-}" "$COLSEP" \
      ${colwidths[2]} "${allHosts["${prefix}ip"]}" "$COLSEP" \
      ${colwidths[3]} "${allHosts["${prefix}user"]:-}" "$COLSEP" \
      "${allHosts["${prefix}detail"]:-}"
    echo
  }
}

function login()
{
  local id cmd prefix user keyfile password
  read -p 'enter id to login: ' id
  prefix="${KEYPREFIX}${id}_"
  user=${allHosts["${prefix}user"]:-}
  if [ -z "$user" ]; then
    if [ -n "${USER:-}" ]; then
      user=${USER}
    # windows bash
    elif [ -n "${USERNAME:-}" ]; then
      user=${USERNAME}
    fi
  fi

  keyfile="${allHosts["${prefix}keyfile"]:-}"
  [ -n "$keyfile" ] && keyfile="-i $keyfile"

  password="${allHosts["${prefix}password"]:-}"
  [ -n "$password" ] && echo "password: $password"

  cmd="ssh $keyfile $user@${allHosts["${prefix}ip"]}"
  echo $cmd
  $cmd
}

COLSEP=' | '
KEYPREFIX='HOST'
# id name ip user
colwidths=( 2 8 15 11 )
declare -A allHosts
numHosts=0
DEFAULTFILE="$(dirname $0)/hosts.yml"
hostsFile=${1:-"$DEFAULTFILE"}

readHosts
calcColWidths
printHosts
login
