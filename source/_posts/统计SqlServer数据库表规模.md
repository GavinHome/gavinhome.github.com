---
title: 统计SqlServer数据库表规模

tags:
- SqlServer

categories:
- SqlServer

date: 2018-09-28
cover: /img/cover/chris-yates-unsplash.jpg
author: 
  nick: gavinhome
  link: https://www.github.com/gavinhome
subtitle: 统计数据库中所有表的数据规模
---

统计数据库中所有表的数据规模：

``` SQL
select* from (select schema_name(t.schema_id) as [Schema], t.name as TableName,i.rows as [RowCount] 
from sys.tables as t, sysindexes as i 
where t.object_id = i.id and i.indid <=1) a

order by a.[RowCount] DESC

```