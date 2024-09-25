USE farmacia1;

CREATE TABLE auditoria_produtos(
id INT AUTO_INCREMENT PRIMARY KEY,
produto_id INT,
acao VARCHAR(50),
data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 

ALTER TABLE auditoria_produtos
	 ADD COLUMN preco_antigo DECIMAL(10,2),
	 ADD COLUMN preco_novo DECIMAL(10,2);

-- ------------------------------------------------------------------------
-- -------------------------------------------------------------------------
DELIMITER //
CREATE TRIGGER auditoria_produtos_trigger
AFTER UPDATE ON produtos
FOR EACH ROW -- para cada linha
BEGIN 
	INSERT INTO auditoria_produtos (produto_id, acao)
    VALUES (OLD.id, 'Atualizado');
END //
DELIMITER ;

SELECT * FROM produtos WHERE id = 1;

UPDATE produtos SET valor = 3.50 WHERE id = 1;

SELECT * FROM auditoria_produtos;
-- ALTERAR A TABELA DE AUDITORIA INCLUINDO OS CAMPOS:
-- preco novo, preco antigo

DROP TRIGGER auditoria_produtos_trigger;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
DELIMITER //
CREATE TRIGGER auditoria_produtos_trigger
AFTER UPDATE ON produtos
FOR EACH ROW -- para cada linha
BEGIN 
	INSERT INTO auditoria_produtos (produto_id, preco_antigo, acao, preco_novo)
    VALUES (OLD.id, OLD.valor, 'Atualizado', NEW.valor);
END //
DELIMITER ;

SELECT * FROM auditoria_produtos;