class Poi < ActiveRecord::Base
    self.table_name = "poi"
    attr_accessible :id, :longitude, :latitude, :position, :kinder, :source, :generated_udid, :create_time, :status_change_time, :status, :priority, :remark, :phrase, :geom, :category
end
