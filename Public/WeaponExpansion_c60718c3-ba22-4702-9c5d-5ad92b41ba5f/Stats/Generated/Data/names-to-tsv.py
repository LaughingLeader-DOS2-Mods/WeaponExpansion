import re

pattern_group = r"new namegroup \"(?P<namegroup>.*?)\""
pattern_name = r"add name(cool)? \"(?P<name>.*?)\",\"(?P<desc>.*?)\""
pattern_blank = r"^\s*$"

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
		self.entries = []

def get_namegroup(line):
	matches = re.search(pattern_group, line)
	if matches:
		namegroup = matches.group("namegroup")
		if namegroup != "":
			return NameGroupEntry(namegroup)
	return None

def get_name(line):
	matches = re.search(pattern_name, line)
	if matches:
		name = matches.group(2)
		desc = matches.group(3)
		return NameEntry(name, desc)
	return None

def is_blank(line):
	if not line.strip():
		return True
	return False

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

def get_line(lineNum, maxLines, contents):
	if lineNum >= maxLines:
		return False
	return contents[lineNum]

active_namegroup = None

while lineNum < maxLines:
	#print("Iterating '{}/{}'".format(lineNum,maxLines))
	line = contents[lineNum]
	if active_namegroup is None:
		namegroup = get_namegroup(line)
		if namegroup != None:
			active_namegroup = namegroup
			namegroups.append(namegroup)
			#print("Set active namegroup to {}".format(active_namegroup.name))
	else:
		if is_blank(line):
			active_namegroup = None
		else:
			name_entry = get_name(line)
			if name_entry != None:
				active_namegroup.entries.append(name_entry)
				#print("Appended entry '{}'".format(name_entry.name))
	lineNum += 1

print("{} total namegroups found.".format(len(namegroups)))

output = ""

# sort
namegroups.sort(key=lambda x: x.name, reverse=False)

for g in namegroups:
	#print("Namegroup: {} | Entries: {}".format(g.name, len(g.entries)))
	locale_name = "{}_DisplayName".format(g.name)
	locale_description = "{}_Description".format(g.name)
	append_num = len(g.entries) > 1
	#for entry in g.entries:
	for i in range(0, len(g.entries)):
		entry = g.entries[i]
		entry_output_name = locale_name
		entry_output_desc = locale_description
		if append_num:
			entry_output_name = "{}_{}".format(locale_name, (i+1))
			entry_output_desc = "{}_{}".format(locale_description, (i+1))
		if entry.name != "":
			output += "{}\t{}\n".format(entry_output_name, entry.name)
		if entry.description != "":
			output += "{}\t{}\n".format(entry_output_desc, entry.name)
	#print("  Entries: {}".format(g.entries))

output_path = os.path.join(script_dir, "ItemProgressionNames-test.tsv")
file = open(output_path, 'w')
file.write(output)