require 'increments/schedule'

module Increments
  RSpec.describe Schedule do
    describe '.each_special_remote_work_day' do
      let(:current_date) { Date.new(2015, 4, 1) }

      around do |example|
        Timecop.freeze(current_date) do
          example.run
        end
      end

      context 'when a block is given' do
        it 'yields each special remote work day over the next year' do
          expect { |probe| Schedule.each_special_remote_work_day(&probe) }
            .to yield_successive_args(
              Date.new(2015, 4, 28),
              Date.new(2015, 12, 22),
              Date.new(2016, 2, 12)
            )
        end
      end

      context 'when no block is given' do
        it 'returns an Enumerator' do
          expect(Schedule.each_special_remote_work_day).to be_an(Enumerator)
        end
      end
    end

    #      April 2015
    # Su Mo Tu We Th Fr Sa
    #           1  2  3  4
    #  5  6  7  8  9 10 11
    # 12 13 14 15 16 17 18
    # 19 20 21 22 23 24 25
    # 26 27 28 29 30

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

    describe '.special_remote_work_day?' do
      subject { Schedule.special_remote_work_day?(date) }

      context 'with a non-holiday Monday' do
        let(:date) { Date.new(2015, 5, 11) }
        it { should be false }
      end

      context 'with a holiday Monday' do
        let(:date) { Date.new(2015, 5, 4) } # Greenery Day
        it { should be false }
      end

      context 'with a Sunday' do
        let(:date) { Date.new(2015, 5, 3) }
        it { should be false }
      end

      context 'with a non-rest day sandwiched between normal remote work day and holiday' do
        let(:date) { Date.new(2015, 4, 28) } # 4/29 is Showa Day
        it { should be true }
      end

      context 'with a rest day sandwiched between rest day and holiday' do
        let(:date) { Date.new(2015, 5, 3) } # 5/2 is Saturday, 5/4 is Greenery Day
        it { should be false }
      end

      context 'with a Monday sandwiched between Sunday and holiday' do
        let(:date) { Date.new(2015, 11, 2) } # 11/1 is Sunday, 11/3 is Culture Day
        it { should be false }
      end
    end

    describe '.office_work_day?' do
      subject { Schedule.office_work_day?(date) }

      context 'with a non-holiday Tuesday' do
        let(:date) { Date.new(2015, 5, 12) }
        it { should be true }
      end

      context 'with a non-holiday Tuesday' do
        let(:date) { Date.new(2015, 5, 16) }
        it { should be false }
      end

      context 'with a normal remote work day' do
        let(:date) { Date.new(2015, 5, 11) }
        it { should be false }
      end

      context 'with a special remote work day' do
        let(:date) { Date.new(2015, 4, 28) }
        it { should be false }
      end
    end

    describe '.pay_day?' do
      subject { Schedule.pay_day?(date) }

      context 'with a weekday 25th' do
        let(:date) { Date.new(2015, 3, 25) }
        it { should be true }
      end

      context 'with a rest day 25th' do
        let(:date) { Date.new(2015, 4, 25) }
        it { should be false }
      end

      context 'with a weekday 24th and the next 25th is a rest day' do
        let(:date) { Date.new(2015, 4, 24) }
        it { should be true }
      end

      context 'with a weekday 23th and the next 24th and 25th are rest day' do
        let(:date) { Date.new(2015, 1, 23) }
        it { should be true }
      end

      context 'with a rest day 26th' do
        let(:date) { Date.new(2015, 3, 26) }
        it { should be false }
      end
    end

    describe '.super_hanakin?' do
      subject { Schedule.super_hanakin?(date) }

      context 'with a Friday pay day' do
        let(:date) { Date.new(2015, 4, 24) }
        it { should be true }
      end

      context 'with a non-Friday pay day' do
        let(:date) { Date.new(2015, 3, 25) }
        it { should be false }
      end
    end
  end
end
