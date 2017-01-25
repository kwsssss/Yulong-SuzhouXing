class Station < ActiveRecord::Base
    self.table_name = "station"
    attr_accessible :id, :guid, :code, :c_name, :e_name, :canton, :road, :road, :category, :is_inactive, :direction, :longitude, :latitude
end