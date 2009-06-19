require 'logger'

BigRecord::Base.logger = Logger.new("debug.log")

BigRecord::Base.configurations = {
  'brunit' => {
    :adapter  => 'hbase',
    :master => 'localhost:60000',
    :regionserver => '0.0.0.0:60020',
    :drb_host => 'localhost',
    :drb_port => '40001'
  }
}

BigRecord::Base.logger.info "Connecting to Hbase data store (#{BigRecord::Base.configurations.inspect})"

BigRecord::Base.establish_connection 'brunit'
