#!/bin/sh

prefix_addition=""

configure_dxvk() {
    local version download_dir 

    echo "Vulkan device found. Configuring DXVK..."
    version="1.10.3"
    download_dir="~/.local/share/shin/tools"
    wget -P "$download_dir" "https://github.com/doitsujin/dxvk/releases/download/v${version}/dxvk-${version}.tar.gz"
    tar -xf "$download_dir/dxvk-${version}.tar.gz" -C "$download_dir"
    WINEPREFIX="$1" "$download_dir/dxvk-$version/setup-dxvk.sh install" > /dev/null 2>&1

}

vulkan_is_there() {
    local death vk_devices

    death=$(vulkaninfo | grep 'Vulkan version')
    vk_devices=$(echo "$death" | wc -l)
    [ $vk_devices -gt 0 ] && return 0 || return 1
}

parse_opt() {

    shift; shift

    while [ $# -gt 0 ]; do
        printf "Arguments: $1\n"

        case "$1" in
            --nv-prime-offload) prefix_addition="${prefix_addition} __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia";;
            --prime-offload) prefix_addition="${prefix_addition} DRI_PRIME=1";; 
            --game-mode) prefix_addition="${prefix_addition} gamemoderun";;

        esac

        shift

    done

}

operation_run() {
    local game_inf game_name game_runner game_dir game_exe game_cmd_prefix previous_dir

    game_inf=$(grep "$1" ~/.local/share/shin/mess.vars)
    game_name=$(echo "$game_inf" | grep -o "${2}_NAME='[^']*" | sed "s/${2}_NAME='//")
    game_runner=$(echo "$game_inf" | grep -o "${2}_RUNNER='[^']*" | sed "s/${2}_RUNNER='//")
    game_dir=$(echo "$game_inf" | grep -o "${2}_DIR='[^']*" | sed "s/${2}_DIR='//")
    game_exe=$(echo "$game_inf" | grep -o "${2}_EXE='[^']*" | sed "s/${2}_EXE='//")
    game_cmd_prefix=$(echo "$game_inf" | grep -o "${2}_CMD_PREFIX='[^']*" | sed "s/${2}_CMD_PREFIX='//")

    printf "Command prefix additions: $prefix_addition\n"
    printf "Game command prefix: $game_cmd_prefix\n"
    printf "Starting $game_name...\n"
    
    previous_dir=$PWD
    cd "$game_dir"

    if [ "$game_runner" = "native" ]; then
        env $game_cmd_prefix $prefix_addition ./$game_exe

    else
        env $game_cmd_prefix $prefix_addition wine $game_exe > /dev/null 2>&1

    fi

    cd "$previous_dir"

}

operation_add() {
    local exe_type runner cmd_prefix is_vulkan_there game_dir game_exe

    exe_type=$(echo "$3" | grep -o ".exe$")
    game_file=$(realpath "$3")    

    if [ -z "$exe_type" ]; then
        chmod +x "$3"
        runner="native"

    else
        printf "Configuring wine prefix...\n"
        ! [ -d "$HOME/.local/share/shin/wineprefixes/$1" ] && mkdir -p "$HOME/.local/share/shin/wineprefixes/$1"
        WINEPREFIX="$HOME/.local/share/shin/wineprefixes/$1" wineboot -u > /dev/null 2>&1
        is_vulkan_there=$(vulkan_is_there)

        [ $is_vulkan_there = 0 ] && configure_dxvk "$HOME/.local/share/shin/wineprefixes/$1" || printf "No Vulkan device found. Falling back to WINED3D"
        runner="wine"
        cmd_prefix="WINEFSYNC=1 WINEESYNC=1 WINEPREFIX=$HOME/.local/share/shin/wineprefixes/$1"

    fi

    game_dir="${game_file%/*}"
    game_exe="${game_file##*/}"

    printf "${1}_CMD_PREFIX='${cmd_prefix}'\n${1}_NAME='${2}'\n${1}_DIR='${game_dir}'\n${1}_EXE='${game_exe}'\n${1}_RUNNER='${runner}'\n\n" >> ~/.local/share/shin/mess.vars

}

## MAIN ##

parse_opt "$@"

if [ "$1" = add ]; then
    printf "Please enter the game ID This will be used to identify your game when using the 'run' operation\n>> "
    read -r game_id

    printf "Please enter the game name\n>> "
    read -r game_name

    operation_add "$game_id" "$game_name" "$2"

elif [ "$1" = "run"  ]; then
    operation_run "$2"

elif [ "$1" = "list" ]; then
    names=$(grep -o "[^_]*_NAME='[^']*" $HOME/.local/share/shin/mess.vars | sed "s/_NAME='/: /g")
    echo "$names"

elif [ "$1" = "help" ]; then 
    cat << EOF
Usage: shin <command> <command arg> [ARGUMENTS]...

Example: shin add <game path>
         shin run <game id> --game-mode --nv-prime-offload

Options:

         --nv-prime-offload         Run the game on NVIDIA GPU using PRIME render offload
         --prime-offload            Run the game on discrete GPU using PRIME render offload
                                    (only for open-source drivers)
         --game-mode                Run the game with Feral Interactive Game Mode to
                                    optimize gaming performance
EOF

fi