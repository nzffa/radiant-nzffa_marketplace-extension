class MembershipController < MarketplaceController
  include UpdateReaderNewsletterPreferences
  radiant_layout "no_layout"
  AFTER_SIGNUP_PATH = '/become-a-nzffa-member/youre-registered'
  before_filter :require_current_reader, :only => [:details, :update]

  def details
    @reader = current_reader
    @subscription = Subscription.active_subscription_for(@reader)
    @last_year_subscription = Subscription.last_year_subscription_for(@reader)
  end

  def dashboard
    # if they are an FFT member take them to 
    if @reader.group_ids.include? NzffaSettings.fft_marketplace_group_id
      redirect_to FFT_MEMBERS_AREA_PATH
    else
      redirect_to REGISTER_PATH
    end
  end

  def register
    if params[:reader]
      # form has been submitted
      if !current_reader
        # new member
        @reader = Reader.new(params[:reader])
        if @reader.save
          @reader.update_attribute(:activated_at, DateTime.now)
          update_newsletter_preference
          MembershipMailer.deliver_registration_email(params[:reader])
          flash[:notice] = "Thanks for registering with the NZFFA. #{@newsletter_alert} #{@fft_alert}"
          redirect_to AFTER_SIGNUP_PATH
        end
      elsif !current_reader.is_secretary
        redirect_to membership_update_path
      end
    else
      @reader = Reader.new
    end

    render :layout => false if request.xhr?
  end
  
  def update
    @reader = current_reader
  end
  
  # dean wants this left in the code for a bit
  def join_fft_button
    @reader = current_reader
    render :layout => false if request.xhr?
  end

  #def join_fft
    #if @reader = current_reader
      #@reader.groups << Group.find(ADMIN_GROUP_ID) unless @reader.groups.include? Group.find(ADMIN_GROUP_ID)
      #@reader.groups << Group.find(FFT_GROUP_ID) unless @reader.groups.include? Group.find(FFT_GROUP_ID)
      #flash[:notice] = 'You have joined the FFT'
      #redirect_to FFT_MEMBERS_AREA_PATH
    #else
      #flash[:notice] = 'You need to register or sign in before continuing'
      #redirect_to MEMBER_PATH
    #end
  #end
end
