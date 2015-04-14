#!/usr/bin/awk

########         INIT         ########
BEGIN                      { go = 0; scope = 0 }

########  FIRST CLASS FOUND   ########
/^C/ && go == 0            {
    print "static const class_t classes[] = {"
    go = 1
    # The next rule will match that line as well, and write the class
}

########     CLASS FOUND      ########
/^C/ && go == 1            {
    if (scope == 1) {
	# We just finished the previous class
	# It's waiting for a subclass but doesn't have any: NULL and close
	print "NULL },"
    }
    if (scope == 2) {
	# We just finished the previous subclasses
	# The last one was waiting for protos but doesn't have any: NULL and close
	# Then we finish the subclass list by an empty element and close it
	print "NULL },"
	print "    {0,NULL,NULL} } },"
    }
    if (scope == 3) {
	# We just finished the protos and subclasses
	# Nothing is waiting for a sublist, we just need to
	#  finish and close the lists with empty elements,
	#  then close the previous class
	print "      {0,NULL} } },"
	print "    {0,NULL,NULL} } },"
    }
    # The name goes from $3 to the end of the line ($0)
    name = substr($0, index($0, $3))
    printf "  { 0x" $2 ", \"" name "\", "
    scope = 1
}

########    SUBCLASS FOUND    ########
/^\t[0-9a-f]/ && go == 1   {
    if (scope == 2) {
	# We just finished the previous subclass
	# It was waiting for protos but doesn't have any: NULL and close
	print "NULL },"
    }
    if (scope == 3) {
	# We just finished the protos for the previous subclass
	# We finish the proto list with an empty element, close it,
	#  and close the previous subclass
	print "      {0,NULL} } },"
    }
    # The name goes from $2 to the end of the line ($0)
    name = substr($0, index($0, $2))
    if (scope == 1)
	print "(subclass_t []) {"
    printf "    { 0x" $1 ", \"" name "\", "
    scope = 2
}

########    PROTOCOL FOUND    ########
/^\t\t[0-9a-f]/ && go == 1 {
    # The name goes from $2 to the end of the line ($0)
    name = substr($0, index($0, $2))
    if (scope == 2)
	print "(protocol_t []) {"
    print "      { 0x" $1 ", \"" name "\" },"
    scope = 3
}

########  END OF LIST FOUND   ########
# (hopefuly <empty line> means end of list!)
/^$/ && go == 1            {
    if (scope == 1) {
	# The list ends with a class with no subclass: NULL and close
	# Then we add an empty class element
	print "NULL },"
	print "  {0,NULL,NULL}"
    }
    if (scope == 2) {
	# The list ends with a subclass with no protos: NULL and close
	# Then we add an empty subclass element, close the subclass and the class
	# Then we add an empty class element
	print "NULL },"
	print "    {0,NULL,NULL} } },"
	print "  {0,NULL,NULL}"
    }
    if (scope == 3) {
	# The list ends with a proto. We add an empty proto and close the protos
	# Then we add an empty subclass element, close the subclass and the class
	# Then we add an empty class element
	print "      {0,NULL} } },"
	print "    {0,NULL,NULL} } },"
	print "  {0,NULL,NULL}"
    }
    # Close the structure
    print "};"
    # Exit, we can't parse the rest of the file!
    exit
}
