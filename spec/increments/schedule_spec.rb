require 'increments/schedule'

module Increments
  RSpec.describe Schedule do
    it 'responds to enumeration methods for each date predicate method' do
      expect(Schedule).to respond_to(*%i(
        each_super_hanakin
        each_pay_day
        each_remote_work_day
        each_normal_remote_work_day
        each_special_remote_work_day
        each_office_work_day
        each_rest_day
        each_weekend
        each_holiday
      ))
    end

    it 'does not respond to enumeration methods for private predicate method' do
      expect(Schedule).not_to respond_to(:each_normal_office_work_day)
    end

    describe 'date enumeration methods' do
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

    describe '.tgif_party_day?' do
      subject { Schedule.tgif_party_day?(date) }

      context 'until May 2015' do
        context 'even with the second Friday of the month' do
          let(:date) { Date.new(2015, 5, 8) }
          it { should be false }
        end
      end

      context 'in June 2015' do
        context 'even with the second Friday of the month' do
          let(:date) { Date.new(2015, 6, 12) }
          it { should be false }
        end

        context 'with 19th' do
          let(:date) { Date.new(2015, 6, 19) }
          it { should be true }
        end
      end

      context 'since July 2015' do
        [
          ['first', false],
          ['second', true],
          ['third', false],
          ['fourth', true],
          ['fifth', false]
        ].each_with_index do |(order, expected), index|
          context "with the #{order} Friday of a month" do
            let(:date) { Date.new(2015, 7, 3 + 7 * index) }
            it { should be expected }
          end
        end

        context 'with the fourth Friday of a month that is a holiday' do
          let(:date) { Date.new(2016, 12, 23) }
          it { should be false }
        end
      end

      context 'with August 21st 2015' do
        let(:date) { Date.new(2015, 8, 21) }

        it 'returns false due to YAPC Asia' do
          should be false
        end
      end

      context 'with August 27th 2015' do
        let(:date) { Date.new(2015, 8, 27) }
        it { should be false }
      end

      context 'with August 28th 2015' do
        let(:date) { Date.new(2015, 8, 28) }

        it 'returns true as compensation of the last week' do
          should be true
        end
      end
    end

    describe '.winter_vacation?' do
      subject { Schedule.winter_vacation?(date) }

      context 'with December 26 2014' do
        let(:date) { Date.new(2014, 12, 26) }
        it { should be false }
      end

      context 'with December 27 2014' do
        let(:date) { Date.new(2014, 12, 27) }
        it { should be true }
      end

      context 'with January 4 2015' do
        let(:date) { Date.new(2015, 1, 4) }
        it { should be true }
      end

      context 'with January 5 2015' do
        let(:date) { Date.new(2015, 1, 5) }
        it { should be false }
      end

      context 'with December 25 2015' do
        let(:date) { Date.new(2015, 12, 25) }
        it { should be false }
      end

      context 'with December 26 2015' do
        let(:date) { Date.new(2015, 12, 26) }
        it { should be true }
      end

      context 'with January 3 2016' do
        let(:date) { Date.new(2016, 1, 3) }
        it { should be true }
      end

      context 'with January 4 2016' do
        let(:date) { Date.new(2016, 1, 4) }
        it { should be false }
      end
    end

    describe '.each_work_time_range' do
      let(:current_date) { Date.new(2015, 4, 1) }
      let(:max_date) { Date.new(2015, 4, 6) }

      around do |example|
        Timecop.freeze(current_date) do
          example.run
        end
      end

      context 'when a block is given' do
        it 'yields each work time range in localtime' do
          expect { |probe| Schedule.each_work_time_range(max_date, &probe) }
            .to yield_successive_args(
              Time.local(2015, 4, 1, 10, 0)..Time.local(2015, 4, 1, 19, 0),
              Time.local(2015, 4, 2, 10, 0)..Time.local(2015, 4, 2, 19, 0),
              Time.local(2015, 4, 3, 10, 0)..Time.local(2015, 4, 3, 19, 0),
              Time.local(2015, 4, 6, 10, 0)..Time.local(2015, 4, 6, 19, 0)
            )
        end
      end

      context 'when no block is given' do
        it 'returns an Enumerator' do
          expect(Schedule.each_special_remote_work_day).to be_an(Enumerator)
        end
      end
    end
  end
end
