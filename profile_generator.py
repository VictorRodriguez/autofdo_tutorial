import argparse
import os
import sys
import subprocess
import logging
import pdb

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

VERSION="0.1"
DEFAULT_LOGGING_LEVEL=logging.INFO

def get_autofdo_path():
    p = subprocess.Popen("./install_autofdo.sh", stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if p.returncode:
        logger.debug(out)
        logger.error(err)
        logger.error("AutoFDO compilation error")
        sys.exit(1)
    return out.split()[-1]

def parse_binaries(perf_file):
    binaries = []
    exist = False
    if not os.path.exists(perf_file) or not os.path.isfile(perf_file):
        logger.error("Perf data file wasn't found")
        sys.exit(1)
    p = subprocess.Popen(["perf", "report", "-i", perf_file, "--sort=dso"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    binaries = [y.split()[1] for y in [x.strip() for x in out.split("\n") if x and not x.startswith("#")]]
    return binaries

def generate_gcov(autofdo_path, binaries):
    gcov = ""
    return gcov

def upload_gcov(gcov):
    pass

if __name__ == "__main__":	
    parser = argparse.ArgumentParser(prog='./profile_generator.py',
                                     usage='%(prog)s [options]')
    parser.add_argument("perf_file", nargs=1,
                        help="Perf data file")
    parser.add_argument('-l', '--verbosity_level', dest='verbosity_level',
                        action='store', default=logging.getLevelName(DEFAULT_LOGGING_LEVEL),
                        choices=[logging.getLevelName(logging.DEBUG),
                                 logging.getLevelName(logging.INFO),
                                 logging.getLevelName(logging.ERROR)],
                        help='Set the verbosity level (default = {default})'.format(default=logging.getLevelName(DEFAULT_LOGGING_LEVEL)))
    parser.add_argument('-v', '--version', action='version',
                        version='%(prog)s Version: {version}'.format(version=VERSION),
                        help='Show version and exit')
    args = parser.parse_args()
    autofdo_path = get_autofdo_path()
    binaries = parse_binaries(args.perf_file[0])
    gcov = generate_gcov(autofdo_path, binaries)
    upload_gcov(gcov)
