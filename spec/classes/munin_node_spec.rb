require 'spec_helper'

describe 'munin::node' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }

      it { should contain_package('munin-node') }

      case facts[:osfamily]
      when 'Solaris'
        munin_node_service = 'smf:/munin-node'
        munin_node_conf    = '/opt/local/etc/munin/munin-node.conf'
      when 'FreeBSD'
        munin_node_conf    = '/usr/local/etc/munin/munin-node.conf'
        munin_node_service = 'munin-node'
      else
        munin_node_service = 'munin-node'
        munin_node_conf = '/etc/munin/munin-node.conf'
      end

      it { should contain_service(munin_node_service) }
      it { should contain_file(munin_node_conf) }


      context 'acl with ipv4 and ipv6 addresses' do
        let(:params) do
          { allow: ['2001:db8:1::',
                    '2001:db8:2::/64',
                    '192.0.2.129',
                    '192.0.2.0/25',
                    '192\.0\.2']
          }
        end
        it { should compile.with_all_deps }
        it do
          should contain_file('/etc/munin/munin-node.conf')
                  .with_content(/^cidr_allow 192.0.2.0\/25$/)
                  .with_content(/^cidr_allow 2001:db8:2::\/64$/)
                  .with_content(/^allow \^192\\.0\\.2\\.129\$$/)
                  .with_content(/^allow 192\\.0\\.2$/)
                  .with_content(/^allow \^2001:db8:1::\$$/)
        end
      end

      context 'with host_name unset' do
        it { should compile.with_all_deps }
        it do
          should contain_file('/etc/munin/munin-node.conf')
                  .with_content(/host_name\s+foo.example.com/)
        end
      end

      context 'with host_name set' do
        let(:params) do
          { host_name: 'something.example.com' }
        end
        it { should compile.with_all_deps }
        it do
          should contain_file('/etc/munin/munin-node.conf')
                  .with_content(/host_name\s+something.example.com/)
        end
      end

      context 'logging to syslog' do
        context 'defaults' do
          let(:params) do
            { log_destination: 'syslog' }
          end
          it{ should compile.with_all_deps }
          it do
            should contain_file(munin_node_conf)
                    .with_content(/log_file\s+Sys::Syslog/)
          end
        end
      end

      context 'with syslog options' do
        let(:params) do
          { log_destination: 'syslog',
            syslog_ident: 'munin-granbusk',
            syslog_facility: 'user1',
          }
        end
        it{ should compile.with_all_deps }
        it do
          should contain_file(munin_node_conf)
                  .with_content(/log_file\s+Sys::Syslog/)
                  .with_content(/syslog_ident\s+"munin-granbusk"/)
                  .with_content(/syslog_facility\s+user1/)
        end
      end

    end
  end

  context 'unsupported' do
    include_context :unsupported
    it {
      expect {
        should contain_class('munin::node')
      }.to raise_error(Puppet::Error, /Unsupported osfamily/)
    }
  end

end
