require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @req = req
    @ivar = _rails_lite_app
  end

  def [](key)
    @hash[key]
  end

  def []=(key, val)
    @hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
  end
end
