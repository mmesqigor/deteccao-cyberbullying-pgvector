CREATE OR REPLACE FUNCTION classificar_knn(k INT, modelo_embedding VARCHAR(50))
RETURNS VOID AS $$

DECLARE
	v_registro RECORD;
	v_rotulo_atribuido VARCHAR(30);
	v_modelo_id INT;
	v_dimensao INT;

BEGIN
    -- Busca o id e dimensão do modelo informado
    SELECT id, dimensao INTO v_modelo_id, v_dimensao
    FROM modelos_embedding
    WHERE nome = modelo_embedding;

	-- Verifica se o modelo existe
    IF v_modelo_id IS NULL THEN
        RAISE EXCEPTION 'Modelo % não encontrado', modelo_embedding;
    END IF;

    -- Limpa classificações anteriores dos dados não rotulados
    UPDATE dados SET rotulo = NULL
    WHERE rotulado = FALSE;
	
	-- Classificação kNN
	FOR v_registro IN (
		SELECT d.id, e.embedding
		FROM dados d JOIN
			 embeddings e ON e.tweet_id = d.id
		WHERE d.rotulado = FALSE AND
			  e.modelo_id = v_modelo_id
	) LOOP
	
		EXECUTE format('
			SELECT rotulo FROM (
				SELECT d.rotulo
				FROM dados d JOIN
					 embeddings e ON e.tweet_id = d.id
				WHERE d.rotulado = TRUE AND
					  e.modelo_id = $1
				ORDER BY e.embedding::vector(%s) <=> $2::vector(%s)
				LIMIT $3
			) vizinhos
			GROUP BY rotulo
			ORDER BY COUNT(*) DESC
			LIMIT 1
		', v_dimensao, v_dimensao)
		INTO v_rotulo_atribuido
		USING v_modelo_id, v_registro.embedding, k;

		UPDATE dados
		SET rotulo = v_rotulo_atribuido
		WHERE id = v_registro.id;
	
	END LOOP;
END;
$$ LANGUAGE plpgsql;