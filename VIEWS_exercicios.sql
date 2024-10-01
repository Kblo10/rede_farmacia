-- Primeira Forma Normal (1FN): A primeira forma normal visa eliminar atributos multivalorados e atributos compostos.
-- Segunda Forma Normal (2FN): Uma tabela encontra-se na segunda forma normal se ela atende todos os requisitos da primeira forma normal e se os registros na tabela, que não são chaves, dependam da chave primária em sua totalidade e não apenas parte dela.
-- Terceira Forma Normal (3FN): Se uma tabela está na primeira e segunda forma normal, mas ao analisarmos um registro encontramos um atributo não chave dependente de outro atributo não chave, precisaremos corrigir a tabela para a terceira forma normal. Aqui basicamente corrigiremos a dependência funcional transitiva.


USE farmacia1;

CREATE VIEW produtos_premium AS 
SELECT nome, valor
FROM produtos
WHERE valor > 50;

SELECT * FROM produtos_premium;

ALTER VIEW produtos_premium AS 
SELECT nome, valor, fabricantes_id
FROM produtos
WHERE valor > 50;

-- ----------------------------------------------------------------------------------- -- ---------- -- --------- -- ------------- -- ------------- -- -------------- -- ---------------- -- --------
-- ------------------ ATIVIDADES -------------------- --
-- 1 View para listar clientes e seus endereços
CREATE VIEW clientes_enderecos AS
SELECT clientes.nome, endereco, bairro, numero FROM enderecos
JOIN clientes ON clientes.endereco_id = enderecos.id;

SELECT * FROM clientes_enderecos;

-- 2 View para listar médicos e suas receitas
CREATE VIEW VIEWmedico_receita AS
SELECT medicos.nome, medicos.crm, receita FROM  receita_medica
JOIN medicos ON medicos.id = receita_medica.medicos_id;

SELECT * FROM VIEWmedico_receita;

-- 3 View para calcular o total de vendas por cliente
CREATE VIEW view_total_vendas_clientes AS
SELECT clientes.nome, COUNT(compras.id) AS vendas FROM clientes
JOIN compras ON clientes.id = compras.clientes_id
GROUP BY clientes.nome;

DROP VIEW view_total_vendas_clientes;
SELECT * FROM view_total_vendas_clientes;

-- 4 View para listar produtos e seus fabricantes
CREATE VIEW view_produtos_fabricantes AS 
SELECT produtos.nome, produtos.descricao, fabricantes.nome AS fabricante FROM fabricantes
JOIN produtos ON produtos.fabricantes_id = fabricantes.id;

SELECT * FROM view_produtos_fabricantes;

-- 5 View para listar o total de produtos vendidos.
CREATE VIEW view_total_produtos_vendidos AS
SELECT produtos.nome, COUNT(produtos_compras.quantidade) FROM produtos
JOIN produtos_compras ON produtos_compras.produtos_id = produtos.id
GROUP BY produtos.nome;

SELECT * FROM view_total_produtos_vendidos ;


-- 6 View para listar os clientes e suas compras. 
CREATE VIEW view_clientes_compras AS
SELECT clientes.id, clientes.nome AS Nome_cliente, COUNT(compras.id) AS Total_compras FROM clientes
JOIN compras ON clientes.id = compras.clientes_id
GROUP BY clientes.nome, clientes.id;

DROP VIEW view_clientes_compras;

SELECT * FROM view_clientes_compras;

-- 7 View para calcular a média de produtos por compra
CREATE VIEW media_produtos AS
SELECT AVG(quantidade) AS Media_Produtos
FROM produtos_compras;

SELECT * FROM media_produtos;


-- 8 View para listar médicos e o número de receitas
CREATE VIEW view_medicos_total_receitas AS
SELECT medicos.nome, COUNT(receita_medica.id) FROM receita_medica
JOIN medicos ON medicos.id = receita_medica.medicos_id
GROUP BY medicos.nome;

SELECT * FROM view_medicos_total_receitas;

-- 9 View para listar compras e produtos associados
CREATE VIEW view_compras_produtos AS 
SELECT compras.id, compras.data_compra, produtos.nome FROM compras
JOIN produtos_compras ON compras.id = produtos_compras.compras_id
JOIN produtos ON produtos.id = produtos_compras.produtos_id;

SELECT * FROM view_compras_produtos;

-- 10 View para listar os clientes  co mais de uma compra 
CREATE VIEW clientes_com_mais_1_compra AS
SELECT nome, COUNT(compras.clientes_id) FROM clientes 
JOIN compras ON compras.clientes_id = clientes.id
GROUP BY nome
HAVING COUNT(compras.id) > 1;

SELECT * FROM clientes_com_mais_1_compra;