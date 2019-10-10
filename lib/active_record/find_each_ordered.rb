module ActiveRecord
  module FindEachOrdered
    # Behaves like find_each, but allows a custom sort order.
    #
    # #find_each forces the records to be returned sorted by 'id'.
    #
    # Make sure none of the returned records have a NULL value for the sort key,
    # or this may fail with an UnsortableNullValue error.
    # If the column is nullable, you may want to add something like:
    #  .where.not(last_name: nil) # assuming a sort_key of :last_name
    # or other criteria that will ensure no NULL values are encountered.
    def find_each_ordered(sort_key, batch_size: 1000)
      return to_enum(:find_each_ordered, sort_key, batch_size: batch_size) unless block_given?
      relation = self
      batch_order = arel_attribute(sort_key).asc
      relation = relation.reorder(batch_order).limit(batch_size)
      records = relation.to_a

      last_offset = nil
      seen_ids = []
      while records.any?
        records_size = records.size
        last_record = records.last
        unless last_record.has_attribute?(sort_key)
          raise ArgumentError.new("Sort key '#{sort_key}' not included in the custom select clause")
        end
        batch_offset = last_record.public_send(sort_key)
        if batch_offset.nil?
          raise UnsortableNullValue, "#{last_record.class} with id #{last_record.id} has a NULL value for sort_key '#{sort_key}'"
        end
        if batch_offset != last_offset
          seen_ids.clear
        end
        last_offset = batch_offset
        # since more than one order could have the same sort_key value, we
        # need to exclude the ones we've seen from the next query
        new_excludes = records.select{|r|
          r.public_send(sort_key) == batch_offset
        }.map(&:id)
        seen_ids.concat(new_excludes)

        records.each{|r| yield r}

        break if records_size < batch_size

        records = relation.where(
          relation.table[sort_key].gteq(batch_offset)
        ).where.not(id: seen_ids).to_a
      end
    end

    class UnsortableNullValue < StandardError; end
  end

  Relation.include(FindEachOrdered)
end
