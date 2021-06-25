# Validate this service is running and serving.

ingress_ip = attribute('ingress-ip')

control "ethtruism_serving" do

  describe http("https://#{ingress_ip}/", headers: { "Host" => "ethtruism.com" }, ssl_verify: false) do
      its('status') { should cmp 200 }
      its('body') { should match /see how many lives you can save for that with effective charity/ }
  end

    describe http("http://#{ingress_ip}/", headers: { "Host" => "ethtruism.com" }) do
        its('status') { should cmp 200 }
        its('body') { should match /see how many lives you can save for that with effective charity/ }
    end
end