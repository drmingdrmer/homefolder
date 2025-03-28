
# read the user specified file, parse the ndjson format.
# the file format is like this:
# ```
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902752","value":{"seq":111902758,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,160,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902768","value":{"seq":111902774,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,176,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902781","value":{"seq":111902787,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,189,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902814","value":{"seq":111902820,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,222,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902821","value":{"seq":111902827,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,229,128,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902850","value":{"seq":111902856,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,130,129,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902912","value":{"seq":111902918,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,192,129,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111902937","value":{"seq":111902943,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,217,129,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ["state_machine/0",{"GenericKV":{"key":"__fd_object_owners/zdcyc/table-by-id/111903014","value":{"seq":111903020,"meta":{"expire_at":null},"data":[10,22,110,112,115,102,122,104,103,103,119,121,104,95,97,100,109,105,110,95,114,111,108,101,18,27,18,19,10,7,100,101,102,97,117,108,116,16,148,193,159,38,24,166,130,174,53,160,6,107,168,6,24,160,6,107,168,6,24]}}}]
# ```
# Only process the lines starting with "state_machine/0", and only the lines with "GenericKV" key,
# and process only the lines with `key` starting with `__fd`.   
# Note that all of the lines are already sorted by the `key` field.
# This script should extract the `key` string, split by slashes ("/"),
# and count the number of entries for each directory, excluding the last entry.
# For example, from the above data, it should output:
#   __fd_object_owners/zdcyc/table-by-id/: 10
#   __fd_object_owners/zdcyc/: 10
#   __fd_object_owners/: 10

