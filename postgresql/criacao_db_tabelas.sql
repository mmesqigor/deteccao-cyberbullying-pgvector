CREATE DATABASE "CyberbullyingDetection"
	WITH
	OWNER = postgres
	ENCODING = 'UTF8'
	LOCALE_PROVIDER = 'icu'
	ICU_LOCALE = 'en-US'
	TEMPLATE = template0
	TABLESPACE = pg_default
	CONNECTION LIMIT = -1
	IS_TEMPLATE = False;

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE dados (
    id SERIAL PRIMARY KEY,
    tweet TEXT NOT NULL,
	rotulo VARCHAR(30) NULL,
	rotulado BOOLEAN NOT NULL,
	indice_original INT NULL
);

CREATE TABLE modelos_embedding (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL UNIQUE,
	dimensao INT NOT NULL
);

CREATE TABLE embeddings (
	id SERIAL PRIMARY KEY,
	embedding VECTOR NOT NULL,
	modelo_id INT NOT NULL REFERENCES modelos_embedding(id),
	tweet_id INT NOT NULL REFERENCES dados(id),
	UNIQUE (tweet_id, modelo_id)
);
