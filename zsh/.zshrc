# Source the .profile if it exists {{{
if [ -f "${HOME}/.profile" ]; then
    source ${HOME}/.profile
fi
# }}}

# Helpful aliases {{{
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
# }}}

# Do what my fat fingers mean {{{
alias l=ls
alias ls-l="ls -l"
alias ls-al="ls -al"
alias iexit=exit
# }}}

# Functions {{{
# Colored man pages
man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
        PAGER="${PAGER:-less}" \
        _NROFF_U=1 \
        man "$@"
}
# }}}

# ZSH options {{{
# Jump to end of autocomplete
setopt alwaystoend
# CD to folder names typed with no other command
setopt autocd
# Sets prompt to read env var instead of dir, when one matches the pwd
#setopt autonamedirs
# Make cd push the old directory onto the directory stack
setopt autopushd
# Treat single word simple commands without redirection as candidates for resumption of an existing job.
setopt autoresume
# Prevents default bahavior of running background jobs at lower priority
unsetopt bgnice
# Prevent case globbing
unsetopt caseglob
# If CDing to invalid dir, attempt to prefix with ~
setopt cdablevars
# Prevent reporting of running background jobs on exit, and don't kill them
unsetopt checkjobs
unsetopt hup
# Don't allow clobbering existing files with > redirection. Use >! to override.
unsetopt clobber
# Our terminal can combined zero-width characters
setopt combiningchars
# Allow completion to happen on both ends of a word, when a cursor is in it
setopt completeinword
# Offer spelling corrections
setopt correct
# Treat the '#', '~' and '^' characters as part of patterns for filename generation, etc.
setopt extendedglob
# Save each command's beginning timestamp and duration to the history file
setopt extendedhistory
# Disable output flow control
unsetopt flowcontrol
# Clear out old history events with duplicates before unique ones
setopt histexpiredupsfirst
# Don't display duplicates when searching history
setopt histfindnodups
# Remove previous dupes when adding new command to history
setopt histignorealldups
# Don't save contiguous dupes
setopt histignoredups
# Commands with a leading space avoid the history
setopt histignorespace
# Clear old dups when saving the history file
setopt histsavenodups
# History expansion should load the line into the cli, not execute it
setopt histverify
# Auto-save new lines to the history file, and import new commands from the history file
setopt sharehistory
# List jobs in long format by default
setopt longlistjobs
# Perform a path search even on command names with slashes in them
setopt pathdirs
# Ignore duplicates in the directory stack
setopt pushdignoredups
# Don't print the directory stack after it's modified
setopt pushdsilent
# Make pushd with no arguments assume pushd $HOME
setopt pushdtohome
# Allow '' to represent a single quote in quoted strings
setopt rcquotes
# }}}

# Load Antibody {{{
# https://github.com/getantibody/antibody
if ! which antibody > /dev/null 2>&1; then
    echo "Antibody is being installed. This may require sudo."
    if which brew > /dev/null 2>&1; then
        brew untap -q getantibody/homebrew-antibody > /dev/null 2>&1 || true
        brew tap -q getantibody/homebrew-antibody
        brew install antibody
    else
        curl -sL https://git.io/antibody | bash -s
    fi
fi
if ! which antibody > /dev/null 2>&1; then
    echo "Error: Antibody could not be loaded."
    exit 1
fi

source <(antibody init)
# }}}

# Theme {{{
antibody bundle mafredri/zsh-async
antibody bundle TomFrost/frost-zsh-prompt
# }}}

# Plugins {{{
antibody bundle zsh-users/zsh-completions
antibody bundle zsh-users/zsh-autosuggestions
antibody bundle zsh-users/zsh-syntax-highlighting
antibody bundle zsh-users/zsh-history-substring-search
# }}}

# Vi mode {{{
KEYTIMEOUT=1
bindkey -v
# Make keys work more like vim, rather than vi. The first fixes backspace.
# See: http://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode
bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
bindkey "^H" backward-delete-char # Control-h also deletes the previous char
bindkey "^U" backward-kill-line
# }}}

# History config {{{
if (( ! EUID )); then
  HISTFILE=~/.zhistory_root
else
  HISTFILE=~/.zhistory
fi
HISTSIZE=1000
SAVEHIST=1000
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# }}}

