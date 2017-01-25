class Line < ActiveRecord::Base
    self.table_name = "line"
    attr_accessible :id, :direction, :name, :is_inactive, :start_time, :end_time
end

