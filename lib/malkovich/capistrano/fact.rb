Capistrano::Configuration.class_eval do
  def _facts
    @_facts ||= {}
  end

  def fact(k, v)
    _facts[k] = v
  end

  def _facter_envs
    _facts.each_pair.map{|k, v| "FACTER_#{k.to_s.upcase}=#{v}"}.join ' '
  end
end

