def reconstruct_path(child, tree):
    result = [child]
    while True:
        parent = tree[child]
        if not parent:
            return result
        result.insert(0, parent)
        child = parent

def find_path(target, production_rules):
    starts = production_rules["start"]
    # BFS
    queue = [s for s in starts]
    tree = {s:None for s in starts}
    while True:
        print
        if not queue:
            raise Exception(f"No path to '{target}' found")
        node = queue.pop(0)
        if node == target:
            break
        for child in production_rules[node]:
            queue.append(child)
            tree[child] = node
    return reconstruct_path(node, tree)

