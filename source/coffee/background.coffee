chrome.runtime.onInstalled.addListener (details) ->
  if details?.reason is 'install'
    if chrome.runtime.openOptionsPage #NOTE Only works in Chrome 42+
      chrome.runtime.openOptionsPage()
    else
      window.open chrome.runtime.getURL 'options/index.html'