# Clone Uber repositories

# Setup Uber dir
mkdir -p ~/Uber

# Clone devpod if not exists
if [ ! -d ~/Uber/devpod-monorepo ]; then
    git clone gitolite@code.uber.internal:devexp/devpod-monorepo ~/devpod-monorepo

# Clone Buildfarm if not exists
if [ ! -d ~/Uber/buildfarm ]; then
    git clone gitolite@code.uber.internal:infra/buildfarm
    