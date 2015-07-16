#!/usr/bin/python

# Copyright (c) <year> Intel Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at//
#   http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import os
import sys
import shutil
import subprocess
import time
import logging
import pdb

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

VERSION="0.1"
DEFAULT_LOGGING_LEVEL=logging.INFO

def get_autofdo_path():
    logger.info("Verifying AutoFDO path")
    p = subprocess.Popen(os.path.join(os.path.dirname(os.path.realpath(__file__)), "install_autofdo.sh"), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if p.returncode:
        logger.debug(out)
        logger.error(err)
        logger.error("AutoFDO compilation error")
        sys.exit(1)
    return out.split()[-1]

def parse_binaries(perf_file):
    logger.info("Parsing perf file")
    binaries = []
    exist = False
    if not os.path.exists(perf_file) or not os.path.isfile(perf_file):
        logger.error("Perf data file wasn't found")
        sys.exit(1)
    cmd = ["perf", "buildid-list", "-i", perf_file, "-H"]
    logger.debug("Executing command: "+" ".join(cmd))
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if not p.returncode:
        logger.debug("Success")
        binaries = [line.strip().split()[1] for line in out.split("\n") if line]
    logger.debug(out)
    logger.debug(err)
    binaries = [line.strip().split()[1] for line in out.split("\n") if line]
    return binaries

def generate_gcov(autofdo_path, perf_file, binaries, automerge=False):
    if not binaries:
        logger.error("No binaries found in "+perf_file)
        sys.exit(1)
    directory = perf_file[:-5] if perf_file.endswith(".data") else perf_file
    directory += "_gcovs"
    if os.path.exists(directory) and os.path.isdir(directory):
        shutil.rmtree(directory)
    os.mkdir(directory)
    logger.info("Generating gcovs")
    gcovs = []
    for binary in binaries:
        if not binary.startswith("["):
            gcov_file = os.path.join(directory, binary.split("/")[-1]+".afdo")
            cmd = [os.path.join(autofdo_path, "create_gcov"), "--binary="+binary, "--profile="+perf_file, "--gcov="+gcov_file, "-gcov_version=1"]
            logger.debug("Executing command "+" ".join(cmd))
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = p.communicate()
            if not p.returncode:
                logger.debug("Successful")
                gcovs.append(gcov_file)
            logger.debug(out)
            logger.debug(err)
    if automerge:
        main_gcov = merge_gcovs(autofdo_path, gcovs) if len(gcovs) > 1 else gcovs[0]
        while not os.path.exists(main_gcov):
            time.sleep(1)
        new_gcov = perf_file.split(".data")[0]+".afdo"
        shutil.copy2(main_gcov, new_gcov)

def merge_gcovs(autofdo_path, gcovs):
    logger.info("Waiting gcov creation")
    while not all([os.path.exists(f) for f in gcovs]):
        time.sleep(1)
    logger.info("Merging gcovs")
    p = subprocess.Popen([os.path.join(autofdo_path, "profile_merger")] + gcovs + ["-gcov_version=1"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return "fbdata.afdo" if not p.returncode else ""


if __name__ == "__main__":	
    parser = argparse.ArgumentParser(prog='./profile_generator.py',
                                     usage='%(prog)s [options]')
    parser.add_argument("perf_files", nargs="+",
                        help="Perf data files")
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
    ch = logging.StreamHandler()    
    if args.verbosity_level == logging.getLevelName(logging.DEBUG):
        ch.setLevel(logging.DEBUG)
    elif args.verbosity_level == logging.getLevelName(logging.INFO):
        ch.setLevel(logging.INFO)
    elif args.verbosity_level == logging.getLevelName(logging.ERROR):
        ch.setLevel(logging.ERROR)
    else:
        logger.error("Unrecognized logging level")
    logger.addHandler(ch)
    autofdo_path = get_autofdo_path()
    for perf_file in args.perf_files:
        binaries = parse_binaries(perf_file)
        gcov = generate_gcov(autofdo_path, perf_file, binaries, automerge=True)
