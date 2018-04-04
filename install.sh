#!/bin/bash

install_cmd="echo 'This system is not supported :(. That sucks. Sorry dude. Next time.' && exit 1"
executable=$0

# Handy defaults
dot_dir=${DOTFILES_DIR:-${HOME}/.dotfiles}
target_dir=${DOTFILES_TARGET:-$HOME}
backup_dir=${DOTFILES_BACKUP:-${HOME}/.dotfiles_backup}
repo_uri=${DOTFILES_REPO:-git@github.com:TomFrost/dotfiles.git}

# Default packages to install, by system
packages_Darwin=(stow macos git iterm2 tmux rtmux vim zsh mount_autorun)
packages_Linux=(stow git tmux vim zsh)

usage() {
    cat <<EOF
Usage: ${executable} [package]

If executed without arguments, all default packages for your specific system
will be installed. Execute with a package name to install a single specific
package.

EOF
}

echo_error() {
    echo -e "\033[0;31m[ :( ] $1 \033[0m"
}

echo_warn() {
    echo -e "\033[0;33m[ :/ ] $1 \033[0m"
}

echo_success() {
    echo -e "\033[0;32m[ :D ] $1 \033[0m"
}

echo_info() {
    echo -e "\033[1;34m[----] $1 \033[0m"
}

ask_for_sudo() {
    # Ask for the administrator password upfront
    echo_info "Requesting root permission for package installs"
    sudo -v
    if [ "$?" -gt 0 ]; then
        echo_warn "Failed, attempting to continue"
    else
        echo_success "I feel so powerful!"
    fi

    # Update existing `sudo` timestamp until this script has finished
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 59
        kill -0 "$$" || exit
    done &> /dev/null &
}

# run_safe "command to run" "error message" "success message"
run_safe() {
    res=$($1 2>&1)
    if [ $? -gt 0 ]; then
        if [ -n "$2" ]; then
            echo_error "$2"
        else
            echo_error "Failed: $1"
        fi
        echo
        cat <<EOF
$res
EOF
        exit 20
    else
        if [ -n "$3" ]; then
            echo_success "$3"
        else
            echo_success "Success: $1"
        fi
    fi
}

bin_exists() {
    if which $1 > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

bin_is_brewed() {
    path=$(which $1 | grep "^/usr/local")
    if [[ is_mac && "$path" == "/usr/local/bin/$1" ]]; then
        return 0
    fi
    return 1
}

is_mac() {
    if [ "$(uname -s)" == "Darwin" ]; then
        return 0
    fi
    return 1
}

install_brew() {
    echo_info "Installing brew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [ "$?" -gt 0 ]; then
        echo_error "Please correct the above and retry"
        exit 5
    fi
    echo_success "Brew successfully installed"
}

bootstrap_pkg_manager() {
    echo_info "Initializing package manager"
    if is_mac; then
        if ! bin_exists brew; then
            install_brew
        fi
        install_cmd=(brew install)
    elif bin_exists apt-get; then
        sudo apt-get update > /dev/null 2>&1
        install_cmd=(sudo apt-get install -y)
    elif bin_exists yum; then
        install_cmd=(sudo yum install)
    elif bin_exists pacman; then
        install_cmd=(sudo pacman -S)
    elif bin_exists emerge; then
        install_cmd=(sudo emerge)
    else
        echo_error "Could not find your package manager. Please update this script!"
        exit 6
    fi
    echo_success "Packages will be installed with '${install_cmd[*]} [package]'"
}

pkg_install() {
    cmd="${install_cmd[*]} $1"
    echo_info "Running $cmd ..."
    run_safe "$cmd" "Please install '$1' manually and re-run script." "Success"
}

pkg_install_if_missing() {
    if ! bin_exists $1; then
        pkg_install ${2:-$1}
    fi
}

repo_cloned() {
    if [ -d "$dot_dir" ]; then
        return 0
    fi
    return 1
}

ensure_cloned() {
    if ! repo_cloned; then
        pkg_install_if_missing git
        echo_info "Cloning dotfiles repo"
        run_safe "git clone $repo_uri $dot_dir" "Failed cloning repo" "Cloned into $dot_dir"
    fi
}

image_exists() {
    if [ -d "$dot_dir/$1" ]; then
        return 0
    fi
    return 1
}

run_install_script() {
    inst_script="$dot_dir/$1/install_"
    if [ -f "$inst_script" ]; then
        source $inst_script
    fi
}

backup_existing() {
    existing=$(stow -n -d "$dot_dir" -t "$target_dir" --ignore="_" $1 2>&1 | \
        grep "existing target" | sed -e 's/^.*: //g')
    if [ "$existing" != "" ]; then
        echo_info "Moving existing files to $backup_dir ..."
        for i in "${existing[@]}"; do
            echo_info "Moving $i"
            dir=$(dirname $i)
            mkdir -p "${backup_dir}/${dir}" && mv ${target_dir}/${i} ${backup_dir}/${i}
        done
        echo_success "All conflicting files for $1 have been moved"
    fi
}

image_install() {
    echo_info "Installing image: $1"
    if ! image_exists $1; then
        echo_error "$1 does not exist in .dotfiles"
        exit 10
    fi
    run_install_script $1
    backup_existing $1
    res=$(stow -d "$dot_dir" -t "$target_dir" -R --ignore="_" $1 2>&1)
    if [ $? -eq 0 ]; then
        echo_success "Installed $1"
    else
        echo_error "Could not stow $1:\n"
        cat <<EOF
$res
EOF
        exit 11
    fi
}

attempt_single_image_install() {
    if [ -n "$1" ]; then
        image_install $1
        exit 0
    fi
}

default_install() {
    system=$(uname -s)
    echo_info "Finding default images for $system..."
    code="{packages_${system}[@]}"
    code="list=(\$$code)"
    eval $code
    if [ ! -n "$list" ]; then
        echo_error "System not recognized. Time to update this script!"
        exit 7
    else
        echo_success "Got image list: ${list[*]}"
    fi
    for i in "${list[@]}"; do
        image_install $i
    done
}

# Application start!
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
fi
ask_for_sudo
bootstrap_pkg_manager
ensure_cloned
pkg_install_if_missing stow
attempt_single_image_install $1
default_install

