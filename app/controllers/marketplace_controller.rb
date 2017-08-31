class MarketplaceController < ReaderActionController
  REGISTER_PATH = '/membership/register'
  FFT_MEMBERS_AREA_PATH = '/specialty-timber-market/participate/membership'
  
  radiant_layout { |c| Radiant::Config['reader.layout'] }
  
  protected
  def require_fft_group
    unless current_reader.group_ids.include? NzffaSettings.fft_marketplace_group_id
      flash[:error] = 'Sorry, but you must belong to Farm Forestry Timbers Group'
      redirect_to root_path
    end
  end
end
