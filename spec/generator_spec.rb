require 'spec_helper'
require 'gemspec_examples'
require 'helpers/generator'
require 'ore/generator'

describe Generator do
  include Helpers::Generator

  context "default" do
    before(:all) do
      @name = 'my-project'

      generate!(@name)
    end

    it "should create the project root directory" do
      expect(@path).to be_directory
    end

    it "should create the lib/ directory" do
      expect(@path).to have_directory('lib')
    end

    it "should create a file to load the project within lib/" do
      expect(@path).to have_file('lib','my','project.rb')
    end

    it "should create a namespace directory within lib/" do
      expect(@path).to have_directory('lib','my','project')
    end

    it "should create a version.rb file within the namespace directory" do
      expect(@path).to have_file('lib','my','project','version.rb')
    end

    it "should not create the bin/ directory by default" do
      expect(@path).not_to have_directory('bin')
    end

    it "should create a test/ directory by default" do
      expect(@path).not_to have_directory('test')
    end

    it "should add a *.gemspec file" do
      expect(@path.join("#{@name}.gemspec")).to be_file
    end

    it "should add a .document file" do
      expect(@path).to have_file('.document')
    end

    it "should add a Rakefile" do
      expect(@path).to have_file('Rakefile')
    end

    it "should add a README.rdoc file" do
      expect(@path).to have_file('README.rdoc')
    end

    it "should add a ChangeLog.rdoc file" do
      expect(@path).to have_file('ChangeLog.rdoc')
    end

    it "should add a LICENSE.txt file" do
      expect(@path).to have_file('LICENSE.txt')
    end
  end

  context "gemspec_yml" do
    before(:all) do
      @name = 'gemspec_yml_project'

      generate!(@name, :gemspec_yml => true)
    end

    it "should add a gemspec.yml file" do
      expect(@path).to have_file('gemspec.yml')
    end

    describe "gemspec.yml" do
      subject { YAML.load_file(@path.join('gemspec.yml')) }

      it "should have a name" do
        expect(subject['name']).to eq(@name)
      end

      it "should not contain a version by default" do
        expect(subject).not_to have_key('version')
      end

      it "should a dummy summary" do
        expect(subject['summary']).to eq(Ore::Options::DEFAULT_SUMMARY)
      end

      it "should a dummy description" do
        expect(subject['description']).to eq(Ore::Options::DEFAULT_DESCRIPTION)
      end

      it "should have a license" do
        expect(subject['license']).to eq(Ore::Options::DEFAULT_LICENSE)
      end

      it "should have authors" do
        expect(subject['authors']).not_to be_empty
      end

      it "should have a dummy homepage" do
        expect(subject['homepage']).not_to be_empty
      end

      it "should have 'rubygems-tasks' as a development dependency" do
        expect(subject['development_dependencies']).to have_key('rubygems-tasks')
      end
    end

    it "should add a *.gemspec file" do
      expect(@path).to have_file("#{@name}.gemspec")
    end

    describe "*.gemspec file" do
      subject { @gemspec }

      it_should_behave_like "a gemspec"
    end
  end

  context "gemspec" do
    before(:all) do
      @name = 'gemspec_project'

      generate!(@name, :gemspec => true)
    end

    it "should disable the gemspec_yml template" do
      expect(@generator.disabled_templates).to include(:gemspec_yml)
    end

    it "should add a *.gemspec file" do
      expect(@path).to have_file("#{@name}.gemspec")
    end

    context "*.gemspec file" do
      subject { @gemspec }

      it_should_behave_like "a gemspec"

      it "should have 'rubygems-tasks' as a development dependency" do
        expect(subject).to have_development_dependency('rubygems-tasks')
      end
    end
  end

  context "git" do
    before(:all) do
      @name = 'git-project'

      generate!(@name, :git => true)
    end

    it "should create a .git directory" do
      expect(@path).to have_directory('.git')
    end

    it "should create a .gitignore file" do
      expect(@path).to have_file('.gitignore')
    end
  end

  context "hg" do
    before(:all) do
      @name = 'hg-project'

      generate!(@name, :hg => true)
    end

    it "should create a .hg directory" do
      expect(@path).to have_directory('.hg')
    end

    it "should create a .hgignore file" do
      expect(@path).to have_file('.hgignore')
    end
  end

  context "bin" do
    before(:all) do
      @name   = 'script-project'
      @script = File.join('bin',@name)

      generate!(@name, :bin => true)
    end

    it "should add a 'bin/' directory" do
      expect(@path).to have_directory('bin')
    end

    it "should add a bin/script-project file" do
      expect(@path).to have_file(@script)
    end

    it "should make the bin/script-project file executable" do
      expect(@path).to have_executable(@script)
    end
  end

  context "bundler" do
    before(:all) do
      @name = 'bundled_project'

      generate!(@name, :bundler => true)
    end

    it "should add a Gemfile" do
      expect(@path).to have_file('Gemfile')
    end

    it "should add 'bundler' as a development dependency" do
      expect(@gemspec).to have_development_dependency('bundler')
    end

    it "should not have any dependencies in the Gemfile" do
      gemfile = (@path + 'Gemfile').read
      expect(gemfile).to eq(<<-GEMFILE)
