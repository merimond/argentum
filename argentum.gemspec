Gem::Specification.new do |s|
  s.name    = "argentum"
  s.version = "1.0.0"
  s.summary = "Collection of small utilities"
  s.authors = ["Alex Serebryakov"]
  s.files   = Dir['lib/**/*.rb']
  s.add_dependency('addressable')
  s.add_dependency('htmlentities')
end
