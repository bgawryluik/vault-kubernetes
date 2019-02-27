#!/usr/bin/env bash

# DESC: Pretty printing functions inspired from https://github.com/Sajjadhosn/dotfiles
# ARGS: $1 (REQ): String text message
#       $2 (REQ): Text color
#       $3 (REQ): Arrow (string representation)
# OUT: NONE
function coloredEcho() {
    local color="${2}"
    if ! [[ ${color} =~ '^[0-9]$' ]]; then
        case $(echo ${color} | tr '[:upper:]' '[:lower:]') in
            black)   color=0 ;;
            red)     color=1 ;;
            green)   color=2 ;;
            yellow)  color=3 ;;
            blue)    color=4 ;;
            magenta) color=5 ;;
            cyan)    color=6 ;;
            white|*) color=7 ;;
        esac
    fi

    tput bold
    tput setaf "${color}"
    echo "${3} ${1}"
    tput sgr0
}

# DESC: Print an info message
# ARGS: $1: String text message
# OUT: printed string message
function info() {
    coloredEcho "${1}" blue "========>"
}

# DESC: Print a success message
# ARGS: $1: String text message
# OUT: printed string message
function success() {
    coloredEcho "${1}" green "========>"
}

# DESC: Print an error message
# ARGS: $1: String text message
# OUT: printed string message
function error() {
    coloredEcho "${1}" red "========>"
}

# DESC: print a substep info message
# ARGS: $1: String text message
# OUT: printed string message
function substep_info() {
    coloredEcho "${1}" magenta "===="
}

# DESC: print a substep success message
# ARGS: $1: String text message
# OUT: printed string message
function substep_success() {
    coloredEcho "${1}" cyan "===="
}

# DESC: print a substep error message
# ARGS: $1: String text message
# OUT: printed string message
function substep_error() {
    coloredEcho "${1}" red "===="
}
