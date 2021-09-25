# emacs_config

## Requirements
- macOS Command line developer tools
- homebrew 

## Installation

- Option 1: As a submodule to your existing dotfiles repo:
```
cd <YOUR_DOTFILES_DIR>/
git submodule add https://github.com/logicleee/emacs_config.git
```

- Option 2: As a stand alone repo
```
git clone https://github.com/logicleee/emacs_config.git
```



- Then run the install/setup scripts:
```
cd emacs_config/
# This script installs Emacs (GUI) on macOS:
./scripts/dotfiles-sys-25-install-emacs.sh

# This script links / sets up .emacs.d
./scripts/dotfiles-usr-82-cfg-emacs.sh
```
NOTE: Emacs will attempt to open, but you might have to allow 
it in **System Preferences** > **Security & Privacy** > **General**
Afterward, Emacs will install packages from melpa -- some installs may
fail.  You may need to just quit & restart a few times.

- Optionally add TeX packages
```
#   NOTE: this script requires sudo privileges (but don't run with sudo)
./scripts/dotfiles-sys-25-install-tex-packages.sh
```