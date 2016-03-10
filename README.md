# flash-player-loader-for-electron

Makes life easier for the electron apps which need the pepper flash player.

## Installation

    npm install --save hrstopwatch

## Usage

    var flashLoader = require('flash-player-loader-for-electron');
    var ppapi_flash_path = '/path/to/dir/contains/flash/player/' + flashLoader.getFilename();
    flashLoader.addSource(ppapi_flash_path);
    flashLoader.load();

