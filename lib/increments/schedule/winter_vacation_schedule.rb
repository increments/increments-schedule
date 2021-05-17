# frozen_string_literal: true

module Increments
  module Schedule
    WinterVacationSchedule = Struct.new(:date) do
      def self.winter_vacation?(date)
        new(date).winter_vacation?
      end

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

        private

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

        private

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
  end
end
