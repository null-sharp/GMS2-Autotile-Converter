local spr = app.activeSprite -- Get the currently opened sprite.

-- If there is no sprite, then cancel the script.
if not spr then
  app.alert("There is no sprite to export.")
  return
end

local currentSelection = spr.selection -- Get the current selection in the sprite.
local frameNumber = app.activeFrame.frameNumber -- Get the current active frame if the user has multiple.

-- Check if the tileset is formatted correctly, depending on if the user has a selection or not.
if currentSelection.isEmpty then
	if (spr.height / spr.width) ~= 1.5 then
		app.alert{title="Incorrect tileset format", text={"This sprite is not in the correct format to generate autotiles.", "If you have multiple tilesets in the same sprite, you can use the selection tool (M).", "The tileset should be two tiles wide and three tiles tall.", "(Image height divided by image width should be 1.5)"}, buttons={"Cancel"}}
		return
	end
else
	if (currentSelection.bounds.height / currentSelection.bounds.width) ~= 1.5 then
		app.alert{title="Incorrect tileset format", text={"The currect selection is not in the correct format to generate autotiles.", "The tileset should be two tiles wide and three tiles tall.", "(Image height divided by image width should be 1.5)"}, buttons={"Cancel"}}
		return
	end
end

-- Generate dialog box and populate with buttons and text.
local d = Dialog("GMS2 Autotile Converter")

if currentSelection.isEmpty then
	d:label{ text="Nothing selected. Using entire sprite." }
else
	d:label{ text="Using current selection." }
end
d:separator()
d:button{ id="gen16Tile", text="16 Tilesheet" }
d:button{ id="gen47Tile", text="47 Tilesheet" }
d:separator()
d:button{ id="preview16Tile", text="16 Tile Preview" }
d:button{ id="preview47Tile", text="47 Tile Preview" }
d:separator()
d:button{ id="cancel", text="Cancel" }
d:show()

local data = d.data -- Get the data from the dialog box, this tells us which button ID the user pressed.

-- Check if cancel was clicked or dialog window was closed.
if not (data.gen16Tile or data.gen47Tile or data.preview16Tile or data.preview47Tile) then return end

local autotile_format
local generate_preview

if data.gen16Tile then
	autotile_format = "16 Tile"
	generate_preview = false
end
if data.gen47Tile then
	autotile_format = "47 Tile"
	generate_preview = false
end
if data.preview16Tile then
	autotile_format = "16 Tile"
	generate_preview = true
end
if data.preview47Tile then
	autotile_format = "47 Tile"
	generate_preview = true
end

-- This table defines the layout of the 47 autotile sheet. Every four values is one tile (NW, NE, SW, SE).
local autotile47TileTable =
{
	"empty", "empty", "empty", "empty", "A3", "B3", "C3", "D3", "A1", "B3", "C3", "D3", "A3", "B1", "C3", "D3", "A1", "B1", "C3", "D3", "A3", "B3", "C3", "D1", "A1", "B3", "C3", "D1", "A3", "B1", "C3", "D1", "A1", "B1", "C3", "D1", "A3", "B3", "C1", "D3", "A1", "B3", "C1", "D3", "A3", "B1", "C1", "D3", "A1", "B1", "C1", "D3", "A3", "B3", "C1", "D1", "A1", "B3", "C1", "D1", "A3", "B1", "C1", "D1", "A1", "B1", "C1", "D1", "A5", "B3", "C5", "D3", "A5", "B1", "C5", "D3", "A5", "B3", "C5", "D1", "A5", "B1", "C5", "D1", "A4", "B4", "C3", "D3", "A4", "B4", "C3", "D1", "A4", "B4", "C1", "D3", "A4", "B4", "C1", "D1", "A3", "B5", "C3", "D5", "A3", "B5", "C1", "D5", "A1", "B5", "C3", "D5", "A1", "B5", "C1", "D5", "A3", "B3", "C4", "D4", "A1", "B3", "C4", "D4", "A3", "B1", "C4", "D4", "A1", "B1", "C4", "D4", "A5", "B5", "C5", "D5", "A4", "B4", "C4", "D4", "A2", "B4", "C5", "D3", "A2", "B4", "C5", "D1", "A4", "B2", "C3", "D5", "A4", "B2", "C1", "D5", "A3", "B5", "C4", "D2", "A1", "B5", "C4", "D2", "A5", "B3", "C2", "D4", "A5", "B1", "C2", "D4", "A2", "B2", "C5", "D5", "A2", "B4", "C2", "D4", "A5", "B5", "C2", "D2", "A4", "B2", "C4", "D2", "A2", "B2", "C2", "D2"
}

