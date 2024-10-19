#!/bin/bash

show_downloads() {
    echo -e "\n--- Heights Available for Download ---"
    echo -e "Provider\t\t\tHeight"
    echo -e "---------------------------------------"

    # KJNodes
    KJ_NODES_ARCHIVE_HEIGHT=$(curl -s https://services.kjnodes.com/testnet/story/snapshot-archive/ | grep -A 1 "Block Height" | grep -o '[0-9]\{6,\}')
    KJ_NODES_PRUNED_HEIGHT=$(curl -s https://services.kjnodes.com/testnet/story/snapshot/ | grep -A 1 "Block Height" | grep -o '[0-9]\{6,\}')

    # Joseph Tran
    JOSEPH_TRAN_ARCHIVE_HEIGHT=$(curl -s https://service.josephtran.xyz/testnet/story/snapshot/ | grep "Archive snapshot:" | sed -n 's/.*Archive snapshot:<\/strong>  <span[^>]*>\([0-9]*\).*/\1/p')
    JOSEPH_TRAN_PRUNED_HEIGHT=$(curl -s https://service.josephtran.xyz/testnet/story/snapshot/ | grep "Prune snapshot:" | sed -n 's/.*Prune snapshot:<\/strong>  <span[^>]*>\([0-9]*\).*/\1/p')

    # Mandragora
    MANDRAGORA_ARCHIVE_HEIGHT=$(curl -s https://snapshots.mandragora.io/info.json | grep '"snapshot_height":' | sed -n 's/.*"snapshot_height": \([0-9]*\).*/\1/p')
    MANDRAGORA_PRUNED_HEIGHT=$(curl -s https://snapshots2.mandragora.io/story/info.json | grep '"snapshot_height":' | sed -n 's/.*"snapshot_height": \([0-9]*\).*/\1/p')

    # ITRocket
    IT_ROCKET_ARCHIVE_HEIGHT=$(curl -s https://server-5.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_height')
    IT_ROCKET_PRUNED_HEIGHT=$(curl -s https://server-3.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_height')

    # ITRocket 2
    IT_ROCKET2_ARCHIVE_HEIGHT=$(curl -s https://server-8.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_height')
    IT_ROCKET2_PRUNED_HEIGHT=$(curl -s https://server-1.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_height')

    # Shaurya Chopra
    SHAURYA_ARCHIVE_HEIGHT=$(curl -s https://story-snapshot.shachopra.com:8443/downloads/height.txt | grep -o '[0-9]\{6,\}')
    SHAURYA_PRUNED_HEIGHT=$(curl -s https://story-snapshot2.shachopra.com:8443/downloads/height.txt | grep -o '[0-9]\{6,\}')

    # Openbitlab
    OPENBITLAB_ARCHIVE_HEIGHT=$(curl -s https://story-testnet-snapshot.openbitlab.com/ | grep "story_archive_" | sed -n 's/.*story_archive*[^0-9]*\([0-9]*\).*/\1/p' | head -n 1)
    OPENBITLAB_PRUNED_HEIGHT=$(curl -s https://story-testnet-snapshot.openbitlab.com/ | grep "story_pruned_" | sed -n 's/.*story_pruned*[^0-9]*\([0-9]*\).*/\1/p' | head -n 1)

    echo -e "\n--- Snapshot Heights ---"
    printf "%-20s %-15s %-15s\n" "Provider" "Pruned Height" "Archive Height"
    echo "---------------------------------------------------------"
    printf "%-20s %-15s %-15s\n" "KJNodes" "$KJ_NODES_PRUNED_HEIGHT" "$KJ_NODES_ARCHIVE_HEIGHT"
    printf "%-20s %-15s %-15s\n" "Joseph Tran" "$JOSEPH_TRAN_PRUNED_HEIGHT" "$JOSEPH_TRAN_ARCHIVE_HEIGHT"
    printf "%-20s %-15s %-15s\n" "Mandragora" "$MANDRAGORA_PRUNED_HEIGHT" "$MANDRAGORA_ARCHIVE_HEIGHT"
    printf "%-20s %-15s %-15s\n" "ITRocket" "$IT_ROCKET_PRUNED_HEIGHT" "$IT_ROCKET_ARCHIVE_HEIGHT"
    printf "%-20s %-15s %-15s\n" "ITRocket 2" "$IT_ROCKET2_PRUNED_HEIGHT" "$IT_ROCKET2_ARCHIVE_HEIGHT"
    printf "%-20s %-15s %-15s\n" "Shaurya Chopra" "$SHAURYA_PRUNED_HEIGHT" "$SHAURYA_ARCHIVE_HEIGHT"
    printf "%-20s %-15s %-15s\n" "Openbitlab" "$OPENBITLAB_PRUNED_HEIGHT" "$OPENBITLAB_ARCHIVE_HEIGHT"
}

download_archive_story() {
    local provider=$1
    case $provider in
        "1")
            wget -O story_snapshot.tar.lz4 https://snapshots.kjnodes.com/story-testnet-archive/snapshot_latest.tar.lz4
            ;;
        "2")
            wget -O story_snapshot.lz4 https://story.josephtran.co/archive_Story_snapshot.lz4
            ;;
        "3")
            wget -O story_snapshot.lz4 https://snapshots.mandragora.io/story_snapshot.lz4
            ;;
        "4")
            SNAP_NAME=$(curl -s https://server-5.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_name')
            wget -O story_snapshot.lz4 https://server-5.itrocket.net/testnet/story/$SNAP_NAME
            ;;
        "5")
            SNAP_NAME=$(curl -s https://server-8.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_name')
            wget -O story_snapshot.lz4 https://server-8.itrocket.net/testnet/story/$SNAP_NAME
            ;;
        "6")
            wget -O story_snapshot.lz4 https://story-snapshot.shachopra.com:8443/downloads/snapshot_story.lz4
            ;;
        "7")
            wget -O story_snapshot.lz4 https://story-testnet-snapshot.openbitlab.com/story_archive_latest.tar.lz4
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
}


download_pruned_story() {
    local provider=$1
    case $provider in
        "1")
            wget -O story_snapshot.tar.lz4 https://snapshots.kjnodes.com/story-testnet/snapshot_latest.tar.lz4
            ;;
        "2")
            wget -O story_snapshot.lz4 https://story.josephtran.co/Story_snapshot.lz4
            ;;
        "3")
            wget -O story_snapshot.lz4 https://snapshots2.mandragora.io/story/story_snapshot.lz4
            ;;
        "4")
            SNAP_NAME=$(curl -s https://server-1.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_name')
            wget -O story_snapshot.lz4 https://server-1.itrocket.net/testnet/story/$SNAP_NAME
            ;;
        "5")
            SNAP_NAME=$(curl -s https://server-3.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_name')
            wget -O story_snapshot.lz4 https://server-3.itrocket.net/testnet/story/$SNAP_NAME
            ;;
        "6")
            wget -O story_snapshot.lz4 https://story-snapshot2.shachopra.com:8443/downloads/snapshot_story.lz4
            ;;
        "7")
            wget -O story_snapshot.lz4 https://story-testnet-snapshot.openbitlab.com/story_pruned_$OPENBITLAB_PRUNED_HEIGHT.tar.lz4
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
}


download_archive_geth() {
    local provider=$1
    case $provider in
        "1")
            wget -O geth_snapshot.tar.lz4 https://snapshots.kjnodes.com/story-testnet-archive/snapshot_latest_geth.tar.lz4
            ;;
        "2")
            wget -O geth_snapshot.lz4 https://story.josephtran.co/archive_Geth_snapshot.lz4
            ;;
        "3")
            wget -O geth_snapshot.lz4 https://snapshots.mandragora.io/geth_snapshot.lz4
            ;;
        "4")
            GETH_NAME=$(curl -s https://server-5.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_geth_name')
            wget -O geth_snapshot.lz4 https://server-5.itrocket.net/testnet/story/$GETH_NAME
            ;;
        "5")
            GETH_NAME=$(curl -s https://server-8.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_geth_name')
            wget -O geth_snapshot.lz4 https://server-8.itrocket.net/testnet/story/$GETH_NAME
            ;;
        "6")
            wget -O geth_snapshot.lz4 https://story-snapshot.shachopra.com:8443/downloads/geth_story.lz4
            ;;
        "7")
            wget -O geth_snapshot.lz4 https://story-testnet-snapshot.openbitlab.com/geth_archive_latest.tar.lz4
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac

}

