Você pode importar dados de um arquivo

# CSV

```PGSQL
CREATE TABLE revenue (
  store VARCHAR,
  year INT,
  revenue INT,
  PRIMARY KEY (product, year)
);

COPY revenue FROM '~/Projects/datasets/revenue.csv' WITH HEADER CSV;
```

# JSON

From Aleksander Piotrowski*  
https://tech.ingrid.com/postgres-til-datatypes-array-json/  
Oct 8, 2021  
*Checkout the article to see other examples  

Initialize database data from JSON file
Using JSON as your initial data source for the table is more straight forward than you may think. All you have to do is listed below:

```PGSQL
BEGIN TRANSACTION;

-- create table for data
CREATE TABLE "recipes" (
  id          SERIAL PRIMARY KEY,
  name 	      TEXT NOT NULL,
  categories  INTEGER[],
  ingredients TEXT[]
)

-- create temporary table for storing json data
-- this table will be removed automatically on commit
CREATE TEMPORARY TABLE temp_import (doc JSON) ON COMMIT DROP;

-- copy file content to newly created table
COPY temp_import from 'server/migrations/recipes.json';

-- insert data from temporary table to real table
insert into "recipes" (id, name)
select p.*
from temp_import l
  cross join lateral json_populate_recordset(null::recipes, doc) as p;
--   cross join lateral json_populate_record(null::recipes, doc) as p;

COMMIT TRANSACTION;
```

A Json example
```JSON
[{"name": "quick recipe", "categories": [1,2,3], "ingredients": ["cornflakes", "milk"]},
{"name": "cool recipe", "categories": [1,2,3], "ingredients": ["bread", "butter"]},
{"name": "lavish meal", "categories": [1,2,3], "ingredients": ["meat", "veggies"]}]
```
