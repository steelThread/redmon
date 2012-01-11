module RedisUtils
  extend self

  FORBIDDEN = [:quit]

  def unquoted
    %w{string OK} << "(empty list or set)"
  end

  def forbidden?(cmd)
    FORBIDDEN.include? cmd
  end

  def empty_result
    '(empty list or set)'
  end

  def unknown(cmd)
    "(error) ERR unknown command '#{cmd}'"
  end

  def wrong_number_of_arguments_for(cmd)
    "(error) ERR wrong number of arguments for '#{cmd}' command"
  end

  def connection_refused_for(url)
    "Could not connect to Redis at #{url.gsub(/\w*:\/\//, '')}: Connection refused"
  end

end