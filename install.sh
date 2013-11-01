#!/bin/bash

if [[ ! -e ~/.cask ]]
then
    echo "Cloning Cask repo"
    git clone git@github.com:cask/cask.git ~/.cask
fi

CURRENT_SHELL=`echo ${SHELL##*/}`
if [[ $CURRENT_SHELL == "bash" ]]
    TARGET="~/.bash_profile"
elif [[ $CURRENT_SHELL == "zsh" ]]
    TARGET="~/.zprofile"
fi
    
if [[ $(grep "cask/bin" "$TARGET") == "" ]]
then
    echo "Adding \$HOME/.cask/bin to \$PATH in ~/.bash_profile"
    echo '' >> ~/.bash_profile
    echo "# Added by ~/.emacs.d/install.sh" >> ~/.bash_profile
    echo "export PATH=\$HOME/.cask/bin:\$PATH" >> ~/.bash_profile
fi

export PATH=$HOME/.cask/bin:$PATH

cd ~/.emacs.d
cask install

# For Python / ELPY
# Prerequisite: Install Python as per:
# http://docs.python-guide.org/en/latest/#getting-started
pip install --upgrade elpy flake8 rope jedi ipython
