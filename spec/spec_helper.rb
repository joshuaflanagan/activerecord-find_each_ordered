require "bundler/setup"
require "active_record"
require "active_record/find_each_ordered"

ActiveRecord::Base.establish_connection(adapter: :sqlite3, database: ":memory:")

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    rebuild_db
  end

  config.around(:each) do |example|
    if ENV["SHOW_SQL"]
      on_query = ->(*args){
        event = ActiveSupport::Notifications::Event.new(*args)
        puts event.payload[:sql]
      }
      ActiveSupport::Notifications.subscribed(on_query, "sql.active_record") do
        example.run
      end
    else
      example.run
    end
  end
end


def rebuild_db
  ActiveRecord::Base.connection.create_table :widgets, force: true do |table|
    table.column :name, :string
    table.column :age, :integer
  end
end
