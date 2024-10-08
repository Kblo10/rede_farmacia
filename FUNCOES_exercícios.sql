USE farmacia1;

SELECT * FROM receita_medica;

USE farmacia1;

DELIMITER //
CREATE FUNCTION calcular_idade(data_nascimento DATE) RETURNS INT 
DETERMINISTIC
BEGIN 
	DECLARE idade INT;
    SET idade = TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE());
    RETURN idade;
END //
DELIMITER ;


SELECT nome, calcular_idade(data_nascimento) AS idade FROM clientes
	WHERE data_nascimento < '2005-12-31';
    
SELECT nome, calcular_idade(data_nascimento) AS idade FROM clientes
	WHERE calcular_idade(data_nascimento) >= 18 ;
    
-- CRIE UMA FUNCAO PARA CONTAR OS ENDERECOS
select COUNT(endereco) from enderecos;

-- FUNCAO CONTANDO CADA ID 
DELIMITER //
CREATE FUNCTION contar_endereco(endereco VARCHAR(30)) RETURNS INT
DETERMINISTIC
	BEGIN
		DECLARE Total INT;
		SELECT COUNT(*) INTO Total FROM enderecos;
		RETURN Total;
	END //
DELIMITER ;

SELECT DISTINCT contar_endereco(endereco) AS total_enderecos FROM enderecos;

-- FUNCAO CONTADO TUDO SEM PRECISAR CONTAR CADA ID
DELIMITER //
CREATE FUNCTION contar_endereco1() RETURNS INT
DETERMINISTIC
	BEGIN
		DECLARE Total INT;
		SELECT COUNT(*) INTO Total FROM enderecos;
		RETURN Total;
	END //
DELIMITER ;

flush privileges;
SELECT contar_endereco1();

-- DROP FUNCTION contar_endereco;

-- -------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------


-- CRIE UMA FUNCAO QUE RETORNA A DATA DA ULTIMA COMPRA DE UM CLIENTE
SELECT compras.id, compras.data_compra FROM compras
	JOIN clientes ON clientes.id = compras.clientes_id
    WHERE compras.id = 1
    GROUP BY compras.id;
    
    
SELECT MAX(data_compra) FROM compras WHERE id = 1;
DELIMITER //
CREATE FUNCTION Ultima_Compra() RETURNS INT
DETERMINISTIC
	BEGIN
		DECLARE Total_ INT;
        SELECT MAX(data_compra) INTO Total_ FROM compras ;
        RETURN Total_;
	END //
DELIMITER ;
DROP FUNCTION Ultima_Compra;

SELECT Ultima_Compra() FROM compras;

-- 00 Criar um usuário com permissao somente a database farmacia
CREATE USER 'alanfarma'@'localhost' IDENTIFIED BY 'senac@123';

GRANT ALL PRIVILEGES ON * . * TO 'alanfarma'@'localhost';

FLUSH PRIVILEGES ;
select * from compras ;

-- ----------------------------------------------------------------------------------------------------------------
-- 1. Função para trazer as vendas dos últimos X dias
-- Crie uma função chamada `vendas_ultimos_dias` que receba como parâmetro o número de dias (x) e retorne o número total de vendas realizadas nos últimos X dias.
DELIMITER //
CREATE FUNCTION vendas_ultimos_dias(dia INT) RETURNS INT
DETERMINISTIC
	BEGIN
		DECLARE total_vendas INT;
        SELECT COUNT(*) INTO total_vendas FROM compras WHERE data_compra >= CURDATE() - INTERVAL dia DAY ;
        RETURN total_vendas;
	END //
DELIMITER ;

-- ----------TESTE------------ -- 
select vendas_ultimos_dias(10);

-- ----------------------------------------------------------------------------------------------------------
-- 2. Função para trazer o nome do médico a partir do CRM
-- Crie uma função chamada `nome_medico_por_crm` que receba como parâmetro o CRM e retorne o nome do médico correspondente.
DELIMITER //
CREATE FUNCTION nome_medico_por_crm(crm VARCHAR(15)) RETURNS VARCHAR(50)
DETERMINISTIC
	BEGIN
		DECLARE nome_medico VARCHAR(50);
        SELECT nome INTO nome_medico FROM medicos WHERE crm = crm LIMIT 1;
        RETURN nome_medico;
	END //
DELIMITER ;

-- TESTE --
SELECT nome_medico_por_crm('CRM10004');

-- ------------------------------------------------------------------------------------------------
-- 3. Função para calcular o total de produtos vendidos
-- Crie uma função chamada `total_produtos_vendidos` que retorne a soma total de produtos vendidos.
select sum(quantidade) from produtos_compras where id = 7;

