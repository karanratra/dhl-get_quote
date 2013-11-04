require 'spec_helper'
require 'dhl-get_quote'

describe Dhl::GetQuote do

  # classvars may be remembered between tests, this sets things back to default
  after(:each) do
    Dhl::GetQuote.set_defaults
  end

  let(:klass) { Dhl::GetQuote }

  let(:valid_request_options) do
    {
      :site_id  => 'SiteId',
      :password => 'p4ssw0rd'
    }
  end

  let (:valid_request) { request = Dhl::GetQuote::Request.new(valid_request_options) }

  describe ".configure" do

    it "must accept and execute a block" do
      expect(
        lambda do
          klass.configure do
            raise RuntimeError, "Testing"
          end
        end
      ).to raise_exception(RuntimeError)
    end

    context "configure() block" do

      describe ".test_mode!" do
        before(:each) do
          klass.configure { |c| c.test_mode! }
        end

        it "must set the class test_mode? to true" do
          expect(klass.test_mode?).to be_true
        end

        it "Dhl::GetQuote::Request must honor this test mode" do
          request = Dhl::GetQuote::Request.new(valid_request_options)
          expect(request.test_mode?).to be_true
        end
      end

      describe ".production_mode!" do
        before(:each) do
          klass.configure { |c| c.production_mode! }
        end

        it "must set the classvar test_mode to false" do
          expect(klass.test_mode?).to be_false
        end

        it "Dhl::GetQuote::Request must honor this test mode" do
          request = Dhl::GetQuote::Request.new(valid_request_options)
          expect(request.test_mode?).to be_false
        end
      end

      describe ".site_id" do
        before(:each) { klass.configure { |c| c.site_id "SomethingHere" } }

        it "must set class site_id to passed string" do
          expect(
            klass.site_id
          ).to eq("SomethingHere")
        end

        it "Dhl::GetQuote::Request must honor this" do
          request = Dhl::GetQuote::Request.new(
            :password => 'xxx'
          )

          expect(
            request.instance_variable_get(:@site_id)
          ).to eq("SomethingHere")
        end
      end

      describe ".password" do
        before(:each) { klass.configure { |c| c.password "ppaasswwoorrdd" } }

        it "must set class password to passed string" do
          expect(klass.password).to eq("ppaasswwoorrdd")
        end

        it "Dhl::GetQuote::Request must honor this" do
          request = Dhl::GetQuote::Request.new(
            :site_id => 'ASiteId'
          )

          expect(request.instance_variable_get(:@password)).to eq("ppaasswwoorrdd")
        end
      end

      describe "kilograms!" do
        # silence deprication notices in tests
        before(:each) { klass.stub(:puts) }

        it "must call #metric_measurements!" do
          # expect(klass).to receive(:metric_measurements!)
          klass.must_receive(:metric_measurements!)
          klass.kilograms!
        end
      end

      describe "pounds!" do
        # silence deprication notices in tests
        before(:each) { klass.stub(:puts) }

        it "must call #us_measurements!" do
          # expect(klass).to receive(:us_measurements!)
          klass.must_receive(:us_measurements!)
          klass.pounds!
        end
      end

      describe "centimeters!" do
        # silence deprication notices in tests
        before(:each) { klass.stub(:puts) }

        it "must call #metric_measurements!" do
          # expect(klass).to receive(:metric_measurements!)
          klass.must_receive(:metric_measurements!)
          klass.centimeters!
        end
      end

      describe "inches!" do
        # silence deprication notices in tests
        before(:each) { klass.stub(:puts) }

        it "must call #us_measurements!" do
          # expect(klass).to receive(:us_measurements!)
          klass.must_receive(:us_measurements!)
          klass.inches!
        end
      end

      describe "us_measurements!" do
        before(:each) { klass.metric_measurements! }
        it "must set the weight and dimensions to LB and IN" do
          klass.us_measurements!
          expect(klass.dimensions_unit).to eq("IN")
          expect(klass.weight_unit).to eq("LB")
        end

        it "Dhl::GetQuote::Request must honor this" do
          klass.us_measurements!
          expect(valid_request.dimensions_unit).to eq("IN")
          expect(valid_request.weight_unit).to eq("LB")
        end
      end

      describe "metric_measurements!" do
        before(:each) { klass.us_measurements! }
        it "must set the weight and dimensions to KG and CM" do
          klass.metric_measurements!
          expect(klass.dimensions_unit).to eq("CM")
          expect(klass.weight_unit).to eq("KG")
        end

        it "Dhl::GetQuote::Request must honor this" do
          klass.metric_measurements!
          expect(valid_request.dimensions_unit).to eq("CM")
          expect(valid_request.weight_unit).to eq("KG")
        end
      end

      describe "set_logger" do
        describe "it sets the logging method" do
          let(:logger_proc) do
            Proc.new do |msg|
              puts msg
            end
          end

          it "must accept an argument" do
            klass.set_logger(logger_proc)
            expect(klass.logger).to eq(logger_proc)
          end

          it "must accept a block" do
            klass.set_logger do
              :foo
            end
            expect(klass.logger).to eq( Proc.new { :foo } )
          end

          it "if both argument and block are given, it uses the block" do
            klass.set_logger(logger_proc) do
              :foo
            end
            expect(klass.logger).to eq( Proc.new { :foo } )
          end

          it "if called without either it uses self.default_logger" do
            # expect(klass).to receive(:default_logger).at_least(:once).and_return(logger_proc)
            klass.must_receive(:default_logger).at_least(:once).and_return(logger_proc)
            klass.set_logger
          end
        end
      end
    end
  end

end