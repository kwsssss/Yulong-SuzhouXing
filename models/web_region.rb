class WebRegion < ActiveRecord::Base
  acts_as_paranoid
  has_many :web_region_geos
  self.table_name = "web_region"
  attr_accessible :id, :name
end
