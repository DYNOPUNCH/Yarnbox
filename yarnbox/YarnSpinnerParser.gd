extends Node

##################################
#------- NODE COLLECTION --------#
##################################

# Holds all nodes 
var node_dictionary = {}

##################################
#---------- VARIABLES -----------#
##################################

# Check if a node is actively having it's lines processed
# Made this to avoide Nodes being nested in other nodes and causeing collisions
# When a node is active keywords are ignored as well
var node_in_progress = false

# Reference to the current node being populated
var current_node: YarnNode = null

##################################
#------- CLASS OBJECTS ----------#
##################################

# A Yarn Node Object that stores all the characteristics of a Node.
class YarnNode:
	var title: String
	var position: Vector2i
	var tags := []
	var lines := []
	
	# Initialize a new Yarn Node
	func _init(_title: String = "", _position: Vector2i = Vector2i(0,0), _tags : Array = [], _lines: Array = []):
		title = _title
		position = _position
		tags = _tags
		lines = _lines
	
	# Checks if an index is out of bounds
	func check_if_index_out_of_bounds(_index: int, _size: int) -> bool:
		if(_size - 1 < _index || _index < 0):
			print("Index out of bounds.")
			return false
		
		return true
	
	# Get string from an array
	func get_string_from_array(_index: int, _array: Array) -> String:
		# Check if index is in bounds
		if(check_if_index_out_of_bounds(_index, _array.size())):
			return ""
			
		# Returns array string at index
		return _array[_index]
	
	# Remove string from array
	func remove_string_from_array(_index: int, _array: Array):
		# Check if index is in bounds
		if(check_if_index_out_of_bounds(_index, _array.size())):
			return
		
		_array.remove_at(_index)
	
	# Set node title
	func set_title(_title: String):
		title = _title
		
	# Get node title
	func get_title() -> String:
		return title
	
	# Set node position
	func set_position(_position: Vector2i):
		position = _position
	
	# Get node position
	func get_position() -> Vector2i:
		return position
		
	# Add node tag
	func add_tag(_newTag: String):
		tags.append(_newTag)
		
	func copy_tags(_tags: Array):
		tags = _tags
	
	# Remove node tag at index
	func remove_tag_at(_index: int):
		remove_string_from_array(_index, tags)
	
	# Returns a specific tag string
	func get_tag_at(_index: int) -> String:
		return get_string_from_array(_index, tags)
	
	# Returns copy of entire tag array
	func get_tag_array() -> Array:
		return tags
	
	# Adds line to node	
	func add_line(_newLine):
		lines.append(_newLine)
		
	# Returns a specific line string
	func get_line_at(_index: int) -> String:
		return get_string_from_array(_index, lines)
		
# Remove node line at index
	func remove_line_at(_index: int):
		remove_string_from_array(_index, lines)

# A line that belongs to a yarn file
class YarnLine:
	# Possible name to be stored
	var name: String
	# Possible dialogue to be stored
	var dialogue: String
	# Number of tabs from the left 
	var tab_count : int
	
	func _init(_name: String = "", _dialogue: String = "", tab_count: int = 0):
		name = _name
		dialogue = _dialogue

# Stores a set of options
class YarnOption:
	# Stores options until no more "->" are found at tab level
	var option : String
	var sublines : Array
	var tab_count : int
	
	func _init(_option: String = "", _sublines: Array = [], _continuation_line: YarnLine = null, _tab_count: int = 0) -> void:
		option = _option
		tab_count = _tab_count
		sublines = _sublines

# The type of statement for the interpretor to comprehend.
enum statement_types {
	JUMP = 0,
	VARIABLE = 1,
	IF = 2
};

# Stores the conditional statement
class YarnStatement:
	# Stores the conditional statement
	var statement: String
	var type: statement_types 

##################################
#----------- KEYWORDS -----------#
##################################

