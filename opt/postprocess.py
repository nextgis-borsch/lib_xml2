from os.path import dirname, abspath
import subprocess

process = subprocess.Popen(['git', 'apply', './opt/ignore_crlf.patch'], cwd = dirname(dirname(abspath(__file__))))