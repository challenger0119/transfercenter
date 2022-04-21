# Usage

1. 安装 `vapor`:  `brew install vapor`

2. 安装 `postgres`:`brew install postgresql`

3. 创建数据表

```sql
create table transfers (id uuid, type varchar(32), name varchar(64), content varchar(256), isimage boolean);
```

4. 执行启动命令

```shell
DATABASE_NAME=[默认生成的DB名] DATABASE_USERNAME=[登陆用户名] vapor run serve --env production --hostname 0.0.0.0
```

> psql -l 查询已有db名称；