-- This table defines the layout of the 16 autotile sheet. Every four values is one tile (NW, NE, SW, SE).
local autotile16TileTable =
{
	"empty", "empty", "empty", "empty", "A3", "B3", "C3", "D3", "A1", "B3", "C3", "D3", "A3", "B1", "C3", "D3", "A4", "B4", "C3", "D3", "A3", "B3", "C1", "D3", "A5", "B3", "C5", "D3", "A3", "B1", "C1", "D3", "A2", "B4", "C5", "D3", "A3", "B3", "C3", "D1", "A1", "B3", "C3", "D1", "A3", "B5", "C3", "D5", "A4", "B2", "C3", "D5", "A3", "B3", "C4", "D4", "A5", "B3", "C2", "D4", "A3", "B5", "C4", "D2", "A2", "B2", "C2", "D2"
}

-- This table stores the location of each subtile by counting left to right, top to bottom.
local subTileTable = 
{
	["A1"] = 2,
	["B1"] = 3,
	["C1"] = 6,
	["D1"] = 7,
	["A2"] = 8,
	["B4"] = 9,
	["A4"] = 10,
	["B2"] = 11,
	["C5"] = 12,
	["D3"] = 13,
	["C3"] = 14,
	["D5"] = 15,
	["A5"] = 16,
	["B3"] = 17,
	["A3"] = 18,
	["B5"] = 19,
	["C2"] = 20,
	["D4"] = 21,
	["C4"] = 22,
	["D2"] = 23
}

local sprCopy = Sprite(spr) -- Make a copy of the sprite so we don't affect the original sprite.

-- Make hidden layers invisible by turning opacity to 0.
for i = 1,#sprCopy.layers do
	if not sprCopy.layers[i].isVisible then
		sprCopy.layers[i].opacity = 0
	end
end

sprCopy:flatten() -- Flatten all layers in the sprite copy.

-- If the use has a selection, crop the sprite.
if not currentSelection.isEmpty then
	sprCopy:crop(currentSelection.bounds)
end

local tile_size = math.floor(sprCopy.width / 2) -- Tile size is just the image width divided by two.
local subtile_size = math.floor(tile_size / 2) -- The subtiles are just half of the tile size.

-- Get the image of the original sprite by creating a new image and copying it over.
-- This ensures that transparency is supported due to the way Aseprite defines an Image.
local img = Image(sprCopy.width, sprCopy.height, sprCopy.colorMode)
img:drawSprite(sprCopy, frameNumber)

-- This function gets the rectangle defining the location of a single subtile.
-- Tile ID is defined by the RPGMaker template ("A1", "B5", etc.)
local function getSubtileRect(tileID)
	local subTileValue = subTileTable[tileID]
	return Rectangle((subTileValue % 4) * subtile_size, math.floor((subTileValue / 4)) * subtile_size, subtile_size, subtile_size)
end

-- Create the new sprite based on which format the user picked.
local newSpr
if autotile_format == "47 Tile" then
	newSpr = Sprite(tile_size * 8, tile_size * 6, sprCopy.colorMode)
else
	newSpr = Sprite(tile_size * 9, tile_size * 2, sprCopy.colorMode)
end

local newImage = newSpr.cels[1].image -- Get the image of the newly created sprite.

-- This function draws a single tile by combining four subtiles as defined in the autotile tables.
local function drawFullTile(tileNumber, tilesetWidth, autotileTable)
	-- This stores the offsets of each subtile since we have to alternate between NW, NE, SW, SE subtiles.
	local subtileOffsets = {{x=0, y=0}, {x=subtile_size, y=0}, {x=0, y=subtile_size}, {x=subtile_size, y=subtile_size}}
	
	local tilePosX = (tileNumber % tilesetWidth) * tile_size -- This is the initial X position of the current tile.
	local tilePosY = math.floor(tileNumber / tilesetWidth) * tile_size -- This is the initial Y position of the current tile.
	
	-- Iterate through all four subtiles. NW, NE, SW, SE.
	for i=1,4 do
		subtileRect = getSubtileRect(autotileTable[1 + (tileNumber * 4) + (i - 1)]) -- Get subtile rectangle.
		local x = tilePosX + subtileOffsets[i].x -- Initialize X position of the subtile
		local y = tilePosY + subtileOffsets[i].y -- Initialize Y position of the subtile
		local xInitPos = x -- Store the initial X position so we can jump back to it in the for loop.
		
		for it in img:pixels(subtileRect) do -- Iterate through the pixels in the subtile rectangle.
			local pixel = it() -- Get the color of the current pixel.
			newImage:drawPixel(x, y, pixel) -- Draw current pixel to the current x and y.
			
			x = x + 1 -- Move one to the right.
			if x == xInitPos + subtileRect.width then -- If we reach the end of the subtile,
				x = xInitPos -- jump back to the left side,
				y = y + 1 -- and go down one pixel.
			end
		end
	end
