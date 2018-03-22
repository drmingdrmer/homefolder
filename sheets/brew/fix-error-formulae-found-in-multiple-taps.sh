
# Error: Formulae found in multiple taps:
#  * homebrew/php/php53
#  * josegonzalez/php/php53
# Please use the fully-qualified name e.g. homebrew/php/php53 to refer the formula.


brew untap josegonzalez/php
brew tap --repair
brew update
