module RedisUtils
  FORBIDDEN = [:quit]

  def unquoted
    %w{string OK} << "(empty list or set)"
  end

  def forbidden?(cmd)
    FORBIDDEN.include? cmd
  end
end