import re

pattern_group = r"new namegroup \"(?P<namegroup>.*?)\""
pattern_name = r"add name(cool)? \"(?P<name>.*?)\",\"(?P<desc>.*?)\""

class NameEntry():
	name = ""
	description = ""
	def __init__(self, name, description=""):
		self.name = name
		self.description = description

class NameGroupEntry():
	name = ""
	entries = []

	def __init__(self, name):
		self.name = name

def get_namegroup(str):
	matches = re.search(pattern_group, str)
	if matches:
		namegroup = matches.group("namegroup")
		if namegroup != "":
			return NameGroupEntry(namegroup)
	return None

def get_name(str):
	matches = re.search(pattern_name, str)
	if matches:
		name = matches.group("name")
		desc = matches.group("desc")
		return NameEntry(name, desc)
	return None

import os

script_dir = os.path.dirname(os.path.realpath('__file__'))
path = "ItemProgressionNames.txt"
file_path = os.path.join(script_dir, path)

print("Opening file '{}'".format(file_path))
file = open(file_path, 'r')

contents = file.readlines()

lineNum = 0
maxLines = len(contents)
namegroups = []

print("Total lines '{}'".format(maxLines))

# for i in range(0, len(contents)):
# 	print("Line '{}' = {}".format(i, contents[i]))

def get_names(namegroup, line):
	name_entry = get_name(line)
	if name_entry != None:
		namegroup.entries.append(name_entry)
		return True
	return False

def get_line(lineNum, maxLines, contents):
	if lineNum >= maxLines:
		return False
	return contents[lineNum]

while lineNum < maxLines:
	#print("Iterating '{}/{}'".format(lineNum,maxLines))
	line = contents[lineNum]
	namegroup = get_namegroup(line)
	if namegroup != None:
		namegroups.append(namegroup)
		lineNum += 1
		while get_names(namegroup, line) is True:
			line = get_line(lineNum, maxLines, contents)
			if line is False:
				break
	lineNum += 1

print("{} total namegroups found.".format(len(namegroups)))

output = ""

for g in namegroups:
	print("Namegroup: {}".format(g.name))
	locale_name = "{}_DisplayName".format(g.name)
	locale_description = "{}_Description".format(g.name)
	for entry in g.entries:
		if entry.name != "":
			output += "{}\t{}\n".format(locale_name, entry.name)
		if entry.description != "":
			output += "{}\t{}\n".format(locale_description, entry.name)
	#print("  Entries: {}".format(g.entries))

output_path = os.path.join(script_dir, "ItemProgressionNames-test.tsv")