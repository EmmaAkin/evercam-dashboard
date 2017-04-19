videojs_array = {}
format_time = null
camera_select = null

initNotification = ->
  Notification.init(".bb-alert")

loadTimelapses = ->
  onError = (jqXHR, status, error) ->
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")
    Notification.show("Failed to retrive timelapses.")

  onSuccess = (timelapses, status, jqXHR) ->
    if timelapses.length is 0
      #$("#divLoadingApps").show()
    else
      $.each timelapses.timelapses, (index, timelapse) ->
        $('#divTimelapses').append getTimelapseHtml(timelapse, index)
        initPlugins(timelapse)

  settings =
    data: {}
    dataType: 'json'
    error: onError
    success: onSuccess
    type: 'GET'
    url: "#{Evercam.API_URL}timelapses?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"
  # cameras/#{Evercam.Camera.id}/
  $.ajax(settings)

initPlugins = (timelapse) ->
  $("#dataslot#{timelapse.id} .radio_edit").iCheck
    radioClass: "iradio_flat-blue"
  $("#dataslot#{timelapse.id} .daterange").datetimepicker({timepicker: false, format: 'd/m/Y'})
  initTimepicker("#dataslot#{timelapse.id} .timerange")
  document.getElementById("timelapse-watermark#{timelapse.id}").addEventListener 'change', readFile
  videojs_array["#{timelapse.id}"] = videojs "video-control-#{timelapse.id}", { }
  initPopup(timelapse.id)

initPopup = (key) ->
  $("#pop-#{key}").popbox
    open: "#open-#{key}"
    box: "#box-#{key}"
    arrow: "#arrow-#{key}"
    arrow_border: "#arrow-border-#{key}"
    close: "#close-popup-#{key}"

