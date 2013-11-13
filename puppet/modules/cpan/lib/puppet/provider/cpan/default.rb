Puppet::Type.type(:cpan).provide( :default ) do
  @doc = "Manages cpan modules"

  commands :cpan => '/usr/bin/cpan'

  def install
  end

  def force
  end

  def create
    result = cpan( resource[:name] )
  end

  def destroy
  end

  def exists?
    result = true
    begin
      Puppet.debug( "perl -M" + resource[:name].to_s + " -e1" )
      result = system( "perl -M" + resource[:name] + " -e1" )
    rescue => e
      Puppet.debug( result + e.message )
      result = false
    end
    result
  end

end
