class WebRegionGeos < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :web_region
  self.table_name = "web_region_geos"
  attr_accessible :id, :web_region_id, :point_order, :longitude, :latitude
end
