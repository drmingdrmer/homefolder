class ConversionError(Exception):
    """
    Exception raised for errors in the video conversion process.
    
    Attributes:
        message -- explanation of the error
        exit_code -- the exit code to use (default 1)
    """
    
    def __init__(self, message, exit_code=1):
        self.message = message
        self.exit_code = exit_code
        super().__init__(self.message) 