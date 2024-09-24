-- Primeira Forma Normal (1FN): A primeira forma normal visa eliminar atributos multivalorados e atributos compostos.
-- Segunda Forma Normal (2FN): Uma tabela encontra-se na segunda forma normal se ela atende todos os requisitos da primeira forma normal e se os registros na tabela, que não são chaves, dependam da chave primária em sua totalidade e não apenas parte dela.
-- Terceira Forma Normal (3FN): Se uma tabela está na primeira e segunda forma normal, mas ao analisarmos um registro encontramos um atributo não chave dependente de outro atributo não chave, precisaremos corrigir a tabela para a terceira forma normal. Aqui basicamente corrigiremos a dependência funcional transitiva.

USE farmacia1;

-- 1. Procedure para somar dois números
-- Crie uma procedure chamada `somar_numeros` que receba dois parâmetros inteiros, `numero1` e `numero2`, e exibe a soma deles.
DELIMITER //
CREATE PROCEDURE soma_num(IN num1 INT, IN num2 INT)
BEGIN 
	SELECT num1 + num2 AS Total_Soma;
END //
DELIMITER ;

-- TESTE
CALL soma_num(1,2);


-- 2. Procedure para inserir um novo cliente
-- Crie uma procedure chamada `inserir_cliente` que receba como parâmetros o nome, telefone e CPF de um cliente, e insira-o na tabela `clientes`.
insert into clientes (nome, telefone, cpf, data_nascimento, endereco_id)
values ('Jeferson','(61) 992836947','04338360160','1995-08-01','4');

DELIMITER //
CREATE PROCEDURE inserir_cli(IN nomecli VARCHAR(20), IN tel VARCHAR(20), IN cpf VARCHAR(20), IN dt_nasc DATE, IN end_id INT)
BEGIN
	 INSERT INTO clientes (nome, telefone, cpf, data_nascimento, endereco_id) values (nomecli, tel, cpf, dt_nasc, end_id) AS Nomes;
END //
DELIMITER ;

-- TESTE
CALL inserir_cli('Jeferson','(61)992836947','04338360160','1995-08-01','4');


-- 3. Procedure para atualizar o telefone de um cliente
-- Crie uma procedure chamada `atualizar_telefone_cliente` que receba o ID do cliente e o novo telefone, e atualize a tabela `clientes` com essa nova informação.
update clientes set telefone = 6199988921 where id = 998; 

DELIMITER //
CREATE PROCEDURE atualizar_telefone_cliente(IN novo_tel VARCHAR(20), IN id_ INT)
BEGIN
	 update clientes set telefone = novo_tel where id = id_; 
END //
DELIMITER ;

-- TESTE
CALL atualizar_telefone_cliente(619955996, 5);


-- 4. Procedure para deletar um cliente
-- Crie uma procedure chamada `deletar_cliente` que receba o ID de um cliente e delete o registro da tabela `clientes`.

delete from clientes where id = 2;

DELIMITER //
CREATE PROCEDURE deletar_cliente(IN id_cli INT)
BEGIN
	 delete from clientes where id = id_cli; 
END //
DELIMITER ;

CALL deletar_cliente(996);



-- 5. Procedure para calcular o total de vendas de um cliente
-- Crie uma procedure chamada `calcular_total_vendas_cliente` que receba o ID de um cliente e exibe o total de vendas desse cliente.





-- 6. Procedure para listar todos os médicos
-- Crie uma procedure chamada `listar_medicos` que exiba todos os médicos cadastrados na tabela `medicos`.
select nome from medicos;
drop procedure atualizar_telefone_cliente;

DELIMITER //
CREATE PROCEDURE listar_medicos()
BEGIN
	 select nome from medicos;
END //
DELIMITER ;

CALL listar_medicos();


-- 7. Procedure para calcular a idade de um cliente
-- Crie uma procedure chamada `calcular_idade_cliente_proc` que receba o ID de um cliente e exiba a idade com base na data de nascimento.
select nome, timestampdiff(YEAR, clientes.data_nascimento, NOW()) from clientes where id = 10;

DELIMITER //
CREATE PROCEDURE calcular_idade_cliente_proc(IN id_cli INT)
BEGIN
	 select timestampdiff(YEAR, data_nascimento, NOW())  as idade from clientes where id = id_cli;
END //
DELIMITER ;
drop procedure calcular_idade_cliente_proc;
CALL calcular_idade_cliente_proc(4) ;

SELECT * from CLIENTES;



-- 8. Procedure para contar o número de clientes
-- Crie uma procedure chamada `contar_clientes_proc` que exibe o número total de clientes cadastrados.

-- 9. Procedure para reutilizar a função de cálculo de idade
-- Reutilize a função `calcular_idade_cliente` em uma procedure chamada `mostrar_idade_cliente`, que exibe a idade do cliente com base no ID.

-- 10. Procedure para reutilizar a função de total de vendas
-- Reutilize a função `total_vendas_por_cliente` em uma procedure chamada `mostrar_total_vendas_cliente`, que exibe o total de vendas de um cliente com base no ID.