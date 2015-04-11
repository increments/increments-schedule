require 'increments/schedule/version'
require 'active_support/all'
require 'holiday_japan'

module Increments
  module Schedule
    extend self # rubocop:disable ModuleFunction

    [
      [:each_remote_work_day,         proc { |date| remote_work_day?(date) }],
      [:each_normal_remote_work_day,  proc { |date| normal_remote_work_day?(date) }],
      [:each_special_remote_work_day, proc { |date| special_remote_work_day?(date) }]
    ].each do |method_name, conditional|
      define_method(method_name) do |max_date = nil, &block|
        return to_enum(__method__, max_date) unless block

        max_date ||= Date.today + 1.year

        Date.today.upto(max_date) do |date|
          block.call(date) if conditional.call(date)
        end
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
        !normal_office_work_day?(date.yesterday) && !normal_office_work_day?(date.tomorrow)
    end

    def office_work_day?(date)
      normal_office_work_day?(date) && !remote_work_day?(date)
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
