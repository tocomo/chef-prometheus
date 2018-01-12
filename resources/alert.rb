property :name,        String, name_property: true, required: true
property :group,       String, default: 'default'
property :expr,        String, required: true
property :xfor,        String, required: true
property :labels,      Hash, required: true
property :annotations, Hash, required: true
property :config_file, String, default: lazy { '/etc/prometheus/alert.rules' }
property :source,      String, default: 'prometheus'

default_action :create

action :create do
  with_run_context :root do
    edit_resource(:template, new_resource.config_file) do |new_resource|
      cookbook new_resource.source
      variables[:alerts] ||= {}
      variables[:alerts][new_resource.group] ||= {}
      variables[:alerts][new_resource.group][new_resource.name] ||= {}
      variables[:alerts][new_resource.group][new_resource.name]['labels'] = new_resource.labels
      variables[:alerts][new_resource.group][new_resource.name]['annotations'] = new_resource.annotations
      variables[:alerts][new_resource.group][new_resource.name]['expr'] = new_resource.expr
      variables[:alerts][new_resource.group][new_resource.name]['for'] = new_resource.xfor
      action :nothing
      delayed_action :create
    end
  end
end

action :delete do
  template config_file do
    action :delete
  end
end