source 'https://rubygems.org'

gemspec
      GEMFILE
    end

    it "should add 'Gemfile.lock' to the .gitignore file" do
      expect(gitignore).to include('/Gemfile.lock')
    end
  end

  context "rdoc" do
    before(:all) do
      @name = 'rdoc-project'

      generate!(@name, :rdoc => true)
    end

    it "should disable the yard template" do
      expect(@generator.disabled_templates).to include(:yard)
    end

    it "should add 'rdoc' as a development dependency" do
      expect(@gemspec).to have_development_dependency('rdoc')
    end

    it "should set @markup to :rdoc" do
      expect(@generator.instance_variable_get('@markup')).to eq(:rdoc)
    end

    it "should add 'html/' to the .gitignore file" do
      expect(gitignore).to include('/html/')
    end

    it "should add a '.document' file" do
      expect(@path).to have_file('.document')
    end

    context ".document" do
      it "should include 'lib/**/*.rb'" do
        expect(document).to include('lib/**/*.rb')
      end

      it "should include 'README.rdoc'" do
        expect(document).to include('README.rdoc')
      end

      it "should include 'ChangeLog.rdoc'" do
        expect(document).to include('ChangeLog.rdoc')
      end

      it "should include 'LICENSE.txt'" do
        expect(document).to include('LICENSE.txt')
      end
    end
  end

  context "yard" do
    before(:all) do
      @name = 'yard-project'

      generate!(@name, :yard => true)
    end

    it "should disable the rdoc template" do
      expect(@generator.disabled_templates).to include(:rdoc)
    end

    it "should add a .yardopts file" do
      expect(@path).to have_file('.yardopts')
    end

    it "should add a '.document' file" do
      expect(@path).to have_file('.document')
    end

    it "should add 'yard' as a development dependency" do
      expect(@gemspec).to have_development_dependency('yard')
    end

    context ".document" do
      it "should not include 'lib/**/*.rb'" do
        expect(document).not_to include('lib/**/*.rb')
      end

      it "should include a '-' separator for non-code files" do
        expect(document).to include('-')
      end

      it "should not include 'README.rdoc'" do
        expect(document).not_to include('README.rdoc')
      end

      it "should include 'ChangeLog.rdoc'" do
        expect(document).to include('ChangeLog.rdoc')
      end

      it "should include 'LICENSE.txt'" do
        expect(document).to include('LICENSE.txt')
      end
    end
  end

  context "yard with markdown" do
    before(:all) do
      @name = 'yard_markdown-project'

      generate!(@name, :yard => true, :markdown => true)
    end

    it "should add a README.md file" do
      expect(@path).to have_file('README.md')
    end

    it "should add a ChangeLog.md file" do
      expect(@path).to have_file('ChangeLog.md')
    end

    it "should set --markup to markdown in .yardopts" do
      expect(yard_opts).to include('--markup markdown')
    end

    context ".document" do
      it "should include 'ChangeLog.md'" do
        expect(document).to include('ChangeLog.md')
      end
    end
  end

  context "yard with textile" do
    before(:all) do
      @name = 'yard_textile-project'

      generate!(@name, :yard => true, :textile => true)
    end

    it "should add a README.tt file" do
      expect(@path).to have_file('README.tt')
    end

    it "should add a ChangeLog.tt file" do
      expect(@path).to have_file('ChangeLog.tt')
    end

    it "should set --markup to textile in .yardopts" do
      expect(yard_opts).to include('--markup textile')
    end

    context ".document" do
      it "should include 'ChangeLog.tt'" do
        expect(document).to include('ChangeLog.tt')
      end
    end
  end

  context "yard with bundler" do
    before(:all) do
      @name = 'bundled_yard_project'

      generate!(@name, :bundler => true, :yard => true)
    end

    it "should still add 'yard' as a development dependency" do
      expect(@gemspec).to have_development_dependency('yard')
    end
  end

  context "test_unit" do
    before(:all) do
      @name = 'test_unit_project'

      generate!(@name, :test_unit => true)
    end

    it "should disable the minitest template" do
      expect(@generator.disabled_templates).to include(:minitest)
    end

    it "should disable the rspec template" do
      expect(@generator.disabled_templates).to include(:rspec)
    end

    it "should create the test/ directory" do
      expect(@path).to have_directory('test')
    end

    it "should create the test/helper.rb file" do
      expect(@path).to have_file('test','helper.rb')
    end

    it "should add a single test_*.rb file" do
      expect(@path).to have_file('test',"test_#{@name}.rb")
    end
  end

  context "minitest" do
    before(:all) do
      @name = 'minitest_project'

      generate!(@name, :minitest => true)
    end

    it "should disable the test_unit template" do
      expect(@generator.disabled_templates).to include(:test_unit)
    end

    it "should disable the rspec template" do
      expect(@generator.disabled_templates).to include(:rspec)
    end

    it "should create the test/ directory" do
      expect(@path).to have_directory('test')
    end

    it "should create the test/helper.rb file" do
      expect(@path).to have_file('test','helper.rb')
    end

    it "should add a single test_*.rb file" do
      expect(@path).to have_file('test',"test_#{@name}.rb")
    end
  end

  context "rspec" do
    before(:all) do
      @name = 'rspec_project'

      generate!(@name, :rspec => true)
    end

    it "should disable the test_unit template" do
      expect(@generator.disabled_templates).to include(:test_unit)
    end

    it "should disable the minitest template" do
      expect(@generator.disabled_templates).to include(:minitest)
    end

    it "should not create the test/ directory" do
      expect(@path).not_to have_directory('test')
    end

    it "should create the spec/ directory" do
      expect(@path).to have_directory('spec')
    end

    it "should add a spec_helper.rb file" do
      expect(@path).to have_file('spec','spec_helper.rb')
    end

    it "should add a single *_spec.rb file" do
      expect(@path).to have_file('spec','rspec_project_spec.rb')
    end

    it "should add a .rspec file" do
      expect(@path).to have_file('.rspec')
    end

    it "should add 'rspec' as a development dependency" do
      expect(@gemspec).to have_development_dependency('rspec')
    end
  end

  context "rspec with bundler" do
    before(:all) do
      @name = 'bundled_rspec_project'

      generate!(@name, :bundler => true, :rspec => true)
    end

    it "should add 'rspec' as a development dependency" do
      expect(@gemspec).to have_development_dependency('rspec')
    end
  end

  context "rubygems-tasks" do
    before(:all) do
      @name = 'rubygems_tasks_project'

      generate!(@name, :rubygems_tasks => true)
    end

    it "should disable the bundler_tasks template" do
      expect(@generator.disabled_templates).to include(:bundler_tasks)
    end

    it "should add 'rubygems-tasks' as a development dependency" do
      expect(@gemspec).to have_development_dependency('rubygems-tasks')
    end
  end

  context "rubygems-tasks with bundler" do
    before(:all) do
      @name = 'bundled_ore_project'

      generate!(@name, :bundler => true, :rubygems_tasks => true)
    end

    it "should add 'rubygems-tasks' as a development dependency" do
      expect(@gemspec).to have_development_dependency('rubygems-tasks')
    end
  end

  context "bundler_tasks" do
    before(:all) do
      @name = 'bundler_tasks_project'

      generate!(@name, :bundler_tasks => true)
    end

    it "should disable the rubygems_tasks template" do
      expect(@generator.disabled_templates).to include(:rubygems_tasks)
    end

    it "should enable the bundler template" do
      expect(@generator.enabled_templates).to include(:bundler)
    end
  end

  context "gem_package_task" do
    before(:all) do
      @name = 'gem_package_task_project'

      generate!(@name, :gem_package_task => true)
    end

    it "should disable the rubygems_tasks template" do
      expect(@generator.disabled_templates).to include(:rubygems_tasks)
    end

    it "should disable the bundler_tasks template" do
      expect(@generator.disabled_templates).to include(:bundler_tasks)
    end
  end

  after(:all) do
    cleanup!
  end
end
