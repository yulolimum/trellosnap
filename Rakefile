task :build do
  sh "cd ext; find . -name \"*.json\" | xargs tar cvf - | (cd ../build ; tar xfp -)"
  sh "cd ext; find . -name \"*.html\" | xargs tar cvf - | (cd ../build ; tar xfp -)"
  sh "cd ext; find . -name \"*.js\" | xargs tar cvf - | (cd ../build ; tar xfp -)"
  sh "cd ext; find . -name \"*.css\" | xargs tar cvf - | (cd ../build ; tar xfp -)"
  sh "cd ext; find . -name \"*.png\" | xargs tar cvf - | (cd ../build ; tar xfp -)"
  sh "cd ext; find . -name \"*.gif\" | xargs tar cvf - | (cd ../build ; tar xfp -)"
  sh "zip -9 -r build.zip ./build/*"
  puts "DONE!"
end

task :default => 'build'