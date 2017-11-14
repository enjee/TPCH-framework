# Pip installs
sudo -H pip install requests
sudo -H pip install natsort

# Install .net core and azcopy
sudo curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev$'
sudo apt-get update
sudo apt-get -y install dotnet-dev-1.1.4

sudo wget -O azcopy.tar.gz https://aka.ms/downloadazcopyprlinux
sudo tar -xf azcopy.tar.gz
sudo ./install.sh

git clone https://github.com/enjee/TPCH-framework

size=$1
sourceurl='https://benchmarkdatasaxion.blob.core.windows.net/'$size'gb'

azcopy --source-key vKqcXAZEI5TjwfBYBjx9BCWzkzmf8hG4t4O3O0h7RQXPcUL6FVSrMamXq+2cS7Qe7h/oVJbv7sboi9JsKQbKJw== --source $sourceurl --destination ~/dataset --recursive

