# shin
A game launcher that "just works". It aims to setup your pre-installed game easier.

## How to use
To add game, simply run `$ shin add <path to game>`. You will be prompted to enter the game ID and the game name.

To run the game, run `$ shin run <game id> [ARGUMENTS]` and the game should start shortly. `[ARGUMENTS]`  is optional but it is recommended to use it as it may improve your game performance.

## Installation
```sh
wget https://raw.githubusercontent.com/hithere-at/shin/master/shin
chmod +x shin
sudo mv shin /usr/local/bin
```

### Arguments
When you are using the `run` command, you can use the provided arguments to tune the game to your liking (e.g run on discrete GPU)

- `--nv-prime-offload` Run the game on discrete GPU instead of built-in CPU graphics (for NVIDIA user with proprietary driver only)
- `--prime-offload` Same as above but this is for open source drivers
- `--game-mode` Enable Feral Interactive Game Mode, resuly may vary

#### Why does this exist
I have been using a specific game launcher and evertime i try to setup my games, it usually doesnt end up well. Some game have a weird GLX error and some game doesnt have DXVK installed even though i have turned one the option. This project wouldnt exist if its not because of my frustration.

