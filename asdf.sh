#!/usr/bin/env bash

echo -e "Installing asdf things"

if test ! $(asdf --version); then
	echo "You haven't installed asdf yet, fool!"
	exit
fi

echo -e "\nInstalling plugins"
plugins=(nodejs ruby erlang elixir golang kubectl minikube helm java)

for i in "${plugins[@]}" 
	do
		echo -e "\n+ $i"
		asdf plugin-add $i
done

echo -e "\n Installing keys for nodejs"
(cd ${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/ && ./import-release-team-keyring)

echo -e "\nInstalling language versions"
runtimes=(nodejs ruby golang kubectl minikube helm)

for i in "${runtimes[@]}" 
	do
		latest_version=$(asdf latest $i)
		echo -e "\n - installing $i $latest_version"
		asdf install $i $latest_version
done

# currently failing...
#latest_erlang=$(asdf latest erlang)
#echo "erlang - ${latest_erlang}"
#asdf install erlang $latest_erlang

#latest_elixir=$(asdf latest elixir)
#echo "elixir - ${latest_elixir}"
#asdf install elixir $latest_elixir

java_version="openjdk-14"
echo "java - ${java_version}"
asdf install java $java_version

echo -e "\n Fin"
