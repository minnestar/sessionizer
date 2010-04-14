namespace :db do
  namespace :test do
    desc 'Causes db:test:prepare to also run the fixie creation files in test/fixie'
    # Somewhat obscure(?) fact: if you create a rake task with the
    # same name as another one (in this case test:db:prepare), it will
    # be run after the first one. That's how this works.
    task :prepare do
      RAILS_ENV = 'test'
      Dir[File.join(RAILS_ROOT, 'test', 'fixie', '*.rb')].sort.each { |fixture| load fixture }
    end
  end
end
