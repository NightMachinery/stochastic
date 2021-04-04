#!/usr/bin/env python3

## @docs
# https://github.com/lark-parser/lark/blob/master/docs/_static/lark_cheatsheet.pdf
# https://lark-parser.readthedocs.io/en/latest/classes.html
##
from lark import Lark, Transformer, v_args
from icecream import ic

calc_grammar = """
    ?start: output
    | name

    mode : "m" "ode"? "=" NUMBER
    max : "max" "=" NUMBER
    ?option: mode | max
    ?output_option : option
    req_num : NUMBER?
    output.2 : "."? "o"i "ut"i? (req_num) output_option*

    name.1 : /.+/

    %import common.CNAME
    %import common.NUMBER
    %import common.SIGNED_NUMBER -> SNUM
    %import common.WS_INLINE
    %ignore WS_INLINE
"""

calc_parser = Lark(calc_grammar, parser='earley')
calc = calc_parser.parse

def extract(tree, terminal, default=None):
    try:
        # Tokens are inherited from strings
        return list(tree.find_data(terminal))[0].children[0]
    except:
        return default

def main():
    while True:
        try:
            s = input('> ')
        except EOFError:
            break
        print(calc(s).pretty())


def test():
    global t1
    t1 = ic(calc("O134 max=9.12 m=9"))
    assert ic(t1.data) == 'output'
    assert ic(extract(t1, 'req_num')) == '134'
    assert ic(extract(t1, 'req_num').type) == 'NUMBER'
    assert ic(extract(t1, 'max')) == '9.12'
    assert ic(extract(t1, 'mode')) == '9'

    ic(calc("OUT 7."))


if __name__ == '__main__':
    from IPython import embed
    embed()
    # test()
    # main()
