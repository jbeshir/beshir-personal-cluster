# Validate the TLS certificates set as persistent data are correctly used for TLS connections with the appropriate SNI.

ingress_ip = attribute('ingress-ip')
howwastoday_io_tls_cert_pem = attribute('howwastoday-io-tls-cert-pem')
ethtruism_io_tls_cert_pem = attribute('ethtruism-com-tls-cert-pem')

ethtruism_io_tls_cert_fingerprint = nil
IO.popen("openssl x509 -noout -fingerprint | grep 'SHA1 Fingerprint'", 'w+') do |f|
  f.puts ethtruism_io_tls_cert_pem
  f.close_write
  ethtruism_io_tls_cert_fingerprint = f.gets
end

howwastoday_io_tls_cert_fingerprint = nil
IO.popen("openssl x509 -noout -fingerprint | grep 'SHA1 Fingerprint'", 'w+') do |f|
  f.puts howwastoday_io_tls_cert_pem
  f.close_write
  howwastoday_io_tls_cert_fingerprint = f.gets
end

control "ethtruism_cert_check" do

  describe command("echo '' | openssl s_client -connect #{ingress_ip}:443 -servername ethtruism.com -showcerts 2>/dev/null | openssl x509 -noout -ext subjectAltName | grep DNS") do
    its('stdout') { should match /DNS:\*\.ethtruism\.com, DNS:ethtruism\.com/ }
  end

  describe command("echo '' | openssl s_client -connect #{ingress_ip}:443 -servername ethtruism.com -showcerts 2>/dev/null | openssl x509 -noout -fingerprint | grep 'SHA1 Fingerprint'") do
    its('stdout') { should eq ethtruism_io_tls_cert_fingerprint }
  end
end

control "howwastoday_cert_check" do

  describe command("echo '' | openssl s_client -connect #{ingress_ip}:443 -servername backend.howwastoday.io -showcerts 2>/dev/null | openssl x509 -noout -ext subjectAltName | grep DNS") do
    its('stdout') { should match /DNS:\*\.howwastoday\.io, DNS:howwastoday\.io/ }
  end

  describe command("echo '' | openssl s_client -connect #{ingress_ip}:443 -servername backend.howwastoday.io -showcerts 2>/dev/null | openssl x509 -noout -fingerprint | grep 'SHA1 Fingerprint'") do
    its('stdout') { should eq howwastoday_io_tls_cert_fingerprint }
  end
end