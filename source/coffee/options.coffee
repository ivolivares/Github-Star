'use strict';
# Adding some functions to JS core
# ----------
Node::prependChild = (el) -> @childNodes[1] and @insertBefore(el, @childNodes[1]) or @appendChild(el)

# General Utils
# ----------
Utils =
  $: (id) -> document.getElementById id

  bind: (el, type, handler) ->
    try
      if el.addEventListener
        el.addEventListener type, handler, false
      else if el.attachEvent
        el.attachEvent "on#{type}", handler
    catch e

  insertAfter: (newNode, referenceNode) ->
    referenceNode.parentNode.insertBefore newNode, referenceNode.nextSibling

  setTimeout: (t, cb) -> window.setTimeout cb, t

  trigger: (element, eventName) ->
    if eventName
      event = document.createEvent 'HTMLEvents'
      event.initEvent eventName, true, false
      element?.dispatchEvent? event

class Options
  constructor: ->
    @UI =
      button:
        save: Utils.$ 'apply-settings'
        reset: Utils.$ 'reset-settings'
      input:
        username: Utils.$ 'github-username'
      section: document.getElementsByTagName('section')?[0]
    @init()

  init: ->
    @restoreOptions()
    @setBindings()

  setBindings: ->
    Utils.bind @UI.button.save, 'click', () =>
      username = @UI.input.username.value
      if username
        @saveOptions username
      else
        @showMessage 'Please enter your github username.', 10000

    Utils.bind @UI.button.reset, 'click', () => @saveOptions()

    Utils.bind @UI.input.username, 'keydown', (e) =>
      Utils.trigger @UI.button.save, 'click' if e.wihch or e.keyCode is 13

  saveOptions: (username = '') ->
    chrome.storage.sync.set
      githubUsername: username
    , () =>
      @UI.input.username.value = username;
      @showMessage 'Options saved.', 5000
    chrome.storage.local.set 'githubUsername': username

  restoreOptions: ->
    chrome.storage.sync.get
      githubUsername: ''
    , (items) =>
      @UI.input.username.value = items.githubUsername or '';

  showMessage: (message, timeout) ->
    @removeMessage()
    div = document.createElement 'div'
    div.setAttribute 'class', 'message'
    div.innerHTML = message or ''
    Utils.insertAfter div, @UI.section.previousElementSibling
    if timeout
      Utils.setTimeout timeout, () => @removeMessage()
  
  removeMessage: -> document.getElementsByClassName('message')?[0]?.remove?()

document.addEventListener 'DOMContentLoaded', new Options