# Flash Player Loader (for electron apps)

Makes life easier for the [electron](http://electron.atom.io/) apps which need the [Pepper Flash Player][1].

The path to the Flash Player for your app usually differs between develop (git) version and release (packed) version.  
This module manages multiple sources for you, and provides extra debug information and error handling.  
Plus some handy features (_OS X only_) like automatically locate the Flash Player and get the version of it.

More details can be found at
[electron docs](https://github.com/atom/electron/blob/master/docs/tutorial/using-pepper-flash-plugin.md).

## Installation

```sh
npm install --save flash-player-loader
```

To run the example app:
```
cd /path/to/flash-player-loader
npm install
npm test
```

## Usage

```js
var flashLoader = require('flash-player-loader');
var path = '/path/to/dir/contains/flash/player';
flashLoader.addSource(path);
flashLoader.addSource('/alternative/path');
flashLoader.load();
```

Alternatively, you can chain the methods together.
```js
require('flash-player-loader').addSource('/path/to/dir').load();
```

_**Do not forget to add the `'web-preferences': {'plugins': true}` option
when creating your BrowserWindow.**_

See `test/index.js` for more detailed example and explanations.

## Get Pepper Flash Player Plug-in

* Install [Google Chrome](https://www.google.com/chrome/browser/desktop/index.html).  
  You can find the path to the Pepper Flash Player in the `chrome://plugins` tab.
* Install the _PPAPI_ [system plug-in][2].
* You can also download and install any older version of the plug-in from [here][3].

## Troubleshooting

##### The path added is correct, but it doesn't load the plug-in
1.  Please make sure that you are not mixing the architecture of electron and Flash Player.  
    That is, 32-bit electron will not work with 64-bit Flash Player, and vice versa.
2.  Please make sure that you have included the option
    `'web-preferences': {'plugins': true}` when creating BrowserWindow.

## API

### `flashLoader.getFilename()`

Returns the Flash Player filename according to the running OS.

### `flashLoader.addSource(location[, version])`

* `location` String
* `version` String (optional)

Adds the location of Pepper Flash Player.

_This method can be called multiple times.
All added sources will be validated in the order they are added,
until the first valid one is found._

The `location` is the _path to the **directory** contains the Pepper Flash Player file_,
or the _full path to the Pepper Flash Player file_
(The filename has to match the string returned by `flashLoader.getFilename()`).  
On **_OS X_**, you can also specify `"@chrome"` or `"@system"` for `location`.   
If `"@chrome"` is specified, it will automatically look for the [Pepper Flash Player][1]
integrated by the newest installed Google Chrome.  
If `"@system"` is specified, it will look for the
[Pepper Flash Player system plug-in][2] (**PPAPI**).

You can optionally pass in a version string, which will be passed to
[Chromium](http://www.chromium.org) with the `ppapi-flash-version` switch.  
_Note:_  
1)  Google Chrome uses this version number to decide which Flash Player to load,
    and for displaying. However, for (most) electron apps, it's useless.
    *It's safe to ignore the version string.*  
2)  On **_OS X_**, the Flash Player version is automatically detected.
    The passed in string is **ignored**.

_This method returns `this`, so it's possible to chain it._

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
_(See the example app for instance.)_

_This method returns `this`, so it's possible to chain it._

### `flashLoader.getVersion(location)` _OS X_

* `location` String

Returns the version of the Flash Player found at the specified location.
An empty string is returned if the location is invalid.


[1]: https://helpx.adobe.com/flash-player/kb/flash-player-google-chrome.html      "Flash Player with Google Chrome"
[2]: https://get.adobe.com/flashplayer/otherversions/                             "Download Pepper Flash Player system plug-in"
[3]: https://helpx.adobe.com/flash-player/kb/archived-flash-player-versions.html  "Download archived Pepper Flash Player"
