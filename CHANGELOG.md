# 1.0.0
  * Feature: Allow variables of the form %{foo} to be substituted using a supplied hash.

# 0.2.0
  * Incompatible change: Globals.read takes a string instead of file name.

# 0.1.4
  * Bug: Settings were null if environment was specified as a symbol instead of a string.

# 0.1.3
  * Feature: Support for defaults available in all environments, whether or not explicitly defined.

# 0.1.2
  * Bug: Remove all dependencies on Rails.

# 0.1.1
  * Bug: Do not crash if an environment is not defined.

# 0.0.2
  * Feature: Crash if the globals file does not exist.

# 0.0.1
  * Feature: Introducing globals, a simple way to define global constants for rails applications.
