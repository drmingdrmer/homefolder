#!/usr/bin/env python
# coding: utf-8

# A script dump qps for the log in following format:
# ```
# f76539b2-4af5-4f12-95fc-e4aab6cda955 2025-03-15T20:00:00.020447+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 17.39µs, busy: 17.24µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: ListKV(ListKVReq { prefix: "__fd_settings/zdcyc/" }) }
# f76539b2-4af5-4f12-95fc-e4aab6cda955 2025-03-15T20:00:00.021413+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 45.44µs, busy: 45.28µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: ["__fd_users/zdcyc/%27convergence_syy%27%40%27%25%27"] }) }
# f76539b2-4af5-4f12-95fc-e4aab6cda955 2025-03-15T20:00:00.023436+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 31.43µs, busy: 31.32µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: ListKV(ListKVReq { prefix: "__fd_clusters_v6/zdcyc/online_clusters/w2/w2/" }) }
# 1c43af30-4091-4031-803c-9bf6c49e4886 2025-03-15T20:00:00.024053+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 35.011µs, busy: 34.861µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: ["__fd_virtual_column/zdcyc/170239627"] }) }
# f76539b2-4af5-4f12-95fc-e4aab6cda955 2025-03-15T20:00:00.026375+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 36.64µs, busy: 36.43µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: ["__fd_database/zdcyc/convergence_trajectory"] }) }
# f76539b2-4af5-4f12-95fc-e4aab6cda955 2025-03-15T20:00:00.027206+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 45.471µs, busy: 45.301µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: ["__fd_database_by_id/23156381"] }) }
# 9c4e39da-e1f4-4202-842f-7bab6994dfe2 2025-03-15T20:00:00.027642+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 26.16µs, busy: 26.01µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: ["__fd_virtual_column/zdcyc/276669750"] }) }
# 9c4e39da-e1f4-4202-842f-7bab6994dfe2 2025-03-15T20:00:00.030218+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 21µs, busy: 20.85µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: ListKV(ListKVReq { prefix: "__fd_index/zdcyc/" }) }
# 9c4e39da-e1f4-4202-842f-7bab6994dfe2 2025-03-15T20:00:00.030708+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 6.22µs, busy: 6.07µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: [] }) }
# 9c4e39da-e1f4-4202-842f-7bab6994dfe2 2025-03-15T20:00:00.035306+08:00  INFO databend_common_base::future: future.rs:140 Elapsed: total: 25.41µs, busy: 25.29µs; ReadRequest: ForwardRequest { forward_to_leader: 1, body: MGetKV(MGetKVReq { keys: ["__fd_database/zdcyc/hj3500000000000058_default"] }) }
# ```

import re
import sys
import os
import argparse
import tarfile
import tempfile
import io
from collections import defaultdict
from datetime import datetime, timedelta
from typing import Optional, Tuple, Iterator, Dict, List, Any, Generator

def parse_log_line(line: str) -> Optional[Tuple[datetime, str, float]]:
    """解析单行日志，提取时间、请求类型和耗时"""
    timestamp_match = re.search(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})', line)
    if not timestamp_match:
        return None
    
    timestamp_str = timestamp_match.group(1)
    timestamp = datetime.strptime(timestamp_str, '%Y-%m-%dT%H:%M:%S')
    
    total_match = re.search(r'total: ([\d.]+)([µm]?)s', line)
    if not total_match:
        return None
    
    total_time = float(total_match.group(1))
    unit = total_match.group(2)
    if unit == 'µ':
        total_time *= 1e-6
    elif unit == 'm':
        total_time *= 1e-3
    
    semicolon_match = re.search(r';([^:]+):', line)
    if semicolon_match:
        request_type = semicolon_match.group(1).strip()
    else:
        request_type = "Unknown"
    
    return timestamp, request_type, total_time

