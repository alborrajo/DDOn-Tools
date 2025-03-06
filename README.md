# DDOn Tools

Tools to be used with [Arrowgene.DragonsDogmaOnline](https://github.com/sebastian-heinz/Arrowgene.DragonsDogmaOnline)

![Screenshot](info/readme%20screenshot.png)

This is a server management utility that allows you to import, edit, and export custom enemy sets and gathering spots.

## Installation

Get the latest release from the [Releases page](https://github.com/alborrajo/DDOn-Tools/releases) and unzip it. Run __DDOn Tools.exe__.

Alternatively, you can follow the steps in the [Development](#development) section

## How to use

- Select a stage in the left menu's first tab
- Move around the map dragging your mouse.
- Zoom with the mouse wheel.
- Add enemies/items by draggin from the list to any of the positions.
    - Click on an enemy/item to change its properties.
    - Delete with right click
    - Save or load your sets to a file from the File menu (top left from the Enemy/Items tabs).
    - Select multiple entries by holding shift and clicking
    - Select an area by holding ctrl and dragging your mouse. Hold shift too to add to an existing selection 
    - If any set placemarks are overlapping you can hide them by having your mouse over them and pressing H. Press Shift+H to unhide hidden placemarks.
    - Change the suggested EXP and HOBO values curve from the Settings
- Optionally set up in the settings an address and credentials for an admin account to use the Chat and Player functionalities
    - Kick players by right clicking their names on the menu

## Development

1. Clone the repository
2. Download [Godot 3.5](https://godotengine.org/)
3. Import and open the project in Godot's project list window
4. Run the program (Press F5 or the play button on the top right)
