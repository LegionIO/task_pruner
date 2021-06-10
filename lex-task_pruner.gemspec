require_relative 'lib/legion/extensions/task_pruner/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-task_pruner'
  spec.version       = Legion::Extensions::TaskPruner::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Prunes old task history from LegionIO'
  spec.description   = 'Prunes old task history from LegionIO'
  spec.homepage      = 'https://github.com/LegionIO/task_pruner'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/task_pruner'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/task_pruner'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.test_files        = spec.files.select { |p| p =~ %r{^test/.*_test.rb} }
  spec.extra_rdoc_files  = %w[README.md LICENSE CHANGELOG.md]
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/LegionIO/task_pruner/issues',
    'changelog_uri' => 'https://github.com/LegionIO/task_pruner/src/main/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/LegionIO/task_pruner',
    'homepage_uri' => 'https://github.com/LegionIO/task_pruner',
    'source_code_uri' => 'https://github.com/LegionIO/task_pruner',
    'wiki_uri' => 'https://github.com/LegionIO/task_pruner/wiki'
  }

  spec.add_dependency 'legion-data'
end
