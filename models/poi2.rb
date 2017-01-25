class Poi2 < ActiveRecord::Base
    self.table_name = "poi2"
    attr_accessible :id, :longitude, :latitude, :position, :kinder, :source, :generated_udid, :create_time, :status, :priority
end
