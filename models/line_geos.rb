class LineGeos < ActiveRecord::Base
  # attr_accessible :title, :body
    self.table_name = "line_geos"
    attr_accessible :id, :line_id, :longitude, :latitude, :point_order
end
