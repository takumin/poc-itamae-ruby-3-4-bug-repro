# Install Ruby 3.4 and Itamae in a Docker environment and test to see if the issue can be reproduced.

```console
$ docker run --name itamae-repro -it ubuntu:trusty
# apt update
# apt install -y build-essential curl bash-completion
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install ruby
```
