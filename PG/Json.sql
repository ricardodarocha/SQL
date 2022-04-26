DROP TABLE IF EXISTS cliente_test CASCADE;
CREATE TABLE cliente_test (
    id SERIAL PRIMARY KEY,
    nome VARCHAR,
    endereco JSON
);

DROP TABLE IF EXISTS pedido_test CASCADE;
CREATE TABLE pedido_test (
    id SERIAL PRIMARY KEY,
    cliente INT REFERENCES cliente_test(id),
    data DATE NOT NULL DEFAULT CURRENT_DATE,
    itens JSONB
);

INSERT INTO cliente_test (nome, endereco) VALUES 
    ('Amazon.com, Inc', '{"address":"410 Terry Ave N", "ciy":"Seattle", "PostalCode":98109, "state":"Washington", "country":"United States"}'),
    ('Samsung Electronics', '{"address":"Samsung-ro 129, Yeongtong-gu", "ciy":"Suwon-si", "state":"Gyeonggi-do", "country":"Soulth Corea", "telefone":"031-200-3113"}'),
    ('Broadcom Corporation Jobs', '{"address":"1320 Ridder Park Drive", "ciy":"San Jose", "state":"California", "country":"United States", "telefone":"1-408-433-8000"}'),
    ('Nvidia Corporation', '{"address":"2701 San Tomas Expressway", "ciy":"Santa Clara", "state":"California", "country":"United States", "telefone": "1+ (408) 486-2000"}');

INSERT INTO pedido_test (cliente, itens) VALUES
    (2, '[{"ref":"1a272fde","sequence":1,"cost":  600.00, "qt": 3, "total": 1800.00},
          {"ref":"331ce9ff","sequence":2,"cost":  190.00, "qt": 1, "total": 190},
          {"ref":"82c22c26","sequence":3,"cost": 5714.20, "qt": 2, "discount": 540.00, "total" : 602.84}]');

SELECT * FROM cliente_test INNER JOIN pedido_test ON cliente_test.id = pedido_test.cliente
