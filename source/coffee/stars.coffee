'use strict';
# Adding some functions to JS core
# ----------
Node::prependChild = (el) -> @childNodes[1] and @insertBefore(el, @childNodes[1]) or @appendChild(el)

# General Utils
# ----------
Utils =
  $: (id) -> document.getElementById id

  addClassName: (el, name) ->
    if not @hasClassName(el, name)
      el.className = if el.className then [el.className, name].join(' ') else name

  bind: (el, type, handler) ->
    try
      if el.addEventListener
        el.addEventListener type, handler, false
      else if el.attachEvent
        el.attachEvent "on#{type}", handler
    catch e

  hasClassName: (el, name) ->
    new RegExp("(?:^|\\s+)#{name}(?:\\s+|$)").test el?.className

  HTTPGet: (url, params = {}, cb) ->
    if window.XMLHttpRequest
      req = new XMLHttpRequest()
    else if window.ActiveXObject
      req = new ActiveXObject 'MSXML2.XMLHTTP.3.0'
    if req?
      req.onreadystatechange = () ->
        if req.readyState is 4 and cb?
          cb req.responseText
      _params = []
      for param, value of params
        _params.push "#{param}=#{encodeURIComponent(value)}"
      req.open 'GET', "#{url}?#{_params.join('&')}", true
      req.send null

  randomID: () -> Math.random().toString(36).substr(2, 5)

  removeClassName: (el, name) ->
    if @hasClassName(el, name)
      c = el.className
      el.className = c.replace new RegExp("(?:^|\\s+)#{name}(?:\\s+|$)", 'g'), ''

  setTimeout: (t, cb) -> window.setTimeout cb, t

  setInterval: (t, cb) -> window.setInterval cb, t

class Stars
  constructor: ->
    @pathname = window.location.pathname
    @instanceID = Utils.randomID()
    @githubUsername = null
    @getGithubUsername () =>
      @init() if @pathname.replace('/', '') is @githubUsername

  init: ->
    @setBindings()
    @getLocation()
    if @inStarred
      @removeSelected()
      @renderContent()
    @getButton()

  setBindings: ->
    for tab in (document.getElementsByClassName('tabnav-tab') or [])
      Utils.bind tab, 'click', (e) =>
        if tab.getAttribute('href').match(/starred/)?
          @renderButton()

  getLocation: ->
    @inStarred = window.location.search.match(/starred/)?
    @renderButton() unless @inStarred
    Utils.setTimeout 2000, () => @getLocation()

  getGithubUsername: (cb) ->
    chrome.storage.local.get 'githubUsername', (data) =>
      if data?.githubUsername
        @githubUsername = data.githubUsername
      else
        console.log 'no set githubUsername'
      cb?()

  removeSelected: ->
    allTabs = document.getElementsByClassName('tabnav-tab')
    for tab in allTabs
      tab.classList.remove 'selected' if tab.classList?[1] is 'selected'

  getButton: ->
    @renderButton() unless document.getElementById(@instanceID)?
    Utils.setTimeout 2000, () => @getButton()

  renderButton: ->
    unless document.getElementById(@instanceID)?
      a = document.createElement 'a'
      a.setAttribute 'id', @instanceID
      Utils.addClassName a, 'tabnav-tab'
      Utils.addClassName a, 'selected' if @inStarred
      a.setAttribute 'href', "#{@pathname}?tab=starred"
      span = document.createElement 'span'
      Utils.addClassName span, 'octicon octicon-star'
      a.appendChild span
      text = document.createTextNode ' Starred'
      a.appendChild text
      Utils.bind a, 'click', (e) =>
        e?.preventDefault?()
        unless @inStarred
          window.location = "#{@pathname}?tab=starred"
      document.getElementsByClassName('tabnav-tabs')?[0].appendChild a
    else
      Utils.removeClassName document.getElementById(@instanceID), 'selected'

  renderContent: ->
    tabContent = document.getElementsByClassName('tab-content')?[0]
    tabContent.innerHTML = ''
    unless @githubUsername
      message = document.createTextNode 'Please configure your Github username on '
      strong = document.createElement 'strong'
      strong.innerHTML = 'Preferences &raquo; Extensions &raquo; Github stars'
      message.appendChild strong
      tabContent.appendChild message
    else
      ul = document.createElement 'ul'
      Utils.addClassName ul, 'repo-list'
      params =
        per_page: 9999999
      Utils.HTTPGet "https://api.github.com/users/#{@githubUsername}/starred", params, (data) =>
          if data?
            data = JSON.parse data
            for repo in (data or [])
              options =
                description: repo.description or ''
                name: repo.name or ''
                owner: repo.owner.login or ''
                ownerURL: repo.owner.html_url or ''
                url: repo.html_url or ''
              repository = @createRepositoryElement options
              ul.appendChild repository
            tabContent.appendChild ul
          else
            message = @getMessage 'You are not set star to any repository yet.'
            tabContent.appendChild message

  getMessage: (message, type = 'warn') ->
    div = document.createElement 'div'
    div.setAttribute 'class', "flash flash-#{type}"
    div.innerHTML = message or ''
    div

  createRepositoryElement: (options = {}) ->
    if options
      repo = document.createElement 'li'
      Utils.addClassName repo, 'repo-list-item'
      name = document.createElement 'h3'
      Utils.addClassName name, 'repo-list-name'
      nameURL = document.createElement 'a'
      nameURL.setAttribute 'href', options.url
      nameURL.innerHTML = options.name
      name.appendChild nameURL
      description = document.createElement 'p'
      Utils.addClassName description, 'repo-list-description'
      description.innerHTML = options.description
      owner = document.createElement 'p'
      Utils.addClassName owner, 'repo-list-meta'
      ownerURL = document.createElement 'a'
      ownerURL.setAttribute 'href', options.ownerURL
      ownerURL.innerHTML = options.owner
      owner.innerHTML = 'Owner '
      owner.appendChild ownerURL
      repo.appendChild name
      repo.appendChild description
      repo.appendChild owner
      repo

document.addEventListener 'DOMContentLoaded', new Stars