SHOW DATABASES;

USE farmacia;

select * from compras WHERE clientes_id = 4;

-- CRIAR UMA FUNCAO PARA VERIFICAR SE UM CLIENTE EXITSTE PELO CPF

DELIMITER //
CREATE PROCEDURE obter_compras_cliente(id_cli INT)
	BEGIN
		SELECT * FROM compras WHERE clientes_id = id_cli;
	END //
DELIMITER ;

CALL obter_compras_cliente(5);

SELECT COUNT(*) FROM compras
	WHERE data_compra >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
    
DELIMITER //
CREATE FUNCTION vendas_ultimos_dias(dias INT) RETURNS INT
DETERMINISTIC
BEGIN 
	DECLARE total_vendas INT;
    SELECT COUNT(*) INTO total_vendas FROM compras WHERE data_compra >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
    RETURN total_vendas;
END //
DELIMITER ;

SELECT vendas_ultimos_dias(10);
select crm from medicos;
SELECT distinct medicos.nome from medicos where crm = 'CRM10001' ;

 set global log_bin_trust_function_creators=1;
-- ---------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------

DELIMITER //
CREATE FUNCTION nomes(num_crm VARCHAR(15)) RETURNS varchar(50)
DETERMINISTIC
BEGIN 
	DECLARE nome_medico VARCHAR(50);
    SELECT distinct nome INTO nome_medico FROM medicos WHERE crm = num_crm ;
    RETURN nome_medico;
END //
DELIMITER ;

 

DROP FUNCTION nomes;

DELIMITER //
CREATE FUNCTION nomes(num_crm VARCHAR(15)) RETURNS varchar(50)
DETERMINISTIC
BEGIN 
	DECLARE nome_medico VARCHAR(50);
    SELECT distinct nome INTO nome_medico FROM medicos WHERE crm = num_crm ;
    RETURN nome_medico;
END //
DELIMITER ;

select nomes('CRM10001');