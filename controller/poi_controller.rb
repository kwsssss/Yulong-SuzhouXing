class Admin::PoiController < Admin::ApplicationController
    #加载html模版
    skip_before_filter :verify_authenticity_token
    layout "admin_user_layout"

    def poiList
        @title = "兴趣点审核"
        source = params[:source]
        position = params[:position]
        status = params[:status]
        category = params[:category]


        sqlCommand = ''
        #定义每页多少条记录
        numPerPage = 50

        #初始值设置为全部
        if (status == nil)
            status = '0'
        end
        #初始值设置为全部
        if (source == nil)
            source = '2'
        end

        #用户输入
        if (source.to_i == 0)
            sqlCommand = 'source = 0'
            #已保留
            if(status.to_i == 1)
                sqlCommand = sqlCommand + ' and status = 1'
            #已删除
            elsif(status.to_i == 2)
                sqlCommand = sqlCommand + ' and status = 2'
            #待审核
            elsif(status.to_i == 3)
                sqlCommand = sqlCommand + ' and status = 0'
            #全部
            else
                sqlCommand = sqlCommand 
            end

        #网页抓取
        elsif (source.to_i == 1)
            sqlCommand = 'source = 1'
            #已保留
            if(status.to_i == 1)
                sqlCommand = sqlCommand + ' and status = 1'
            #已删除
            elsif(status.to_i == 2)
                sqlCommand = sqlCommand + ' and status = 2'
            #待审核
            elsif(status.to_i == 3)
                sqlCommand = sqlCommand + ' and status = 0'
            #全部
            else
                sqlCommand = sqlCommand 
            end
        #所有
        else
            #已保留
            if(status.to_i == 1)
                sqlCommand = 'status = 1'
            #已删除
            elsif(status.to_i == 2)
                sqlCommand = 'status = 2'
            #待审核
            elsif(status.to_i == 3)
                sqlCommand = 'status = 0'
            #全部
            else
                sqlCommand = sqlCommand 
            end
        end

        if (sqlCommand != '')
            #加地点
            if (position.to_s != '')
                sqlCommand = sqlCommand + " and position like '%" + position.to_s + "%'"
            end
            #加类别

            if (category.to_s != '')
                sqlCommand = sqlCommand + " and category = '" + category.to_s + "'"
            end
        #来源和状态都为全部的情况－－>sqlCommand = ''
        else

            if (position.to_s != '')
                sqlCommand = "position like '%" + position.to_s + "%'"
                #加类别
                if (category.to_s != '')
                    sqlCommand = sqlCommand + " and category = '" + category.to_s + "'"
                end
            #查询地点为空
            else
                #加类别
                if (category.to_s != '')
                    sqlCommand = sqlCommand + "category = '" + category.to_s + "'"
                end
            end
        end
        

        
        if (sqlCommand == '')
            @result = Poi.order("status asc, id desc").paginate(:page => params[:page], :per_page => numPerPage)
        else
            @result = Poi.order("status asc, id desc").where(sqlCommand).paginate(:page => params[:page], :per_page => numPerPage)
        end
        

        sqlCount = "SELECT * FROM poi"
        if (sqlCommand != '')
            sqlCount = sqlCount + ' WHERE ' + sqlCommand
        end

        recordCount = Poi.find_by_sql(sqlCount)
        #pages = 一共多少页
        @pages = (recordCount.count.to_f / numPerPage).ceil
    end

    #修改兴趣点－－位置和权重
    def submitModify
        pos = params['modify-position']          #位置
        pri = params[:priority]                  #权重
        cat = params['modify-category']     #类别
        longi = params[:itemlongi]
        lati = params[:itemlati]
        item = Poi.find(params[:itemId])

        if item.present? && pos.present? && pri =~ /\d/ && cat.present? && longi =~ /\d/ && lati =~ /\d/
            item.update_attributes(position: pos, priority: pri, category: cat, longitude: longi.to_f * 1000000, latitude: lati.to_f * 1000000)
            status = 1
        elsif pos.blank?
            status = -1     #地址为空
        elsif pri != ~/\d/
            status = -2     #权重不是数字
        elsif cat.blank?
            status = -3     #类别有误
        elsif longi.blank?
            status = -4     
        elsif lati.blank?
            status = -5
        else
            status = 0      #未知错误
        end
        render text: status
    end

    #保留/删除按钮
    def statusChange
        itemId = params[:id]
        dataStatus = params[:status]   #1=保留，2=删除
        item = Poi.find(params[:id])

        if item.present?
            item.update_attribute("status", dataStatus)
            status = 1      #update成功
        else
            status = 0      #update失败
        end
        render text: status
    end

    #查找中心点附近的点
    def adjacentPoints
        north = params[:north]
        south = params[:south]
        west = params[:west]
        east = params[:east]

        sqlCommand = "SELECT position,longitude,latitude FROM poi WHERE longitude BETWEEN ? AND ? AND latitude BETWEEN ? AND ?;"
        points = Poi.find_by_sql([sqlCommand,west,east,south,north])

        render json: points
    end

    def similarPoints
        position = params[:position]
        sourceType = params[:sourceType]
        statusType = params[:statusType]
        categoryType = params[:categoryType]

        sqlCommand = "SELECT position,longitude,latitude FROM poi WHERE"
        #状态是否为保留，若没选则默认保留
        if statusType != nil && statusType.to_s != '0'
            sqlCommand = sqlCommand + " status = '" + statusType.to_s + "'"
        else
            sqlCommand = sqlCommand + " status = '1'"
        end
        #来源
        if sourceType != nil && sourceType.to_s != '2'
            sqlCommand = sqlCommand + " AND source = '" +  sourceType.to_s + "'"
        end
        if position != nil
            sqlCommand = sqlCommand + " AND position like '%" + position.to_s + "%'"
        end
        if categoryType != nil && categoryType.to_s != ''
            sqlCommand = sqlCommand + " AND category = '" + categoryType.to_s + "'"
        end

        sqlCommand = sqlCommand + ";"

        points = Poi.find_by_sql(sqlCommand)
        render json: points
    end
end
