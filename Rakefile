namespace :sass do
  desc "Watches background and browser-action sass files."
  task :watch do
    system "sass --watch ext/assets/stylesheets/background:ext/assets/stylesheets/ ext/assets/stylesheets/browser-action:ext/assets/stylesheets/ --style compressed --sourcemap=none"
    puts "SASS: Sass watch started!"
  end
end

namespace :jade do
  desc "Watched the views directory"
  task :watch do
    puts "JADE: Watching the ext/views directory"
    system "jade --watch ext/views/*/*.jade"
  end
end


namespace :coffee do

end

namespace :files do
  desc "Watches for Sass and Coffee changes."
  task :watch do
    Rake::Task["sass:watch"].invoke
    Rake::Task["jade:watch"].invoke
    puts "FILES: Sass watch, jade watch, and coffee started!"
  end
end

desc "Set up the project. Run updates."
task :setup do
  puts "UPDATE: Updating bourbon"
  system "cd ext/assets/stylesheets/_base/; bourbon update"

  puts "UPDATE: Updating neat"
  system "cd ext/assets/stylesheets/_base/; neat update"

  puts "You are ready to start. Run 'rake' to start compiling!"
end

task default: "files:watch"
