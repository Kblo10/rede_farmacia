-- Primeira Forma Normal (1FN): A primeira forma normal visa eliminar atributos multivalorados e atributos compostos.
-- Segunda Forma Normal (2FN): Uma tabela encontra-se na segunda forma normal se ela atende todos os requisitos da primeira forma normal e se os registros na tabela, que não são chaves, dependam da chave primária em sua totalidade e não apenas parte dela.
-- Terceira Forma Normal (3FN): Se uma tabela está na primeira e segunda forma normal, mas ao analisarmos um registro encontramos um atributo não chave dependente de outro atributo não chave, precisaremos corrigir a tabela para a terceira forma normal. Aqui basicamente corrigiremos a dependência funcional transitiva.

USE farmacia1;
select * from auditoria_produtos;
CREATE TABLE auditoria_produtos(
id INT AUTO_INCREMENT PRIMARY KEY,
produto_id INT,
acao VARCHAR(50),
data_modificacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 

ALTER TABLE auditoria_produtos
	 ADD COLUMN nome VARCHAR(30),
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

-- TESTE 
UPDATE produtos SET valor = 3.90 WHERE id = 1;
-- --------------------------------------------
SELECT * FROM produtos WHERE id = 1;

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

-- TESTE 
INSERT INTO produtos_compras(quantidade, compras_id, produtos_id)
	VALUES ('3','1','1');
    
    SELECT * FROM produtos WHERE id = 2;

-- ----------------------------------------------------------
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

-- TESTE 
INSERT INTO clientes(nome, telefone, cpf, data_nascimento)
	VALUES('Cris R.','619999999','748526476821','2000-08-09');

select * from clientes where nome like 'Cris%';


-- 3. Trigger para registrar alterações no valor de um produto
-- Crie uma trigger chamada `log_alteracao_preco_produto` que registre em uma tabela de log sempre que o preço de um produto for alterado.
DELIMITER //
CREATE TRIGGER auditoria_prod
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN 
	INSERT INTO auditoria_produtos(produto_id, acao, preco_antigo, preco_novo, nome)
		VALUES (OLD.id, 'Atualizado', OLD.valor, NEW.valor, OLD.nome);
END //
DELIMITER ;


-- TESTE
UPDATE produtos SET valor = 4.95 WHERE id = 1;
select * from auditoria_produtos where produto_id = 1;

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

-- TESTE com cliente que possui compras
DELETE FROM clientes WHERE id = 56;
-- TESTE com cliente que não possui compras
DELETE FROM clientes WHERE id = 97; -- ja deletado

select * from compras;
DROP TRIGGER impedir_exclusao_cliente_com_compras;


-- 5. Trigger para calcular o total da venda automaticamente
-- Crie uma trigger chamada `calcular_total_venda` que automaticamente calcule e insira o valor total da venda ao realizar uma inserção na tabela `vendas`.
ALTER TABLE compras
	ADD COLUMN valor_total DECIMAL(10,2);

DELIMITER //
CREATE TRIGGER calcular_total_venda
AFTER INSERT ON produtos_compras
FOR EACH ROW
BEGIN 
	UPDATE compras 
    SET valor_total = valor_total + (NEW.quantidade * (SELECT valor FROM produtos WHERE id = NEW.produtos_id))
    WHERE id = NEW.compras_id;
END //
delimiter ;

-- TESTE
INSERT INTO produtos_compras(quantidade, compras_id, produtos_id)
	VALUES ('30','11','3') ;

ALTER TABLE compras ADD COLUMN valor_total DOUBLE(10,2) DEFAULT 0;
ALTER TABLE compras DROP COLUMN valor_total;
SELECT * FROM produtos_compras WHERE compras_id = 11;
SELECT * FROM compras WHERE id = 11; -- consulta de compras


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
DELIMITER //
CREATE TRIGGER atualizar_total_gasto_cliente
AFTER UPDATE ON compras
FOR EACH ROW
BEGIN 
	UPDATE clientes SET total_gasto = total_gasto + NEW.valor_total
		WHERE id = NEW.clientes_id ;
END //
DELIMITER ;


-- 8. Trigger para registrar exclusão de produtos no log
-- Crie uma trigger chamada `log_exclusao_produto` que registre a exclusão de produtos na tabela `log_exclusoes_produtos`.
DELIMITER //
CREATE TRIGGER auditoria_prod_delete
AFTER DELETE ON produtos
FOR EACH ROW
BEGIN 
	INSERT INTO auditoria_produtos(produto_id, acao, preco_antigo, nome)
		VALUES (OLD.id, 'Deletado', OLD.valor, OLD.nome);
END //
DELIMITER ;

select * from produtos_compras
right join produtos on produtos.id = produtos_compras.produtos_id
where produtos_id is null;

-- INSERCAO
INSERT INTO produtos(nome, descricao, valor, fabricantes_id, tipos_produtos_id, qtd_produtos)
	VALUES ('Arroz', 'Alimento', 10.50, 1, 1, 100);
    
-- TESTE 
DELETE FROM produtos WHERE id = 82 ;

-- 9. Trigger para atualizar a última compra do cliente
-- Crie uma trigger chamada `atualizar_ultima_compra_cliente` que atualize a data da última compra do cliente na tabela `clientes` após uma compra ser realizada.
ALTER TABLE clientes
	ADD COLUMN ultima_compra DATE;
    
DELIMITER //
CREATE TRIGGER atualizar_ultima_compra_cliente
AFTER INSERT ON compras
FOR EACH ROW
BEGIN
	UPDATE clientes SET ultima_compra = NEW.data_compra
    WHERE id = NEW.clientes_id;
END //
DELIMITER ;

INSERT INTO compras(data_compra, clientes_id)
	VALUES (CURDATE(), 55);
    
SELECT * FROM clientes WHERE id = 55;


-- 10. Trigger para registrar auditoria de alterações de clientes
-- Crie uma trigger chamada `auditar_alteracao_cliente` que registre alterações no cadastro de clientes em uma tabela de auditoria.
CREATE TABLE IF NOT EXISTS auditoria_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    nome VARCHAR(255),
    acao VARCHAR(30),
    campo_alterado VARCHAR(30),
    antigo_valor VARCHAR(30),
    novo_valor VARCHAR(30),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP	
);
drop table auditoria_clientes;

DELIMITER //

CREATE TRIGGER auditar_alteracao_cliente
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
	IF OLD.nome <> NEW.nome THEN -- entao
	INSERT INTO auditoria_clientes(id_cliente, acao, campo_alterado, antigo_valor, novo_valor)
		VALUES (OLD.id, 'Atualizacao', 'nome', OLD.nome, NEW.nome);
	END IF;
    IF OLD.cpf <> NEW.cpf THEN -- entao
	INSERT INTO auditoria_clientes(id_cliente, acao, campo_alterado, antigo_valor, novo_valor)
		VALUES (OLD.id, 'Atualizacao', 'cpf', OLD.cpf, NEW.cpf);
	END IF;
END //
DELIMITER ;

-- TESTE
UPDATE clientes SET nome = 'Ronaldinho Gaúcho' where id = 7;
UPDATE clientes SET cpf = '04454555862' where id = 6;

select * from auditoria_clientes;

select * from clientes where id = 6;
drop trigger auditar_alteracao_cliente;
