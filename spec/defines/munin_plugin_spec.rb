require 'spec_helper'

describe 'munin::plugin', :type => 'define' do

  let(:title) { 'testplugin' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Solaris'
        conf_dir = '/opt/local/etc/munin'
        share_dir = '/opt/local/share'
      when 'FreeBSD'
        conf_dir = '/usr/local/etc/munin'
        share_dir = '/usr/local/share'
      else
        conf_dir = '/etc/munin'
        share_dir = '/usr/share'
      end

      context 'with no parameters' do
        it do
          expect { should contain_file("#{conf_dir}/plugins/testplugin") }
            .to raise_error("expected that the catalogue would contain File[#{conf_dir}/plugins/testplugin]")
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_ensure('absent')
        end
      end

      context 'with ensure=link parameter' do
        let(:params) { { :ensure => 'link' } }
        it do
          should contain_file("#{conf_dir}/plugins/testplugin")
                  .with_ensure('link')
                  .with_target("#{share_dir}/munin/plugins/testplugin")
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_ensure('absent')
        end
      end

      context 'with ensure=link and target parameters' do
        let (:title) { 'test_foo' }
        let (:params) do
          { :ensure => 'link',
            :target => 'test_' }
        end
        it do
          should contain_file("#{conf_dir}/plugins/test_foo")
                  .with_ensure('link')
                  .with_target("#{share_dir}/munin/plugins/test_")
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/test_foo.conf")
                  .with_ensure('absent')
        end
      end

      context 'with ensure=present and source parameters' do
        let(:params) do
          { :ensure => 'present',
            :source => 'puppet:///modules/munin/plugins/testplugin' }
        end
        it do
          should contain_file("#{conf_dir}/plugins/testplugin")
                    .with_ensure('present')
                    .with_source('puppet:///modules/munin/plugins/testplugin')
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_ensure('absent')
        end
      end

      context 'with ensure=present, source and config parameters' do
        let(:params) do
          { :ensure => 'present',
            :source => 'puppet:///modules/munin/plugins/testplugin',
            :config => [ 'something wonderful' ],
          }
        end
        it do
          should contain_file("#{conf_dir}/plugins/testplugin")
                  .with_ensure('present')
                  .with_source('puppet:///modules/munin/plugins/testplugin')
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_ensure('present')
                  .with_content(/something wonderful/)
        end
      end

      context 'only configuration' do
        let (:params) do
          { :config => ['env.rootdn cn=admin,dc=example,dc=org'],
            :config_label => 'slapd_*',
          }
        end
        it do
          should contain_file("#{conf_dir}/plugin-conf.d/testplugin.conf")
                  .with_ensure('present')
                  .with_content(/env.rootdn/)

        end
        it do
          expect { should contain_file("#{conf_dir}/plugins/testplugin") }
            .to raise_error("expected that the catalogue would contain File[#{conf_dir}/plugins/testplugin]")
        end
      end

      context 'with absolute target' do
        let(:params) do
          { ensure: 'link',
            target: '/full/path/to/testplugin' }
        end
        it do
          should contain_file("#{conf_dir}/plugins/testplugin")
                  .with_ensure('link')
                  .with_target('/full/path/to/testplugin')
        end
      end

    end
  end

end
