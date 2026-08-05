# Estudo de Caso do Uso de um Sistema de Gerenciamento de Banco de Dados para Detecção de Cyberbullying

**Universidade Federal de Uberlândia (UFU)**
**Faculdade de Computação — Bacharelado em Sistemas de Informação**
 
Trabalho de Conclusão de Curso (TCC) apresentado como parte dos requisitos exigidos para a obtenção do título de Bacharel em Sistemas de Informação.
 
- **Autor:** Igor Melo Mesquita
- **Orientadora:** Profa. Dra. Maria Camila Nardini Barioni

---

A facilidade de acesso às redes sociais intensificou episódios de cyberbullying entre os usuários, prática que afeta negativamente a vida das vítimas. Diante dessa problemática, este trabalho tem como objetivo avaliar a aplicabilidade do PGVector (uma extensão para criar Sistemas de Gerenciamento de Banco de Dados Vetoriais) em processos de detecção de mensagens potencialmente associadas ao cyberbullying, unindo busca por similaridade semântica a um modelo supervisionado de aprendizado de máquina. Com esse propósito, dados da plataforma X (antigo Twitter) foram coletados e submetidos a etapas de pré-processamento textual, representação vetorial, amostragem, armazenamento no PostgreSQL com a extensão PGVector, classificação e avaliação dos resultados. Na etapa de classificação, foram comparados três modelos de geração de embeddings — SBERT, BERT e FastText —, cada um combinado ao algoritmo kNN executado diretamente no SGBDV, por meio de uma função implementada em PL/pgSQL. Os resultados demonstraram que o SBERT apresentou o melhor desempenho (k=9, f1-score de 0,77), superando o BERT (k=7, f1-score de 0,65) e o FastText (k=5, f1-score de 0,59), confirmando que embeddings otimizados para comparação por similaridade são mais adequados a esse tipo de tarefa. Conclui-se que o PostgreSQL, por meio do PGVector, é capaz de atuar como um ambiente completo de classificação por similaridade, validando sua aplicabilidade para a detecção de cyberbullying.

Palavras-chave: cyberbullying, PGVector, embeddings, similaridade semântica, aprendizado de máquina supervisionado.

## Objetivos

**Objetivo geral:** avaliar a aplicabilidade do PGVector — extensão do SGBD PostgreSQL — em processos de detecção de mensagens potencialmente associadas ao cyberbullying por meio de busca por similaridade semântica em embeddings.

**Objetivos específicos:**
- Demonstrar o uso de embeddings em Sistemas de Gerenciamento de Banco de Dados Vetoriais (SGBDVs).
- Implementar o algoritmo de classificação kNN diretamente no SGBDV, por meio de funções nativas do PostgreSQL.
- Analisar os resultados obtidos no armazenamento e na recuperação das representações vetoriais.

## Conclusões

Os resultados obtidos demonstraram que é viável utilizar o PostgreSQL com a extensão PGVector para a detecção de cyberbullying por meio de busca por similaridade vetorial. Dentre os três modelos de representação vetorial avaliados, o SBERT apresentou o melhor desempenho (k=9, f1-score de 0,77), superando o BERT (k=7, f1-score de 0,65) e o FastText (k=5, f1-score de 0,59) — confirmando que embeddings projetados especificamente para comparação por similaridade são mais adequados a algoritmos baseados em distância vetorial, como o kNN, do que embeddings de "propósito geral", como o BERT.

Por outro lado, a análise das matrizes de confusão e dos UMAPs revelou uma limitação consistente nos três modelos: as classes *not_cyberbullying* e *other_cyberbullying*, por serem definidas por exclusão, apresentaram alta heterogeneidade semântica, o que dispersou seus embeddings no espaço vetorial e prejudicou o desempenho do classificador especificamente para esses rótulos.

A principal contribuição deste trabalho foi demonstrar, na prática, que o PostgreSQL, por meio da extensão PGVector, é capaz de atuar não apenas como um repositório de embeddings, mas também como um ambiente completo de classificação por similaridade — dispensando a necessidade de treinamento prévio de um modelo supervisionado tradicional, já que o próprio kNN realiza a classificação diretamente a partir dos dados armazenados.

