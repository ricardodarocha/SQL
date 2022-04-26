Você pode importar dados de um arquivo

```PGSQL
CREATE TABLE revenue (
  store VARCHAR,
  year INT,
  revenue INT,
  PRIMARY KEY (product, year)
);

COPY revenue FROM '~/Projects/datasets/revenue.csv' WITH HEADER CSV;
```

