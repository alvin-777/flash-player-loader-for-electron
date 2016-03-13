# Flash Player Loader (for electron apps)

Makes life easier for the [electron](http://electron.atom.io/) apps
which need the Pepper Flash Player.

## Installation

```sh
npm install --save flash-player-loader
```

## Usage

```js
var flashLoader = require('flash-player-loader');
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
If `"@chrome"` is specified, it will automatically look for the Flash Player
integrated by the newest installed Google Chrome.  
If `"@system"` is specified, it will look for the globally installed Pepper Flash Player.

You can optionally pass in a version string, which will be passed to
[Chromium](http://www.chromium.org) with the `ppapi-flash-version` switch.  
_Note:_  
1)  Google Chrome uses this version number to decide which flash player to load,
    and for displaying. However, for (most) electron apps, it's useless.
    *It's safe to ignore it.*  
2)  On **_OS X_**, the Flash Player version is automatically detected.
    The passed in string is **ignored**.

### `flashLoader.load()`

Validates the source(s) added by `addSource()`, in the order they are added.
The first valid one will be loaded.

### `flashLoader.debug([logFunc[, errFunc]])`

* `logFunc` Function (optional)
* `errFunc` Function (optional)

Enable debug mode.
When enabled, extra information and error messages will be print to the console.

By default it uses `console.log` to log extra information,
and `console.error` for error messages.  
You can optionally specify a customised log function and error function,
to make the output format match other output of your app,
or log the information in other forms (e.g., write to a log file).  
If only one function is passed in, both `logFunc` and `errFunc` will use it.  
_(See the test app for instance.)_

### `flashLoader.getVersion(location)` _OS X_

* `location` String

Returns the version of the Flash Player found at the specified location.
An empty string is returned if the location is invalid.
