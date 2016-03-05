{app} = require 'electron'
{join} = require 'path'
fs = require 'fs'

doNothing = ->
log = doNothing
error = doNothing

debugMode = false
debug = (b = true, logFunc, errFunc) ->
  debugMode = b
  if debugMode
    if typeof logFunc is 'function'
      log = error = logFunc
    else
      log = console.log.bind console
    if typeof errFunc is 'function'
      error = errFunc
    else
      error ?= console.error.bind console
    log 'Debugging Flash Loader'
  else
    log = error = doNothing

PLATFORM = process.platform
FILENAME = switch PLATFORM
  when 'darwin' then 'PepperFlashPlayer.plugin'
  when 'linux'  then 'libpepflashplayer.so'
  when 'win32'  then 'pepflashplayer.dll'

validatePath = (path) ->
  return false if typeof path isnt 'string' or not path.endsWith FILENAME
  try
    fs.accessSync path
  catch
    return false
  true

reVerNum = /(\d+)\.(\d+)\.(\d+)\.(\d+)/
getNewerVersion = (ver1, ver2) ->
  v1 = reVerNum.exec ver1
  v2 = reVerNum.exec ver2
  if not v1
    return if v2 then ver2 else ''
  for i in [1..4]
    continue if v1[i] == v2[i]
    return if parseInt(v1[i]) > parseInt(v2[i]) then ver1 else ver2
  ver1 # Exactly the same version

findChromeFlashPath = ->
  # Refer to: https://helpx.adobe.com/flash-player/kb/flash-player-google-chrome.html
  switch PLATFORM
    when 'darwin'
      try
        # Usually there are 2 directories under the 'Versions' directory,
        # all named after their respective Google Chrome version number.
        # Find the newest version of Google Chrome
        # and use its built-in Pepper Flash Player plugin.
        chromeVersionsDir = '/Applications/Google Chrome.app/Contents/Versions'
        chromeVersions = fs.readdirSync chromeVersionsDir
        return null if chromeVersions.length is 0 # Broken Chrome...
        chromeVer = chromeVersions.reduce getNewerVersion
        chromeFlashPath = join chromeVersionsDir, chromeVer,
          'Google Chrome Framework.framework/Internet Plug-Ins/PepperFlash', FILENAME
        fs.accessSync chromeFlashPath
        chromeFlashPath
      catch
        null
    else null

findSystemFlashPath = ->
  # Download/install from: https://get.adobe.com/flashplayer/otherversions/
  switch PLATFORM
    when 'darwin'
      try
        systemFlashPath = '/Library/Internet Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin'
        fs.accessSync systemFlashPath
        systemFlashPath
      catch
        null
    else null

getFlashVersion = (loc) ->
  return '' if typeof loc isnt 'string'
  path = switch loc.toLowerCase()
    when '@chrome' then findChromeFlashPath()
    when '@system' then findSystemFlashPath()
    else loc
  return '' if not validatePath path
  switch PLATFORM
    when 'darwin'
      # The version info is in the Info.plist inside PepperFlashPlayer.plugin
      plistPath = join path, 'Contents', 'Info.plist'
      plistContent = fs.readFileSync(plistPath, 'utf8')
      match = /<key>CFBundleVersion<\/key>\s*<string>(\d+(?:\.\d+)*)<\/string>/.exec plistContent
      if match and match.length > 1 then match[1] else ''
    else ''

flashSources = []
addSource = (location) ->
  flashSources.push location

getPath = (loc) ->
  if loc?
    switch loc.toLowerCase()
      when '@chrome'
        flashPath = findChromeFlashPath()
        errMsg = 'Could not load Chrome Pepper Flash Player'
      when '@system'
        flashPath = findSystemFlashPath()
        errMsg = 'Could not load system Pepper Flash Player plug-in'
      else
        flashPath = loc if validatePath loc
        errMsg = "Could not load '#{FILENAME}' from: \n#{loc}"
  else
    for loc in flashSources
      flashPath = getPath loc
      break if flashPath?
  error errMsg if errMsg? and not flashPath?
  flashPath

load = ->
  flashPath = getPath()
  if flashPath?
    log "Loading Pepper Flash Player from: \n#{flashPath}"
    log "Pepper Flash Player version: #{getFlashVersion flashPath}" if PLATFORM is 'darwin'
    app.commandLine.appendSwitch 'ppapi-flash-path', flashPath
    # Note: the 'ppapi-flash-version' switch is used by Google Chrome to decide
    # which flash player to load (it'll choose the newest one), and dioplay in
    # the 'chrome://version', 'chrome://plugins', 'chrome://flash' pages.
    # But it's useless here, so we just ignore it.

if process.type is 'browser'
  exports.addSource = addSource
  exports.load = load

exports.debug = debug
exports.FLASH_PLAYER_FILENAME = FILENAME
exports.getVersion = getFlashVersion
