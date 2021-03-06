require File.dirname(__FILE__) + '/spec_helper.rb'

require 'yaml'

module GeoUtm
  # http://rspec.info/
  describe GeoUtm do
    before :each do
      @testdata = nil
      File.open(File.join(File.dirname(__FILE__), 'testdata.yaml')) {|f| @testdata = YAML::load f }
    end
    
    it "should return an ellipsoid for every test sample" do
      @testdata.each do |sample|
        Ellipsoid::lookup(sample[:ellipsoid]).should be_a_kind_of(Ellipsoid)
      end
    end
    
    it "should convert from lat/lon to UTM" do
      @testdata.each do |sample|
        latlon = LatLon.new sample[:latitude].to_f, sample[:longitude].to_f
        utm = latlon.to_utm Ellipsoid::lookup(sample[:ellipsoid])
        utm.n.should be_close(sample[:northing].to_f, 0.01)
        utm.e.should be_close(sample[:easting].to_f, 0.01)
        utm.zone.should == sample[:zone]
      end
    end

    it "should convert from UTM to lat/lon" do
      @testdata.each do |sample|
        utm = UTM.new sample[:zone], sample[:easting].to_f, sample[:northing].to_f, 
          Ellipsoid::lookup(sample[:ellipsoid])
        latlon = utm.to_lat_lon
        latlon.lat.should be_close(sample[:latitude].to_f, 0.01)
        latlon.lon.should be_close(sample[:longitude].to_f, 0.01)
      end
    end
  end
end
