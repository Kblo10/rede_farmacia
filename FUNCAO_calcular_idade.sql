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


SELECT contar_endereco1();

DROP FUNCTION contar_endereco;


-- CRIE UMA FUNCAO QUE RETORNA A DATA DA ULTIMA COMPRA DE UM CLIENTE
SELECT compras.id, compras.data_compra FROM compras
	JOIN clientes ON clientes.id = compras.clientes_id
    WHERE compras.id = 1
    GROUP BY compras.id;
    
    
SELECT MAX(data_compra) FROM compras WHERE id = 1;
