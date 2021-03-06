require 'spec_helper'

describe 'mcollective' do
  it { should contain_class('mcollective') }
  it { should_not contain_class('mcollective::client') }
  it { should_not contain_class('mcollective::middleware') }

  describe '#server' do
    context 'default (true)' do
      it { should contain_class('mcollective::server') }
    end

    context 'false' do
      let(:params) { { :server => false } }
      it { should_not contain_class('mcollective::server') }
    end
  end

  describe 'installing a server' do
    describe '#factsource' do
      it 'should default to yaml' do
        should contain_mcollective__server__setting('factsource').with_value('yaml')
      end

      describe 'yaml' do
        let(:facts) { { :osfamily => 'RedHat', :number_of_cores => 42 } }
        it { should contain_file('/etc/mcollective/facts.yaml') }
        it { should contain_file('/etc/mcollective/facts.yaml').with_content(/^  osfamily: RedHat/) }
        it { should contain_file('/etc/mcollective/facts.yaml').with_content(/^  number_of_cores: 42/) }
        it 'should be alpha-sorted' do
          should contain_file('/etc/mcollective/facts.yaml').with_content(/^  number_of_cores:.*?^  osfamily:/m)
        end
      end

      describe 'facter' do
        let(:params) { { :server => true, :factsource => 'facter' } }
        it { should contain_mcollective__server__setting('factsource').with_value('facter') }
        it { should contain_package('mcollective-facter-facts') }
      end
    end

    describe '#connector' do
      it 'should default to activemq' do
        should contain_mcollective__common__setting('connector').with_value('activemq')
      end

      describe 'activemq' do
        describe 'setting connectors' do
          let(:params) { { :server => true, :middleware_hosts => %w{ foo bar } } }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.size').with_value(2) }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.host').with_value('foo') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.1.port').with_value('61614') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.host').with_value('bar') }
          it { should contain_mcollective__common__setting('plugin.activemq.pool.2.port').with_value('61614') }
        end
      end
    end

    describe '#securityprovider' do
      it 'should default to ssl' do
        should contain_mcollective__common__setting('securityprovider').with_value('ssl')
      end

      describe 'ssl' do
        it { should contain_mcollective__server__setting('plugin.ssl_server_public').with_value('/etc/mcollective/server_public.pem') }
        it { should contain_file('/etc/mcollective/server_public.pem') }
      end

      describe 'psk' do
        let(:params) { { :server => true, :securityprovider => 'psk' } }
        it { should contain_mcollective__common__setting('securityprovider').with_value('psk') }
        it { should contain_mcollective__common__setting('plugin.psk').with_value('changemeplease') }
      end
    end
  end

  describe 'installing middleware' do
    let(:params) { { :middleware => true } }
    it { should contain_class('mcollective::middleware') }

    context '#connector' do
      it 'should default to apache' do
        should contain_class('mcollective::middleware::activemq')
      end

      context 'activemq' do
        it { should contain_class('activemq') }
        it { should contain_class('activemq').with_instance('mcollective') }

        context '#middleware_ssl' do
          it 'should default to true' do
            # We create a truststore when we're doing tls
            should contain_java_ks('mcollective:truststore')
          end

          context 'true' do
            it { should contain_java_ks('mcollective:truststore').with_password('puppet') }
          end

          context 'false' do
            let(:params) { { :middleware => true, :middleware_ssl => false } }
            it { should_not contain_java_ks('mcollective:truststore') }
          end
        end

        context '#activemq_template' do
          context 'default (in-module)' do
            let(:params) { { :middleware => true } }
            it { should contain_file('activemq.xml').with_content(/middleware/) }
          end

          context 'set' do
            let(:params) { { :middleware => true, :activemq_template => 'site_mcollective/test_activemq.xml.erb' } }
            it { should contain_file('activemq.xml').with_content(/^Test of the mcollective::activemq_template parameter/) }
          end
        end

        context '#activemq_config' do
          context 'default (use template in-module)' do
            let(:params) { { :middleware => true } }
            it { should contain_file('activemq.xml').with_content(/middleware/) }
          end

          context 'set' do
            let(:params) { { :middleware => true, :activemq_config => 'Lovingly hand-crafted' } }
            it { should contain_file('activemq.xml').with_content('Lovingly hand-crafted') }
          end
        end
      end
    end
  end
end
