# GMS2 Autotile Converter

This is a script for Aseprite that will convert the RPG Maker "A2" style tilesets into an equivalent autotile sheet for GameMaker Studio 2. The script can generate both the 16 and 47 autotile formats. It also includes a preview function that allows you to see how the tileset will look directly in Aseprite without having to import into GameMaker Studio 2.

## Requirements

* This script requires the pixel art application [Aseprite](https://www.aseprite.org/). I would recommend buying it from the website, as it gives more money to the developer and also comes with a Steam key.
* This script was tested using the latest version of Aseprite at the current time, which is "Aseprite v1.2.21". Older versions of Aseprite might work, but I would recommend updating to the latest version available to you.


## Installation

* First, [download the repo ZIP file](https://github.com/null-sharp/GMS2-Autotile-Converter/archive/master.zip).
* The easiest way to install the script is to open Aseprite and go to **File -> Scripts -> Open Scripts Folder**. Then simply drag the Lua file into the folder.
* You must close your Aseprite application and open it up again in order to refresh the scripts list.
* I highly recommend assigning the script to a keyboard shortcut by going to **Edit -> Keyboard Shortcuts**. Then simply search for "GMS2", and assign the script to a shortcut of your choosing. Personally I use **Shift+A** because it is easy to press and isn't used by any other Aseprite commands.

## Obtaining A2 Tilesets

This script expects the tileset to be formatted in the RPG Maker A2 tile format. If you are unfamiliar with this format, the article [Anatomy of an Autotile](https://blog.rpgmakerweb.com/tutorials/anatomy-of-an-autotile/) explains it very well. It is basically a way to generate 47 tiles from only 5 tiles. The way it does this is by splitting up the tiles into "minitiles", which it then combines in various ways to form all of the necessary autotiles.

If you are interested in making your own A2 tilesets, I would recommend this YouTube series by CrackedRabbitGaming ([Part 1](https://www.youtube.com/watch?v=nvdf6SM0N0k), [Part 2](https://www.youtube.com/watch?v=2A2S_fc-UR8), [Part 3](https://www.youtube.com/watch?v=16Te4ESqYWI)). You can also Google "RPG Maker A2 tiles" to get ideas for the different kinds of things you can make with autotiles. Just be careful to not use any official RPG Maker tiles in your GameMaker Studio 2 games, as they are only licensed for use in RPG Maker.

There are plenty of independent artists that sell RPG Maker formatted tilesets that are able to be used in any game engine of your choice. Personally, I am a big fan of [finalbossblues](https://finalbossblues.itch.io/). [MalibuDarby](https://malibudarby.itch.io/) also has some really nice looking tilesets.

## Usage

You can use the script in two ways:
1. Simply open a single A2 formatted sprite, or create one yourself. The dimensions of the sprite must be two tiles wide and three tiles tall. In other words, the sprite height divided by the sprite width must be **1.5**. If it is not the correct dimensions, the script will give you an error and refuse to run.
2. If you have a tilesheet that contains multiple A2 tilesets, you can select the tileset using the Rectangular Marquee Tool (shortcut is **M**). Remember that you must select the exact tileset, if you miss it by one or two pixels, the dimensions will be incorrect. I recommend using the Grid settings in Aseprite. You can use **View -> Show -> Grid** to enable the grid, **View -> Grid -> Snap to Grid** to enable snapping, and **Grid -> Grid Settings** to change the grid size.

Once you have the tileset selected, simply run the script using the keyboard shortcut you set or by going to **File -> Scripts -> GMS2 Autotile Converter**. If the script detects a valid A2 tileset, it will open a window with four buttons.