getTimelapseHtml = (timelapse, index) ->
  html = "   <div id='dataslot#{timelapse.id}' class='list-border margin-bottom10'>"
  html += "    <div class='col-xs-12 col-sm-6 col-md-4' style='min-height:0px;'>"

  html += "    <div class='' style='margin-top: 5px;'>"
  html += "      <ul id='ul-nav-tab' class='nav nav-tabs'><li class='dropdown pull-right tabdrop hide'></li>"
  html += "        <li id='live-view-tab' class='active'>"
  html += "          <a data-toggle='tab' data-target='#live_video#{timelapse.id}' class='nav-tab-live nav-tab-' aria-expanded='false'><span>View Video</span></a>"
  html += "        </li>"
  html += "        <li>"
  html += "          <a data-toggle='tab' data-target='#settings#{timelapse.id}' class='nav-tab-recordings' aria-expanded='true'>Settings <i class='fa fa-cog'></i></a>"
  html += "        </li>"
  html += "      </ul>"
  html += "      <div class='clear-f'></div>"
  html += "    </div>"

  html += "    <div class='card tab-content' style='min-height:0px;'>"
  html += "      <div id='live_video#{timelapse.id}' class='tab-pane active'>"
  html += "        <div class='snapstack-loading' id='snaps-#{timelapse.id}'>"
  html += "          <video data-setup='{ \"playbackRates\": [0.06, 0.12, 0.25, 0.5, 1, 1.5, 2, 2.5, 3] }' poster='#{Evercam.API_URL}cameras/#{timelapse.camera_id}/thumbnail?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}' preload=\"none\" controls class=\"video-js vjs-default-skin video-bg-width\" id=\"video-control-#{timelapse.id}\">"
  html += "            <source type='application/x-mpegURL' src='#{Evercam.SEAWEEDFS_URL}#{timelapse.camera_id}/timelapses/#{timelapse.id}/index.m3u8'></source>"
  html += "          </video>"
  html += "        </div>"
  html += "        <input type='hidden' id='timelapse-camera-id#{timelapse.id}' value='#{timelapse.camera_id}'/>"
  html += "        <div class='hash-label snapmail-title'><a data-toggle='modal' data-target='#snapmail-form' class='tools-link edit-snapmail' data-val='#{timelapse.id}' title='#{timelapse.title}'>#{timelapse.title}</a><span class='camera-name'>#{timelapse.camera_name}</span><span class='line-end'></span></div>"
  html += "        <div class='camera-time'><span class='spn-label'>Total Snapshots:</span><div class='div-snapmail-values'>#{(if timelapse.snapshot_count is null then 0 else timelapse.snapshot_count)}</div><div class='clear-f'></div></div>"
  html += "        <div class='camera-time'><span class='spn-label'>Created At:</span><div class='div-snapmail-values'>#{format_time.formatDate((new Date(timelapse.created_at*1000)), "d M Y, H:i:s")}</div><div class='clear-f'></div></div>"
  html += "        <div class='camera-time'><span class='spn-label'>Last Snapshot At:</span><div class='div-snapmail-values'>#{(if timelapse.snapshot_count == 0 then '---' else format_time.formatDate((new Date(timelapse.last_snapshot_at*1000)), "d M Y, H:i:s"))}</div><div class='clear-f'></div></div>"
  html += "        <div class='camera-time'><span class='spn-label'>HLS URL:</span><div class='div-snapmail-values'><input id='txtHlsUrl#{timelapse.id}' type='text' readonly class='txt-width' value='#{Evercam.SEAWEEDFS_URL}#{timelapse.camera_id}/timelapses/#{timelapse.id}/index.m3u8'/>"
  html += "        <span class='copy-to-clipboard' data-val='#{timelapse.id}' alt='Copy to clipboard' title='Copy to clipboard'><i class='fa fa-files-o' aria-hidden='true'></i></span></div><div class='clear-f'></div></div>"
  html += "      </div>"

  html += "      <div id='settings#{timelapse.id}' class='tab-pane'>"
  html += "        <table class='table' style='margin-bottom:0px;'>"
  html += "          <tr>"
  html += "            <td class='col-sm-3'>Title: </td>"
  html += "            <td class='col-sm-9'><input type='text' id='timelapse-title#{timelapse.id}' value='#{timelapse.title}' required='required' class='form-control'/></td>"
  html += "          </tr>"
  html += "          <tr><td>Interval: </td><td><select id='timelapse-frequency#{timelapse.id}' class='form-control'>"
  html += "            <option value='0'>Select Interval</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 1)} value='1'>1 Frame Every 1 min</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 5)} value='5'>1 Frame Every 5 min</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 15)} value='15'>1 Frame Every 15 min</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 30)} value='30'>1 Frame Every 30 min</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 60)} value='60'>1 Frame Every 1 hour</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 360)} value='360'>1 Frame Every 6 hours</option>"
  html += "            <option #{select_frequency(timelapse.frequency, 720)} value='720'>1 Frame Every 12 hours</option></select></td>"
  html += "          </tr>"
  html += "          <tr>"
  html += "            <td><label>Date Range:</label></td>"
  html += "            <td>"
  html += "              <div class='col-sm-4 radio-list padding-left0'>"
  html += "                <label class='radio-inline'>"
  html += "                  <input id='chkDateRangeAlways' name='date_range_edit#{timelapse.id}' data-val='#{timelapse.id}' type='radio' #{select_date_time_range(timelapse.date_always, true)} value='true' class='icheck radio_edit date_range_edit'/>&nbsp;Always"
  html += "                </label>"
  html += "              </div>"
  html += "              <div class='col-sm-4 radio-list padding-left0'>"
  html += "                <label class='radio-inline'>"
  html += "                  <input id='chkDateRange' name='date_range_edit#{timelapse.id}' data-val='#{timelapse.id}' type='radio' #{select_date_time_range(timelapse.date_always, false)} value='false' class='icheck radio_edit date_range_edit'/>&nbsp;Range"
  html += "                </label>"
  html += "              </div>"
  html += "            </td>"
  html += "          </tr>"

  html += "          <tr class='range-row'>"
  html += "            <td></td>"
  html += "            <td>"
  html += "              <div id='row_date_range#{timelapse.id}' style='display: #{if timelapse.date_always then "none" else "block"};'>"
  html += "                <div class='col-sm-6 padding-left0'><input type='text' id='txt_from_date#{timelapse.id}' class='form-control daterange' value='#{setDate(timelapse.date_always, timelapse.from_date, "d/m/Y", "")}' placeholder='From Date'></div>"
  html += "                <div class='col-sm-6 padding-left0'><input type='text' id='txt_to_date#{timelapse.id}' class='form-control daterange' value='#{setDate(timelapse.date_always, timelapse.to_date, "d/m/Y", "")}' placeholder='To Date'></div>"
  html += "              </div>"
  html += "            </td>"
  html += "          </tr>"
  html += "          <tr>"
  html += "            <td><label>Time Range:</label></td>"
  html += "            <td>"
  html += "              <div class='col-sm-4 radio-list padding-left0'>"
  html += "                <label class='radio-inline'>"
  html += "                  <input id='chkTimeRangeAlways' name='time_range_edit#{timelapse.id}' data-val='#{timelapse.id}' #{select_date_time_range(timelapse.time_always, true)} type='radio' value='true' class='icheck radio_edit time_range_edit' />&nbsp;Always"
  html += "                </label>"
  html += "              </div>"
  html += "              <div class='col-sm-4 radio-list padding-left0'>"
  html += "                <label class='radio-inline'>"
  html += "                  <input id='chkTimeRange' name='time_range_edit#{timelapse.id}' data-val='#{timelapse.id}' #{select_date_time_range(timelapse.time_always, false)} type='radio' value='false' class='icheck radio_edit time_range_edit' />&nbsp;Range"
  html += "                </label>"
  html += "              </div>"
  html += "            </td>"
  html += "          </tr>"
  html += "          <tr class='range-row'>"
  html += "            <td></td>"
  html += "            <td>"
  html += "              <div id='row_time_range#{timelapse.id}' style='display: #{if timelapse.time_always then "none" else "block"};padding-top:5px;'>"
  html += "                <div class='col-sm-6 padding-left0'><input type='text' id='txt_from_time#{timelapse.id}' class='form-control timerange' placeholder='From Time' readonly value='#{setDate(timelapse.time_always, timelapse.from_date, "H:i", "00:00")}'></div>"
  html += "                <div class='col-sm-6 padding-left0'><input type='text' id='txt_to_time#{timelapse.id}' class='form-control timerange' placeholder='To Time' readonly value='#{setDate(timelapse.time_always, timelapse.to_date, "H:i", "23:59")}'></div>"
  html += "              </div>"
  html += "            </td>"
  html += "          </tr>"
  html += "          <tr>"
  html += "            <td><label>Recoording:</label></td>"
  html += "            <td>"
  html += "              <div class='col-sm-4 radio-list padding-left0'>"
  html += "                <label class='radio-inline'>"
  html += "                  <input id='recording_active#{timelapse.id}' name='recording_status#{timelapse.id}' data-val='#{timelapse.id}' type='radio' #{(if timelapse.status is 'Paused' then '' else 'checked')} value='0' class='icheck radio_edit'/>&nbsp;Active"
  html += "                </label>"
  html += "              </div>"
  html += "              <div class='col-sm-5 radio-list padding-left0'>"
  html += "                <label class='radio-inline'>"
  html += "                  <input id='recording_paused#{timelapse.id}' name='recording_status#{timelapse.id}' data-val='#{timelapse.id}' type='radio' #{(if timelapse.status is 'Paused' then 'checked' else '')} value='3' class='icheck radio_edit'/>&nbsp;Paused"
  html += "                </label>"
  html += "              </div>"
  html += "            </td>"
  html += "          </tr>"
  html += "          <tr>"
  html += "            <td><label>Watermark Pos:</label></td>"
  html += "            <td>"
  html += "              <select id='timelapse-watermark-pos#{timelapse.id}' class='form-control'>"
  html += "                <option #{select_frequency(timelapse.watermark_position, "TopLeft")} value='TopLeft'>Top Left</option>"
  html += "                <option #{select_frequency(timelapse.watermark_position, "TopRight")} value='TopRight'>Top Right</option>"
  html += "                <option #{select_frequency(timelapse.watermark_position, "BottomLeft")} value='BottomLeft'>Bottom Left</option>"
  html += "                <option #{select_frequency(timelapse.watermark_position, "BottomRight")} value='BottomRight'>Bottom Right</option>"
  html += "               </select>"
  html += "            </td>"
  html += "          </tr>"
  html += "          <tr>"
  html += "            <td><label>Watermark Logo:</label></td>"
  html += "            <td>"
  html += "              <div class='col-sm-11 padding-left0'>"
  html += "                <input id='timelapse-watermark#{timelapse.id}' data-val='#{timelapse.id}' type='file' class='form-control' accept='image/*'>"
  html += "              </div>"
  html += "              <div class='col-sm-1 padding-left0'>"
  html += "                <img id='img-watermark#{timelapse.id}' src='#{timelapse.watermark_logo}' style='height:35px;'>"
  html += "                <input type='hidden' id='watermark-base64#{timelapse.id}' value='#{timelapse.watermark_logo}'>"
  html += "              </div>"
  html += "            </td>"
  html += "          </tr>"
  html += "          <tr>"
  html += "            <td></td>"
  html += "            <td>"
  html += "              <div class='pull-left form-group'><button type='button' class='btn btn-primary edit-timelapse' data-val='#{timelapse.id}'><i class='fa fa-check'></i> Save</button></div>"
  html += "              <button type='button' class='btn btn-danger delete-timelapse' data-val='#{timelapse.id}'><i class='fa fa-remove'></i> Delete</button>"
  html += "            </td>"
  html += "          </tr>"
  html += "        </table>"
  html += "      </div>"
  html += "    </div>"

  html += "    <div style='min-height:0px;display: none;'>"
  html += "        <div class='text-right delete-timelapse'>"
  html += "             <span id='pop-#{timelapse.id}' class='popbox2'><div id='open-#{timelapse.id}' href='javascript:;' class='tools-link open2' data-val='#{timelapse.id}'><div class='icon-button red margin-24 margin-left-0'><i class='fa fa-trash-o main-color plus-btn' title='Delete'></i><paper-ripple class='circle recenteringTouch' fit></paper-ripple></div></div>"
  html += "             <div class='collapse-popup'>"
  html += "               <div class='box-snapmail' id='box-#{timelapse.id}' style='width:288px;'>"
  html += "                   <div class='arrow2' id='arrow-#{timelapse.id}'></div>"
  html += "                   <div class='arrow-border2' id='arrow-border-#{timelapse.id}'></div>"
  html += "                   <div class='margin-bottom-10'>Are you sure?</div>"
  html += "                   <div class='margin-bottom-10'><input class='btn btn-primary delete-btn' type='button' value='Yes, Remove' camera-id='#{timelapse.camera_id}' data-val='#{timelapse.id}'/><div id='close-popup-#{timelapse.id}' class='btn closepopup2 grey' fit><div class='text-center'>Cancel</div></div></div>"
  html += "               </div>"
  html += "             </div></span>"
  html += "       </div>"
  html += "       </div>"
  html += "    </div>"
  html += "  </div>"
  html

