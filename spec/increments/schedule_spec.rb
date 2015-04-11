require 'increments/schedule'

module Increments
  RSpec.describe Schedule do
    #       May 2015
    # Su Mo Tu We Th Fr Sa
    #                 1  2
    #  3  4  5  6  7  8  9
    # 10 11 12 13 14 15 16
    # 17 18 19 20 21 22 23
    # 24 25 26 27 28 29 30
    # 31
    describe '.normal_remote_work_day?' do
      subject { Schedule.normal_remote_work_day?(date) }

      context 'with a non-holiday Monday' do
        let(:date) { Date.new(2015, 5, 11) }
        it { should be true }
      end

      context 'with a holiday Monday' do
        let(:date) { Date.new(2015, 5, 4) } # Greenery Day
        it { should be false }
      end

      context 'with any other weekday' do
        let(:date) { Date.new(2015, 5, 12) }
        it { should be false }
      end

      context 'with weekend' do
        let(:date) { Date.new(2015, 5, 16) }
        it { should be false }
      end
    end
  end
end
