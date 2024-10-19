#!/bin/bash

GO_VERSION="1.22.7"
STORY_VERSION="v0.11.0"
GETH_VERSION="v0.9.4"
NETWORK="iliad"
USERNAME=$(whoami)
SEEDS="6a07e2f396519b55ea05f195bac7800b451983c0@story-seed.mandragora.io:26656,51ff395354c13fab493a03268249a74860b5f9cc@story-testnet-seed.itrocket.net:26656,5d7507dbb0e04150f800297eaba39c5161c034fe@135.125.188.77:26656"
PEERS="2f372238bf86835e8ad68c0db12351833c40e8ad@story-testnet-rpc.itrocket.net:26656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@story-testnet.rpc.kjnodes.com:26656,25747524aca5e9c878bbde97a9854f24255fceb9@157.173.116.70:26656,960278d079a111b44c207dca7c2ffac640b477d1@44.223.234.211:26656,cc4dee220372ab3bf22bc9a91c385f16b724917a@207.188.6.109:26656,95937ce9971e81f61c3249f50404868bcedc77e7@148.251.8.22:27136,aac5871efa351872789eef15c2da7a55a68abdad@88.218.226.79:26656,cbaa226e66502b6b032f5e648d4d754f26bf9ca6@65.109.84.22:47656,7b71e1c1674828a0e2bf1f987246f0ddd4616281@88.198.70.23:16756,07ab4164e1d0ee17c565542856ac58981537156f@37.27.124.51:42656,8c1b516805e0c4631306032a0108e51339ab7cfd@78.46.60.145:26656,371ee318d105b0239b3997c287068ccbbcd46a91@3.248.113.42:26656,f1e8a864dd243b89e58b4722af0d46bc3f9782a0@65.108.40.171:26656,a2fe3dfd6396212e8b4210708e878de99307843c@54.209.160.71:26656,15c7e2b630c04ee11b2c3cfbfb1ede0379df9407@52.74.117.64:26656,895ae17826c88a0eacb6178aafc30a73f89f8f2d@82.223.31.166:33556,5e4f9ce2d20f2d3ef7f5c92796b1b954384cbfe1@34.234.176.168:26656,359e4420e63db005d8e39c490ad1c1c329a68df3@3.222.216.118:26656,f4d96bf0dc67a05a48287ca2c821bc8e1d2b2023@63.35.134.129:26656,c82d2b5fe79e3159768a77f25eee4f22e3841f56@3.209.222.59:26656"
MAX_INBOUND_PEERS=300
MAX_OUTBOUND_PEERS=200
STORY_PORT=266

if [ "$USERNAME" == "root" ]; then
    STORY_HOME="/root/.story/story"
    GETH_HOME="/root/.story/geth"
    BIN_PATH="/root/go/bin/"
else
    STORY_HOME="/home/$USERNAME/.story/story"
    GETH_HOME="/home/$USERNAME/.story/geth"
    BIN_PATH="/home/$USERNAME/go/bin/"
fi


menu() {

    echo "Story Relaxed Automation"
    echo "1. Install Node"
    echo "2. Check Story Version"
    echo "3. Check Geth Version"
    echo "4. Check Sync Status"
    echo "5. Check Story Logs"
    echo "6. Check Geth Logs"
    echo "7. Restart Geth"
    echo "8. Restart Story"
    echo "9. Restart all"
    echo "10. Quit"
    echo ""
    echo -n "Please enter your choice: "
}


install_node() {
    ask_install_versions
    update_system
    install_dependencies
    install_go
    build_story
    build_geth
    init_network
    update_config
    create_story_systemd
    create_geth_systemd
    load_genesis
    load_addrbook
    echo "Enable Universal Firewall with Story and SSH exceptions? Y/n"
    read -r ENABLE_FIREWALL
    if [ "$ENABLE_FIREWALL" == "Y" ]; then
        enable_ufw
    fi
    download_apply_snapshot
    start_story
    start_geth
}


