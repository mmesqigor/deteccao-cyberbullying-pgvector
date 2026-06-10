CREATE OR REPLACE FUNCTION classificar_knn(k INT)
RETURNS VOID AS $$

DECLARE
	registro RECORD;
	rotulo_atribuido VARCHAR(30);

BEGIN
	UPDATE dados_nao_rotulados SET rotulo = NULL;
	
	FOR registro IN (SELECT id, embedding FROM dados_nao_rotulados) LOOP
		SELECT rotulo INTO rotulo_atribuido
		FROM (
			SELECT rotulo
			FROM dados_rotulados
			ORDER BY embedding <=> registro.embedding
			LIMIT k
		) vizinhos
		GROUP BY rotulo
		ORDER BY COUNT(*) DESC
		LIMIT 1;

		UPDATE dados_nao_rotulados
		SET rotulo = rotulo_atribuido
		WHERE id = registro.id;
	END LOOP;
END;
$$ LANGUAGE plpgsql;
