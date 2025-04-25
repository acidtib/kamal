require "test_helper"

class ConfigurationProxyTest < ActiveSupport::TestCase
  setup do
    @deploy = {
      service: "app", image: "dhh/app", registry: { "username" => "dhh", "password" => "secret" },
      builder: { "arch" => "amd64" }, servers: [ "1.1.1.1" ]
    }
  end

  test "ssl with host" do
    @deploy[:proxy] = { "ssl" => true, "host" => "example.com" }
    assert_equal true, config.proxy.ssl?
  end

  test "ssl with multiple hosts passed via host" do
    @deploy[:proxy] = { "ssl" => true, "host" => "example.com,anotherexample.com" }
    assert_equal true, config.proxy.ssl?
  end

  test "ssl with multiple hosts passed via hosts" do
    @deploy[:proxy] = { "ssl" => true, "hosts" => [ "example.com", "anotherexample.com" ] }
    assert_equal true, config.proxy.ssl?
  end

  test "ssl with no host" do
    @deploy[:proxy] = { "ssl" => true }
    assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
  end

  test "ssl with both host and hosts" do
    @deploy[:proxy] = { "ssl" => true, host: "example.com", hosts: [ "anotherexample.com" ] }
    assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
  end

  test "ssl false" do
    @deploy[:proxy] = { "ssl" => false }
    assert_not config.proxy.ssl?
  end

  test "false not allowed" do
    @deploy[:proxy] = false
    assert_raises(Kamal::ConfigurationError, "proxy: should be a hash") do
      config.proxy
    end
  end

  test "ssl with certificate and private key from secrets" do
    with_test_secrets("secrets" => "CERT_PEM=certificate\nKEY_PEM=private_key") do
      @deploy[:proxy] = {
        "ssl" => true,
        "host" => "example.com",
        "certificate_pem" => "CERT_PEM",
        "private_key_pem" => "KEY_PEM"
      }

      proxy = config.proxy
      assert_equal "/home/kamal-proxy/.apps-config/app/tls/cert.pem", proxy.certificate_pem
      assert_equal "/home/kamal-proxy/.apps-config/app/tls/key.pem", proxy.private_key_pem
    end
  end

  test "ssl with certificate and no private key" do
    with_test_secrets("secrets" => "CERT_PEM=certificate") do
      @deploy[:proxy] = {
        "ssl" => true,
        "host" => "example.com",
        "certificate_pem" => "CERT_PEM"
      }
      assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
    end
  end

  test "ssl with private key and no certificate" do
    with_test_secrets("secrets" => "KEY_PEM=private_key") do
      @deploy[:proxy] = {
        "ssl" => true,
        "host" => "example.com",
        "private_key_pem" => "KEY_PEM"
      }
      assert_raises(Kamal::ConfigurationError) { config.proxy.ssl? }
    end
  end

  private
    def config
      Kamal::Configuration.new(@deploy)
    end
end