ask_install_versions() {
    echo "Please enter Story version to install (blank for ${STORY_VERSION}):"
    read -r TEMP_VERSION
    if [ ! -z "${TEMP_VERSION}" ]; then
        STORY_VERSION=$TEMP_VERSION
    fi

    echo "Please enter Story version to install (blank for ${GETH_VERSION}):"
    read -r TEMP_VERSION
    if [ ! -z "${TEMP_VERSION}" ]; then
        GETH_VERSION=$TEMP_VERSION
    fi
}


update_system() {
    echo "Updating the system"
    sudo apt update && sudo apt upgrade -y
}


install_dependencies() {
    echo "Install other dependencies"
    sudo apt install curl tar wget clang pkg-config libssl-dev libleveldb-dev jq build-essential git make ncdu screen unzip bc fail2ban -y
}


install_go() {
    echo "Install Go"
    cd $HOME
    wget "https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$GO_VERSION.linux-amd64.tar.gz"
    rm "go$GO_VERSION.linux-amd64.tar.gz"
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
}


build_story() {
    echo "Build Story"
    rm -rf $HOME/story
    git clone https://github.com/piplabs/story
    cd $HOME/story
    git checkout $STORY_VERSION
    go build -o story ./client
    cp ./story $HOME/go/bin/
    cd $HOME
}


build_geth() {
    echo "Build Geth"
    rm -rf $HOME/story-geth
    git clone https://github.com/piplabs/story-geth story-geth
    cd $HOME/story-geth
    git checkout $GETH_VERSION
    make geth
    cp ./build/bin/geth $HOME/go/bin/
    cd $HOME
}


init_network() {
    echo "Init ${NETWORK}"
    $HOME/go/bin/story init --network $NETWORK
}


update_config() {
    echo "Please enter the moniker:"
    read -r MONIKER

    sed -i -e "s|moniker = \"[^\"]*\"|moniker = \"$MONIKER\"|g" $STORY_HOME/config/config.toml

    echo "Please enter the first 3 number for protocol port (default 266 if blank):"
    read -r STORY_PORT

    sed -i "s%:26658%:${STORY_PORT}58%g" $STORY_HOME/config/config.toml
    sed -i "s%:26657%:${STORY_PORT}57%g" $STORY_HOME/config/config.toml
    sed -i "s%:26656%:${STORY_PORT}56%g" $STORY_HOME/config/config.toml
    sed -i "s%:26660%:${STORY_PORT}60%g" $STORY_HOME/config/config.toml

    sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" $STORY_HOME/config/config.toml
    sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $STORY_HOME/config/config.toml

    sed -i -e "s|max_num_inbound_peers = [^\"]*|max_num_inbound_peers = $MAX_INBOUND_PEERS|g" $STORY_HOME/config/config.toml
    sed -i -e "s|max_num_outbound_peers = [^\"]*|max_num_outbound_peers = $MAX_OUTBOUND_PEERS|g" $STORY_HOME/config/config.toml

    sed -i -e "s|indexer = \"[^\"]*\"|indexer = \"null\"|g" $STORY_HOME/config/config.toml

    sed -i -e "s|prometheus = false|prometheus = true|g" $STORY_HOME/config/config.toml
    sed -i -e "s|namespace = \"[^\"]*\"|namespace = \"tendermint\"|g" $STORY_HOME/config/config.toml

    sed -i "s%:1317%:${STORY_PORT}17%g" $STORY_HOME/config/story.toml
    sed -i "s%:8551%:${STORY_PORT}51%g" $STORY_HOME/config/story.toml
}

