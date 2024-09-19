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