USE farmacia1;

SELECT * FROM compras; -- 1000
SELECT * FROM receita_medica; -- 1000
SELECT * FROM medicos; -- 100
SELECT * FROM produtos_compras;

-- 1. Qual é o nome do fabricante com o ID 5?
SELECT nome FROM fabricantes
	WHERE id = 5;

-- 2. Qual é o nome e a data de criação da compra com o ID 10?
select * from compras where id = 10;

SELECT clientes.nome FROM clientes
	INNER JOIN compras ON compras.clientes_id = clientes.id
	WHERE clientes.id = (select compras.id from compras where id = 10);
    
SELECT * FROM clientes ;
    
-- 3. Traga todos os produtos cadastrados neste mês.
SELECT * FROM produtos;

-- 4. Quantos produtos foram comprados na compra com o ID 15?

SELECT SUM(quantidade) AS Total_Compra_15 FROM produtos_compras
	WHERE id = 15;

    
SELECT * FROM produtos;

-- 5. De quem é a compra do ID 15?
SELECT nome, clientes_id FROM compras
	JOIN clientes ON compras.clientes_id = clientes.id
    WHERE compras.id = 15;
    
    
SELECT clientes.nome FROM clientes 
	WHERE clientes.id = 1055;

-- 6. Quais clientes estão associados ao endereço ‘Vila Prudente, 31 ?
SELECT clientes.nome, endereco, numero, bairro FROM enderecos
	JOIN clientes ON enderecos.id = clientes.endereco_id
	WHERE enderecos.bairro = 'Vila Prudente' AND enderecos.numero = 31
    ;

select * from clientes;
select * from enderecos where numero = 32;
	
SELECT * FROM enderecos;
-- 7. Quais clientes compraram vitamina C?
select produtos.nome from produtos;
select * from clientes;
select * from produtos_compras;

SELECT clientes.nome, produtos.nome FROM clientes
	JOIN compras ON clientes.id = compras.clientes_id
    JOIN produtos_compras ON compras.id = produtos_compras.compras_id
    JOIN produtos ON produtos_compras.produtos_id = produtos.id
		AND produtos.nome = 'Vitamina C';
	


-- 8. Qual cliente comprou mais produtos?
SELECT clientes.nome, SUM(produtos_compras.quantidade) AS total FROM clientes
INNER JOIN compras ON clientes.id = compras.clientes_id
INNER JOIN produtos_compras ON compras.id = produtos_compras.compras_id
	GROUP BY clientes.id
    ORDER BY total DESC LIMIT 1;
    
select * from produtos_compras;

-- 9. Qual é o valor total gasto pelo cliente que mais comprou?
SELECT clientes.nome, SUM(produtos.valor * produtos_compras.quantidade) AS total_gasto FROM clientes
		INNER JOIN compras ON clientes.id = compras.clientes_id
        INNER JOIN produtos_compras ON compras.id = produtos_compras.compras_id
        INNER JOIN produtos ON produtos_compras.produtos_id = produtos.id
			GROUP BY clientes.id ORDER BY total_gasto DESC LIMIT 1;
    
-- 10. Liste todos os médicos que emitiram receitas neste mês.

SELECT DISTINCT medicos.nome FROM medicos 
INNER JOIN receita_medica ON medicos.id = receita_medica.medicos_id 
WHERE MONTH(receita_medica.data_criacao) = MONTH(CURRENT_DATE());
