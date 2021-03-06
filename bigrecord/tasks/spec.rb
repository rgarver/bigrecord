desc "Run #{DATA_STORES.join(" and ")} specs"
task :spec => DATA_STORES.map{|store| "spec:#{store}" }

namespace :spec do
  unit_specs        = ROOT + 'spec/unit/**/*_spec.rb'
  integration_specs = ROOT + 'spec/integration/**/*_spec.rb'
  all_specs         = ROOT + 'spec/**/*_spec.rb'

  def run_spec(name, adapter, files, rcov)
    Spec::Rake::SpecTask.new(name) do |t|
      t.spec_opts << File.open("spec/spec.opts").readlines.map{|x| x.chomp}
      t.spec_files = Pathname.glob(files.to_s).map { |f| f.to_s }
      connection_path = "spec/connections/#{adapter}"
      t.libs << "spec" << connection_path
    end
  end

  DATA_STORES.each do |adapter|
    task adapter.to_sym => "spec:#{adapter}:all"

    namespace adapter.to_sym do

      desc "Run all specifications"
      run_spec('all', adapter, all_specs, false)

      desc "Run unit specifications"
      run_spec('unit', adapter, unit_specs, false)

      desc "Run integration specifications"
      run_spec('integration', adapter, integration_specs, false)

    end
  end
end