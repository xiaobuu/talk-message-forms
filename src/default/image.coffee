React = require 'react'

LiteImageLoading = React.createFactory require('react-lite-misc').ImageLoading
LiteImageLocal = React.createFactory require './image-local'

div = React.createFactory 'div'
img = React.createFactory 'img'
span = React.createFactory 'span'

T = React.PropTypes

module.exports = React.createClass
  displayName: 'message-form-image'

  propTypes:
    collectionMode: T.bool
    onClick: T.func
    onLoaded: T.func
    attachment: T.object.isRequired
    eventBus: T.object

  getInitialState: ->
    isUploadImage: false

  componentDidMount: ->
    if @props.eventBus?
      unless @props.attachment.data.fileKey?
        @props.eventBus.addListener 'uploader/create', @onCreate
        @props.eventBus.addListener 'uploader/progress', @onProgress
        @props.eventBus.addListener 'uploader/complete', @onDone
        @props.eventBus.addListener 'uploader/error', @onDone

  componentWillUnoumt: ->
    if @props.eventBus?
      @props.eventBus.removeListener 'uploader/create', @onCreate
      @props.eventBus.removeListener 'uploader/progress', @onProgress
      @props.eventBus.removeListener 'uploader/complete', @onDone
      @props.eventBus.removeListener 'uploader/error', @onDone

  componentWillReceiveProps: (nextProps) ->
    console.log 'will receive', nextProps

  onClick: ->
    @props.onClick?()

  onClickUploadImage: ->
    if @state.progress is 1
      @props.onClick?()

  onLoaded: ->
    @props.onLoaded?()

  onCreate: (data) ->
    {fileName, fileSize} = data
    if (fileName is @props.attachment.data.fileName) and (fileSize is @props.attachment.data.fileSize)
      @setState
        isUploadImage: true
        progress: 0

  onProgress: (progress, data) ->
    {fileName, fileSize} = data
    if (fileName is @props.attachment.data.fileName) and (fileSize is @props.attachment.data.fileSize)
      @setState
        progress: progress
        isUploadImage: true

  onDone: ->
    @setState progress: 1

  renderPreview: ->
    if @props.attachment.data.thumbnailUrl?.length
      imageHeight = @props.attachment.data.imageHeight
      imageWidth = @props.attachment.data.imageWidth
      thumbnailUrl = @props.attachment.data.thumbnailUrl

      boundary = if @props.collectionMode then 200 else 240
      reg = /(\/h\/\d+)|(\/w\/\d+)/g

      if imageWidth > boundary
        previewHeight = Math.round(imageHeight / (imageWidth / boundary))
        previewWidth = boundary
      else
        previewHeight = imageHeight
        previewWidth = imageWidth

      if previewHeight > boundary
        previewWidth = Math.round(previewWidth / (previewHeight / boundary))
        previewHeight = boundary

      if reg.test thumbnailUrl
        src = thumbnailUrl
          .replace(/(\/h\/\d+)/g, "/h/#{ previewHeight }")
          .replace(/(\/w\/\d+)/g, "/w/#{ previewWidth }")
      else
        src = thumbnailUrl

      style =
        height: previewHeight
        maxWidth: previewWidth

      if @state.isUploadImage
        image = LiteImageLocal
          key: @props.attachment.data.fileName
          src: src
          onClick: @onClickUploadImage
          onLoaded: @onLoaded
      else
        image = LiteImageLoading
          uploading: @state.isUploadImage and @state.progress < 1
          src: src
          onClick: @onClick
          onLoaded: @onLoaded

      div className: 'preview', style: style,
        image
        @renderLoadingScreen()
        @renderLoadingIndicator()

  renderLoadingScreen: ->
    return if not @state.isUploadImage or  @state.progress is 1
    style =
      width: "#{@state.progress * 100}%"
    div className: 'progress-background',
      div className: 'progress-bar', style: style

  renderLoadingIndicator: ->
    return if not @state.isUploadImage or @state.progress is 1
    div className: 'uploading-indicator'

  render: ->
    div className: 'attachment-image',
      @renderPreview()