end

-- Depending on the selected tile format, draw all of the full tiles sequentially.
if autotile_format == "47 Tile" then

	-- If the original sprite is opened from a file, append _47Tile to the end to make saving easier.
	local filename = spr.filename
	for c= #filename, 1, -1 do
		if filename:sub(c,c) == "." then
			newSpr.filename = filename:sub(0, c - 1) .. "_47Tile" .. filename:sub(c, #filename)
			filename = newSpr.filename
			break
		end
	end
	if filename == spr.filename then
		newSpr.filename = filename .. "_47Tile"
	end
	
	-- Draw all 47 tiles. 8 is the number of tiles wide the autotile sheet is.
	for j=1,47 do
		drawFullTile(j, 8, autotile47TileTable)
	end
else -- 16 Tile

	-- If the original sprite is opened from a file, append _16Tile to the end to make saving easier.
	local filename = spr.filename
	for c= #filename, 1, -1 do
		if filename:sub(c,c) == "." then
			newSpr.filename = filename:sub(0, c - 1) .. "_16Tile" .. filename:sub(c, #filename)
			filename = newSpr.filename
			break
		end
	end
	if filename == spr.filename then
		newSpr.filename = filename .. "_16Tile"
	end
	
	-- Draw all 16 tiles. 9 is the number of tiles wide the autotile sheet is.
	for j=1,16 do
		drawFullTile(j, 9, autotile16TileTable)
	end
	
	-- This code draws the final tile, which is just copied from the top left corner of the original tileset.
	local xx = tile_size * 8
	local yy = tile_size
	local xInitPos = xx
	
	for it in img:pixels(Rectangle(0, 0, tile_size, tile_size)) do
		local pixel = it()
		newImage:drawPixel(xx, yy, pixel)
		
		xx = xx + 1
		if xx == xInitPos + tile_size then
			xx = xInitPos
			yy = yy + 1
		end
	end
end

newSpr:setPalette(spr.palettes[1]) -- Copy the palette of the original sprite over to the new sprite.

sprCopy:close() -- Close the sprite copy as we no longer need it.
app.refresh()

if not generate_preview then
	return
end

if autotile_format == "47 Tile" then -- Generate 47 tile preview.
	local preview47Tilemap = 
	{
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 47, 0, 44, 46, 0, 44, 34, 34, 34, 46, 0, 0, 43, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 44, 16, 46, 0, 0,
	0, 43, 0, 35, 37, 0, 35, 21, 21, 21, 37, 0, 0, 45, 0, 0, 0,
	0, 45, 0, 41, 39, 0, 41, 29, 29, 29, 39, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 35, 37, 0, 0,
	0, 43, 0, 35, 37, 0, 35, 21, 21, 21, 37, 0, 35, 2, 3, 37, 0,
	0, 33, 0, 17, 25, 0, 17, 1, 1, 1, 25, 0, 41, 9, 5, 39, 0,
	0, 20, 34, 10, 25, 0, 17, 1, 1, 1, 25, 0, 0, 41, 39, 0, 0,
	0, 33, 0, 17, 25, 0, 17, 1, 1, 1, 25, 0, 0, 0, 0, 0, 0,
	0, 45, 0, 41, 39, 0, 41, 29, 13, 29, 39, 0, 36, 34, 34, 38, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 33, 0, 0, 0, 33, 0, 0, 33, 0,
	0, 35, 37, 0, 0, 0, 35, 21, 4, 21, 37, 0, 33, 0, 0, 33, 0,
	0, 41, 15, 34, 38, 0, 17, 5, 29, 9, 25, 0, 33, 0, 0, 33, 0,
	0, 0, 33, 0, 33, 0, 17, 25, 0, 17, 25, 0, 33, 0, 0, 33, 0,
	0, 35, 8, 34, 40, 0, 17, 3, 21, 2, 25, 0, 33, 0, 0, 33, 0,
	0, 41, 39, 0, 0, 0, 41, 29, 29, 29, 39, 0, 42, 34, 34, 40, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	}

	local genTileImg = Image(newSpr.width, newSpr.height, newSpr.colorMode)
	genTileImg:drawSprite(newSpr, 1)
	local previewSprite = Sprite(tile_size * 17, tile_size * 18, spr.colorMode)
	previewSprite.filename = "Preview"
	local previewImage = previewSprite.cels[1].image

	for p=1,#preview47Tilemap do
		local tileNum = preview47Tilemap[p]
		local spritePosX = (tileNum % 8) * tile_size
		local spritePosY = math.floor(tileNum / 8) * tile_size
		local tilePosX = ((p-1) % 17) * tile_size
		local tilePosY = math.floor((p-1) / 17) * tile_size
		local tileInitX = tilePosX
		
		for it in genTileImg:pixels(Rectangle(spritePosX, spritePosY, tile_size, tile_size)) do
			local pixel = it()
			previewImage:drawPixel(tilePosX, tilePosY, pixel)
			
			tilePosX = tilePosX + 1
			if tilePosX == tileInitX + tile_size then
				tilePosX = tileInitX
				tilePosY = tilePosY + 1
			end
		end
	end

	newSpr:close()
	app.refresh()
else -- Generate 16 tile preview.
	local preview16Tilemap = 
	{
	17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
	17, 8, 4, 4, 4, 12, 8, 4, 4, 4, 4, 12, 17, 8, 4, 4, 4, 4, 12, 17,
	17, 14, 13, 13, 13, 15, 6, 1, 1, 1, 1, 11, 17, 6, 1, 1, 1, 1, 11, 17,
	17, 8, 12, 8, 4, 12, 14, 13, 13, 13, 13, 15, 17, 6, 1, 1, 1, 1, 11, 17,
	17, 6, 11, 6, 1, 11, 8, 4, 12, 8, 4, 12, 17, 6, 1, 1, 1, 1, 11, 17,
	17, 6, 11, 6, 1, 11, 6, 1, 11, 6, 1, 3, 12, 6, 1, 1, 1, 1, 11, 17,
	17, 6, 11, 6, 1, 11, 14, 13, 15, 6, 1, 1, 11, 14, 13, 13, 13, 13, 15, 17,
	17, 14, 15, 14, 13, 15, 17, 17, 17, 6, 1, 9, 15, 17, 17, 17, 17, 17, 17, 17,
	17, 8, 4, 12, 17, 8, 4, 12, 17, 14, 13, 15, 17, 17, 8, 4, 4, 4, 12, 17,
	17, 6, 1, 11, 17, 6, 1, 11, 8, 4, 4, 4, 4, 12, 6, 9, 13, 5, 11, 17,
	17, 14, 13, 7, 4, 10, 13, 15, 6, 1, 1, 1, 1, 11, 6, 11, 17, 6, 11, 17,
	17, 17, 17, 6, 1, 11, 17, 17, 6, 1, 9, 5, 1, 11, 6, 11, 17, 6, 11, 17,
	17, 8, 4, 10, 13, 7, 4, 12, 6, 1, 3, 2, 1, 11, 6, 11, 17, 6, 11, 17,
	17, 6, 1, 11, 17, 6, 1, 11, 6, 1, 1, 1, 1, 11, 6, 3, 4, 2, 11, 17,
	17, 14, 13, 15, 17, 14, 13, 15, 14, 13, 13, 13, 13, 15, 14, 13, 13, 13, 15, 17,
	17, 8, 4, 12, 8, 4, 12, 8, 4, 12, 8, 4, 4, 12, 17, 17, 17, 17, 17, 17,
	17, 6, 1, 11, 6, 1, 11, 6, 1, 3, 2, 1, 1, 3, 12, 17, 8, 4, 12, 17,
	17, 14, 5, 3, 2, 9, 15, 14, 5, 1, 1, 9, 5, 1, 11, 17, 6, 1, 11, 17,
	17, 17, 14, 13, 13, 15, 17, 17, 14, 13, 13, 15, 14, 13, 15, 17, 14, 13, 15, 17,
	17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17
	}
	
	local genTileImg = Image(newSpr.width, newSpr.height, newSpr.colorMode)
	genTileImg:drawSprite(newSpr, 1)
	local previewSprite = Sprite(tile_size * 20, tile_size * 20, spr.colorMode)
	previewSprite.filename = "Preview"
	local previewImage = previewSprite.cels[1].image

	for p=1,#preview16Tilemap do
		local tileNum = preview16Tilemap[p]
		local spritePosX = (tileNum % 9) * tile_size
		local spritePosY = math.floor(tileNum / 9) * tile_size
		local tilePosX = ((p-1) % 20) * tile_size
		local tilePosY = math.floor((p-1) / 20) * tile_size
		local tileInitX = tilePosX
		
		for it in genTileImg:pixels(Rectangle(spritePosX, spritePosY, tile_size, tile_size)) do
			local pixel = it()
			previewImage:drawPixel(tilePosX, tilePosY, pixel)
			
			tilePosX = tilePosX + 1
			if tilePosX == tileInitX + tile_size then
				tilePosX = tileInitX
				tilePosY = tilePosY + 1
			end
		end
	end

	newSpr:close()
	app.refresh()
end