
def generate_flags
  config = ''
  node['prometheus']['cli_opts'].sort.each do |opt_key, opt_value|
    config += "--#{opt_key}=#{opt_value} " if opt_value != ''
  end
  node['prometheus']['cli_flags'].sort.each do |opt_flag|
    config += "--#{opt_flag} " if opt_flag != ''
  end
  config
end
