#!/usr/bin/env python
import re
import os
import sys


def ssi(path):
    def get_include_file_content(x):
        indent = x.group(1)
        path = os.path.join("src", "include", x.group(3))
        with open(path) as f:
            text = f.read()

        text = text.strip().split(os.linesep)
        text[0] = indent + text[0]
        return (os.linesep + indent).join(text)

    with open(path) as f: content = f.read()
    return re.sub(r'( *)<!-- *#include *(virtual|file)=[\'"]([^\'"]+)[\'"] *-->',
      get_include_file_content, content)


if __name__ == "__main__":
    dirname = "site"
    for path in sys.argv[1:]:
        basename = os.path.basename(path)
        with open(os.path.join(dirname, basename), "w") as f:
            f.write(ssi(path))
