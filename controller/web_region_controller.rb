class Admin::WebRegionController < Admin::ApplicationController
	skip_before_filter :verify_authenticity_token

	def web_region
		@title = "地图区划"
		@result = WebRegion.order("id desc")
	end

	#取出保存好的点
	#input: region_name
	#output: 该region_name下所有的经纬度
	def getAllPoints
		region_name = params[:region_name]
		sqlCommand = "SELECT longitude, latitude FROM web_region_geos INNER JOIN web_region
		ON web_region_geos.web_region_id=web_region.id WHERE name=? order by point_order"
		result = WebRegionGeos.find_by_sql([sqlCommand, region_name])
		#result = WebRegionGeos.joins('INNER JOIN web_region ON web_region_geos.web_region_id=web_region.id').where(name: region_name).order("point_order")
		render json: result
	end

	#新的点存入数据库
	#input: 区域名，该点的顺序（该区域名下第？个点），经度，纬度
	#output: return 1
	def insert_new_point
		district_name = params[:region_name]
		point_order = params[:order]
		longitude = params[:longitude]
		latitude = params[:latitude]

		#检查是否已存在这个地理区域
		sqlCommand = "SELECT id FROM web_region WHERE name=?"
		district = WebRegion.find_by_sql([sqlCommand, district_name])

		if (district.length != 0)
			current_web_region_id = district[0]["id"]
		else
			WebRegion.create(name: district_name)
			current_district = WebRegion.find_by(name: district_name)
			current_web_region_id = current_district.id
		end
		WebRegionGeos.create(web_region_id: current_web_region_id, point_order: point_order, longitude: longitude, latitude: latitude)
		render text: 1
	end

	#删除最新画的点（撤销功能）
	#input: 区域名，该点的顺序（该区域名下第？个点）
	#output: failed(point does not exist) return 0, success return 1
	def delete_point
		point_order = params[:order]
		district_name = params[:region_name]

		current_district = WebRegion.find_by_name(district_name)
		current_web_region_id = current_district.id

		deleted_point = WebRegionGeos.where(point_order: point_order, web_region_id: current_web_region_id).first
		if (deleted_point == nil)
			status = 0
		else
			status = 1
			deleted_point.destroy
		end
		render text: status
	end

	#清空该区域名下所有点
	#input:	区域名
	#output: return 1 (nearly impossible return 0)
	def clear_region
		district_name = params[:region_name]
		current_district = WebRegion.find_by_name(district_name)
		current_web_region_id = current_district.id

		all_deleted_point = WebRegionGeos.where(web_region_id: current_web_region_id)
		if (all_deleted_point == nil)
			status = 0
		else
			status = 1
			all_deleted_point.destroy_all
		end
		render text: status
	end

	#新建一个区域名
	#input: 区域名
	#output: success return 1, failed return 0(empty region_name or region_name already exist)
	def create_new_region
		new_district_name = params[:region_name]
		#区域名不为空
		if new_district_name.present? && new_district_name.to_s != ''
			current_district = WebRegion.find_by_name(new_district_name)
			#区域名已存在
			if current_district.present?
				status = 0
			else
				WebRegion.create(name: new_district_name)
				status = 1
			end
		else
			status = 0
		end
		render text: status
	end

	#删除区域名
	#input: 区域名
	#output: return 1
	def delete_region
		district_name = params[:region_name]
		current_district = WebRegion.find_by_name(district_name)
		if (current_district == nil)
			status = 0
		else
			status = 1
			current_district.destroy
		end
		render text: status
	end

end
