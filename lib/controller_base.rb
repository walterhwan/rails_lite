require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params)
    @params = route_params.merge(req.params)
    @req, @res = req, res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'already built response' if already_built_response?
    res.set_header('Location', url)
    res.status = 302

    session.store_session(@res)

    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'already built response' if already_built_response?
    @res["Content-Type"] = content_type
    @res.write(content)

    session.store_session(@res)

    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name) # i.e. render :new
    raise 'already built response' if already_built_response?

    @res['Content-Type'] = 'text/html'
    path = __dir__ + '/../views/' + self.class.to_s.underscore + '/' + template_name.to_s + '.html.erb'

    lines = File.readlines(path)
    @res.write(ERB.new(lines.join).result(binding))

    @already_built_response = true
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.try(name)
  end
end
