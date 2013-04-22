require 'rubygems'
require 'httparty'
require 'erb'
class Dhl::GetQuote::Request
  attr_reader :site_id, :password, :from_country_code, :from_postal_code, :to_country_code, :to_postal_code
  attr_accessor :pieces

  DIMENSIONS_UNIT_CODES = { :centimeters => "CM", :inches => "IN" }
  WEIGHT_UNIT_CODES = { :kilograms => "KG", :pounds => "LB" }

  XML_TEMPLATE_PATH = "tpl/request.xml.erb"

  def initialize(options={})
    [ :site_id, :password ].each do |req|
      raise Dhl::GetQuote::OptionsError, ":#{req} is a required option" unless options[req]
      instance_variable_set("@#{req}", options[req])
    end
    @pieces = []
  end

  def from(country_code, postal_code)
    @from_postal_code = postal_code.to_s
    validate_country_code!(country_code)
    @from_country_code = country_code
  end

  def to(country_code, postal_code)
    @to_postal_code = postal_code.to_s
    validate_country_code!(country_code)
    @to_country_code = country_code
  end

  def dutiable?
    !!@is_dutiable
  end

  def dutiable(val)
    @is_dutiable = !!val
  end

  def dutiable!
    dutiable(true)
  end

  def not_dutiable!
    dutiable(false)
  end

  def dimensions_unit
    @dimensions_unit ||= DIMENSIONS_UNIT_CODES[:centimeters]
  end

  def weight_unit
    @weight_unit ||= WEIGHT_UNIT_CODES[:kilograms]
  end

  def centimeters!
    @dimensions_unit = DIMENSIONS_UNIT_CODES[:centimeters]
  end
  alias :centimetres! :centimeters!

  def inches!
    @dimensions_unit = DIMENSIONS_UNIT_CODES[:inches]
  end

  def centimeters?
    dimensions_unit == DIMENSIONS_UNIT_CODES[:centimeters]
  end
  alias :centimetres? :centimeters?

  def inches?
    dimensions_unit == DIMENSIONS_UNIT_CODES[:inches]
  end

  def kilograms!
    @weight_unit = WEIGHT_UNIT_CODES[:kilograms]
  end
  alias :kilogrammes! :kilograms!

  def pounds!
    @weight_unit = WEIGHT_UNIT_CODES[:pounds]
  end

  def pounds?
    weight_unit == WEIGHT_UNIT_CODES[:pounds]
  end

  def kilograms?
    weight_unit == WEIGHT_UNIT_CODES[:kilograms]
  end
  alias :kilogrammes? :kilograms?

  def to_xml
    validate!
    ERB.new(File.new(XML_TEMPLATE_PATH).read).result(binding)
  end

  def ready_time(time=Time.now)
    time.strftime("PT%HH%MM")
  end

  def post
    validate!
    response = HTTParty.post("https://xmlpitest-ea.dhl.com/XMLShippingServlet",
      :body => to_xml,
      :headers => { 'Content-Type' => 'application/xml' }
    ).response
    raise response.body
    # case response.code
    # when /^2\d+/
    #   return true
    # when "401"
    #   raise Trigonal::InvalidCredentialsError, "Email address and password or key was not accepted"
    # else
    #   raise Trigonal::UnknownServerError, "Unknown upstream server (code #{response.code}) occured"
    # end
  end

protected

  def validate!
    raise Dhl::GetQuote::FromNotSetError, "#from() is not set" unless (@from_country_code && @from_postal_code)
    raise Dhl::GetQuote::ToNotSetError, "#to() is not set" unless (@to_country_code && @to_postal_code)
    validate_pieces!
  end

  def validate_pieces!
    pieces.each do |piece|
      klass_name = "Dhl::GetQuote::Piece"
      if piece.class.to_s != klass_name
        raise Dhl::GetQuote::PieceError, "entry in #pieces is not a #{klass_name} object!"
      end
    end
  end

  def validate_country_code!(country_code)
    unless country_code =~ /^[A-Z]{2}$/
      raise Dhl::GetQuote::CountryCodeError, 'country code must be upper-case, two letters (A-Z)'
    end
  end
end