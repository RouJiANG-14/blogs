# 保序查询

## 背景

记录一下保证顺序的查询小技巧

## 实现

我从一个数据库表中查询出一个通过orderby的id list， 然后通过找个id list去另一张表中去查询数据， 查出来的数据顺序要和id list的顺序一样。

```Java
List<String> ids = childRepo.findParentIdByIdsInOrderByUpdatedTime(childIds);
List<Parent> parents = parentRepo.findByIdsIn(ids);
Map<String, Parent> parentIdMap = parents.steam().collect(toMap(Parent::getId, Function.identity()));

// 保序
List<Parent> sortedParents = ids.stream().map(id -> parentMap.get(id)).collect(toList());

return sortedParents;

```
