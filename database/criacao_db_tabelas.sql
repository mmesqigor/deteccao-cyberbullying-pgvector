CREATE DATABASE "CyberbullyingDetection"
	WITH
	OWNER = postgres
	ENCODING = 'UFT8'
	LOCALE_PROVIDER = 'icu'
	ICU_LOCALE = 'en-US'
	TABLESPACE = pg_default
	CONNECTION LIMIT = -1
	IS_TEMPLATE = False;

CREATE TABLE dados_rotulados (
    id SERIAL PRIMARY KEY,
    tweet TEXT,
    embedding VECTOR(384),
	rotulo VARCHAR(30)
);

CREATE TABLE dados_nao_rotulados (
	id SERIAL PRIMARY KEY,
	tweet TEXT,
	embedding VECTOR(384)
);

CREATE INDEX ON dados USING hnsw (embedding vector_cosine_ops);
