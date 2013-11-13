Puppet::Type.newtype(:cpan) do
  ensurable

  newparam(:name) do
    desc "The name of the module."
  end

end
