[![Joknarf Tools](https://img.shields.io/badge/Joknarf%20Tools-Visit-darkgreen?logo=github)](https://joknarf.github.io/joknarf-tools)
[![bash](https://img.shields.io/badge/shell-bash%20|%20zsh%20|%20ksh%20-blue.svg)]()
[![bash](https://img.shields.io/badge/OS-Linux%20|%20macOS%20|%20SunOS%20...-blue.svg)]()
[![Licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://shields.io/)

# lsicon

Simple ls command enhancer in less than 12K (only uses bash/ls/awk)

<img width="1641" height="584" alt="image" src="https://github.com/user-attachments/assets/85f3031a-c7e7-4add-a6eb-30b14efb26cc" />

## Prerequisites

* GNU ls
  * on BSD/MacOS coreutils package needed
* awk
* bash
* Nerd Font in your Terminal

## Install

You can use a plugin manager, like the famous [thefly](https://github.com/joknarf/thefly)
```
. <(curl https://raw.githubusercontent.com/joknarf/thefly/main/thefly) install
fly add joknarf/lsicon
```
or just clone the repo, and put `ls+*` files in dir in your PATH
```
git clone https://github.com/joknarf/lsicon
```

## Usage

The lsicon command `ls+` is used with exactly same options as GNU `ls`
```
ls+
ls+ -alrt
...
```
You may want to replace the `ls` command with ls+ using:
```
alias ls='ls+'
```

## Customize

You can customize all icons association :
- editing `ls+.icons`
- creating a `~/.config/ls+/icons` file
- format of file : `<icon> <ext> [<ext>...]`

You can customize all colors association :
- editing `ls+.colors`
- creating a `~/.config/ls+/colors` file
- format of file : `<colorname> <ext> [<ext>...]`