def read_tar_gz_lines(tar_gz_path: str) -> Generator[str, None, None]:
    """打开tar.gz文件并返回一个生成器，每次生成一行日志内容"""
    with tarfile.open(tar_gz_path, 'r:gz') as tar:
        for member in tar:
            if not member.isfile():
                continue
                
            f = tar.extractfile(member)
            if f is None:
                print(f"错误: 无法提取文件 {member.name}", file=sys.stderr)
                sys.exit(1)
                
            for line in f:
                try:
                    line_str = line.decode('utf-8')
                    yield line_str
                except UnicodeDecodeError:
                    print(f"错误: 无法解码文件 {member.name} 中的内容", file=sys.stderr)
                    sys.exit(1)

def read_file_lines(file_path: str) -> Generator[str, None, None]:
    """读取普通文件并返回一个生成器，每次生成一行内容"""
    try:
        with open(file_path, 'r') as f:
            for line in f:
                yield line
    except IOError as e:
        print(f"错误: 无法读取文件 '{file_path}': {e}", file=sys.stderr)
        sys.exit(1)

def analyze_logs(log_lines: Iterator[str]) -> None:
    """流式分析日志，按分钟统计各类请求的QPS，假定日志时间戳递增"""
    current_minute_counts: Dict[str, int] = defaultdict(int)
    current_minute_times: Dict[str, List[float]] = defaultdict(list)
    
    print(f"{'时间':<20}{'请求类型':<20}{'QPS':>10}{'平均耗时(ms)':>15}")
    print("-" * 65)
    
    current_minute: Optional[str] = None
    
    for line in log_lines:
        if 'Elapsed:' not in line:
            continue
            
        parsed_data = parse_log_line(line)
        if not parsed_data:
            continue
            
        timestamp, request_type, total_time = parsed_data
        
        minute_key = timestamp.strftime('%Y-%m-%d %H:%M')
        
        if current_minute is not None and minute_key != current_minute:
            for req_type, count in sorted(current_minute_counts.items()):
                qps = count / 60.0  # 每分钟的请求除以60秒
                
                avg_time = sum(current_minute_times[req_type]) / count * 1000
                
                print(f"{current_minute:<20}{req_type:<20}{qps:>10.2f}{avg_time:>15.2f}")
            
            current_minute_counts = defaultdict(int)
            current_minute_times = defaultdict(list)
        
        current_minute = minute_key
        
        current_minute_counts[request_type] += 1
        
        current_minute_times[request_type].append(total_time)
    
    if current_minute is not None:
        for req_type, count in sorted(current_minute_counts.items()):
            qps = count / 60.0  # 每分钟的请求除以60秒
            
            avg_time = sum(current_minute_times[req_type]) / count * 1000
            
            print(f"{current_minute:<20}{req_type:<20}{qps:>10.2f}{avg_time:>15.2f}")

def main() -> None:
    """主函数"""
    parser = argparse.ArgumentParser(
        description='分析Databend元数据日志文件并计算每分钟的请求QPS和平均响应时间，'
                    '支持普通日志文件和tar.gz压缩文件')
    parser.add_argument('log_file', nargs='?', 
                        help='输入日志文件路径，支持普通文本文件或.tar.gz压缩文件，'
                             '不提供则从标准输入读取')
    args = parser.parse_args()
    
    if args.log_file:
        if not os.path.exists(args.log_file):
            print(f"错误: 找不到文件 '{args.log_file}'", file=sys.stderr)
            sys.exit(1)
            
        if args.log_file.endswith('.tar.gz'):
            print(f"正在流式处理压缩文件: {args.log_file}", file=sys.stderr)
            log_lines = read_tar_gz_lines(args.log_file)
            analyze_logs(log_lines)
        else:
            log_lines = read_file_lines(args.log_file)
            analyze_logs(log_lines)
    else:
        log_lines = (line for line in sys.stdin)
        analyze_logs(log_lines)

if __name__ == "__main__":
    main()
