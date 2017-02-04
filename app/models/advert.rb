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
  default_scope :order => 'created_at DESC'

  has_attached_file :image,
      :styles => { :medium => "640x480>", :thumb => "120x90>" },
      :path        => ":rails_root/public/attachments/:attachment/:id/:style/:basename.:extension",
      :url         => "/attachments/:attachment/:id/:style/:basename.:extension",
      :default_url => "/attachments/:attachment/missing/missing.png"
  validates_attachment_size :image, :in => 1.kilobytes..5.megabytes

  belongs_to :reader
  named_scope :not_expired, lambda { {:conditions => ['expires_on > ? OR is_company_listing = ?', Date.today, true] }}
  named_scope :published, lambda { {:conditions => {:is_published => true}} }

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

  def categories
    if self[:categories]
      self[:categories].split('|')
    else
      []
    end
  end

  def timber_species_terms
    self[:timber_species].split(', ')
  rescue
    []
  end
  
  def timber_species_terms=(list)
    self[:timber_species] = list.join(', ')
  end

  def timber_for_sale_terms
    self[:timber_for_sale].split(', ')
  rescue
    []
  end

  def timber_for_sale_terms=(list)
    self[:timber_for_sale] = list.join(', ')
  end

  def timber_species
    self[:timber_species] || ''
  end

  def supplier_of
    self[:supplier_of] || ''
  end

  def timber_for_sale
    self[:timber_for_sale] || ''
  end

  def buyer_of
    self[:buyer_of] || ''
  end

  def services
    self[:services] || ''
  end

  def categories=(list)
    if list.is_a? String
      self[:categories] = list
    else
      self[:categories] = list.join '|'
    end
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
    ['Timber', 'Logs', 'Standing trees', 'Firewood']
  end

  def self.supplier_of_options
    'Timber, logs, Sawmills, Machinery, Firewood, Trees, Structural Glulam, Glue-laminated timber panels, Outdoor furniture, Indoor furniture/cabinet/joinery, Panelling/sarking, Benchtops, Trusses'.split(', ')
  end

  def self.timber_species_options
    'Cypress
    Macrocarpa
    Redwood
    Eucalypt
    Southern beech
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
    London plane
    Sycamore
    Larch
    Tulipwood
    Walnut
    Ash'.split("\n").map(&:strip)
  end

  def self.timber_for_sale_options
    'Green sawn ungraded timber
    Seasoned ungraded timber
    Profiled and dressed ungraded timber
    Structural graded timber
    Flooring timber - graded
    Timber for glue laminating - graded
    Decking timber - graded
    Cladding timber - graded
    Sleepers
    Timber for furniture/joinery - graded
    Slabs
    Panelling timber - graded
    Mouldings and architraves - graded
    Timber for structural glulam - graded'.split("\n").map(&:strip)
  end

  def self.services_options
    'Logging and harvesting
    Log brokerage
    Log transport
    Timber transport
    Sawmilling service
    Kiln drying service
    Machining and profiling
    Glue laminating
    Construction and building
    Registered architect
    Design
    Structural engineer
    Stress grading
    Timber merchant
    Floor laying and installation
    Floor sanding and repairs
    Decking installation
    Interior joinery furniture and fitouts
    Exterior joinery and furniture
    Manufacturing
    Retailer
    Cabinetmaking
    Resawing
    Sustainable Forest Management plans and permits'.split("\n").map(&:strip)
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
