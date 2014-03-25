module Symphony
  # Build filename
  FINAL   = "build/Battle-Symphony.rb"
  # Source files
  TARGETS = [
    "src/config.rb",
    "src/default-action.rb",
    "src/auto-symphony.rb",
    "src/data-initialize.rb",
    "src/action-defines.rb",
    "src/action-import.rb",
    "src/sprite-initialize.rb",
    "src/sprite-object.rb",
    "src/sprite-core.rb",
  ]
end

def symphony_build
  final = File.new(Symphony::FINAL, "w+")
  Symphony::TARGETS.each { |file|
    src = File.open(file, "r+")
    final.write(src.read + "\n")
    src.close
  }
  final.close
end

symphony_build()
