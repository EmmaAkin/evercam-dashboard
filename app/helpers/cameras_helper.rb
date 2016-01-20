module CamerasHelper
  def preview(camera, refresh=false)
    thumbnail_url = camera['thumbnail_url']
    proxy = "#{EVERCAM_API}cameras/#{camera['id']}/recordings/snapshots/latest/jpg?api_id=#{current_user.api_id}&api_key=#{current_user.api_key}"

    # TODO: replace with image_tag
    if thumbnail_url.blank? && !camera['is_online']
      return "<img id='message' class='no-thumbnail' src='#{asset_path("offline.png")}' data-proxy=#{proxy}>".html_safe
    elsif thumbnail_url.blank? && camera['is_online']
      return "<img class='snapshot-proxy' src='#{proxy}' data-proxy=#{proxy}>".html_safe
    elsif refresh
      return "<img id='message' class='snapshot-proxy' src='#{thumbnail_url}' data-proxy=#{proxy}'>".html_safe
    else
      return "<img class='snapshot-proxy' src='#{thumbnail_url}' data-proxy=#{proxy}>".html_safe
    end
  end
end