DELIMITER //
CREATE FUNCTION total_produtos_vendidos(prod_vend INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE total_produtos INT;
    SELECT SUM(quantidade) INTO total_produtos FROM produtos_compras WHERE id = prod_vend;
    RETURN total_produtos;
END //
DELIMITER ;

-- TESTE 
SELECT total_produtos_vendidos(10) ;

-- ----------------------------------------------------------------------------
-- 4. Função para calcular a idade do cliente
-- Crie uma função chamada `calcular_idade_cliente` que receba como parâmetro a data de nascimento do cliente e retorne sua idade.
DELIMITER //
CREATE FUNCTION calcular_idade_cliente(idade_cli INT) RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE calc_idade INT;
	select TIMESTAMPDIFF(YEAR, clientes.data_nascimento, NOW()) into calc_idade from clientes WHERE id = idade_cli;
    RETURN calc_idade;
END //
DELIMITER ;

-- TESTE 
SELECT calcular_idade_cliente(3);

-- -------------------------------------------------------------------------------------------------------------
-- 5. Função para trazer o total de vendas por cliente
-- Crie uma função chamada `total_vendas_por_cliente` que receba como parâmetro o ID do cliente e retorne o total de vendas desse cliente.
select clientes.nome, count(compras.id) as total_vendas from compras
join clientes on compras.clientes_id = clientes.id
where clientes.nome = 'Tammy Corran';
select nome from clientes;
DELIMITER //
CREATE FUNCTION total_vendas_por_cliente(total_cli VARCHAR(100)) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE t_vendas_c VARCHAR(50);
    SELECT count(compras.id) INTO t_vendas_c from compras
		join clientes on compras.clientes_id = clientes.id
		where clientes.nome = total_cli ;
	RETURN t_vendas_c ;
END //
DELIMITER ;

-- TESTE 
SELECT total_vendas_por_cliente('Tammy Corran') AS total_de_vendas ;

-- ------------------------------------------------------------------------------------------------
-- 6. Função para contar o número de clientes
-- Crie uma função chamada `contar_clientes` que retorne o número total de clientes cadastrados no banco de dados.
select count(clientes.id) from clientes;

DELIMITER //
CREATE FUNCTION contar_clientes() RETURNS INT 
DETERMINISTIC
BEGIN 
	DECLARE contador_cli INT;
    SELECT COUNT(clientes.id) into contador_cli FROM clientes;
    RETURN contador_cli;
END //
DELIMITER ;

-- TESTE
SELECT contar_clientes();
    

-- 7. Função para calcular a média de produtos vendidos
-- Crie uma função chamada `media_produtos_por_compra` que retorne a média de produtos vendidos.
select avg(quantidade) AS média from produtos_compras
where id = 2;

DELIMITER //
CREATE FUNCTION media_produtos_por_compra(m_produtos_c VARCHAR(50)) RETURNS INT
DETERMINISTIC
BEGIN 
	DECLARE media_prod VARCHAR(50);
    select avg(quantidade) INTO media_prod from produtos_compras 
    join produtos on produtos.id =  produtos_compras.produtos_id where produtos.nome = m_produtos_c;
    RETURN media_prod;
END //
DELIMITER ;

drop function media_produtos_por_compra;
SELECT media_produtos_por_compra('Paracetamol') AS media;

select avg(quantidade) from produtos_compras where id = 1;
select * from produtos_compras;


-- 8. Função para trazer o nome do cliente a partir do ID
-- Crie uma função chamada `nome_cliente_por_id` que receba como parâmetro o ID do cliente e retorne o nome do cliente.
SELECT clientes.nome FROM clientes
WHERE id = 2;

DELIMITER //
CREATE FUNCTION nome_cliente_por_id(nome_cli INT) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN 
	DECLARE nome_id VARCHAR(50);
    SELECT clientes.nome INTO nome_id FROM clientes WHERE clientes.id = nome_cli ;
    RETURN nome_id;
END //
DELIMITER ;

drop function nome_cliente_por_id;
SELECT nome_cliente_por_id(1);


-- 9. Função para calcular o total de vendas por mês
-- Crie uma função chamada `total_vendas_por_mes` que retorne o número total de vendas realizadas no mês atual.


-- 10.    Função para calcular o número de compras em um determinado período
-- Crie uma função chamada compras_no_periodo que receba duas datas como parâmetros e retorne o número total de compras realizadas nesse período.
SELECT * FROM compras;
SELECT COUNT(*) FROM compras; 
SELECT COUNT(DATE_FORMAT(data_compra, '%d-%m-%y')) AS total_compras FROM compras
WHERE data_compra BETWEEN '2023-09-13' AND '2023-09-20';

DELIMITER //
CREATE FUNCTION total_compras_periodo(cmp DATE, cmp2 DATE) RETURNS INT 
DETERMINISTIC
BEGIN 
	DECLARE total_periodo INT;
    SELECT COUNT(DATE_FORMAT(data_compra, '%d-%m-%y')) AS data_compra INTO total_periodo 
    FROM compras
	WHERE data_compra BETWEEN cmp AND cmp2;
    RETURN total_periodo;
END //
DELIMITER ;

SELECT total_compras_periodo('2023-09-13','2023-09-20');