select_frequency = (frequency, option) ->
  if frequency is option
    "selected"
  else
    ""

select_date_time_range = (is_always, option) ->
  if is_always is option
    "checked"
  else
    ""

setDate = (is_always, datetime, format, default_val) ->
  if is_always
    default_val
  else
    return format_time.formatDate((new Date(datetime*1000)), "#{format}")

copyToClipboard = ->
  $('#divTimelapses').on "click", ".copy-to-clipboard", ->
    timelapse_id = $(this).attr("data-val")
    elem = document.getElementById("txtHlsUrl#{timelapse_id}")
    # create hidden text element, if it doesn't already exist
    targetId = '_hiddenCopyText_'
    isInput = elem.tagName == 'INPUT' or elem.tagName == 'TEXTAREA'
    origSelectionStart = undefined
    origSelectionEnd = undefined
    if isInput
    # can just use the original source element for the selection and copy
      target = elem
      origSelectionStart = elem.selectionStart
      origSelectionEnd = elem.selectionEnd
    else
    # must use a temporary form element for the selection and copy
      target = document.getElementById(targetId)
      if !target
        target = document.createElement('textarea')
        target.style.position = 'absolute'
        target.style.left = '-9999px'
        target.style.top = '0'
        target.id = targetId
        document.body.appendChild target
      target.textContent = elem.textContent
    # select the content
    currentFocus = document.activeElement
    target.focus()
    target.setSelectionRange 0, target.value.length
    # copy the selection
    succeed = undefined
    try
      succeed = document.execCommand('copy')
    catch e
      succeed = false
    # restore original focus
    if currentFocus and typeof currentFocus.focus == 'function'
      currentFocus.focus()
    if isInput
    # restore prior selection
      elem.setSelectionRange origSelectionStart, origSelectionEnd
    else
    # clear temporary content
      target.textContent = ''
    succeed

