updateCode = () ->
  camera = $('#widget-camera').val()
  refresh = $('#widget-refresh-rate').val()
  width = $('#widget-camera-width').val()
  option_width = $('#width-option').val()
  pre_auth = $('#widget-authenticate').val()

  url = window.location.origin
  camera_name = $('#widget-camera option:selected').text()
  offline = camera_name.indexOf('(Offline)') != -1
  priv = if camera_name.indexOf('(Private)') == -1 then 'false' else 'true'
  api_credentials = if pre_auth == 'true' then "&api_id=#{window.api_credentials.api_id}&api_key=#{window.api_credentials.api_key}" else ''

  baseText = "<div id='ec-container-#{camera}' style='width:
    #{width}#{option_width}'></div>
    <script src='#{url}/live.view.widget.js?refresh=#{refresh}&camera=#{camera}&private=#{priv}#{api_credentials}' async></script>"
  $('#code').text(baseText)
  document.removeEventListener("visibilitychange", window.ec_vis_handler, false);
  clearTimeout(window.ec_watcher) if window.ec_watcher?
  $('.preview').html(baseText) unless offline
  true

updatePartialValues = ->
  camera = $('#widget-camera').val()
  refresh = $('#widget-refresh-rate').val()
  width = $('#widget-camera-width').val()
  option_width = $('#width-option').val()
  pre_auth = $('#widget-authenticate').val()

  url = window.location.origin
  camera_name = $('#widget-camera option:selected').text()
  offline = camera_name.indexOf('(Offline)') != -1
  priv = if camera_name.indexOf('(Private)') == -1 then 'false' else 'true'
  api_credentials = if pre_auth == 'true' then "&api_id=#{window.api_credentials.api_id}&api_key=#{window.api_credentials.api_key}" else ''

  baseText = "<div id='ec-container-#{camera}' style='width:
    #{width}#{option_width}'><div>
    <script src='#{url}/live.view.widget.js?refresh=#{refresh}&camera=#{camera}&private=#{priv}#{api_credentials}' async></script>"
  $('#code').text(baseText)
  $("#ec-container-#{camera}").width("#{width}#{option_width}")

$ ->
  updateCode()
  $('#widget-camera-width').change(updatePartialValues)
  $('#width-option').change(updatePartialValues)
  $('#widget-refresh-rate').change(updateCode)
  $('#widget-camera').change(updateCode)
  $('#widget-authenticate').change(updatePartialValues)
  $('#code').on 'click', ->
    @select()
    return
