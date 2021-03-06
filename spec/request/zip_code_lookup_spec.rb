require 'spec_helper'

describe USPS::Request::ZipCodeLookup do
  it "should be using the proper USPS api settings" do
    USPS::Request::ZipCodeLookup.tap do |klass|
      klass.secure.should be_false
      klass.api.should == 'ZipCodeLookup'
      klass.tag.should == 'ZipCodeLookupRequest'
    end
  end

  it "should not allow more than 5 addresses" do
    Proc.new do
      USPS::Request::AddressStandardization.new([USPS::Address.new] * 6)
    end.should raise_exception(ArgumentError)
  end

  it "should be able to build a proper request" do
    request = USPS::Request::AddressStandardization.new(
      USPS::Address.new(
        :name => 'Joe Jackson',
        :company => 'Widget Tel Co.',
        :address => '999 Serious Business Av',
        :address2 => 'Suite 2000',
        :city  => 'Awesome Town',
        :state => 'FL'
      )
    )

    xml = Nokogiri::XML.parse(request.build)

    xml.search('Address').first.tap do |node|
      node.attr('ID').should == '0'

      node.search('FirmName').text.should == 'Widget Tel Co.'
      node.search('Address1').text.should == 'Suite 2000'
      node.search('Address2').text.should == '999 Serious Business Av'
      node.search('City').text.should == 'Awesome Town'
      node.search('State').text.should == 'FL'
    end
  end
end
