-- Primeira Forma Normal (1FN): A primeira forma normal visa eliminar atributos multivalorados e atributos compostos.
-- Segunda Forma Normal (2FN): Uma tabela encontra-se na segunda forma normal se ela atende todos os requisitos da primeira forma normal e se os registros na tabela, que não são chaves, dependam da chave primária em sua totalidade e não apenas parte dela.
-- Terceira Forma Normal (3FN): Se uma tabela está na primeira e segunda forma normal, mas ao analisarmos um registro encontramos um atributo não chave dependente de outro atributo não chave, precisaremos corrigir a tabela para a terceira forma normal. Aqui basicamente corrigiremos a dependência funcional transitiva.

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

-- ---------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------

-- 1. Trigger para atualizar o estoque após uma venda
-- Crie uma trigger chamada `atualizar_estoque_venda` que diminua a quantidade do produto no estoque sempre que uma venda for realizada.
select * from produtos;
select * from produtos_compras;

alter table produtos 
	add column qtd_produtos INT default 100;
    
UPDATE produtos SET qtd_produtos = qtd_produtos - 1
	WHERE id = 1;
    
DELIMITER //
CREATE TRIGGER atualizar_estoque_venda
AFTER INSERT ON produtos_compras
FOR EACH ROW
	BEGIN 
		UPDATE produtos SET qtd_produtos = qtd_produtos - NEW.quantidade WHERE id = NEW.produtos_id ;
	END//
DELIMITER ;

INSERT INTO produtos_compras(quantidade, compras_id, produtos_id)
	VALUES ('3','2','2');
    
    SELECT * FROM produtos WHERE id = 2;

-- 2. Trigger para evitar CPF duplicado em clientes
-- Crie uma trigger chamada `evitar_cpf_duplicado` que impeça a inserção de clientes com o mesmo CPF na tabela `clientes`.
DELIMITER //
CREATE TRIGGER validar_cpf
BEFORE INSERT ON clientes -- antes de inserir na tabela
FOR EACH ROW
BEGIN 
	IF (SELECT COUNT(*) FROM clientes WHERE cpf = NEW.cpf) > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'CPF ja cadastrado';
    END IF;
END //
DELIMITER ;
DROP TRIGGER validar_cpf;

INSERT INTO clientes(nome, telefone, cpf, data_nascimento)
	VALUES('Cris R.','619999999','748526476821','2000-08-09');


-- 3. Trigger para registrar alterações no valor de um produto
-- Crie uma trigger chamada `log_alteracao_preco_produto` que registre em uma tabela de log sempre que o preço de um produto for alterado.



-- 4. Trigger para impedir exclusão de clientes com compras
-- Crie uma trigger chamada `impedir_exclusao_cliente_com_compras` que impeça a exclusão de clientes que já realizaram compras.
DELIMITER //
CREATE TRIGGER impedir_exclusao_cliente_com_compras
BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN
	IF (SELECT COUNT(*) FROM compras WHERE clientes_id = OLD.id)  > 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Cliente nao pode ser deletado, pois ja possui compras';
    END IF;
END //
DELIMITER ;

DELETE FROM clientes WHERE id = 87;

DROP TRIGGER impedir_exclusao_cliente_com_compras;
-- 5. Trigger para calcular o total da venda automaticamente
-- Crie uma trigger chamada `calcular_total_venda` que automaticamente calcule e insira o valor total da venda ao realizar uma inserção na tabela `vendas`.

-- 6. Trigger para impedir vendas de produtos sem estoque
-- Crie uma trigger chamada `impedir_venda_sem_estoque` que impeça a venda de produtos que não possuem estoque suficiente.
SELECT qtd_produtos FROM produtos WHERE id = 2;

DELIMITER //
CREATE TRIGGER conferir_estoque
BEFORE INSERT ON produtos_compras
FOR EACH ROW
BEGIN 
	IF (SELECT qtd_produtos FROM produtos WHERE id = NEW.produtos_id) < NEW.quantidade THEN -- entao
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Estoque insuficiente.';
    END IF;
END //
DELIMITER ;

-- 6.1 Crie uma procedure para cadastrar novos produtos na compra. 
DELIMITER //
CREATE PROCEDURE criar_produto_venda(IN qtd INT, IN compraId INT, IN proId INT)
BEGIN
	INSERT INTO produtos_compras (quantidade, compras_id, produtos_id)
		VALUES (qtd, compraId, proId);
	SELECT nome, (qtd_produtos + qtd)  AS 'Estoque_Antigo', qtd_produtos AS 'Estoque_Atual' FROM produtos WHERE id = proId;
END //
DELIMITER ;
DROP PROCEDURE criar_produto_venda;
CALL criar_produto_venda(5,2,2);

SELECT nome, qtd_produtos AS Estoque_Atual FROM produtos WHERE id= 2;


-- 7. Trigger para calcular o total gasto por um cliente após cada compra
-- Crie uma trigger chamada `atualizar_total_gasto_cliente` que atualize o total gasto por um cliente sempre que uma nova compra for registrada.

-- 8. Trigger para registrar exclusão de produtos no log
-- Crie uma trigger chamada `log_exclusao_produto` que registre a exclusão de produtos na tabela `log_exclusoes_produtos`.

-- 9. Trigger para atualizar a última compra do cliente
-- Crie uma trigger chamada `atualizar_ultima_compra_cliente` que atualize a data da última compra do cliente na tabela `clientes` após uma compra ser realizada.

-- 10. Trigger para registrar auditoria de alterações de clientes
-- Crie uma trigger chamada `auditar_alteracao_cliente` que registre alterações no cadastro de clientes em uma tabela de auditoria.
