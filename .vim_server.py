from threading import Thread
import subprocess
import sys
import os
import re


fname, cwd = sys.argv[1], sys.argv[2]
pdfname = ".".join(fname.split(".")[:-1]) + ".pdf"


full       = re.compile(r"[Oo]verfull|[Uu]nderfull|[Bb]adbox")
definition = re.compile(r"[Uu]se of .* doesn't match its definition")
control    = re.compile(r"[Uu]ndefined control sequence")
error      = re.compile(r"tex:\d*:")
warnings   = re.compile(r"[Ww]arning")
errors     = re.compile(r"[Ee]rror")
catch      = re.compile(r"^!")


# Perform the LaTeX compilation here (subprocess call, etc.)
output = subprocess.run(["latexmk", "-pdf", "-logfilewarninglist", fname], 
        capture_output = True)


def parse(output):
    stdout, log = output.stdout.decode().split("\n"), ["Latexmk Errors & Warnings\n"]
    warn = True
    for line in stdout:
        if error.search(line):
            path, no, msg = line.split(":")
            line = "[ERROR] @ line #" + no + ": " + msg + " @ " + path
            log.append(line)
    for line in stdout:
        if definition.search(line):
            log.append(line)
    for line in stdout:
        if control.search(line):
            log.append(line)
    for line in stdout:
        if errors.search(line):
            line = line.split("has")[0]
            line = line.lstrip(")")
            line = "".join(line.split(": ")[1:])
            log.append(line + "\n")
    for line in stdout:
        if catch.search(line):
            log.append(line)
    for line in stdout:
        if warnings.search(line):
            if warn: log.append("[WARNINGS]")
            warn = False
            line = line.split("has")[0]
            line = line.lstrip(")")
            log.append(line)
    for line in stdout:
        if full.search(line):
            log.append(line)
    log = "\n".join(log)
    return log


def t(): os.system(f"evince {pdfname}")

thread = Thread(target=t)
thread.daemon = True
thread.start()


exts = ('aux', 'fdb_latexmk', 'fls', 'out', 'log')
cmd  = f'find {cwd} -type f'
for ext in exts:
    cmd += f' -name "*.{ext}" -delete -o'


cmd = cmd[:-3]
os.system(cmd)


log = parse(output)
logname = ".".join(fname.split(".")[:-1]) + ".log"
with open(logname, "w") as fhand:
    fhand.write(log)
