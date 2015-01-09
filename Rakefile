namespace :sass do
  desc "Watches the background.sass"
  task :watch_background do
    puts "SASS: Watching background.sass"
    # system "sass --watch assets/stylesheets:assets/stylesheets --style compressed"
  end

  desc "Watches the browser_action.sass"
  task :watch_browser_action do
    puts "SASS: Watching browser_action.sass"
    # system "sass --watch assets/stylesheets:assets/stylesheets --style compressed"
  end

  desc "Watches all sass files."
  task watch: [:watch_background, :watch_browser_action]  do
    puts "SASS: Sass watch started!"
  end
end

namespace :coffee do

end

namespace :files do
  desc "Watches for Sass and Coffee changes."
  task :watch do
    Rake::Task["sass:watch"].invoke
    puts "FILES: Sass watch and coffee started!"
  end
end

task default: "files:watch"
