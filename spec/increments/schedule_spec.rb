require 'increments/schedule'

module Increments
  RSpec.describe Schedule do
    it 'responds to enumeration methods for each date predicate method' do
      expect(Schedule).to respond_to(
        :each_super_hanakin,
        :each_pay_day,
        :each_rest_day,
        :each_weekend,
        :each_holiday
      )
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
          expect { |probe| Schedule.each_super_hanakin(&probe) }
            .to yield_successive_args(
              Date.new(2015, 4, 24),
              Date.new(2015, 7, 24),
              Date.new(2015, 9, 25),
              Date.new(2015, 10, 23),
              Date.new(2015, 12, 25),
              Date.new(2016, 3, 25)
            )
        end
      end

      context 'when no block is given' do
        it 'returns an Enumerator' do
          expect(Schedule.each_super_hanakin).to be_an(Enumerator)
        end
      end
    end

    describe '.remote_work_day?' do
      subject { Schedule.remote_work_day?(date) }

      context 'with a Wednesday work day' do
        let(:date) { Date.new(2018, 9, 12) }
        it { should be true }
      end

      context 'with a Thursday work day' do
        let(:date) { Date.new(2018, 9, 11) }
        it { should be false }
      end
    end

    describe '.foundation_anniversary?' do
      subject { Schedule.foundation_anniversary?(date) }

      context 'with February 29 2012' do
        let(:date) { Date.new(2012, 2, 29) }
        it { should be true }
      end

      context 'with February 29 2016' do
        let(:date) { Date.new(2016, 2, 29) }
        it { should be true }
      end

      context 'with February 28 2012' do
        let(:date) { Date.new(2012, 2, 28) }
        it { should be false }
      end

      context 'with February 28 2013' do
        let(:date) { Date.new(2013, 2, 28) }
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

      context 'with a weekday 24th whose next 25th is a rest day' do
        let(:date) { Date.new(2015, 4, 24) }
        it { should be true }
      end

      context 'with a weekday 23th whose next 24th and 25th are rest day' do
        let(:date) { Date.new(2015, 1, 23) }
        it { should be true }
      end

      context 'with a weekday 22th whose next 23rd, 24th and 25th are rest day' do
        let(:date) { Date.new(2016, 12, 22) }
        it { should be true }
      end

      context 'with a rest day 23rd whose next 24th and 25th are rest day' do
        let(:date) { Date.new(2016, 12, 23) }
        it { should be false }
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

    describe '.winter_vacation_day?' do
      subject { Schedule.winter_vacation_day?(date) }

      context 'on 2014-2015' do
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
      end

      context 'on 2015-2016' do
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

      context 'on 2016-2017' do
        context 'with December 27 2016' do
          let(:date) { Date.new(2016, 12, 27) }
          it { should be false }
        end

        context 'with December 28 2016' do
          let(:date) { Date.new(2016, 12, 28) }
          it { should be true }
        end

        context 'with January 3 2017' do
          let(:date) { Date.new(2017, 1, 3) }
          it { should be true }
        end

        context 'with January 4 2017' do
          let(:date) { Date.new(2017, 1, 4) }
          it { should be false }
        end
      end

      context 'on 2017-2018' do
        context 'with December 27 2017' do
          let(:date) { Date.new(2017, 12, 27) }
          it { should be false }
        end

        context 'with December 28 2017' do
          let(:date) { Date.new(2017, 12, 28) }
          it { should be true }
        end

        context 'with January 3 2018' do
          let(:date) { Date.new(2018, 1, 3) }
          it { should be true }
        end

        context 'with January 4 2018' do
          let(:date) { Date.new(2018, 1, 4) }
          it { should be false }
        end
      end
    end
  end
end