saveTimelapse = ->
  $('#save-timelapse').on 'click', ->
    save_button = $(this)
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    if $("#timelapse-camera").val() is ''
      Notification.show("Please select camera to continue.")
      return false

    if $("#timelapse-title").val() is ''
      Notification.show("Please enter timelapse title.")
      return false

    if $("#timelapse-frequency").val() is "0"
      Notification.show("Please select timelapse interval.")
      return false

    d = new Date()
    fromDate = "#{(d.getMonth()+1)}/#{d.getDate()}/#{d.getFullYear()}"
    toDate = fromDate
    fromTime = "00:00"
    toTime = fromTime
    dateAlways = $('input[name=date_range]:checked').val()
    timeAlways = $('input[name=time_range]:checked').val()
    if dateAlways is "false"
      fromDate = change_date_format($("#txt_from_date").val())
      if fromDate is ""
        Notification.show("Please select from date range.")
        return false
      toDate = change_date_format($("#txt_to_date").val())
      if toDate is ""
        Notification.show("Please select to date range.")
        return false

    if timeAlways is "false"
      fromTime = $("#txt_from_time").val()
      if fromTime is ""
        Notification.show("Please select from time range.")
        return false

      toTime = $("#txt_to_time").val()
      if toTime is ""
        Notification.show("Please select to time range.")
        return false

      if fromTime is toTime
        Notification.show('To time and from time cannot be same.')
        return false

    watermark_logo = ""
    if $("#timelapse-watermark").val() isnt ""
      watermark_logo = $("#watermark-base64").val().replace("data:image/jpeg;base64,", "")

    o =
      title: $("#timelapse-title").val()
      date_always: dateAlways
      time_always: timeAlways
      frequency: $("#timelapse-frequency").val()
      from_datetime: (new Date("#{fromDate} #{fromTime}"))/1000
      to_datetime: (new Date("#{toDate} #{toTime}"))/1000
      watermark_logo: watermark_logo
      watermark_position: $("#timelapse-watermark-pos").val()

    save_button.attr 'disabled', true

    onError = (jqXHR, status, error) ->
      response = JSON.parse(jqXHR.responseText)
      if jQuery.type(response.message) is "object"
        Notification.show "#{response["message"]}"
      else
        Notification.show "#{response.message}"
      save_button.removeAttr('disabled')

    onSuccess = (result, status, jqXHR) ->
      timelapse = result.timelapses[0]
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      save_button.removeAttr('disabled')
      $('#divTimelapses').prepend getTimelapseHtml(timelapse, 0)
      initPlugins(timelapse)
      $("#timelapse-form").modal("hide")
      clearForm()

    settings =
      data: o
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "POST"
      url: "#{Evercam.API_URL}cameras/#{$("#timelapse-camera").val()}/timelapses?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

