class Admin::AdvertsController < Admin::ResourceController
  only_allow_access_to :index, :new, :edit, :create, :update, :remove, :destroy,
    :when => [:admin, :designer]

  before_filter :load_advert, :only => [:show, :edit, :update, :destroy]
  helper :adverts

  def index
    @adverts = Advert.all
  end

  def new
    @advert = Advert.new
  end

  def update
    @advert.update_attributes params[:advert]
    flash[:notice] = 'Advert updated'
    response_for :update
  end

  def create
    @advert = Advert.create(params[:advert])
    if @advert.valid?
      redirect_to [:admin, :adverts], :notice => 'Advert created'
    else
      render :new
    end
  end

  def destroy
    @advert.destroy
  redirect_to [:admin, :adverts], :notice => 'Destroyed advert'
  end

  protected
  def load_advert
    @advert = Advert.find(params[:id])
  end
end
