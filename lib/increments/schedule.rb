require 'increments/schedule/version'
require 'holiday_japan'

module Increments
  module Schedule
    extend self # rubocop:disable ModuleFunction

    DATE_OF_SPECIAL_TGIF_PARTY = Date.new(2015, 6, 19)
    START_DATE_OF_NORMAL_TGIF_PARTY_SCHEDULE = Date.new(2015, 7, 1)
    DATE_RANGE_OF_YAPC_ASIA = Date.new(2015, 8, 20)..Date.new(2015, 8, 22)

    def super_hanakin?(date = Date.today)
      date.friday? && pay_day?(date)
    end

    def tgif_party_day?(date = Date.today)
      if date >= START_DATE_OF_NORMAL_TGIF_PARTY_SCHEDULE
        if second_or_fourth_friday_in_month?(date)
          !cancelled_tgif_party_day?(date)
        else
          cancelled_tgif_party_day?(date - 7) && !cancelled_tgif_party_day?(date)
        end
      else
        date == DATE_OF_SPECIAL_TGIF_PARTY
      end
    end

    def pay_day?(date = Date.today)
      return work_day?(date) if date.day == 25
      next_basic_pay_day = Date.new(date.year, date.month, 25)
      next_basic_pay_day = next_basic_pay_day.next_month if date > next_basic_pay_day
      date.next_day.upto(next_basic_pay_day).all? do |date_until_basic_pay_day|
        rest_day?(date_until_basic_pay_day)
      end
    end

    def work_day?(date = Date.today)
      !rest_day?(date)
    end

    def office_work_day?(date = Date.today)
      work_day?(date) && !remote_work_day?(date)
    end

    def remote_work_day?(date = Date.today)
      normal_remote_work_day?(date) || special_remote_work_day?(date)
    end

    def normal_remote_work_day?(date = Date.today)
      date.monday? && work_day?(date)
    end

    def special_remote_work_day?(date = Date.today)
      normal_office_work_day?(date) &&
        !normal_office_work_day?(date - 1) && !normal_office_work_day?(date + 1)
    end

    def rest_day?(date = Date.today)
      weekend?(date) || holiday?(date)
    end

    def weekend?(date = Date.today)
      date.saturday? || date.sunday?
    end

    def holiday?(date = Date.today)
      HolidayJapan.check(date)
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

    def each_work_time_range(max_date = nil)
      return to_enum(__method__, max_date) unless block_given?

      each_work_day(max_date) do |work_day|
        yield opening_time_of_date(work_day)..closing_time_of_date(work_day)
      end
    end

    private

    def normal_office_work_day?(date = Date.today)
      !rest_day?(date) && !normal_remote_work_day?(date)
    end

    def second_or_fourth_friday_in_month?(date)
      date.friday? && (date.day / 7).odd?
    end

    def cancelled_tgif_party_day?(date)
      second_or_fourth_friday_in_month?(date) && (rest_day?(date) || yapc_asia_day?(date))
    end

    def yapc_asia_day?(date)
      DATE_RANGE_OF_YAPC_ASIA.include?(date)
    end

    def opening_time_of_date(date)
      date.to_time + 10 * 60 * 60
    end

    def closing_time_of_date(date)
      date.to_time + 19 * 60 * 60
    end
  end
end