enable_ufw() {
    echo "Enable UFW"
    SSH_PORT=$(echo ${SSH_CLIENT##* })

    sudo ufw allow $SSH_PORT
    sudo ufw allow ${STORY_PORT}45/tcp
    sudo ufw allow ${STORY_PORT}46/tcp
    sudo ufw allow ${STORY_PORT}03/tcp
    sudo ufw allow ${STORY_PORT}03/udp
    sudo ufw allow ${STORY_PORT}56/tcp
    sudo ufw allow ${STORY_PORT}60/tcp
    sudo ufw enable
}


create_story_systemd() {
    echo "Create Story service"
    sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Service
After=network.target

[Service]
User=$USERNAME
ExecStart=$BIN_PATH/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable story.service
}


# Create Geth systemd
create_geth_systemd() {
    echo "Create Story service"
    sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=$USERNAME
ExecStart=$BIN_PATH/story-geth --iliad --syncmode full --authrpc.port ${STORY_PORT}51 --port ${STORY_PORT}03 --discovery.port ${STORY_PORT}03 --metrics --pprof
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable story.service
}


load_genesis() {
    echo "Load Genesis"
    wget -O $STORY_HOME/config/genesis.json https://snapshots.polkachu.com/testnet-genesis/story/genesis.json
}


load_addrbook() {
    echo "Load addrbook"
    wget -O $STORY_HOME/config/addrbook.json https://snapshots.polkachu.com/testnet-addrbook/story/addrbook.json
}


download_apply_snapshot() {
    echo "Apply Snapshots"
    sudo rm -rf $GETH_HOME/iliad/geth/chaindata
    sudo rm -rf $STORY_HOME/data

    wget -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4
    wget -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4

    lz4 -c -d geth_snapshot.lz4 | tar -xv -C $GETH_HOME/iliad/geth
    lz4 -c -d story_snapshot.lz4 | tar -xv -C $STORY_HOME

    sudo rm -v geth_snapshot.lz4
    sudo rm -v story_snapshot.lz4
}


start_story() {
    echo "Start Story"
    sudo systemctl start story
}


start_geth() {
    echo "Start Geth"
    sudo systemctl start story-geth
}


check_sync_status() {
    RPC_PORT=$(grep '^laddr.*57"$' $STORY_HOME/config/config.toml | sed -E 's/^.*(.{5})"$/\1/')

    local_height=$(curl -s localhost:${RPC_PORT}/status | jq -r '.result.sync_info.latest_block_height')
    local_time=$(curl -s localhost:${RPC_PORT}/status | jq -r '.result.sync_info.latest_block_height')
    network_height=$(curl -s https://story-testnet-rpc.polkachu.com/status | jq -r '.result.sync_info.latest_block_height')
    network_time=$(curl -s https://story-testnet-rpc.polkachu.com/status | jq -r '.result.sync_info.latest_block_time')

    difference=$((network_height - local_height))

    printf "%-20s %-20s %-20s %-30s %-20s\n" "Local Height" "Local Time" "Network Height" "Network Time" "Blocks Difference"
    printf "%-20s %-20s %-20s %-30s %-20s\n" "$local_height" "$local_time" "$network_height" "$network_time" "$difference"

    read
}


check_story_version() {
    story version
    echo -e "\nPress the Enter key to continue."
    read
}


check_geth_version() {
    geth version
    echo -e "\nPress the Enter key to continue."
    read
}


check_story_logs() {
    sudo journalctl -u story -f -o cat
}


check_geth_logs() {
    sudo journalctl -u story-geth -f -o cat
}


restart_geth() {
    echo "Restart geth"
    sudo systemctl restart story-geth
    read
}


restart_story() {
    echo "Restart story"
    sudo systemctl restart story
    read
}


restart_all() {
    echo "Stop Geth"
    sudo systemctl stop story-geth
    echo "Stop Story"
    sudo systemctl stop story
    echo "Start Geth"
    sudo systemctl start story-geth
    echo "Start Story"
    sudo systemctl start story
}


#Main
while true; do
    menu
    read choice
    case $choice in
        1) install_node ;;
        2) check_story_version ;;
        3) check_geth_version ;;
        4) check_sync_status ;;
        5) check_story_logs ;;
        6) check_geth_logs ;;
        7) restart geth ;;
        8) restart story ;;
        9) restart all ;;
        10) exit 0 ;;
        *) ;;
    esac
done
