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

    def remote_work_day?(date = Date.today)
      date.wednesday? && work_day?(date)
    end

    def rest_day?(date = Date.today)
      weekend?(date) || holiday?(date) || winter_vacation_day?(date)
    end

    def weekend?(date = Date.today)
      date.saturday? || date.sunday?
    end

    def holiday?(date = Date.today)
      HolidayJapan.check(date)
    end

    def winter_vacation_day?(date = Date.today)
      WinterVacationSchedule.new(date).winter_vacation?
    end

    alias winter_vacation? winter_vacation_day?

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

    WinterVacationSchedule = Struct.new(:date) do
      def winter_vacation?
        year_end_vacation.days.include?(date) || new_year_vacation.days.include?(date)
      end

      private

      def year_end_vacation
        @year_end_vacation ||= YearEndVacation.new(date.year)
      end

      def new_year_vacation
        @new_year_vacation ||= NewYearVacation.new(date.year)
      end

      YearEndVacation = Struct.new(:year) do
        def days
          beginning_day..dec_31
        end

        def beginning_day
          if coupled_new_year_vacation.days.count >= 5
            last_saturday
          else
            [dec_28, last_saturday].min
          end
        end

        def dec_28
          @dec_28 ||= Date.new(year, 12, 28)
        end

        def dec_31
          @dec_31 ||= Date.new(year, 12, 31)
        end

        def last_saturday
          @last_saturday ||= dec_31.find_previous(&:saturday?)
        end

        def coupled_new_year_vacation
          @coupled_new_year_vacation ||= NewYearVacation.new(year + 1)
        end
      end

      NewYearVacation = Struct.new(:year) do
        def days
          jan_1..end_day
        end

        def end_day
          return jan_3 if first_sunday <= jan_3

          if first_weekend_almost_adjoins_jan_3?
            first_sunday
          else
            jan_3
          end
        end

        def first_weekend_almost_adjoins_jan_3?
          jan_3.next_day.upto(first_sunday).all? { |d| d.friday? || d.saturday? || d.sunday? }
        end

        def first_sunday
          @first_sunday ||= jan_1.find_next(&:sunday?)
        end

        def jan_1
          @jan_1 ||= Date.new(year, 1, 1)
        end

        def jan_3
          @jan_3 ||= Date.new(year, 1, 3)
        end
      end
    end

    class Date < Date
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
