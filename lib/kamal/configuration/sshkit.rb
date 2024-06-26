class Kamal::Configuration::Sshkit
  include Kamal::Configuration::Validation

  attr_reader :sshkit_config

  def initialize(config:)
    @sshkit_config = config.raw_config.sshkit || {}
    validate! sshkit_config
  end

  def max_concurrent_starts
    sshkit_config.fetch("max_concurrent_starts", 30)
  end

  def pool_idle_timeout
    sshkit_config.fetch("pool_idle_timeout", 900)
  end

  def keys_only?
    !!ssh_config.fetch("keys_only", false)
  end
  
  def keys
    ssh_config.fetch("keys", []) if keys_only?
  end

  def key_data
    ssh_config.fetch("key_data", []) if keys_only?
  end

  def to_h
    sshkit_config
  end
end
