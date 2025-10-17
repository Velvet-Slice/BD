DROP DATABASE if EXISTS confeitaria;
CREATE DATABASE IF NOT EXISTS confeitaria;

use confeitaria;-- Apaga as tabelas se elas já existirem, para evitar erros ao rodar o script várias vezes.
DROP TABLE IF EXISTS `pedidos`;
DROP TABLE IF EXISTS `funcionarios`;
DROP TABLE IF EXISTS `produtos`;
DROP TABLE IF EXISTS `categorias`;
DROP TABLE IF EXISTS `clientes`;


-- Tabela: Categoria
-- Armazena os tipos de produtos (ex: Bolos, Doces, Salgados).
CREATE TABLE `categorias` (
    `idCat` INT AUTO_INCREMENT PRIMARY KEY,
    `nomeCat` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Tabela: Produto
-- Armazena os produtos à venda. Cada produto pertence a uma categoria.
CREATE TABLE `produtos` (
    `idProd` INT AUTO_INCREMENT PRIMARY KEY,
    `nomeProd` VARCHAR(255) NOT NULL,
    `imagem_url` VARCHAR(255) NULL, -- Armazena o "endereço" da imagem
    `descricaoProd` TEXT NULL,
    `precoProd` DECIMAL(10, 2) NOT NULL,
    `idCat` INT NULL,
    CONSTRAINT `fk_produto_categoria`
        FOREIGN KEY (`idCat`) 
        REFERENCES `categorias`(`idCat`)
        ON DELETE SET NULL -- Se uma categoria for deletada, o produto fica sem categoria, mas não é apagado.
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Tabela: Clientes
-- Armazena os dados dos clientes.
CREATE TABLE `clientes` (
    `idCli` INT AUTO_INCREMENT PRIMARY KEY,
    `nomeCli` VARCHAR(255) NOT NULL,
    `data_nascimentoCli` DATE NULL,
    `telefoneCli` VARCHAR(20) NULL,
    `cpfCli` VARCHAR(14) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Tabela: Funcionarios
-- Armazena os dados dos funcionários.
CREATE TABLE `funcionarios` (
    `idFuncionario` INT AUTO_INCREMENT PRIMARY KEY,
    `nomeFunc` VARCHAR(255) NOT NULL,
    `cpfFunc` VARCHAR(14) NOT NULL UNIQUE,
    `telefoneFunc` VARCHAR(20) NULL,
    `emailFunc` VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Tabela: Pedidos
-- Armazena os pedidos feitos pelos clientes.
-- Adicionei a coluna 'cliente_id' que é essencial para saber quem fez o pedido.
-- ... (seu script de criação de categorias, produtos, clientes, funcionarios) ...

-- Tabela: Pedidos (MODIFICADA)
-- Removemos a ligação direta com um único produto.
CREATE TABLE `pedidos` (
    `idPed` INT AUTO_INCREMENT PRIMARY KEY,
    `data_pedido` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `data_entrega` DATE NOT NULL,
    `idCli` INT NULL,
    CONSTRAINT `fk_pedido_cliente`
        FOREIGN KEY (`idCli`) 
        REFERENCES `clientes`(`idCli`)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- NOVA TABELA: itens_pedido
-- Esta é a tabela de junção que resolve o relacionamento.
CREATE TABLE `itens_pedido` (
    `idItem` INT AUTO_INCREMENT PRIMARY KEY,
    `idPed` INT NOT NULL, -- Chave estrangeira para a tabela 'pedidos'
    `idProd` INT NOT NULL, -- Chave estrangeira para a tabela 'produtos'
    `quantidade` INT NOT NULL,
    `preco_unitario` DECIMAL(10, 2) NOT NULL, -- Guarda o preço do produto NO MOMENTO DA COMPRA
    
    CONSTRAINT `fk_item_pedido`
        FOREIGN KEY (`idPed`) 
        REFERENCES `pedidos`(`idPed`),
        
    CONSTRAINT `fk_item_produto`
        FOREIGN KEY (`idProd`) 
        REFERENCES `produtos`(`idProd`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ================================================================= --
--                    INSERINDO DADOS DE EXEMPLO                     --
-- ================================================================= --

-- Inserindo Categorias
INSERT INTO `categorias` (`nomeCat`) VALUES 
('Bolos'), 
('Doces Finos'), 
('Salgados para Festa');

-- Inserindo Produtos
INSERT INTO `produtos` (`nomeProd`, `imagem_url`, `descricaoProd`, `precoProd`, `idCat`) VALUES
('Bolo de Chocolate com Morango', '/imagens/bolo-chocolate-morango.jpg', 'Delicioso bolo de massa de chocolate com recheio e cobertura de brigadeiro e morangos frescos.', 120.50, 1),
('Bolo de Cenoura com Cobertura', '/imagens/bolo-cenoura.jpg', 'Bolo fofinho de cenoura com cobertura de chocolate.', 65.00, 1),
('Caixa de Brigadeiros Gourmet (12 un)', '/imagens/brigadeiros.jpg', 'Brigadeiros feitos com chocolate belga.', 45.80, 2),
('Cento de Coxinhas de Frango', '/imagens/coxinhas.jpg', 'Coxinhas cremosas com recheio de frango desfiado e catupiry.', 90.00, 3);

-- Inserindo Clientes
INSERT INTO `clientes` (`nomeCli`, `data_nascimentoCli`, `telefoneCli`, `cpfCli`) VALUES
('Ana Clara Souza', '1995-08-15', '(11) 98765-4321', '111.222.333-44'),
('Bruno Martins', '1988-02-20', '(21) 91234-5678', '555.666.777-88');

-- Inserindo Funcionários
INSERT INTO `funcionarios` (`nomeFunc`, `cpfFunc`, `telefoneFunc`, `emailFunc`) VALUES
('Carlos Eduardo Pereira', '999.888.777-66', '(11) 99999-8888', 'carlos.pereira@empresa.com'),
('Fernanda Lima', '555.444.333-22', '(11) 97777-6666', 'fernanda.lima@empresa.com');

-- Inserindo Pedidos
-- ================================================================= --
--     INSERINDO DADOS CORRETAMENTE (NOVO MODELO COM ITENS)      --
-- ================================================================= --

-- Pedido 1: Ana pediu um Bolo de Chocolate
-- Passo 1: Inserir o "cabeçalho" do pedido na tabela 'pedidos'
INSERT INTO `pedidos` (`data_pedido`, `data_entrega`, `idCli`) 
VALUES ('2025-10-10 14:30:00', '2025-10-15', 1);

-- Passo 2: Inserir o item específico na tabela 'itens_pedido'
-- O idPed '1' corresponde ao pedido que acabamos de criar para a Ana (idCli 1).
-- O idProd '1' corresponde ao 'Bolo de Chocolate com Morango'.
INSERT INTO `itens_pedido` (`idPed`, `idProd`, `quantidade`, `preco_unitario`) 
VALUES (1, 1, 1, 120.50);


-- Pedido 2: Bruno pediu um Cento de Coxinhas
-- Passo 1: Inserir o "cabeçalho" do pedido na tabela 'pedidos'
INSERT INTO `pedidos` (`data_pedido`, `data_entrega`, `idCli`) 
VALUES ('2025-10-12 18:00:00', '2025-10-14', 2);

-- Passo 2: Inserir o item específico na tabela 'itens_pedido'
-- O idPed '2' corresponde ao pedido que acabamos de criar para o Bruno (idCli 2).
-- O idProd '4' corresponde ao 'Cento de Coxinhas de Frango'.
INSERT INTO `itens_pedido` (`idPed`, `idProd`, `quantidade`, `preco_unitario`) 
VALUES (2, 4, 1, 90.00);


-- EXEMPLO DE PEDIDO COM MÚLTIPLOS ITENS
-- Vamos supor que a Ana (idCli 1) fez um novo pedido
INSERT INTO `pedidos` (`data_pedido`, `data_entrega`, `idCli`) 
VALUES ('2025-10-16 10:00:00', '2025-10-20', 1);

-- Agora adicionamos os itens para o pedido de id 3 (o que acabamos de criar)
-- Item 1: Um Bolo de Cenoura (idProd 2)
INSERT INTO `itens_pedido` (`idPed`, `idProd`, `quantidade`, `preco_unitario`) 
VALUES (3, 2, 1, 65.00);

-- Item 2: Duas caixas de brigadeiro (idProd 3)
INSERT INTO `itens_pedido` (`idPed`, `idProd`, `quantidade`, `preco_unitario`) 
VALUES (3, 3, 2, 45.80);

