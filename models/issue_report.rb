class IssueReport < ActiveRecord::Base
	self.table_name = "issue_report"
	attr_accessible :id, :udid, :date, :description, :status, :contact_type_id, :contact, :remark
end