/*
Banco de Dados do curso de SQL
VendasCrm.DB
*/

CREATE DATABASE VendasCrm;

create table Cidade (
	Id SERIAL primary key,
	Nome VARCHAR,
	Uf VARCHAR);
  
  INSERT INTO CIDADE (Id, Nome, Uf)
  VALUES (1, 'BELO HORIZONTE', 'MG')
        ,(2, 'CHAPECO','SC')
        ,(3, 'FLORIANOPOLIS', 'SC')
        ,(4, 'GRAMADO', 'RS')
        ,(5, 'JUIZ DE FORA', 'MG')
        ,(6, 'RIO NOVO', 'MG')
        ,(7, 'RIO DE JANEIRO', 'RJ')
        ,(8, 'SANTOS', 'SP')
        ,(9, 'PETROPOLIS', 'RJ')
  ;

create table Cliente (
Id SERIAL primary key,
Nome VARCHAR,
Cidade int4 ,
FOREIGN KEY (Cidade) REFERENCES Cidade(ID) );

create table Status (
ID SERIAL primary key, --	Auto-generated primary key.
Nome VARCHAR );--	Short Nome of the status (e.g., new, processed).

create table Venda	(
Id SERIAL primary key, 
Cliente int4,
Data Timestamp,
Conclusao Timestamp,
Status Int4, 
foreign key (cliente) references Cliente(ID),
FOREIGN KEY (Status) REFERENCES Status(ID) );

create table Pagamento (
Venda int4,
Nome VARCHAR, 
Vencimento DATE,
Pagamento DATE,
Valor Numeric(15,2),
Pago Numeric(15,2) ,
FOREIGN KEY (venda) REFERENCES Venda(ID));

create table Categoria ( 
ID SERIAL primary key, --	Auto-generated primary key.
Nome VARCHAR ,--	Nome of the category, e.g., toys, LEGO, etc.
Grupo int4 ,
foreign key (grupo) references Categoria(ID));--	Foreign key indicating the parent category; null if this is a top-level category.

create table Imposto (
Id VARCHAR NOT NULL PRIMARY KEY,
Taxa NUMERIC(15,2) );

create table Produto (
ID SERIAL primary key, --	Auto-generated primary key.
Nome VARCHAR, --		Product Nome.
Preco	NUMERIC(15,2), -- Product price without tax.
Quantidade NUMERIC(15,2), --	Amount of this product in stock.
Imposto VARCHAR,  --	Foreign key to the VAT table.
Categoria int4, --	Foreign key to the category table. 
Descricao varchar,
FOREIGN KEY (Imposto) references Imposto(ID),
FOREIGN KEY (categoria) references Categoria(ID) ) ;

create table Item	(
ID SERIAL primary key, --	Auto-generated primary key.
Venda int4 ,
Produto int4 ,
Quantidade NUMERIC(15,2), 
Preco NUMERIC(15,2) ,
FOREIGN KEY (venda) REFERENCES Venda(ID), 
FOREIGN KEY (produto) REFERENCES Produto(ID) );
