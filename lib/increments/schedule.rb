require 'increments/schedule/version'
require 'holiday_japan'

module Increments
  module Schedule
    extend self # rubocop:disable ModuleFunction

    [
      [:each_super_hanakin,           :super_hanakin?],
      [:each_pay_day,                 :pay_day?],
      [:each_remote_work_day,         :remote_work_day?],
      [:each_normal_remote_work_day,  :normal_remote_work_day?],
      [:each_special_remote_work_day, :special_remote_work_day?]
    ].each do |enumeration_method, predicate_method|
      define_method(enumeration_method) do |max_date = nil, &block|
        return to_enum(__method__, max_date) unless block

        max_date ||= Date.today + 365

        Date.today.upto(max_date) do |date|
          block.call(date) if send(predicate_method, date)
        end
      end
    end

    def super_hanakin?(date)
      pay_day?(date) && date.friday?
    end

    def pay_day?(date)
      return !rest_day?(date) if date.day == 25
      next_basic_pay_day = Date.new(date.year, date.month, 25)
      next_basic_pay_day = next_basic_pay_day.next_month if date > next_basic_pay_day
      date.next_day.upto(next_basic_pay_day).all? do |date_until_basic_pay_day|
        rest_day?(date_until_basic_pay_day)
      end
    end

    def remote_work_day?(date)
      normal_remote_work_day?(date) || special_remote_work_day?(date)
    end

    def normal_remote_work_day?(date)
      date.monday? && !rest_day?(date)
    end

    def special_remote_work_day?(date)
      normal_office_work_day?(date) &&
        !normal_office_work_day?(date - 1) && !normal_office_work_day?(date + 1)
    end

    def office_work_day?(date)
      !rest_day?(date) && !remote_work_day?(date)
    end

    def rest_day?(date)
      weekend?(date) || holiday?(date)
    end

    def weekend?(date)
      date.saturday? || date.sunday?
    end

    def holiday?(date)
      HolidayJapan.check(date)
    end

    private

    def normal_office_work_day?(date)
      !rest_day?(date) && !normal_remote_work_day?(date)
    end
  end
end
