defprotocol Hello.TemplateSource do
  def template_url_base(source)
  def list_url(source)
  def parse_path(source, path)
end
