import os

# 导入自己包内的模块
from videoconv.ffmpeg_params import FFmpegParams

def get_output_name(params: FFmpegParams, default_output_dir: str, input_file: str, output_arg: str = None):
    input_fn = input_file

    # get the part since "./", if not found, use the whole input_fn
    if input_file.find("./") != -1:
        input_fn = input_file[input_file.find("./") + 2:]

    # strip the extension
    input_name_without_ext = os.path.splitext(input_fn)[0]

    output_name = None

    if output_arg is None:
        os.makedirs(default_output_dir, exist_ok=True)
        output_name = os.path.join(default_output_dir, input_fn)
    elif '*' in output_arg:
        output_name = output_arg.replace('*', input_name_without_ext)
    elif output_arg.endswith('/'):
        os.makedirs(output_arg, exist_ok=True)
        output_name = os.path.join(output_arg, input_fn)
    else:
        return output_arg

    output_name_without_ext, ext = os.path.splitext(output_name)
    output_name = f"{output_name_without_ext}-{params.video_width}x-{params.video_bitrate}"
    
    if params.start_time is not None or params.end_time is not None:
        time_info = ""
        if params.start_time is not None:
            time_info += f"-from_{params.start_time.replace(':', '_')}"
        if params.end_time is not None:
            time_info += f"-to_{params.end_time.replace(':', '_')}"
        output_name += time_info
    
    output_name += ext

    return output_name 