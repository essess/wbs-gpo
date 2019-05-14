#!/usr/bin/env python3

from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()
vu.add_osvvm()                      #<< needed ?
vu.add_verification_components()    #<< pickup wishbone stuff

# Create library 'lib'
lib = vu.add_library("lib")

# Add all files ending in .vhd in current working directory to library
lib.add_source_files("*.vhd")

# Run vunit function
vu.main()