deleteTimelapse = ->
  $('#divTimelapses').on 'click', '.delete-timelapse', ->
    timelapse_id = $(this).attr("data-val")
    camera_id = $("#timelapse-camera-id#{timelapse_id}").val()
    onError = (jqXHR, status, error) ->
      if jqXHR.status is 403
        Notification.show "You don't have sufficient permission."
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"

    onSuccess = (result, status, jqXHR) ->
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      Notification.show('Timelapse deleted successfully.')
      player = videojs_array["#{timelapse_id}"]
      player.dispose()
      $("#dataslot#{timelapse_id}").remove()

    settings =
      data: {}
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "DELETE"
      url: "#{Evercam.API_URL}cameras/#{camera_id}/timelapses/#{timelapse_id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

editTimelapse = ->
  $('#divTimelapses').on 'click', '.edit-timelapse', ->
    save_button = $(this)
    timelapse_id = $(this).attr("data-val")
    $(".bb-alert").removeClass("alert-info").addClass("alert-danger")

    if $("#timelapse-title#{timelapse_id}").val() is ''
      Notification.show("Please enter timelapse title.")
      return false

    if $("#timelapse-frequency#{timelapse_id}").val() is "0"
      Notification.show("Please select timelapse interval.")
      return false

    d = new Date()
    fromDate = "#{(d.getMonth()+1)}/#{d.getDate()}/#{d.getFullYear()}"
    toDate = fromDate
    fromTime = "00:00"
    toTime = fromTime
    dateAlways = $("input[name=date_range_edit#{timelapse_id}]:checked").val()
    timeAlways = $("input[name=time_range_edit#{timelapse_id}]:checked").val()
    if dateAlways is "false"
      fromDate = change_date_format($("#txt_from_date#{timelapse_id}").val())
      if fromDate is ""
        Notification.show("Please select from date range.")
        return false
      toDate = change_date_format($("#txt_to_date#{timelapse_id}").val())
      if toDate is ""
        Notification.show("Please select to date range.")
        return false

    if timeAlways is "false"
      fromTime = $("#txt_from_time#{timelapse_id}").val()
      if fromTime is ""
        Notification.show("Please select from time range.")
        return false

      toTime = $("#txt_to_time#{timelapse_id}").val()
      if toTime is ""
        Notification.show("Please select to time range.")
        return false

      if fromTime is toTime
        Notification.show('To time and from time cannot be same.')
        return false

    watermark_logo = ""
    if $("#watermark-base64#{timelapse_id}").val() isnt ""
      watermark_logo = $("#watermark-base64#{timelapse_id}").val().replace("data:image/jpeg;base64,", "")

    o =
      title: $("#timelapse-title#{timelapse_id}").val()
      date_always: dateAlways
      time_always: timeAlways
      frequency: $("#timelapse-frequency#{timelapse_id}").val()
      from_datetime: (new Date("#{fromDate} #{fromTime}"))/1000
      to_datetime: (new Date("#{toDate} #{toTime}"))/1000
      watermark_logo: watermark_logo
      watermark_position: $("#timelapse-watermark-pos#{timelapse_id}").val()
      status: $("input[name=recording_status#{timelapse_id}]:checked").val()

    save_button.attr 'disabled', true

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 500
        Notification.show "500 Internal Server Error"
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"
      save_button.removeAttr('disabled')

    onSuccess = (result, status, jqXHR) ->
      snapMail = result.timelapses[0]
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      Notification.show('Timelapse updated.')
      save_button.removeAttr('disabled')

    settings =
      data: o
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "PATCH"
      url: "#{Evercam.API_URL}cameras/#{$("#timelapse-camera-id#{timelapse_id}").val()}/timelapses/#{timelapse_id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

