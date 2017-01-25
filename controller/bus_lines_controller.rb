class Admin::BusLinesController < Admin::ApplicationController
	#加载html模版
    skip_before_filter :verify_authenticity_token
    layout "admin_user_layout"

    def busLines
        # sqlCommand11 = "select name from line;"
        # result22 = Line.find_by_sql([sqlCommand11])

        # result22.each_with_index do |item,index|
        #     result22[index].name = result22[index].name.delete("路")
            
        # end

        @suspect = params[:suspect]
        if @suspect == nil
            @suspect = 0
        end

        @title = "公交路线"
        status = params[:status]
        line_number = params[:line_number]
        kind = params[:kind]

        if @suspect.to_i == 1
            if line_number == nil
        	   line_number = ''
            end

            if (status == nil)
                status = '1'
            end

            if (kind == nil)
                kind = '0'
            end

            sqlCommand = ''
            #定义每页多少条记录
            numPerPage = 50

            #初始值设置为全部
        

            if (status.to_i == 0)
                sqlCommand = 'is_inactive = true'
            elsif (status.to_i == 1)
                sqlCommand = 'is_inactive = false'
            else
                sqlCommand = sqlCommand
            end

            if (sqlCommand != '')

                if (line_number.to_s == '')
                    sqlCommand = sqlCommand
                else
            	   sqlCommand = sqlCommand + " and name like '" + line_number.to_s + "%'"
                end

            else

                if (line_number.to_s == '')
                    sqlCommand = ''
                else
            	   sqlCommand = "name like '" + line_number.to_s + "%'"
                end
            end

            if (sqlCommand != '')
                if (kind.to_i == 1)
                    sqlCommand = sqlCommand + " and category_id = 50"
                elsif (kind.to_i == 2)
                    sqlCommand = sqlCommand + " and category_id = 1"
                elsif (kind.to_i == 3)
                    sqlCommand = sqlCommand + " and category_id = 30"
                elsif (kind.to_i == 4)
                    sqlCommand = sqlCommand + " and category_id = 2"
                end
            else
                if (kind.to_i == 1)
                    sqlCommand = sqlCommand + "category_id = 50"
                elsif (kind.to_i == 2)
                    sqlCommand = sqlCommand + "category_id = 1"
                elsif (kind.to_i == 3)
                    sqlCommand = sqlCommand + "category_id = 30"
                elsif (kind.to_i == 4)
                    sqlCommand = sqlCommand + "category_id = 2"
                end
            end
            sql = "(start_time = '00:00:00' or end_time = '00:00:00' or direction is null or name is null)"

            if sqlCommand != ''
                sqlCommandd = sqlCommand + ' and ' + sql
            else
                sqlCommandd = sql 
            end

            
            @result = Line.order("id desc").where(sqlCommandd).paginate(:page => params[:page], :per_page => numPerPage)
            

            sqlCount = "SELECT * FROM line"
            if (sql != '')
                sqlCount = sqlCount + ' WHERE ' + sqlCommandd
            end

            recordCount = Line.find_by_sql(sqlCount)
            #pages = 一共多少页
            @pages = (recordCount.count.to_f / numPerPage).ceil

        else
            if line_number == nil
               line_number = ''
            end

            if (status == nil)
                status = '1'
            end

            if (kind == nil)
                kind = '0'
            end

            sqlCommand = ''
            #定义每页多少条记录
            numPerPage = 50

            #初始值设置为全部
        

            if (status.to_i == 0)
                sqlCommand = 'is_inactive = true'
            elsif (status.to_i == 1)
                sqlCommand = 'is_inactive = false'
            else
                sqlCommand = sqlCommand
            end

            if (sqlCommand != '')

                if (line_number.to_s == '')
                    sqlCommand = sqlCommand
                else
                   sqlCommand = sqlCommand + " and name like '" + line_number.to_s + "%'"
                end

            else

                if (line_number.to_s == '')
                    sqlCommand = ''
                else
                   sqlCommand = "name like '" + line_number.to_s + "%'"
                end
            end

            if (sqlCommand != '')
                if (kind.to_i == 1)
                    sqlCommand = sqlCommand + " and category_id = 50"
                elsif (kind.to_i == 2)
                    sqlCommand = sqlCommand + " and category_id = 1"
                elsif (kind.to_i == 3)
                    sqlCommand = sqlCommand + " and category_id = 30"
                elsif (kind.to_i == 4)
                    sqlCommand = sqlCommand + " and category_id = 2"
                end
            else
                if (kind.to_i == 1)
                    sqlCommand = sqlCommand + "category_id = 50"
                elsif (kind.to_i == 2)
                    sqlCommand = sqlCommand + "category_id = 1"
                elsif (kind.to_i == 3)
                    sqlCommand = sqlCommand + "category_id = 30"
                elsif (kind.to_i == 4)
                    sqlCommand = sqlCommand + "category_id = 2"
                end
            end

            if (sqlCommand == '')
                @result = Line.order("id desc").paginate(:page => params[:page], :per_page => numPerPage)
            else
                @result = Line.order("id desc").where(sqlCommand).paginate(:page => params[:page], :per_page => numPerPage)
            end

            sqlCount = "SELECT * FROM line"

            if (sqlCommand != '')
                sqlCount = sqlCount + ' WHERE ' + sqlCommand
            end

            recordCount = Line.find_by_sql(sqlCount)
            #pages = 一共多少页
            @pages = (recordCount.count.to_f / numPerPage).ceil
        end
    end

    def statusChange
        itemId = params[:id]
        dataStatus = params[:is_inactive]
        item = Line.find(params[:id])

        if item.present?
            item.update_attribute("is_inactive", dataStatus)
            status = 1      #update成功
        else
            status = 0      #update失败
        end
        render text: status
    end

    def getStations
    	lineid = params[:lineid]
    	item = Line.find(lineid)
    	sqlCommand = "select line_station.line_id, line_station.station_order,
    	station.c_name, station.longitude, station.latitude from line_station join station on(line_station.station_id=station.id)
    	where line_station.line_id= ? order by station_order;"
    	result = Station.find_by_sql([sqlCommand, lineid])
    	render json:result
    end


    def getAllLines
        sqlCommand = "select distinct name from line WHERE is_inactive = false AND category_id = 50;"
        result = Line.find_by_sql([sqlCommand])
        result.each do |item|
            item.name = item.name.rstrip
        end
        render json:result
    end

    def saveGeosAndUpdate
        transRatio = 1000000                                # def float => int ratio *1000000
        name = params[:name]                                # 找到公交名
        if (/[夜游快]/ =~ name) == nil
            name += "路"
        end
        firststation = params[:start]                       # 首站
        finalstation = params[:end]                         # 末站
        station = "公交" + firststation + "站" + "-" + "公交" + finalstation + "站" # 连接首末站得出direction

        pointsArray = params[:pts]                          # 经纬度array
        status = params[:status]                            # up_down属性
        # sqlCommand = "select id from line WHERE direction = '#{station}' and name = '#{name}' and is_inactive = false;"
        # sqlCommand = "select * from line WHERE direction = '#{station}' and name = '#{name}' and is_inactive = false;"
        # result = Line.find_by_sql([sqlCommand])             # 找到line id
        result = Line.where('direction = ? and name = ? and is_inactive = false', station, name)
        if result.present?
            
            namex = Array.new
            #每条线路update到line.geom
            pointsArray.each_with_index do |item,index|
                # result.each_with_index do |itor|
                #     record = LineGeos.find_by_line_id_and_point_order(itor,index)
                #     if record.present? && (record.longitude != item["lng"]*transRatio.to_i || record.latitude != item["lat"]*transRatio.to_i)
                #         record.update_attributes(longitude:item["lng"]*transRatio.to_i,latitude:item["lat"]*transRatio.to_i)
                #     elsif record.blank?
                #         LineGeos.create(line_id:itor["id"], longitude:item["lng"]*transRatio.to_i,latitude:item["lat"]*transRatio.to_i,point_order:index)
                #     end  
                # end
                #ST_AddPoint(result.geom, ST_MakePoint(item["lng"]*transRatio.to_i,item["lat"]*transRatio.to_i),index)
                #sql = "geom = ST_AddPoint(geom, ST_MakePoint(?,?),?)"
                #Line.where('direction = ? and name = ? and is_inactive = false', station, name).update_all([sql, item["lng"]*transRatio.to_i, item["lat"]*transRatio.to_i, index])
                #my_s = my_s + (item["lng"]*transRatio.to_i).to_s + ' ' + (item["lat"]*transRatio.to_i).to_s + ','
                namex.push((item["lng"]).to_s + ' ' + (item["lat"]).to_s)
            end
            names = namex.join(',')
            my_ss = "SRID=4326;LINESTRING(#{names})"
            result.update_all(['geom = ST_GeomFromText(?)',my_ss])
            
            # update 公交线路的up_down属性
            # result.each_with_index do |itor|
            #     item = Line.find(itor)
            #     if item.present? && item.up_down != status.to_s
            #         item.update_attribute("up_down", status)
            #     end
            # end
            render text:1
        else
            render text:0
        end
    end
end
