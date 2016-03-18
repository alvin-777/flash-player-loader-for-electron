electron = require 'electron'
app = if process.type is 'browser' then electron.app else electron.remote.app
{join} = require 'path'
fs = require 'fs'

doNothing = ->
log = doNothing
error = doNothing

debug = (logFunc, errFunc) ->
  if typeof logFunc is 'function'
    log = error = logFunc
  else
    log = console.log.bind console
    error = console.error.bind console
  error = errFunc if typeof errFunc is 'function'
  log 'Debugging Flash Loader'
  @

PLATFORM = process.platform
FILENAME = switch PLATFORM
  when 'darwin' then 'PepperFlashPlayer.plugin'
  when 'linux'  then 'libpepflashplayer.so'
  when 'win32'  then 'pepflashplayer.dll'

# `path`  can be the full path to the file,
#         or the path to the dir contains the file.
# Returns the validated path string, or null if `path` is not valid.
validatePath = (path) ->
  p = path
  try
    fs.accessSync p
    if not p.endsWith FILENAME
      p = join path, FILENAME
      fs.accessSync p
  catch
    return null
  p


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

findChromeFlashPath = (getAll = false) ->
  # Refer to: https://helpx.adobe.com/flash-player/kb/flash-player-google-chrome.html
  switch PLATFORM
    when 'darwin'
      if getAll
        paths = []
        try
          flashDir = join app.getPath('appData'), 'Google/Chrome/PepperFlash'
          flashVersions = fs.readdirSync flashDir
          for ver in flashVersions
            paths.push(join flashDir, ver)
      try
        # Usually there are 2 directories under the 'Versions' directory,
        # all named after their respective Google Chrome version number.
        # Find the newest version of Google Chrome
        # and use its built-in Pepper Flash Player plugin.
        chromeVersionsDir = '/Applications/Google Chrome.app/Contents/Versions'
        internalFlashDir = 'Google Chrome Framework.framework/Internet Plug-Ins/PepperFlash'
        chromeVersions = fs.readdirSync chromeVersionsDir
        if not getAll
          return null if chromeVersions.length is 0 # Broken Chrome...
          chromeVer = chromeVersions.reduce getNewerVersion
          chromeFlashPath = join chromeVersionsDir, chromeVer, internalFlashDir
          fs.accessSync chromeFlashPath
          chromeFlashPath
        else
          for ver in chromeVersions
            paths.push(join chromeVersionsDir, ver, internalFlashDir)
          paths.map(validatePath).filter (x) -> x
      catch
        null
    else null

findSystemFlashPath = ->
  # Download/install from: https://get.adobe.com/flashplayer/otherversions/
  switch PLATFORM
    when 'darwin'
      try
        systemFlashPath = '/Library/Internet Plug-Ins/PepperFlashPlayer'
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
  path = validatePath path
  return '' if not path
  switch PLATFORM
    when 'darwin'
      # The version info is in the Info.plist inside PepperFlashPlayer.plugin
      plistPath = join path, 'Contents', 'Info.plist'
      plistContent = fs.readFileSync(plistPath, 'utf8')
      match = /<key>CFBundleVersion<\/key>\s*<string>(\d+(?:\.\d+)*)<\/string>/.exec plistContent
      if match and match.length > 1 then match[1] else ''
    else ''

getAllChromeFlashVersions = ->
  paths = findChromeFlashPath true
  paths.map (p) -> [getFlashVersion(p), p]

flashSources = []
usingIndex = -1
addSource = (location, version) ->
  o = loc: location
  if version?
    if typeof version is 'string' and reVerNum.test version
      o.ver = version
    else
      error "Invalid version string for #{location}: #{version}"
  flashSources.push o
  @

getPath = (loc) ->
  if loc?
    switch loc.toLowerCase()
      when '@chrome'
        flashPath = findChromeFlashPath()
        errMsg = 'Could not load Chrome integrated Pepper Flash Player plug-in'
      when '@system'
        flashPath = findSystemFlashPath()
        errMsg = 'Could not load Pepper Flash Player system plug-in'
      else
        flashPath = loc
        errMsg = "Could not load '#{FILENAME}' from: \n#{loc}"
  else
    if flashSources.length is 0
      errMsg = 'No source has been added. Please call `addSource()` \
                to add the location where Flash Player can be found.'
    for src, i in flashSources
      flashPath = getPath src.loc
      usingIndex = i
      break if flashPath?
  flashPath = validatePath flashPath
  error errMsg if errMsg? and not flashPath?
  flashPath

load = ->
  flashPath = getPath()
  if flashPath?
    log "Loading Pepper Flash Player: \n#{flashPath}"
    app.commandLine.appendSwitch 'ppapi-flash-path', flashPath
    # Note: the 'ppapi-flash-version' switch is used by Google Chrome to decide
    # which flash player to load (it'll choose the newest one), and display in
    # the 'chrome://version', 'chrome://plugins', 'chrome://flash' pages.
    # However, for (most) electron apps, it's useless. It's safe to ignore it.
    ver = getFlashVersion flashPath
    ver = flashSources[usingIndex].ver if usingIndex >= 0 and not ver
    if ver
      log "Pepper Flash Player version: #{ver}"
      app.commandLine.appendSwitch 'ppapi-flash-version', ver

if process.type is 'browser'
  exports.addSource = addSource
  exports.load = load

exports.debug = debug
exports.getFilename = () -> FILENAME
exports.getVersion = getFlashVersion
exports.getAllChromeFlashVersions = getAllChromeFlashVersions