toggleStatus = ->
  $('#divTimelapses').on 'click', '.toggle-status', ->
    control = $(this)
    timelapse_id = $(this).attr("data-val")
    camera_id = $(this).attr("camera-id")
    if $(this).attr("status") is 'stop'
      timelapse_status = 3
    else
      timelapse_status = 0

    onError = (jqXHR, status, error) ->
      if jqXHR.status is 403
        Notification.show "You don't have sufficient permission."
      else
        response = JSON.parse(jqXHR.responseText)
        Notification.show "#{response.message}"


    onSuccess = (result, status, jqXHR) ->
      # snapMail = result.timelapses[0]
      $(".bb-alert").removeClass("alert-danger").addClass("alert-info")
      if timelapse_status is 3
        control.attr('status', 'start')
        control.removeClass("fa-pause").addClass("fa-play")
      else
        control.attr('status', 'stop')
        control.removeClass("fa-play").addClass("fa-pause")

    settings =
      data: {status: timelapse_status}
      dataType: 'json'
      error: onError
      success: onSuccess
      type: "PATCH"
      url: "#{Evercam.API_URL}cameras/#{camera_id}/timelapses/#{timelapse_id}?api_id=#{Evercam.User.api_id}&api_key=#{Evercam.User.api_key}"

    $.ajax(settings)

