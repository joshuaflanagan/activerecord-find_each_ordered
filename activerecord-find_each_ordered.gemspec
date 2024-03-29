lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "activerecord-find_each_ordered"
  spec.version       = "0.1.0"
  spec.authors       = ["Joshua Flanagan"]
  spec.email         = ["joshuaflanagan@gmail.com"]

  spec.summary       = %q{Allow custom sort order with find_each behavior}
  spec.description   = %q{Allow custom sort order with find_each behavior}
  spec.homepage      = "https://github.com/joshuaflanagan/activerecord-find_each_ordered"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
