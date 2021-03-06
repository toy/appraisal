require 'spec_helper'

describe 'Appraisals file Bundler DSL compatibility' do
  it 'supports all Bundler DSL in Appraisals file' do
    build_gems %w(bagel orange_juice milk waffle coffee ham sausage pancake)
    build_git_gems %w(egg croissant pain_au_chocolat)

    build_gemfile <<-Gemfile
      source 'https://rubygems.org'
      git_source(:custom_git_source) { |repo| "../gems/\#{repo}" }
      ruby RUBY_VERSION

      gem 'bagel'
      gem "croissant", :custom_git_source => "croissant"

      git '../gems/egg' do
        gem 'egg'
      end

      path '../gems/waffle' do
        gem 'waffle'
      end

      group :breakfast do
        gem 'orange_juice'
      end

      platforms :ruby, :jruby do
        gem 'milk'

        group :lunch do
          gem "coffee"
        end
      end

      source "https://other-rubygems.org" do
        gem "sausage"
      end

      gem 'appraisal', :path => #{PROJECT_ROOT.inspect}
    Gemfile

    build_appraisal_file <<-Appraisals
      appraise 'breakfast' do
        source 'http://some-other-source.com'
        ruby "1.8.7"

        gem 'bread'
        gem "pain_au_chocolat", :custom_git_source => "pain_au_chocolat"

        git '../gems/egg' do
          gem 'porched_egg'
        end

        path '../gems/waffle' do
          gem 'chocolate_waffle'
        end

        group :breakfast do
          gem 'bacon'

          platforms :rbx do
            gem "ham"
          end
        end

        platforms :ruby, :jruby do
          gem 'yoghurt'
        end

        source "https://other-rubygems.org" do
          gem "pancake"
        end

        gemspec
        gemspec :path => "sitepress"
      end
    Appraisals

    run 'bundle install --local'
    run 'appraisal generate'

    expect(content_of 'gemfiles/breakfast.gemfile').to eq <<-Gemfile.strip_heredoc
      # This file was generated by Appraisal

      source "https://rubygems.org"
      source "http://some-other-source.com"

      ruby "1.8.7"

      git "../../gems/egg" do
        gem "egg"
        gem "porched_egg"
      end

      path "../../gems/waffle" do
        gem "waffle"
        gem "chocolate_waffle"
      end

      gem "bagel"
      gem "croissant", :git => "../../gems/croissant"
      gem "appraisal", :path => #{PROJECT_ROOT.inspect}
      gem "bread"
      gem "pain_au_chocolat", :git => "../../gems/pain_au_chocolat"

      group :breakfast do
        gem "orange_juice"
        gem "bacon"

        platforms :rbx do
          gem "ham"
        end
      end

      platforms :ruby, :jruby do
        gem "milk"
        gem "yoghurt"

        group :lunch do
          gem "coffee"
        end
      end

      source "https://other-rubygems.org" do
        gem "sausage"
        gem "pancake"
      end

      gemspec :path => "../"
      gemspec :path => "../sitepress"
    Gemfile
  end
end
