#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u@\h.lxc\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
#
#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Dump all our sources of $PATHs here, sort, and reassemble
declare -a PATHS
PATHS=(
    '/usr/local/go/bin'
    '/root/.cargo/bin'
    '/var/lib/git/bash_aliases/tools'
    ${PATH//:/ } )
export PATH="$( echo ${PATHS[@]} | sort -u | sed 's/ /:/g' )"

## Common paths
export BTC="/var/lib/bitcoind"
export GIT="/var/lib/git"
export LBIN="/usr/local/bin"
export LOG="/var/log"
export LTC="/var/lib/litecoind"
export LXC="/var/lib/lxc"
export NG="/etc/nginx"
export TOR="/var/lib/tor"
export WWW="/var/www/html"

## Regular Expressions
export RX_IP='([0-9]{1,3}\.){3}[0-9]{1,3}'
export RX_NET="$REGEX_IPV4_ADDR/([0-9]{1,2}|$REGEX_IPV4_ADDR)"
export RX_SOCK="$REGEX_IPV4_ADDR:[0-9\*]{1,5}"

## Compound commands
alias update-all='apt update && apt full-upgrade -y && apt-get autoremove -y --purge'

# Default flags
alias blkid='blkid -o list'
alias chmod='chmod -vf'
alias chown='chown -vf'
alias cp='cp -vf'
alias df='df -h'
alias free='free -ht'
alias lxc-ls='lxc-ls -f'
alias ls='exa -a'
alias l='exa -a'
alias ll='exa -la'
alias netstat='netstat -plantu'
alias mv='mv -vf'
alias rm='rm -vf'
alias rmr="rm -R"

## Systemd shortcuts
alias sc='systemctl'
alias scd='sc disable'
alias scdr='sc daemon-reload'
alias sce='sc enable'
alias scr='sc restart'

## Shortcuts
alias chmodx='chmod -vf +x'
alias chmodr='chmod -R'
alias chownr='chown -R'
alias cpr='cp -R'
alias entropy='cat /proc/sys/kernel/random/entropy_avail'
alias ip6='ip -6'
alias ip6-pub='ip -6 -o addr | grep -vi "fe80::" | sed -s "s/\\\/\n/g"'

# Function: random-key <bits>
#    Generate a random base64 encoded string of <bits> length
function random-key {
    if [[ -z "$1" ]]; then
        echo "Usage: random-key <bits>"
        return
    fi
    head -c $((($1/3*4)+1)) /dev/random | base64 | head -c $1
}

# Function: lxc-sa
#     Start and attach to container
function lxc-sa {
    if [[ -z "$1" ]]; then
        echo "Usage: lxc-sa -n containername"; exit 1
    elif [[ "$1" == "-n" ]] || [[ "$1" == "--name" ]]; then
        name="$2"
    else
        name="$1"
    fi
    lxc-start -n "$name"
    lxc-wait -s "RUNNING" -n "$name"
    lxc-attach -n "$name"
}


# Function: lxc-stopall
#     Stop all active lxc containers
function lxc-stopall {
    for c in $(sudo -sH lxc-ls --active); do
        echo "Stopping ${c}..."
        lxc-stop -n "${c}"
    done
}


# Function: lxc-restart -n <container>
#     Stop and start a given lxc container
function lxc-restart {
    if [[ -n "$2" ]]; then
        c="$2"
    elif [[ -n "$1" ]]; then
        c="$1"
    else
        echo "Usage: lxc-restart -n containername"; exit 1
    fi
    echo "Restarting ${c}..."
    lxc-stop -n "$c"
    lxc-wait -s "STOPPED" -n "$c"
    lxc-start -n "$c"
}
alias lxc-rs='lxc-restart'


# Function: rand <min> <max>
#     Print random int between <min> and <max> (inclusive)
function rand {
    if [[ -n "$2" ]]; then
       echo $(( ( RANDOM % ( $2 - $1 + 1) ) + $1 ))
       return 1
    fi
    echo "Usage: rand <min> <max>"
}


# Function: gen-hex <bits>
#     Generate a string of hex bits of length <bits>
#     @Depends: rand()
function gen-hex {
    if [[ -z "$1" ]]; then
        echo "Usage: gen-hex <bits>"
        return 1
    fi

    output=""
    for n in `seq 1 $1`; do
        output=$output`printf "%x" "$( rand 0 15 )"`
    done
    echo "$output"
}


# Function: gen-mac <prefix>
#     Generate a random mac address with optional <prefix>
#     @Depends: gen-hex(), rand()
function gen-mac {
    # Append ":" to prefix if needed
    if [[ -n "$1" ]] && [[ "$(echo $1 | tail -c2)" != ":" ]]; then prefix="${1}:"
    else prefix="$1"; fi

    # How many hex pairs to gen?
    len=$( echo "$prefix" | wc -c )
    if [ $len -gt 0 ]; then len=$(( 6 - ( len / 3 ) )); fi

    for n in `seq 1 $len`; do
        # Don't append ":" to last pair
        if [ $n -eq $len ]; then colon=""
        else colon=":"; fi
        # Add pairs to prefix
        prefix="${prefix}$(gen-hex 2)${colon}"
    done

    echo "$prefix"
}

alias clexit='export CLEAN_HISTORY=1; echo "" > "$HOME/.bash_history"; clear; exit'
alias cexit='clexit'
alias cxit='clexit'

# Text color
export DEFAULT='\e[39m'
export BLACK='\e[30m'
export RED='\e[31m'
export GREEN='\e[32m'
export YELLOW='\e[33m'
export BLUE='\e[34m'
export MAGENTA='\e[35m'
export CYAN='\e[36m'
export WHITE='\e[97m'

# Background color
export BGDEFAULT='\e[49m'
export BGBLACK='\e[40m'
export BGRED='\e[41m'
export BGYELLOW='\e[43m'
export BGBLUE='\e[44m'
export BGMAGENTA='\e[45m'
export BGCYAN='\e[46m'
export BGWHITE='\e[107m'

# Text style
export RESET='\e[0m'
export BOLD='\e[1m'
export UNDERLINE='\e[4m'

# Functions
function red { echo -e "${RED}${BOLD}${*}${RESET}${DEFAULT}"; }
function yellow { echo -e "${YELLOW}${BOLD}${*}${RESET}${DEFAULT}"; }
function green { echo -e "${GREEN}${BOLD}${*}${RESET}${DEFAULT}"; }
function blue { echo -e "${BLUE}${BOLD}${*}${RESET}${DEFAULT}"; }
function magenta { echo -e "${MAGENTA}${BOLD}${*}${RESET}${DEFAULT}"; }
function cyan { echo -e "${CYAN}${BOLD}${*}${RESET}${DEFAULT}"; }
function white { echo -e "${WHITE}${BOLD}${*}${RESET}${DEFAULT}"; }

