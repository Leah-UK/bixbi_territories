USE `es_extended`;

CREATE TABLE `bixbi_territories` (
	`name` VARCHAR(50) NOT NULL,
	`gang` VARCHAR(50) NOT NULL DEFAULT '',
	`itemstake` TINYINT NOT NULL DEFAULT 5,
	`washtake` TINYINT NOT NULL DEFAULT 5,

	PRIMARY KEY (`name`)
);