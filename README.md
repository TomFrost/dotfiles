# Tom's dotfiles
Mostly original configs, totally original installer. Compatible with macOS and various Linuxes.

## Another installer? Why?

- It's based on [GNU Stow](https://www.gnu.org/software/stow/).
- Automatically backs up any existing dotfiles before they get replaced.
- It's wonderfully modular and OS-independent. Dotfiles are organized in per-app packages.
- Each dotfile package can have its own install script. For example, installing the zsh dotfiles installs zsh itself, and makes it your default shell.
- With no arguments, it installs a defined list of packages depending on your OS. But you can also install them piecemeal.
- Because it's stow, you can also uninstall dotfile packages by name with a single command.

## Usage

### DISCLAIMER
**If you are not me (and statistially, you're not!), do not install these dotfiles directly.** Fork this repo, and at a _minimum_, edit `git/.gitconfig` with your own info before installing.

### Installing from a single command (if you're me)

```shell
sh <(curl -fsSL https://rawgit.com/TomFrost/dotfiles/master/install.sh)
```

The above command only requires bash, curl, and an OS package manager. If you're on a mac, [brew](http://brew.sh) will be installed automatically if it's not there. This repo will automatically be cloned into `~/.dotfiles`. Want it somewhere else? Set `DOTFILES_DIR=${HOME}/somewhere/else`.

### Picking and choosing

By default, the install script will install a set of dotfile packages appropriate for your OS. If you want to install non-default packages, or none of the defaults, just specify the package to install:

```shell
git clone https://github.com/TomFrost/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh tmux
```

If you didn't install the default set, it's highly recommended to `./install.sh stow` first.

### Editing the default package sets

The default packages are determined by the output of `uname -s`. You can find them defined near the top of `install.sh`, looking something like this:

```shell
# Default packages to install, by system
packages_Darwin=(stow git iterm2 tmux vim zsh)
packages_Linux=(stow git tmux vim zsh)
```

Just add (or remove) folder names in the space-separated lists.

### Removing an installed package

It's up to you to remove software packages you no longer want using your package manager. To remove a dotfile package, execute the following from the `.dotfiles` directory:

```shell
stow -D tmux
```

Replace tmux with the name of the package to unlink.

### Adding a new package

Adding a new set of dotfiles is simple. Just create a new folder in `~/.dotfiles`, and put your dotfiles in it. Need them to live somewhere other than `${HOME}` when they're installed? Just replicate the folder structure you need. Check out `iterm2` for a great example.

Include a file named `install_` at the root of your package, and the install script will execute it via bash before linking your dotfiles. All the functions set up in `install.sh` are available to call, so feel free to run commands like `pkg_install_if_missing cowsay`, `is_mac`, and `echo_info "You look mighty fine today, $USER"`. This is also the appropriate place to link, create, or copy files that don't belong under `${HOME}`.

If you need other files in your package that shouldn't be symlinked under `${HOME}`, the installer will ignore any files ending in `_`. Go nuts.

## This repo is for me
I'm always happy to share, but these are my personal configs, and they live and breathe. I'll edit and break them without warning. I won't post compatibility warnings or toil over semantic versioning. I may decide to compeltely rewrite my install script one day. If you like any of these configs, fork the repo so you're in control of them. Use at your own risk.

## License
The contents of this repo are Copyright Tom Shawver under the included ultra-permissive MIT license unless stated otherwise.