Como sugestões para trabalhos futuros, destacam-se: investigar estratégias para lidar com a heterogeneidade semântica das classes *not_cyberbullying* e *other_cyberbullying*; avaliar o impacto da dimensionalidade dos embeddings no desempenho da classificação; adotar uma divisão dos dados em treino, validação e teste; repetir o experimento com diferentes sementes de amostragem; e realizar uma análise estatística formal das diferenças de desempenho entre os modelos e valores de k testados.

## Estrutura do Projeto

```bash
├── cyberbullyingDetection.ipynb        # Notebook principal (pipeline completo)
├── datasets/
│   ├── cyberbullying_tweets.csv        # Base de dados de tweets rotulados
│   └── girias.csv                      # Dicionário de gírias usado na normalização de texto
└── postgresql/
    ├── criacao_db_tabelas.sql          # Criação do banco, extensão PGVector e tabelas
    ├── criacao_indices_hnsw.sql        # Criação dos índices HNSW por modelo de embedding
    └── algoritmo_knn.sql               # Função PL/pgSQL de classificação kNN via PGVector
```

## Pré-requisitos

- Python 3.8+
- Jupyter Notebook ou JupyterLab
- PostgreSQL com a extensão [PGVector](https://github.com/pgvector/pgvector) instalada

## Instalação das dependências

```bash
pip install pandas numpy psycopg2-binary pgvector contractions emoji emot urlextract nltk langdetect sentence-transformers torch transformers fasttext-wheel scikit-learn matplotlib seaborn umap-learn
```

O notebook também baixa automaticamente, na primeira execução, recursos do NLTK (`words`, `wordnet`, `omw-1.4`, `averaged_perceptron_tagger`, `punkt`, entre outros) e o modelo pré-treinado do FastText para inglês.

## Como Reproduzir

### Obter os dados

O dataset de tweets rotulados (`datasets/cyberbullying_tweets.csv`) e o dicionário de gírias (`datasets/girias.csv`) já estão inclusos no repositório.

### Configurar o banco de dados

Antes de executar a etapa de armazenamento no notebook, execute os scripts SQL na seguinte ordem no PostgreSQL:

```bash
psql -U postgres -f postgresql/criacao_db_tabelas.sql
psql -U postgres -d CyberbullyingDetection -f postgresql/criacao_indices_hnsw.sql
psql -U postgres -d CyberbullyingDetection -f postgresql/algoritmo_knn.sql
```

Isso cria o banco `CyberbullyingDetection`, habilita a extensão `vector`, as tabelas (`dados`, `modelos_embedding`, `embeddings`), os índices HNSW e a função de classificação kNN.

### Executar o notebook

Execute `cyberbullyingDetection.ipynb` em ordem sequencial. O notebook está organizado nas seguintes seções:

| Seção | Descrição |
|---|---|
| Bibliotecas | Bibliotecas utilizadas ao longo do projeto |
| Coleta dos Dados | Carregamento do dataset de tweets |
| Pré-processamento dos Dados | Limpeza (URLs, e-mails, menções, espaços), normalização (caracteres alongados, emojis/emoticons, acentos, gírias, contrações) e remoção (números, pontuação) |
| Lematização | Lematização dos tweets com WordNet |
| Representação Vetorial dos Dados | Geração dos embeddings com SBERT, BERT e FastText |
| Amostragem | Amostragem estratificada 70/30 |
| Armazenamento dos Dados | Inserção dos dados e embeddings no PostgreSQL/PGVector e criação dos índices HNSW |
| Classificação e Avaliação | Classificação kNN para diferentes valores de k e cálculo de métricas |
| Matriz de Confusão | Matrizes de confusão para os melhores k de cada modelo (SBERT k=9, BERT k=7, FastText k=5) |
| UMAP | Visualização da separabilidade das classes via redução de dimensionalidade |
