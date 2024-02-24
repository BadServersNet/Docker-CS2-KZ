sleep 1

mkdir -p ${HOME}/gs
steamcmd +force_install_dir ${HOME}/gs +login anonymous +app_update 730 ${EXTRA_FLAGS} +quit

mkdir -p ${HOME}/.steam/sdk32
cp -v /root/.local/share/Steam/steamcmd/linux32/steamclient.so ${HOME}/.steam/sdk32/steamclient.so

mkdir -p ${HOME}/.steam/sdk64
cp -v /root/.local/share/Steam/steamcmd/linux64/steamclient.so ${HOME}/.steam/sdk64/steamclient.so

csgo_folder="${HOME}/gs/game/csgo"

metamod_url="https://mms.alliedmods.net/mmsdrop/2.0/mmsource-2.0.0-git1282-linux.tar.gz"
echo "Downloading and extracting metamod"
curl -Lqs "$metamod_url" | tar -xz -C "$csgo_folder"

repo_owner="KZGlobalTeam"
repo_name="cs2kz-metamod"
latest_release=$(curl -s "https://api.github.com/repos/${repo_owner}/${repo_name}/releases" | jq 'sort_by(.created_at) | reverse | .[0]')
download_url=$(echo "$latest_release" | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url')

if [ -z "$download_url" ]; then
  echo "Error: Unable to find pre-release download URL."
  exit 1
fi

echo Downloading $(echo "$latest_release" | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .name')

gameinfo_path="${csgo_folder}/gameinfo.gi"
metamod_include_path=$'\t\t\tGame\tcsgo/addons/metamod\n'

curl -Lqs "$download_url" | tar -xz -C "$csgo_folder"

if grep -qF "metamod" "$gameinfo_path"; then
  echo "Metamod addon include already exists. Skipping."
else
  sed -i "/Game_LowViolence/ a\\
$metamod_include_path" "$gameinfo_path"
  echo "Metamod addon include added successfully."
fi

${HOME}/gs/game/cs2.sh -dedicated +ip ${SERVER_IP} -port ${SERVER_PORT} +map de_dust2 -maxplayers ${MAXPLAYERS} +sv_password ${SERVER_PASSWORD} +sv_setsteamaccount ${GSLT} ${EXTRA_FLAGS}