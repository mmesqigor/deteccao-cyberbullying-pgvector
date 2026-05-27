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

CREATE TABLE dados_rotulados (
    id SERIAL PRIMARY KEY,
    tweet TEXT,
    embedding VECTOR(384),
	rotulo VARCHAR(30)
);

CREATE TABLE dados_nao_rotulados (
	id SERIAL PRIMARY KEY,
	tweet TEXT,
	embedding VECTOR(384),
	rotulo VARCHAR(30),
	indice_original INT
);

CREATE INDEX ON dados_rotulados USING hnsw (embedding vector_cosine_ops);


