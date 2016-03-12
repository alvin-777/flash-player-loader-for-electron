# flash-player-loader-for-electron

Makes life easier for the electron apps which need the Pepper Flash Player.

## Installation

```sh
npm install --save flash-player-loader-for-electron
```

## Usage

```js
var flashLoader = require('flash-player-loader-for-electron');
var ppapi_flash_path = '/path/to/dir/contains/flash/player/' + flashLoader.getFilename();
flashLoader.addSource(ppapi_flash_path);
flashLoader.load();
```

## API

### `flashLoader.getFilename()`

Returns the Flash Player filename according to the running OS.

### `flashLoader.addSource(location[, version])`

* `location` String
* `version` String (optional)

Adds the location of Flash Player.

The `location` is basically the _path to the Pepper Flash Player file_.  
On **_OS X_**, you can also specify `"@chrome"` or `"@system"` for `location`.   
If `"@chrome"` is specified, it will automatically look for the Flash Player integrated by the newest installed Google Chrome.  
If `"@system"` is specified, it will look for the globally installed Pepper Flash Player.

You can optionally pass in a version string, which will be passed to [Chromium](http://www.chromium.org) with the `ppapi-flash-version` switch.  
_Note:_  
1) Google Chrome uses this version number to decide which flash player to load, and for displaying. However, for (most) electron apps, it's useless. *It's safe to ignore it.*  
2) On **_OS X_**, the Flash Player version is automatically detected. The passed in string is **ignored**.

### `flashLoader.load()`

Validates the source(s) added by `addSource()`, in the order they are added,
the first valid one will be loaded.

### `flashLoader.debug(enable[, logFunc[, errFunc]])`

* `enable` Boolean
* `logFunc` Function (optional)
* `errFunc` Function (optional)

Debug mode. If enabled, it will output extra information and error messages.

You can optionally specify a customised log function and error function,
to make the output match other output of your app.  
If `logFunc` is omitted, it will use `console.log` to log extra information.  
If `errFunc` is omitted, it will use `logFunc` to log error messages.
If `logFunc` is also omitted, it will use `console.error`.  
_(See the test app for instance.)_

### `flashLoader.getVersion(location)` _OS X_

* `location` String

Returns the version of the Flash Player found at the specified location.
An empty string is returned if the location is invalid.
