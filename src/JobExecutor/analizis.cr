require "json"
require "./analizis/*"

# init Page for each Page
# run on nodes of HTML doc
#
# for each Node trying to find Sequence of Node`s childrens,
# that will be relevant to requirements, that given in options
#
# for find equense, programm calculating Signatures of nodes,
# and collecting them into SignatureSet`s

# Signature buildings with Node arguments, Node childrens arguments,
# and Node descendants arguments. When sognature becomes irrelevant,
# the scan is terminated.

# For check the relevancy, OptionSet takes a group of the scan results,
# and puts them into match Options (that builded for that results part)
