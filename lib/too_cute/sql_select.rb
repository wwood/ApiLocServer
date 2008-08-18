# By default we just want to do a select_all to get back a result set as an array of hashes.
# This sucks a little because the column order is not preserved.
module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def db_too_cute(sql)
        select_all(sql)[0..Array::MAX_ROWS_KAWAII]
      end
    end
  end
end

# For Mysql, we'll do an execute to get back a Mysql::Result, which has a too_cute method
# that will preserve column order
module ActiveRecord
  module ConnectionAdapters
    class MysqlAdapter
      def db_too_cute(sql)
        execute(sql)
      end
    end
  end
end

class Mysql
  class Result
    def too_cute
      columns = []
      fetch_fields.each {|f| columns << {:key => f.name}}

      data = []  
      each_hash do |r| 
        next if data.size >= Array::MAX_ROWS_KAWAII
        data << r
      end
      
      {:type => 'grid', :columns => columns, :data => data}
    end
  end
end