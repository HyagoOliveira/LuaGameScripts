
# Lua Game Scripts

Lua Scripts for games running on **BizHawk** multi-platform emulator.

## Supported Games

- SNES
    - Mega Man X
    - Mega Man X2
    - Mega Man X3
- PSOne
    - Mega Man X4
    - Mega Man X5
    - Mega Man X6

## Features

- Show the Axis Aligned Bounding Box (AABB) from the Player, Enemies and its items/projectiles;
- Show the Player properties (HP, position, speed etc);
- Show the Enemy properties (HP, position, speed etc);
- Free control of the Camera;
- Free control of the Player;
- Prevent changes from the Player life, position, gravity, speed;
    - Freeze the Player position is a good way for collecting animation references.

![alt text](/~Doc/mmx-aabb-x.png)

![alt text](/~Doc/mmx4-aabb-zero.png)

*Red AABB are for damager colliders (boxes able to inflict damage).*

![alt text](/~Doc/mmx5-aabb-x.jpg)

*Green AABB are for damageable colliders (boxes able to receive damage).*

![alt text](/~Doc/mmx6-aabb-x.png)


## Installation

1. If you didn't already, install the [BizHawk emulator](https://github.com/TASVideos/BizHawk#installing) and setup its BIOS;
2. Copy all contents from this repo to the `/Lua` folder inside the path where you installed the BizHawk emulator:
    1. eg. `[BizHawk-path]/[version]/Lua`

## Usage

1. Open your game. The game should be named exactly as:
    1. `Mega Man X (USA)`, `Mega Man X2 (USA)` or `Mega Man X3 (USA)` for SNES.
    2. `Mega Man X4 (USA)`, `Mega Man X5 (USA)` or `Mega Man X6 (USA)` for the PSOne.
2. Go to Tools > Lua Console;
3. Click on Scripts > Open Script;
4. Go to the folder where you pasted the scripts from this repo and select:
    1. `/Lua/SNES/MegaMan/MegaManX.lua` for Mega Man X, X2 or X3;
    2. `/Lua/PSX/MegaMan/MegaManX.lua` for Mega Man X4, X5 or X6;
5. A successfully message will be outputted.

## License
[MIT](https://choosealicense.com/licenses/mit/)

---

**Hyago Oliveira**

[BitBucket](https://bitbucket.org/HyagoGow/) -
[LinkedIn](https://www.linkedin.com/in/hyago-oliveira/) -
<hyagogow@gmail.com>