clearForm = ->
  camera_select.val("").trigger("change")
  $("#txt_timelapse_id").val("")
  $("#timelapse-title").val("")
  $("#timelapse-frequency").val("0")
  $("#txt_from_date").val("")
  $("#txt_to_date").val("")
  $("#txt_from_time").val("00:00")
  $("#txt_to_time").val("23:59")
  $('#chkDateRangeAlways').iCheck('check')
  $("#row_date_range").slideUp()
  $('#chkTimeRangeAlways').iCheck('check')
  $("#row_time_range").slideUp()
  $('#timelapse-form .caption').html 'New Timelapse'

change_date_format = (date) ->
  if date isnt ""
    dates_array = date.split("/")
    "#{dates_array[1]}/#{dates_array[0]}/#{dates_array[2]}"
  else
    ""

show_hide_datetime = ->
  $('[name="date_range"]').on 'ifClicked', ->
    id = $(this).attr('id')
    if $(this).val() is "false"
      $("#row_date_range").slideDown()
    else
      $("#row_date_range").slideUp()

  $('#divTimelapses').on 'ifClicked', '.date_range_edit', ->
    id = $(this).attr('id')
    timelapse_id = $(this).attr("data-val")
    if $(this).val() is "false"
      $("#row_date_range#{timelapse_id}").slideDown()
    else
      $("#row_date_range#{timelapse_id}").slideUp()

  $('[name="time_range"]').on 'ifClicked', ->
    id = $(this).attr('id')
    if $(this).val() is "false"
      $("#row_time_range").slideDown()
    else
      $("#row_time_range").slideUp()

  $('#divTimelapses').on 'ifClicked', '.time_range_edit', ->
    id = $(this).attr('id')
    timelapse_id = $(this).attr("data-val")
    if $(this).val() is "false"
      $("#row_time_range#{timelapse_id}").slideDown()
    else
      $("#row_time_range#{timelapse_id}").slideUp()

initTimepicker = (control) ->
  $("#{control}").timepicker
    timeFormat: 'h:i'
    minuteStep: 1
    showSeconds: false
    showMeridian: false

handleModelEvents = ->
  $("#timelapse-form").on "hide.bs.modal", ->
    clearForm()

initSelect2 = ->
  camera_select = $('#timelapse-camera').select2
    placeholder: 'Select Camera',
    allowClear: true,
    templateSelection: format,
    templateResult: format

format = (state) ->
  if !state.id
    return state.text
  if state.id == '0'
    return state.text
  if state.element
    if state.element.attributes[1].value is "false"
      camera_status = "<i class='red main-sidebar fa fa-chain-broken'></i>"
    else
      camera_status = ""
    return $("<span><img id='#{state.id}' style='width: 25px;height: auto;' src='#{state.element.attributes[2].value}' class='gravatar1'/>&nbsp;#{state.text}#{camera_status}</span>")
  else
    state.text

initControls = ->
  $("input[type=radio]").iCheck
    radioClass: "iradio_flat-blue"
  $('.daterange').datetimepicker({timepicker: false, format: 'd/m/Y'})
  format_time = new DateFormatter()

readFile = ->
  timelapse_id = $(this).attr("data-val")
  if @files and @files[0]
    FR = new FileReader
    FR.addEventListener 'load', (e) ->
      $("#img-watermark#{timelapse_id}").attr("src", e.target.result)
      $("#watermark-base64#{timelapse_id}").val(e.target.result)
    FR.readAsDataURL @files[0]
  else
    $("#img-watermark#{timelapse_id}").attr("src", "")
    $("#watermark-base64#{timelapse_id}").val("")

window.initializeTimelapse = ->
  loadTimelapses()
  show_hide_datetime()
  initTimepicker(".timerange")
  handleModelEvents()
  saveTimelapse()
  editTimelapse()
  toggleStatus()
  deleteTimelapse()
  copyToClipboard()
  initNotification()
  initSelect2()
  initControls()
  #selectWatermark()
  document.getElementById('timelapse-watermark').addEventListener 'change', readFile
