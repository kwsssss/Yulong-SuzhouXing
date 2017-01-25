class Admin::BusStationController < Admin::ApplicationController
	#加载html模版
    skip_before_filter :verify_authenticity_token
    layout "admin_user_layout"

    def busstation
    	@title = "公交站台"
        status = params[:status]
        station_name = params[:station_name]
        station_code = params[:station_code]
        type = params[:station]
        @suspect = params[:suspect]
        if @suspect == nil
            @suspect = 0
        end


        if @suspect.to_i == 1
            if (status == nil)
                status = '1'
            end
        
            if station_name == nil
                station_name = ''
            end

            if station_code == nil
                station_code = ''
            end

            if (type == nil)
                type = '4' 
            end

            sqlCommand = ''
            #定义每页多少条记录
            numPerPage = 50

            if (status.to_i == 0)
                sqlCommand = 'is_inactive = true'
            elsif (status.to_i == 1)
                sqlCommand = 'is_inactive = false'
            else
                sqlCommand = sqlCommand
            end

            if (sqlCommand != '')
                if (station_name != '')
                    sqlCommand = sqlCommand + " and c_name like '%" + station_name + "%'"
                else
                    sqlCommand = sqlCommand
                end
            else
                if (station_name != '')
                    sqlCommand = "c_name like '%" + station_name + "%'"
                else
                    sqlCommand = ''
                end
            end
        
            if (sqlCommand != '')
                if (station_code != '')
                    sqlCommand = sqlCommand + " and code like '%" + station_code + "%'"
                else
                    sqlCommand = sqlCommand
                end
            else
                if (station_code != '')
                    sqlCommand = "code like '%" + station_code + "%'"
                else
                    sqlCommand = ''
                end
            end

            if (sqlCommand != '')
                if (type.to_i == 1)
                    sqlCommand = sqlCommand + " and category = 1"
                elsif (type.to_i == 2)
                    sqlCommand = sqlCommand + " and category = 50"
                elsif (type.to_i == 3)
                    sqlCommand = sqlCommand + " and category = 30"
                end
            else
                if (type.to_i == 1)
                    sqlCommand = "category = 1"
                elsif (type.to_i == 2)
                    sqlCommand = "category = 50"
                elsif (type.to_i == 3)
                    sqlCommand = "category = 30"
                end
            end

            sql = "(longitude = 0 or latitude = 0 or e_name is null)"
            
            if sqlCommand != ''
                sqlCommandd = sqlCommand + ' and ' + sql
            else
                sqlCommandd = sql 
            end
            @result = Station.order("id desc").where(sqlCommandd).paginate(:page => params[:page], :per_page => numPerPage)
            sqlCount = "SELECT * FROM station"
            if (sql != '')
                sqlCount = sqlCount + ' WHERE ' + sqlCommandd
            end
        
            recordCount = Station.find_by_sql(sqlCount)
            #pages = 一共多少页
            @pages = (recordCount.count.to_f / numPerPage).ceil


        else
            if (status == nil)
                status = '1'
            end
        
            if station_name == nil
                station_name = ''
            end

            if station_code == nil
                station_code = ''
            end

            if (type == nil)
                type = '4' 
            end

            sqlCommand = ''
            #定义每页多少条记录
            numPerPage = 50

            if (status.to_i == 0)
                sqlCommand = 'is_inactive = true'
            elsif (status.to_i == 1)
                sqlCommand = 'is_inactive = false'
            else
                sqlCommand = sqlCommand
            end

            if (sqlCommand != '')
                if (station_name != '')
                    sqlCommand = sqlCommand + " and c_name like '%" + station_name + "%'"
                else
                    sqlCommand = sqlCommand
                end
            else
                if (station_name != '')
                    sqlCommand = "c_name like '%" + station_name + "%'"
                else
                    sqlCommand = ''
                end
            end
        
            if (sqlCommand != '')
                if (station_code != '')
                    sqlCommand = sqlCommand + " and code like '%" + station_code + "%'"
                else
                    sqlCommand = sqlCommand
                end
            else
                if (station_code != '')
                    sqlCommand = "code like '%" + station_code + "%'"
                else
                    sqlCommand = ''
                end
            end

            if (sqlCommand != '')
                if (type.to_i == 1)
                    sqlCommand = sqlCommand + " and category = 1"
                elsif (type.to_i == 2)
                    sqlCommand = sqlCommand + " and category = 50"
                elsif (type.to_i == 3)
                    sqlCommand = sqlCommand + " and category = 30"
                end
            else
                if (type.to_i == 1)
                    sqlCommand = "category = 1"
                elsif (type.to_i == 2)
                    sqlCommand = "category = 50"
                elsif (type.to_i == 3)
                    sqlCommand = "category = 30"
                end
            end
        
            if (sqlCommand == '')
                @result = Station.order("id desc").paginate(:page => params[:page], :per_page => numPerPage)
            else
                @result = Station.order("id desc").where(sqlCommand).paginate(:page => params[:page], :per_page => numPerPage)
            end

            sqlCount = "SELECT * FROM station"
            if (sqlCommand != '')
                sqlCount = sqlCount + ' WHERE ' + sqlCommand
            end
        
            recordCount = Station.find_by_sql(sqlCount)
            #pages = 一共多少页
            @pages = (recordCount.count.to_f / numPerPage).ceil
            end
        
    end   

    def submitModify
        longi = params[:itemlongi]          
        lati = params[:itemlati]     
        id = params[:itemId]   
        item = Station.find(id)
        if item.present? && longi =~ /\d/ && lati =~ /\d/
            item.update_attributes(longitude: longi.to_f * 100000, latitude: lati.to_f * 100000)
            status = 1
        elsif longi.blank?
            status = -1     
        elsif lati.blank?
            status = -2
        else
            status = -3     
        end
        render text: status
    end 

    def getLines
        stationid = params[:stationid]
        sqlCommand = "select line.name from line_Station join line on(line_station.line_id=line.id)
        where line_station.station_id= ? and line.is_inactive = false"
        result = Line.find_by_sql([sqlCommand, stationid])
        puts result
        render json:result
        
    end
end
