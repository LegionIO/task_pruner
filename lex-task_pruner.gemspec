# frozen_string_literal: true

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
  spec.required_ruby_version = '>= 3.4'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.extra_rdoc_files = %w[README.md LICENSE CHANGELOG.md]
  spec.metadata = {
    'bug_tracker_uri'       => 'https://github.com/LegionIO/task_pruner/issues',
    'changelog_uri'         => 'https://github.com/LegionIO/task_pruner/blob/main/CHANGELOG.md',
    'documentation_uri'     => 'https://github.com/LegionIO/task_pruner',
    'homepage_uri'          => 'https://github.com/LegionIO/task_pruner',
    'source_code_uri'       => 'https://github.com/LegionIO/task_pruner',
    'wiki_uri'              => 'https://github.com/LegionIO/task_pruner/wiki',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_dependency 'legion-data'
end
