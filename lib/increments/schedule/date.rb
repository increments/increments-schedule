require 'date'

module Increments
  module Schedule
    class Date < ::Date
      INFINITY_FUTURE = Date.new(10_000, 1, 1)
      INFINITY_PAST = Date.new(0, 1, 1)

      def find_next
        upto(INFINITY_FUTURE) do |date|
          break date if yield date
        end
      end

      def find_previous
        downto(INFINITY_PAST) do |date|
          break date if yield date
        end
      end

      def end_of_month
        date = Date.today
        date.next_month - (date.next_month.day - 1)
      end
    end
  end
end
