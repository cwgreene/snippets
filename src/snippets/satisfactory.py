from collections import namedtuple
from enum import Enum
from typing import Dict, List, NamedTuple, TypeAlias


class ProductName(str, Enum):
    IRON_ORE = "Iron Ore"
    IRON_INGOT = "Iron Ingot"
    IRON_PLATE = "Iron Plate"
    IRON_ROD = "Iron Rod"

class Product(NamedTuple):
    Name : ProductName
    Cost: int
    Time : int
    Output : int

ProductionRules = Dict[Product,List[Product]]

starts = [ProductName.IRON_ORE]
satisfactory_rules : ProductionRules = {
    ProductName.IRON_ORE:  [
        Product(Name=ProductName.IRON_INGOT,
                Cost=1,
                Time=2,
                Output=1)
    ],
    ProductName.IRON_INGOT: [
        Product(
            Name=ProductName.IRON_PLATE,
            Cost=3,
            Time=12,
            Output=2
        ),
        Product(
            Name=ProductName.IRON_ROD,
            Cost=1,
            Time=2,
            Output=1
        )
    ],
    ProductName.IRON_PLATE: [],
    ProductName.IRON_ROD: []
}

def reconstruct_path(child : ProductName, tree) -> List[ProductName]:
    result = [child]
    while True:
        parent = tree[child]
        if not parent:
            return result
        result.insert(0, parent)
        child = parent

def find_path(target : ProductName, production_rules : ProductionRules, starts: ProductName) -> List[ProductName]:
    starts = starts
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
            queue.append(child.Name)
            tree[child.Name] = node
    return reconstruct_path(node, tree)

def compute_rate(target : ProductName, production_rules : ProductionRules):
    path = find_path(target, production_rules, starts)
    time = 0
    for this,next in zip(path[:-1], path[1:]):
        rules = production_rules[this]
        for rule in rules:
            if rule.Name == next:
                time *= rule.Cost # Need this many
                time += rule.Time
                time /= rule.Output # Get this many
    return 1/time

print(compute_rate(ProductName.IRON_ROD, satisfactory_rules))