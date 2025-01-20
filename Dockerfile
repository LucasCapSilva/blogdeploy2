# Etapa 1: Build
FROM openjdk:17.0.1-jdk-oracle as build

WORKDIR /workspace/app

# Copia os arquivos necessários
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Dá permissão de execução ao mvnw
RUN chmod +x ./mvnw

# Instala as dependências e compila o projeto
RUN ./mvnw clean install -DskipTests

# Extrai as dependências do JAR gerado
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# Etapa 2: Runtime
FROM openjdk:17.0.1-jdk-oracle

# Configura o volume para persistência
VOLUME /tmp

# Define o caminho das dependências copiadas da etapa de build
ARG DEPENDENCY=/workspace/app/target/dependency

# Copia as dependências, classes e metadados
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

# Define o ponto de entrada do container
ENTRYPOINT ["java","-cp","app:app/lib/*","com.generation.blogpessoal.BlogpessoalApplication"]
