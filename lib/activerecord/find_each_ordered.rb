require "active_support"

ActiveSupport.on_load(:active_record) do
  require "active_record/find_each_ordered"
end