#TODO Put this in a seprate file.
# List of yarn keywords and matching functions
# Only accessible when node is not in progress 
var yarn_keywords = {
	"title:" : title_handler,
	"position:" : position_handler,
	"tags:" : tags_handler,
	"---" : triple_dash_handler,
	}

var yarn_special_characters = {
	"===" : triple_equal_handler,
	"->" : point_handler,
	":" : colon_handler,
	"<<" : l_angle_bracket_handler
}

##################################
#----------- GENERIC ------------#
##################################

# Checks if node dictionary has atleast one element
func check_node_dictionary_initialized() -> bool:
	# Check if the node has been initialized
	if(node_dictionary.size() == 0):
		print("a \"title:\" keyword must be used first to initialize the node")
		return false
	
	# If dictionary has been initialized return true;
	return true

# Returns value from from string. 
func get_string_value_from_pair(_string: String) -> String:
	
	# Split the title from the from the word. 
	var word_tokens := []
	word_tokens = _string.split(" ")
	
	# Make sure there are only 2 values in array and return null if there are more.
	if(word_tokens.size() > 2):
		print("There cannot be any spaces in declaration keywords")
		return ""
		
	if(word_tokens.size() == 1):
		print_rich("[color=green][Recommended]:[/color] Statement is empty. Remove if not in use.")
		return ""
	
	# Get rid of keyword at the front.
	word_tokens.pop_front()
	
	# Store value in temp variable.
	var value = word_tokens[0]
	
	return value

func get_char_index(line: String, _char: String) -> int:
		# Find the index of colon
	var index = line.findn(_char)
		
	return index

##################################
#----------- HANDLERS -----------#
##################################

# Handles "title" keyword
# Extracts node title
# Adds new node to dictionary with generic information.
# Sets current node to reference the new titled node.
func title_handler(line: String):
	
	# Copy title
	var title = get_string_value_from_pair(line)
	
	# Create new node
	node_dictionary[title] = YarnNode.new(title, Vector2i(0,0), [], []);
	
	# Store reference to node in current node
	current_node = node_dictionary[title]

# Handles "position" keyword
# Sets position value to current node object
func position_handler(line: String):
	pass
	# If dictionary doesn't have a first element return
	if(!check_node_dictionary_initialized() && current_node != null):
		return
	
	# Get position values
	var value: String = get_string_value_from_pair(line)
	
	# Split position values from string
	var position: Array = value.split(",")
	
	current_node.set_position(Vector2i(int(position[0]), int(position[1])))

# Handles "tags" keyword
func tags_handler(line: String):
	pass
	# If dictionary doesn't have a first element return
	if(!check_node_dictionary_initialized() && current_node != null):
		return
		
	# Get position values
	var value: String = get_string_value_from_pair(line)
	
	if(value == ""):
		return
	
	# Split position values from string
	var tags: Array = value.split(",")
	
	current_node.copy_tags(tags)
	
	return

# Handles "---" keyword
# Makes line writing active
func triple_dash_handler(line: String):
	node_in_progress = true
	
# Handles "===" keyword
# Dereferences current node and closes out current node for writing 
func triple_equal_handler(line: String):
	current_node = null
	node_in_progress = false

# Handles ":" special character
func colon_handler(line: String):
	
	# Find the index of colon
	var index = line.findn(":")
	
	# Temporary dialogue object
	var temp_dialogue_line: YarnLine
	
	# Extract name, dialogue and tab count
	var temp_name: String = line.substr(0, index)
	var temp_dialogue: String = line.substr(index + 1, line.length() - 1)
	
	# Set the name and dialogue 
	# Remove white space from edges
	temp_dialogue_line = YarnLine.new(temp_name.strip_edges(), temp_dialogue.strip_edges(), line.count("\t"))
	
	# Add line to node's lines
	current_node.add_line(temp_dialogue)
	
	print_rich("[color=yellow]Name:[/color]" + temp_dialogue_line.name + " [color=yellow]Dialogue:[/color]" + temp_dialogue_line.dialogue)
	print_rich("[color=green]tab count: [/color]" + str(temp_dialogue_line.tab_count))

