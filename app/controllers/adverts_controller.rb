class AdvertsController < MarketplaceController
  radiant_layout "fft"

  before_filter :load_company_listing, :only => [:my_adverts, :edit_company_listing]
  before_filter :load_advert, :only => [:edit, :update, :destroy, :renew, :email]
  before_filter :require_reader, :only => [:my_adverts, :new, :create, :edit, :update, :edit_company_listing, :renew]
  before_filter :require_fft_group, :only => [:my_adverts, :new, :create, :edit, :update, :edit_company_listing, :renew]


  def edit_company_listing
    render :layout => false if request.xhr?
  end

  def new
    @advert = Advert.new
    render :layout => false if request.xhr?
  end

  def index
    @adverts = Advert.not_expired.find(:all, index_params).paginate(pagination_params)
    render :layout => false if request.xhr?
  end

  def my_adverts
    @adverts = current_reader.adverts.not_company_listings
    render :layout => false if request.xhr?
  end

  def index_table
    @adverts = Advert.not_expired.find(:all, index_params).paginate(pagination_params)
    render :partial => 'table', :layout => false
  end

  def show
    if @advert = Advert.not_expired.find_by_id(params[:id])
      @other_listings = Advert.not_expired.find(:all, :conditions => {:reader_id => @advert.reader_id})
      render :layout => false if request.xhr?
    else
      flash[:error] = "Advert not found"
      redirect_to adverts_path
    end
  end

  def edit
  end

  def renew
    @advert.update_attribute(:expires_on, 1.month.from_now)
    flash[:notice] = "Advert will expire on #{@advert.expires_on}"
    redirect_to :action => :my_adverts
  end

  def update
    # Send empty select2 fields so the database is always updated
    Advert::SERIALIZED_COLUMNS.each{|attrib| params[:advert][attrib] ||= [] }

    if @advert.update_attributes(params[:advert])
      flash[:notice] = 'Advert was successfully updated.'
      if @advert.is_company_listing?
        redirect_to FFT_MEMBERS_AREA_PATH
      else
        redirect_to :action => :my_adverts
      end
    else
      @company_listing = @advert
      render :action => "edit"
    end
  end

  # this method is ugly because life is ugly
  # in short: the nice way to write this works fine in dev but fails
  # mysteriously in production...
  def create
    reader_attrs = params[:advert].delete(:reader_attributes)
    @advert = Advert.new params[:advert]
    @advert.reader = current_reader

    if @advert.is_company_listing?
      #update reader attributes
      reader_result = current_reader.update_attributes(reader_attrs)

      #save and respond
      if reader_result && @advert.save
        flash[:notice] = 'Advert was successfully created.'
        redirect_to :action => :my_adverts
      else
        render :action => 'edit_company_listing'
      end
    else
      @advert.expires_on = 1.month.from_now
      if @advert.save
        flash[:notice] = 'Advert was successfully created.'
        redirect_to :action => :my_adverts
      else
        render :action => "new"
      end
    end
  end

  def destroy
    @advert.destroy
    redirect_to :action => :my_adverts
  end

  protected


  def load_company_listing
    return unless current_reader
    @company_listing = Advert.find(:first, :conditions => {:is_company_listing => true, :reader_id => current_reader.id})
    if @company_listing.nil?
      @company_listing = Advert.new(:is_company_listing => true, :reader => current_reader)
    end
  end

  def load_advert
    @advert = Advert.find params[:id], :conditions => { :reader_id => current_reader.id }
  end

  def pagination_params
    find_options = {}
    if params[:page] and params[:page].to_i > 0
      find_options[:page] = params[:page]
    else
      find_options[:page] = 1
    end
    find_options[:per_page] = 8
    find_options
  end

  def index_params
    find_options = {}

    unless params[:query].blank?
      fields = %w[categories
                  title
                  body
                  supplier_of
                  buyer_of
                  services
                  readers.website
                  timber_for_sale
                  timber_species
                  business_description
                  readers.organisation
                  readers.name
                  readers.description
                  readers.physical_address
                  readers.post_line1
                  readers.post_line2
                  readers.region]
      terms = params[:query].split(' ')
      query = terms.map{ |term| fields.map { |field| "#{field} LIKE ?" }.join(" OR ")}.join(") AND (")
      query = "("+query+")"
      values = terms.map{ |term| ["%#{term}%"] * fields.size }.flatten
      find_options[:conditions] = [query, *values]
    end

    order_options = { 'title'          => 'adverts.title DESC',
                      'date'           => 'adverts.updated_at DESC',
                      'title_reversed' => 'adverts.title ASC',
                      'date_reversed'  => 'adverts.updated_at ASC' }

    if order_options[params[:sort]]
      find_options[:order] = order_options[params[:sort]]
    else
      find_options[:order] = order_options['date']
    end
    find_options
  end
end
