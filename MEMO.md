# Install Ruby 3.4 and Itamae in a Docker environment and test to see if the issue can be reproduced.

```console
$ docker run --name itamae-repro -it ubuntu:trusty
# apt update && apt install --no-install-recommends -y build-essential curl git bash-completion vim-tiny
# CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# export GEM_HOME="$HOME/.gem"
# export GEM_PATH="$HOME/.gem"
# export PATH="$HOME/.gem/bin"
# brew install ruby
# gem install itamae
# itamae version
```
