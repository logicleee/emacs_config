#!/usr/bin/env bash
# used for converting Emacs LaTeX to PDF

brew install --cask basictex

eval "$(/usr/libexec/path_helper)"
sudo tlmgr update --self
sleep 1
sudo tlmgr option repository ctan
sleep 1

# ! LaTeX Error: File `wrapfig.sty' not found.
# ! LaTeX Error: File `marvosym.sty' not found.
# ! LaTeX Error: File `wasysym.sty' not found.
# ! LaTeX Error: File `titlesec.sty' not found.
# ! LaTeX Error: File `fullpage.sty' not found.

sudo tlmgr install collection-fontsrecommended
sudo tlmgr install wrapfig
sudo tlmgr install marvosym
sudo tlmgr install wasysym
sudo tlmgr install titlesec
sudo tlmgr install preprint #fullpage
sudo tlmgr install enumitem
