class Advert < ActiveRecord::Base
  CATEGORIES = ['supplier of', 'timber for sale', 'buyer of', 'services']
  REGIONS = 'Northland
            Auckland
            Waikato
            Bay of Plenty
            Gisborne
            Hawkes Bay
            Wanganui / Manawatu / Wairarapa
            Taranaki
            Wellington
            Tasman
            Marlborough
            Canterbury
            West Coast
            Otago
            Southland'.split("\n").map(&:strip)
  SERIALIZED_COLUMNS = ["timber_species", "timber_for_sale", "buyer_of", "supplier_of", "services", "categories"]

  has_attached_file :image,
      :styles => { :medium => "640x480>", :thumb => "120x90>" },
      :path        => ":rails_root/public/attachments/:attachment/:id/:style/:basename.:extension",
      :url         => "/attachments/:attachment/:id/:style/:basename.:extension",
      :default_url => "/attachments/:attachment/missing/missing.png"
  validates_attachment_size :image, :in => 1.kilobytes..5.megabytes

  SERIALIZED_COLUMNS.each do |attrib|
    serialize attrib.to_sym
  end

  belongs_to :reader
  named_scope :not_expired, lambda { {:conditions => ['(adverts.expires_on > ? OR adverts.is_company_listing = ?) AND groups.id = ? AND subscriptions.expires_on >= ? AND subscriptions.begins_on <= ? AND subscriptions.cancelled_on IS NULL', Date.today, true, Group.fft_group, Date.today, Date.today], :include => [:reader => [:groups, :subscriptions]] }}
  
  named_scope :published, lambda { {:conditions => {:is_published => true}} }

  named_scope :company_listings, {:conditions => {:is_company_listing => true }}
  named_scope :not_company_listings, {:conditions => {:is_company_listing => false }}

  validates_presence_of :reader
  validates_presence_of :expires_on, :unless => :is_company_listing

  validates_length_of :title, :minimum => 3, :unless => :is_company_listing
  validates_length_of :body, :minimum => 15, :unless => :is_company_listing
  #validate :one_company_listing_per_reader

  accepts_nested_attributes_for :reader

  #validates_inclusion_of :category, :in => CATEGORIES


  def snippet
    if body and body.length > 78
      body[0..78]+"..."
    else
      body
    end
  end

  def to_param
		"#{id}-#{title}".gsub(/[^a-zA-Z0-9]/,"-")
	end

  def reader_physical_address
    reader.physical_address
  end

  def reader_postal_address
    lines = []
    [:post_line1, :post_line2, :post_province, :post_city, :post_country, :postcode].each do |method|
      if reader.send(method).present?
        lines << reader.send(method)
      end
    end
    lines.join(', ')
  end

  def self.buyer_of_options
    %w(Timber Logs Standing\ trees Firewood)
  end

  def self.supplier_of_options
    %w(Timber
    logs
    Sawmills
    Machinery
    Firewood
    Trees
    Structural\ Glulam
    Glue-laminated\ timber\ panels
    Outdoor\ furniture
    Indoor\ furniture/cabinet/joinery
    Panelling/sarking
    Benchtops
    Trusses)
  end

  def self.timber_species_options
    %w(Cypress
    Macrocarpa
    Redwood
    Eucalypt
    Southern\ beech
    Totara
    Kahikatea
    Rimu
    Matai
    Blackwood
    Kauri
    Cedar
    Paulownia
    Poplar
    Oak
    Elm
    Rata
    Spruce
    Tawa
    London\ plane
    Sycamore
    Larch
    Tulipwood
    Walnut
    Ash)
  end

  def self.timber_for_sale_options
    %w(Green\ sawn\ ungraded\ timber
    Seasoned\ ungraded\ timber
    Profiled\ and\ dressed\ ungraded\ timber
    Structural\ graded\ timber
    Flooring\ timber\ -\ graded
    Timber\ for\ glue\ laminating\ -\ graded
    Decking\ timber\ -\ graded
    Cladding\ timber\ -\ graded
    Sleepers
    Timber\ for\ furniture/joinery\ -\ graded
    Slabs
    Panelling\ timber\ -\ graded
    Mouldings\ and\ architraves\ -\ graded
    Timber\ for\ structural\ glulam\ -\ graded)
  end

  def self.services_options
    %w(Logging\ and\ harvesting
    Log\ brokerage
    Log\ transport
    Timber\ transport
    Sawmilling\ service
    Kiln\ drying\ service
    Machining\ and\ profiling
    Glue\ laminating
    Construction\ and\ building
    Registered\ architect
    Design
    Structural\ engineer
    Stress\ grading
    Timber\ merchant
    Floor\ laying\ and\ installation
    Floor\ sanding\ and\ repairs
    Decking\ installation
    Interior\ joinery\ furniture\ and\ fitouts
    Exterior\ joinery\ and\ furniture
    Manufacturing
    Retailer
    Cabinetmaking
    Resawing
    Sustainable\ Forest\ Management\ plans\ and\ permits)
  end

  private
  def one_company_listing_per_reader
    if is_company_listing?
      existing = Advert.find(:all, :conditions => {:is_company_listing => true, :reader_id => reader_id})
      if [0,1].include? existing.size
        # thats good
      else
        self.errors.add(:is_company_listing, "There is already a company listing for this reader id #{reader_id} n: #{existing.size}")
      end
    end
  end
end