download_pruned_geth() {
    local provider=$1
    case $provider in
        "1")
            wget -O geth_snapshot.tar.lz4 https://snapshots.kjnodes.com/story-testnet/snapshot_latest_geth.tar.lz4
            ;;
        "2")
            wget -O geth_snapshot.lz4 https://story.josephtran.co/Geth_snapshot.lz4
            ;;
        "3")
            wget -O geth_snapshot.lz4 https://snapshots2.mandragora.io/story/geth_snapshot.lz4
            ;;
        "4")
            GETH_NAME=$(curl -s https://server-1.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_geth_name')
            wget -O geth_snapshot.lz4 https://server-1.itrocket.net/testnet/story/$GETH_NAME
            ;;
        "5")
            GETH_NAME=$(curl -s https://server-3.itrocket.net/testnet/story/.current_state.json | jq -r '.snapshot_geth_name')
            wget -O geth_snapshot.lz4 https://server-3.itrocket.net/testnet/story/$GETH_NAME
            ;;
        "6")
            wget -O geth_snapshot.lz4 https://story-snapshot2.shachopra.com:8443/downloads/geth_story.lz4
            ;;
        "7")
            wget -O geth_snapshot.lz4 https://story-testnet-snapshot.openbitlab.com/geth_pruned_latest.tar.lz4
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac

}


select_download_snapshot() {
    echo -e "\n--- Choose if story or geth snapshot ---"
    echo "1) Archive Story"
    echo "2) Archive Geth"
    echo "3) Pruned Story"
    echo "4) Pruned Geth"
    read -p "Enter your choice (1-4): " choice

    local provider=$1
    case $choice in
        "1") download_archive_story $provider
             ;;
        "2") download_archive_geth $provider
             ;;
        "3") download_pruned_story $provider
             ;;
        "4") download_pruned_geth $provider
             ;;
        *)
            echo "Invalid selection."
            ;;
    esac
}




show_downloads

echo -e "\n--- Choose a provider to download a snapshot ---"
echo "1) KJNodes"
echo "2) Joseph Tran"
echo "3) Mandragora"
echo "4) ITRocket"
echo "5) ITRocket2"
echo "6) Shaurya Chopra"
echo "7) Openbitlab"

read -p "Enter your choice (1-7): " choice

select_download_snapshot $choice