#TODO Test Parsing options

# Handles "->" special chacter
func point_handler(line: String):
	
	# Find the index of colon
	var index = line.findn("->")
	
	# Extracts the option text
	var option_contents = line.substr(index + 2, line.length() - 1)
	
	option_contents = option_contents.strip_edges()
	
	var tab_count : int = line.count("\t")
	
	# Temporary dialogue object
	var temp_option_line: YarnOption
	
	temp_option_line = YarnOption.new(option_contents, [], null,tab_count)
	
	# Add line to node's lines
	current_node.add_line(temp_option_line)
	
	print_rich("[color=red]Option:[/color]" + temp_option_line.option + "\n[color=green]tab count:[/color]" + str(tab_count))

func l_angle_bracket_handler(line: String):
	
	# Dictionary of statement types
	var statement_type = {}
	
	print("Found Statement")

##################################
#------ PARSING FUNCTIONS -------#
##################################

# Loads and returns the raw contents of a file as an array of lines.
func loadFileRawLines(filename: String) -> Array:
	
	# Temporary varible that holds the lines to be copied over
	var lines := []
	
	# Attempt to open file 
	var file = FileAccess.open(filename, FileAccess.READ)
	
	# If file load fails show error message and pop out.
	if(file == null):
		print("File does not exist")
		return lines
	
	# Load lines of text into memory and add to temporary lines varaible
	while(!file.eof_reached()):
		var line = file.get_line()
		lines.append(line)
	
	# Close file and free it from memory and print success message
	file.close()
	print("File loaded successfully")
	
	# Return file contents
	return lines
	
# Detect if there is a "title" keyword and returns the name
func parseForNodes(line: String) -> String:
	
	# Stores word tokens in an array
	var word_tokens := []
	
	# Stores the keyword that passed
	var current_keyword: String
	
	# Seperate line word "tokens"
	word_tokens = line.strip_edges().split(" ", false)
	
	# Check for keywords from all words.
	# This is squarly for when you're outside a node.
	for keyword in yarn_keywords:
		if keyword in word_tokens:
			
			# If a keyword matches it calls a function from the yarn keyword dictionary
			yarn_keywords[keyword].call(line)

			
	return ""
	
func parseForLines(line: String):
	
	# You could iterate through all special characters if needed
	for special_character in yarn_special_characters.keys():
		if (line.contains(special_character)):
			#print("Found special character:", special_character)
			yarn_special_characters[special_character].call(line)
			return
	
	# No special characters, treat as normal dialogue
	if(current_node != null):
		var temp_dialogue_line : YarnLine = YarnLine.new("", line, line.count("\t"))
		current_node.add_line(temp_dialogue_line)
		print("Default: " + line)
		print_rich("[color=green]tab count: [/color]" + str(temp_dialogue_line.tab_count))
		
	#print_rich("[color=green]Dialogue:[/color]" + current_node.lines[-1].dialogue)

func jumpToLine():
	pass




# Calls loadFileRawLines, validates that it's a yarn files, and parses the contents into the system
func loadYarnfile(filename: String):
	
	# Verify that the filename is a valid yarn file
	if(filename.ends_with(".yarn") == false):
		print("This function only accepts .yarn extensions.")
		return
	
	# Copy File lines
	var lines_array = loadFileRawLines(filename)
	
	# Start Parsing Lines
	for line in lines_array: 
		if(node_in_progress == false):
			# Parses outer parts of node 
			parseForNodes(line)
		else:
			# Parses inner Part of node
			parseForLines(line)
			

func _ready() -> void:
	
	# Testing to see if it works
	loadYarnfile("MyStory.yarn")
	print("\ndictionary size: " + str(node_dictionary.size()))
