CREATE OR REPLACE FUNCTION criar_indice_hnsw(modelo_nome VARCHAR(50))
RETURNS VOID AS $$
DECLARE
    v_modelo_id INT;
    v_dimensao  INT;
BEGIN
    SELECT id, dimensao INTO v_modelo_id, v_dimensao
    FROM modelos_embedding
    WHERE nome = modelo_nome;

    IF v_modelo_id IS NULL THEN
        RAISE EXCEPTION 'Modelo % não encontrado', modelo_nome;
    END IF;

    EXECUTE format(
        'CREATE INDEX IF NOT EXISTS hnsw_%s ON embeddings 
         USING hnsw ((embedding::vector(%s)) vector_cosine_ops)
         WHERE modelo_id = %s',
        modelo_nome, v_dimensao, v_modelo_id
    );
END;
$$ LANGUAGE plpgsql;