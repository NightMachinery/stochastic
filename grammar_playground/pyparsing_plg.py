#!/usr/bin/env python3

import pyparsing as pp

habit_pat = pp.Regex(
    r"^(?:\.\.?)?habit\s*"
    + r"(?P<t>\d*\.?\d*)?\s*"
    + r"(?:m=(?P<mode>\d+)\s*)?"
    + r"(?:max=(?P<max>\d+\.?\d*)\s*)?"
    + r"(?:cs1=(?P<cs1>\S+)\s*)?"
    + r"(?:cs2=(?P<cs2>\S+)\s*)?"
    + r"(?P<name>.+)$"
)

m = habit_pat.parseString(".habit cs1=HElo max=8.1 wow")
print(dict(m))
