# GMS2 Autotile Converter

This is a script for Aseprite that will convert the RPG Maker "A2" style tilesets into an equivalent autotile sheet for GameMaker Studio 2. The script can generate both the 16 and 47 autotile formats. It also includes a preview function that allows you to see how the tileset will look directly in Aseprite without having to import into GameMaker Studio 2. The script supports most of the features of Aseprite. You can build your tilesets on multiple layers, and the script will copy any layers that are currently set to visible into the final generated autotile sheet. You can also use Aseprite's animation functionality to store tilesets in multiple frames. The script will copy whatever frame you currently have selected.

## Requirements

* This script requires the pixel art application [Aseprite](https://www.aseprite.org/). I would recommend buying it from the website, as it gives more money to the developer and also comes with a Steam key.
* This script was tested using the latest version of Aseprite at the current time, which is "Aseprite v1.2.21". Older versions of Aseprite might work, but I would recommend updating to the latest version available to you.


## Installation

* First, [download the repo ZIP file](https://github.com/null-sharp/GMS2-Autotile-Converter/archive/master.zip).
* The easiest way to install the script is to open Aseprite and go to **File -> Scripts -> Open Scripts Folder**. Then simply drag the Lua file into the folder.
* You must close your Aseprite application and open it up again in order to refresh the scripts list.
* I highly recommend assigning the script to a keyboard shortcut by going to **Edit -> Keyboard Shortcuts**. Then simply search for "GMS2", and assign the script to a shortcut of your choosing. Personally I use **Shift+A** because it is easy to press and isn't used by any other Aseprite commands.

## A2 Tilesets

This script expects the tileset to be formatted in the RPG Maker A2 tile format. If you are unfamiliar with this format, the article [Anatomy of an Autotile](https://blog.rpgmakerweb.com/tutorials/anatomy-of-an-autotile/) explains it very well. It is basically a way to generate 47 tiles from only 5 tiles. The way it does this is by splitting up the tiles into "minitiles", which it then combines in various ways to form all of the necessary autotiles.

If you are interested in making your own A2 tilesets, I would recommend this YouTube series by CrackedRabbitGaming ([Part 1](https://www.youtube.com/watch?v=nvdf6SM0N0k), [Part 2](https://www.youtube.com/watch?v=2A2S_fc-UR8), [Part 3](https://www.youtube.com/watch?v=16Te4ESqYWI)). You can also Google "RPG Maker A2 tiles" to get ideas for the different kinds of things you can make with autotiles. Just be careful to not use any official RPG Maker tiles in your GameMaker Studio 2 games, as they are only licensed for use in RPG Maker.

There are plenty of independent artists that sell RPG Maker formatted tilesets that are able to be used in any game engine. Personally, I am a big fan of [finalbossblues](https://finalbossblues.itch.io/). [MalibuDarby](https://malibudarby.itch.io/) also has some really nice looking tilesets.

## Usage

You can use the script in two ways:
1. Simply open a single A2 formatted sprite, or create one yourself. The dimensions of the sprite must be two tiles wide and three tiles tall. In other words, the sprite height divided by the sprite width must be **1.5**. If it is not the correct dimensions, the script will give you an error and refuse to run.
2. If you have a tilesheet that contains multiple A2 tilesets, you can select the tileset using the Rectangular Marquee Tool (shortcut is **M**). Remember that you must select the exact tileset, if you miss it by one or two pixels, the dimensions will be incorrect. I recommend using the Grid settings in Aseprite. You can use **View -> Show -> Grid** to enable the grid, **View -> Grid -> Snap to Grid** to enable snapping, and **Grid -> Grid Settings** to change the grid size.

Once you have the tileset opened or selected, simply run the script using the keyboard shortcut you set earlier or by going to **File -> Scripts -> GMS2 Autotile Converter**. If the script detects a valid A2 tileset, it will open a window with four buttons.

![Dialog window](/images/dialog.png)

### 16 Tilesheet

This will generate a GMS2 16-tile autotile image. The sprite will open up in a new Aseprite tab, and you can save it to your computer as a PNG or whatever file type you choose. The 16-tile autotiles are best suited for natural terrain like grass and dirt.

#### Special note about 16-tile autotile generation

In GMS2, the last tile in the 16-tile autotile set is expected to be the "solid" tile of the outer terrain surface. There is no way to generate this solid tile from the standard A2 tileset, as it only contains the complete tile information for the center terrain surface. As a workaround for this, I have repurposed the top left tile in the A2 tileset:

![Top left tile labelled A](/images/top-left-tile-before.png)

The tile labelled **A** is a part of every RPG Maker A2 tileset, but it is not actually used to generate tiles. Instead, it is used as an icon for representing the tileset in the RPG Maker engine. As such, it serves no purpose in a GMS2 tileset. We can replace the top left tile with the solid outer surface tile, and the script will automatically place it in the generated 16-tile autotile sheet. If you are using premade RPG Maker tilesheets, these solid tiles will almost always be provided somewhere else in the same sprite sheet. Once you replace the top left tile, the A2 tileset will look like this:

![Top left tile replaced](/images/replace-top-left-tile.png)

Generating the above A2 tileset results in the following GMS2 autotile sheet:

![Generated 16 tilesheet](/images/generated-16-tile.png)

You might notice there are actually 17 tiles, not 16. The tile labelled "A" is actually the closest thing to the "solid" outer tile we can achieve with the standard A2 tileset. This tile is included in the sheet on the rare occasion when you might want to use this tile instead, or if you don't have a solid tile to use. The tile labelled "B" is just the same top-left tile that we copied into the original A2 tileset. When you are importing this autotile sheet into GMS2, you can choose either A or B to use as the solid tile.

### 47 Tilesheet

This will generate a GMS2 47-tile autotile image. The sprite will open up in a new Aseprite tab, and you can save it to your computer as a PNG or whatever file type you choose. The 47-tile autotiles are best suited for structural features like walls, fences, holes, and bodies of water. Unlike the 16-tile generation, the 47-tile generation has no special considerations. The top-left tile is simply ignored in the original tileset. Generating the same A2 tileset from above will give use the following GMS2 tilesheet:

![Generated 47 tilesheet](/images/generated-47-tile.png)

### 16 Tile Preview and 47 Tile Preview

The preview buttons will generate a pre-made map directly in Aseprite to give you an idea of what it will look like in GMS2. This is useful if you are designing your own A2 tilesets, so you don't have to constantly export from Aseprite and import into GMS2. The following image shows what the above A2 tileset looks like when prviewed in 16-tile and 47-tile respectively:

![Previews](/images/previews.png)

As you can see, this type of natural grass and dirt tile is much better suited to the 16-tile format. This is because the 47-tile format does not make use of the solid outer tiles like the 16-tile does. However, you can take advantage of tile layers in GMS2 to make 47-tile look great as well. Just place a layer of all grass underneath the 47-tile layer. By doing this, you get the increased flexibility of the 47-tile autotile while also retaining a more natural look.

## Importing to GMS2

Once you generate the tileset and save it to your computer, you just have to import the sprite into GMS2, create a tileset, assign the sprite, and set up the autotiles. The autotile sheets generated by this script are automatically ordered in the same order as GMS2 expects them, so you just have to click them from left to right. Also, if you are importing multiple autotile sheets and don't want to manually click the tiles 47 times, you can just duplicate an existing tileset that already has autotiles set up and replace the sprite with a different tilesheet. This only seems to work if the sprites are the exact same dimensions.

Rather than go into detail about using autotiles in GMS2, I will just link [this video that explains it well](https://www.youtube.com/watch?v=JRb4_GzF95k).
