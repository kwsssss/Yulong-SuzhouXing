class Admin::IssueReportController < Admin::ApplicationController
	  skip_before_filter :verify_authenticity_token

	def list
		@title = "用户反馈"
		statustype = params[:statustype]
		@status = params[:statustype]
		# 分页处理

		if (statustype.to_i == 1)
			# 选择已处理的反馈  
			@result = IssueReport.order("status asc,id desc").where("status = 1 or status =2").paginate(:page => params[:page], :per_page => 50 )
		elsif (statustype.to_i == 0)
			# 选择所有反馈
			@result = IssueReport.order("status asc,id desc").paginate(:page => params[:page], :per_page => 50 )  
		elsif (statustype.to_i == 5)
			# 选择待处理的反馈 
			@result = IssueReport.order("status asc,id desc").where("status = 0").paginate(:page => params[:page], :per_page => 50 )
		elsif (statustype.to_i == 3)
			# 选择已忽略的反馈 
			@result = IssueReport.order("status asc,id desc").where("status = 3").paginate(:page => params[:page], :per_page => 50 )
		else
			@result = IssueReport.order("status asc,id desc").paginate(:page => params[:page], :per_page => 50 )  
		end  
		
	end

	def ignore
		item = IssueReport.find(params[:id])
		if item.present?
			#设定选中反馈状态为：已忽略
			item.update_attribute("status",3)
		end

		redirect_to admin_issue_report_path

	end

	def complete
		item_remark = params[:my_comment]
		item = IssueReport.find(params[:my_id])
		if item.present?
			#设定选中反馈状态为：已处理，设置备注（处理方案）为读取值
			item.update_attributes(status: 1, remark: item_remark)
		end
		redirect_to admin_issue_report_path
	end
end
