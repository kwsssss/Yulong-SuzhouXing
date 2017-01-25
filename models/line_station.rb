class Line_station < ActiveRecord::Base
    self.table_name = "line_station"
    attr_accessible :line_id, :station_id, :station_order
end