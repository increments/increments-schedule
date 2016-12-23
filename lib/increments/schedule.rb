require 'increments/schedule/version'
require 'holiday_japan'

module Increments
  module Schedule
    extend self # rubocop:disable ModuleFunction

    def foundation_anniversary?(date = Date.today)
      date.month == 2 && date.day == 29
    end

    def super_hanakin?(date = Date.today)
      date.friday? && pay_day?(date)
    end

    def pay_day?(date = Date.today)
      return work_day?(date) if date.day == 25
      return false if rest_day?(date)
      next_basic_pay_day = Date.new(date.year, date.month, 25)
      next_basic_pay_day = next_basic_pay_day.next_month if date > next_basic_pay_day
      date.next_day.upto(next_basic_pay_day).all? do |date_until_basic_pay_day|
        rest_day?(date_until_basic_pay_day)
      end
    end

    def work_day?(date = Date.today)
      !rest_day?(date)
    end

    alias remote_work_day? work_day?

    def rest_day?(date = Date.today)
      weekend?(date) || holiday?(date) || winter_vacation?(date)
    end

    def weekend?(date = Date.today)
      date.saturday? || date.sunday?
    end

    def holiday?(date = Date.today)
      HolidayJapan.check(date)
    end

    def winter_vacation?(date = Date.today)
      case date.month
      when 1
        return true if date.day <= 3
        date <= ExtendedDate.new(date.year, 1, 1).find_next(&:sunday?)
      when 12
        return true if date.day >= 28
        date >= ExtendedDate.new(date.year, 12, 31).find_previous(&:saturday?)
      else
        false
      end
    end

    public_instance_methods.select { |name| name.to_s.end_with?('?') }.each do |predicate_method|
      enumeration_method = 'each_' + predicate_method.to_s.sub(/\?\z/, '')

      define_method(enumeration_method) do |max_date = nil, &block|
        return to_enum(__method__, max_date) unless block

        max_date ||= Date.today + 365

        Date.today.upto(max_date) do |date|
          block.call(date) if send(predicate_method, date)
        end
      end
    end

    class ExtendedDate < Date
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
    end
  end
end
