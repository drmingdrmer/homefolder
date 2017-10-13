
# filename  Specifies that a FileHandler be created, using the specified
#           filename, rather than a StreamHandler.
# filemode  Specifies the mode to open the file, if filename is specified
#           (if filemode is unspecified, it defaults to 'a').
# format    Use the specified format string for the handler.
# datefmt   Use the specified date/time format.
# level     Set the root logger level to the specified level.
# stream    Use the specified stream to initialize the StreamHandler. Note
#           that this argument is incompatible with 'filename' - if both
#           are present, 'stream' is ignored.

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG, format='[%(asctime)s,%(process)d-%(thread)d,%(filename)s,%(lineno)d,%(levelname)s] %(message)s')
