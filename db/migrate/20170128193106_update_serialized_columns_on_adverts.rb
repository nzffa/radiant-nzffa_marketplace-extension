class UpdateSerializedColumnsOnAdverts < ActiveRecord::Migration
  def self.up
    Advert.all.each do |ad|
      Advert::SERIALIZED_COLUMNS.each do |attrib|
        split_str = ','
        split_str = '|' if attrib == 'categories'
        unless ad.send(attrib).is_a? Array
          ad.send("#{attrib}=", ad.send(attrib).to_s.split(split_str).map(&:strip))
          # to_s because ad.send(attrib) may be nil
        end
      end
      ad.save
    end
  end

  def self.down
    Advert.all.each do |ad|
      Advert::SERIALIZED_COLUMNS.each do |attrib|
        split_str = ','
        split_str = '|' if attrib == 'categories'
        if ad.send(attrib).is_a? Array
          ad.send("#{attrib}=", ad.send(attrib).join(split_str))
        end
      end
      ad.save
    end
  end
end
