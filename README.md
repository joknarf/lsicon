[![Joknarf Tools](https://img.shields.io/badge/Joknarf%20Tools-Visit-darkgreen?logo=github)](https://joknarf.github.io/joknarf-tools)
[![bash](https://img.shields.io/badge/shell-bash%20|%20zsh%20|%20ksh%20-blue.svg)]()
[![bash](https://img.shields.io/badge/OS-Linux%20|%20macOS%20|%20SunOS%20...-blue.svg)]()
[![Licence](https://img.shields.io/badge/licence-MIT-blue.svg)](https://shields.io/)

# lsicon

Simplest and fastes ls command enhancer in less than 16K (only uses bash/ls/awk)

![image](https://github.com/user-attachments/assets/d76ec9f8-b745-46ef-8ce1-2c667ba7c578)

Much faster than other "modern" tools (here /usr containing ~150000 files):

| Tool       | Command                | Time (wsl ubuntu)  | Time (centos9)   |
|------------|------------------------|--------------------|------------------|
|            |                        | `tty       notty`  | `tty     notty`  |
| GNU ls     | `ls -lR --color /usr ` | `10.250s   6.001s` | `2.011s  1.049s` |   
| **lsicon** | `ls+ -lR /usr        ` | `10.878s   6.096s` | `3.202s  1.269s` |   
| lsd        | `lsd -lR /usr        ` | `27.941s  13.698s` | `8.564s  2.627s` |
| eza        | `eza --icons -lR /usr` | `31.340s  28.509s` | `8.795s  4.751s` |

## features

* all GNU ls features
* display colors/icons according to file types/extensions/permissions
* display symlink target according to target file types/permissions
* display broken symlink
* highlight current user/groups and permissions
* easy customization for colors/icons/extensions

## Prerequisites

* GNU ls
  * on BSD/MacOS/Alpine coreutils package needed
* GNU awk
  * on BSD/MacOS/Alpine gawk package needed
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
By default with stdout not a tty, `ls+` falls back to ls command, if want to pipe to pager (less...) with icons/colors:
```
ls+ --color |less -RESX
```

## Customize

You can customize all icons association :
- editing `ls+.icons`
- creating a `~/.config/ls+/icons` file
- format of file : `<icon> .<ext> [.<ext>...]`

You can customize all colors association :
- editing `ls+.colors`
- creating a `~/.config/ls+/colors` file
- format of file : `<colorname> .<ext> [.<ext>...]`

You can customize all theme colors :
- editing `ls+.theme`
- creating a `~/.config/ls+/theme` file
- format of file : `<colorname> <r;g;b>`
- creating an empty theme, will use standard 16 colors
