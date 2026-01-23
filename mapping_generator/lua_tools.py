
import luaparser.ast
import luaparser.astnodes

def lua_to_dict(file: str) -> dict:
    with open(file, 'r', encoding='utf-8') as f:
        lua_string = f.read()
    tree = luaparser.ast.parse(lua_string)
    node = tree
    def to_kv_pair(field) -> tuple:
        key = field.key.s if isinstance(field.key, luaparser.astnodes.String) else field.key.n
        if isinstance(field.value, luaparser.astnodes.String):
            value = field.value.s
        elif isinstance(field.value, luaparser.astnodes.Number):
            value = field.value.n
        elif isinstance(field.value, luaparser.astnodes.Table):
            value = to_array(field.value.fields)
        else:
            value = field.value
        return key, value

    def to_array(node_list) -> list | dict:
        d = {}
        for n in node_list:
            key, value = to_kv_pair(n)
            d[key] = value
        if d.keys() == {i for i in range(1, len(d) + 1)}:
            return list(d.values())
        return d

    d = None
    while True:
        if isinstance(node, list) and len(node) == 1:
            node = node[0]
        elif isinstance(node, luaparser.astnodes.Block):
            node = node.body
        elif isinstance(node, luaparser.astnodes.Chunk):
            node = node.body
        elif isinstance(node, luaparser.astnodes.Return):
            node = node.values
        elif isinstance(node, luaparser.astnodes.Table):
            d = to_array(node.fields)
            break
        else:
            raise ValueError(f"Unexpected AST node type: {type(node)}")

    return d
