import re

pattern_group = r"new namegroup \"(?P<namegroup>.*?)\""
pattern_name = r"add name \"(?P<name>.*?)\",\"(?P<desc>.*?)\""
pattern_namecool = r"add namecool \"(?P<name>.*?)\",\"(?P<desc>.*?)\""
pattern_blank = r"^\s*$"

allow_empty = False

class NameEntry():
	def __init__(self, name, description="", isCool=False):
		self.name = name
		self.description = description
		self.cool = isCool
		self.locale_name = ""
		self.locale_description = ""

class NameGroupEntry():
	def __init__(self, name):
		self.name = name
		self.entries = []
		self.total = 0

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
		name = matches.group('name')
		desc = matches.group('desc')
		return NameEntry(name, desc)
	else:
		matches = re.search(pattern_namecool, line)
		if matches:
			name = matches.group('name')
			desc = matches.group('desc')
			return NameEntry(name, desc, True)
	return None

def is_blank(line):
	if not line.strip():
		return True
	return False

import os

script_dir = os.path.dirname(os.path.realpath('__file__'))
path = "ItemProgressionNames_PreLocaleUpdate.txt"
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
				active_namegroup.total += 1
				#print("Appended entry '{}'".format(name_entry.name))
	lineNum += 1

print("{} total namegroups found.".format(len(namegroups)))

def export_tsv(namegroups):
	output = "Key\tContent\n"
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
				entry_output_name = "{}_{}_DisplayName".format(g.name, (i+1))
				entry_output_desc = "{}_{}_Description".format(g.name, (i+1))
			entry.locale_name = entry_output_name
			entry.locale_description = entry_output_desc
			if entry.name != "" or allow_empty:
				output += "{}\t{}\n".format(entry_output_name, entry.name)
			if entry.description != "" or allow_empty:
				output += "{}\t{}\n".format(entry_output_desc, entry.description)
		#print("  Entries: {}".format(g.entries))

	output_path = os.path.join(script_dir, "ItemProgressionNames-test.tsv")
	file = open(output_path, 'w')
	file.write(output)

# Rebuild ItemProgressionNames.txt
def export_txt(namegroups):
	output = ""
	namegroups.sort(key=lambda x: x.name, reverse=False)
	for g in namegroups:
		output += "new namegroup \"{}\"\n".format(g.name)
		for i in range(0, len(g.entries)):
			entry = g.entries[i]
			desc = entry.locale_description if allow_empty else ""
			if entry.cool:
				output += "add namecool \"{}\",\"{}\"\n".format(entry.locale_name, desc)
			else:
				output += "add name \"{}\",\"{}\"\n".format(entry.locale_name, desc)
		output += "\n"

	output_path = os.path.join(script_dir, "ItemProgressionNames-new.txt")
	file = open(output_path, 'w')
	file.write(output)

export_tsv(namegroups)
export_txt(namegroups)