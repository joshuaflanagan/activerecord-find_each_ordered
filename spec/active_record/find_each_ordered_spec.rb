require "spec_helper"

RSpec.describe ActiveRecord::FindEachOrdered do
  class Widget < ActiveRecord::Base
  end

  before do
    Widget.delete_all
    Widget.create!(id: 1, name: "Echo", age: 1)
    Widget.create!(id: 2, name: "Zulu", age: 8)
    Widget.create!(id: 3, name: "Delta", age: 8)
    Widget.create!(id: 4, name: "Bravo", age: 8)
    Widget.create!(id: 5, name: "Foxtrot", age: 2)
    Widget.create!(id: 6, name: "Charlie", age: 3)
    Widget.create!(id: 7, name: "Victor", age: 3)
  end

  specify "yields all records from a relation, sorted by provided sort_key" do
    yielded_records = []

    Widget.all.find_each_ordered(:name) do |record|
      yielded_records.push(record)
    end

    expect(yielded_records.map(&:id)).to eq([4, 6, 3, 1, 5, 7, 2])
  end

  specify "only yields each record once, even across multiple db calls" do
    yielded_records = []

    Widget.all.find_each_ordered(:name, batch_size: 2) do |record|
      yielded_records.push(record)
    end

    expect(yielded_records.map(&:id)).to eq([4, 6, 3, 1, 5, 7, 2])
  end

  specify "only yields each record once, even when the sort values are not unique" do
    yielded_records = []

    Widget.all.find_each_ordered(:age, batch_size: 2) do |record|
      yielded_records.push(record)
    end

    aggregate_failures do
      # assert that the records came back in sort order
      expect(yielded_records.map(&:age)).to eq([1,2,3,3,8,8,8])
      # assert that each record was yielded - disregarding order
      expect(yielded_records.map(&:id)).to match_array([1,2,3,4,5,6,7])
    end
  end

  specify "yields each record, even when multiple pages of records have same sort key" do
    Widget.update_all(name: "Bob")
    loop_protection_count = 0
    yielded_records = []

    Widget.all.find_each_ordered(:name, batch_size: 2) do |record|
      loop_protection_count += 1
      raise "likely infinite loop" if loop_protection_count > 100
      yielded_records.push(record)
    end

    # assert that each record was yielded - disregarding order
    expect(yielded_records.map(&:id)).to match_array([1,2,3,4,5,6,7])
  end

  specify "returns an enumerator when no block provided" do
    return_value = Widget.all.find_each_ordered(:name)
    expect(return_value).to be_a(Enumerator)
    expect(return_value.map(&:id)).to eq([4, 6, 3, 1, 5, 7, 2])
  end

  specify "raises ArgumentError if the sort_key would not be returned by the relation" do
    expect{
      Widget.select(:id, :age).find_each_ordered(:name).to_a
    }.to raise_error(ArgumentError, /'name'/)
  end

  specify "raises UnsortableNullValue if a NULL value for the sort_key is encountered" do
    Widget.update_all(name: nil)
    expect{
      Widget.all.find_each_ordered(:name, batch_size: 2).to_a
    }.to raise_error(ActiveRecord::FindEachOrdered::UnsortableNullValue)
  end

  specify "only returns up to batch_size records from each trip to the db" do
    desired_batch_size = 2
    queries = []
    on_query = ->(*args){
      event = ActiveSupport::Notifications::Event.new(*args)
      queries << event.payload
    }

    ActiveSupport::Notifications.subscribed(on_query, "sql.active_record") do
      Widget.all.find_each_ordered(:name, batch_size: desired_batch_size).to_a
    end

    expect(queries.length).to eq(4)

    binds = queries.map{|p| limit=p[:binds].detect{|b| b.name == "LIMIT"}; limit&.value}
    expect(binds.uniq).to eq([desired_batch_size])
  end
end
