# 🌦️ Aplicativo de Previsão do Tempo (CPTEC/INPE)

**Atividade 2 – Previsão do tempo**  
**Disciplina:** Programação para Dispositivos Móveis II  
**Docente:** Prof. Arley  
**Instituição:** Faculdade de Tecnologia (Fatec)  
**Autor:** Alisson Gritti  

---

## 📌 Visão Geral do Projeto

Aplicativo desenvolvido em **Flutter** para consulta da previsão do tempo em qualquer município brasileiro, consumindo dados em tempo real disponibilizados pelo Web Service oficial em formato **XML** do **CPTEC/INPE** (Centro de Previsão de Tempo e Estudos Climáticos do Instituto Nacional de Pesquisas Espaciais).

O aplicativo permite pesquisar municípios, visualizar a previsão meteorológica oficial para 4 dias, acompanhar a evolução de temperaturas mínimas e máximas por meio de **gráficos interativos**, persistir cidades favoritas e histórico localmente, e consultar dados mesmo em modo offline através de uma camada de **cache local**.

---

## 🚀 Funcionalidades Implementadas

### 1. Pesquisa de Cidades
- **Busca por localidade:** campo de pesquisa com teclado de ação rápida que consulta o endpoint `listaCidades?city={nome}` do CPTEC/INPE.
- **Apresentação dos resultados:** listagem detalhada com o **nome da cidade**, a **UF (Unidade Federativa)** e o **código identificador oficial**.
- **Tratamento de acentuação e encoding:** decodificação em `ISO-8859-1` (Latin-1) para exibir corretamente nomes como *São Paulo*, *Campinas do Piauí*, *São Paulo das Missões*, etc.
- **Identificador oficial:** navegação e consulta de previsão baseadas exclusivamente no ID retornado pelo serviço.

### 2. Consulta da Previsão do Tempo (4 Dias)
- **Previsão estendida:** consulta o endpoint `cidade/{id}/previsao.xml` e apresenta todos os 4 dias retornados pelo CPTEC.
- **Informações por dia:**
  - **Data da previsão formatada** por extenso (ex: *"Sexta-feira, 20/11/2026"*).
  - **Temperaturas Mínima e Máxima** em graus Celsius (°C) com indicadores visuais de variação.
  - **Descrição da condição do tempo:** conversão automática das siglas oficiais do CPTEC (como `ci`, `pc`, `pn`, `c`, `t`, `cl`, etc.) em textos compreensíveis.
  - **Ícones dinâmicos:** representação gráfica específica para sol, chuvas, tempestades, nublado, chuvisco, nevoeiro, etc.
  - **Índice Ultravioleta (IUV):** exibição quando disponível no retorno XML, acompanhado de classificação de risco conforme diretrizes da OMS (*Baixo*, *Moderado*, *Alto*, *Muito Alto*, *Extremo*).
- **Data de atualização:** exibição da data de emissão informada pelo serviço do CPTEC (`<atualizacao>`) e carimbo de data/hora da consulta local.

### 3. Visualização com Gráficos
- **Gráfico Interativo de Temperatura (`fl_chart`):**
  - Curvas de temperatura máxima (em laranja/vermelho) e mínima (em azul).
  - Eixos graduados com indicação em °C e dias da previsão (dd/MM).
  - Marcadores de pontos em cada dia com preenchimento em gradiente.

### 4. Atualização e Tratamento de Erros
- **Ação de Atualização:** botão de refresh dedicado na AppBar e suporte a gesto *Pull-to-Refresh* (`RefreshIndicator`).
- **Indicador de carregamento:** feedback visual com `CircularProgressIndicator` durante requisições.
- **Localidades não encontradas:** mensagem explicativa caso nenhuma cidade corresponda ao termo pesquisado.
- **Tratamento de falhas de conexão e indisponibilidade:** captura de `SocketException`, `TimeoutException` e `HttpException` com mensagens amigáveis em português e botão de "Tentar Novamente".
- **Previsão inexistente:** tratamento de respostas contendo nós com valor literal `"null"` (comportamento padrão do CPTEC para códigos sem previsão), impedindo encerramento inesperado do aplicativo.
- **Resiliência a campos ausentes:** valores nulos ou faltantes são tratados com fallbacks seguros.
- **Identificação da fonte:** badges e rodapés identificando expressamente o **CPTEC/INPE** como provedor dos dados.

---

## 💾 Estratégia de Persistência Local

A persistência de dados local foi implementada utilizando a biblioteca **`shared_preferences`**, adotando três frentes estratégicas:

1. **Cidades Favoritas (`cptec_cidades_favoritas`):**
   - O usuário pode favoritar/desfavoritar qualquer localidade tocando no ícone de estrela.
   - A lista de favoritas é serializada em JSON e exibida no topo da tela inicial para acesso instantâneo sem necessidade de redigitar a busca.

2. **Histórico de Buscas Recentes (`cptec_historico_consultas`):**
   - As últimas 10 localidades consultadas são armazenadas automaticamente em formato LRU (sem repetições).
   - O usuário pode acessar rapidamente suas últimas pesquisas ou limpar o histórico a qualquer momento.

3. **Cache Offline da Previsão (`cptec_cache_previsao_{cidadeId}`):**
   - A cada consulta bem-sucedida, o conjunto completo de previsão para 4 dias, juntamente com a data/hora local da consulta, é salvo no cache local.
   - Em caso de perda de conexão com a internet ou indisponibilidade temporária dos servidores do CPTEC, o aplicativo automaticamente recupera e exibe a última previsão salva, exibindo um aviso de **Modo Offline** e informando quando os dados foram obtidos.

---

## 📦 Bibliotecas Utilizadas

| Biblioteca | Versão | Finalidade |
| :--- | :--- | :--- |
| **`http`** | `^1.2.0` | Realização das requisições HTTP/HTTPS para os Web Services do CPTEC/INPE |
| **`xml`** | `^6.5.0` | Análise e extração dos nós XML (`<cidades>`, `<cidade>`, `<previsao>`, etc.) |
| **`fl_chart`** | `^0.68.0` | Renderização do gráfico interativo de linha para temperaturas mínimas e máximas |
| **`shared_preferences`** | `^2.2.2` | Persistência local no dispositivo (Favoritos, Histórico e Cache Offline) |
| **`intl`** | `^0.19.0` | Formatação de datas em padrão brasileiro (`pt_BR`) e internacionalização |
| **`cupertino_icons`** | `^1.0.8` | Conjunto adicional de ícones |

---

## 🏗️ Estrutura do Projeto

```text
Atv2-PrevisaoTempo/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml       # Permissões de INTERNET e cleartext traffic
├── lib/
│   ├── main.dart                     # Ponto de entrada e configuração do tema
│   ├── models/
│   │   ├── cidade.dart               # Modelo de localidade (id, nome, uf, favoritos)
│   │   ├── previsao_dia.dart         # Modelo da previsão diária (data, temp, iuv, ícone)
│   │   └── previsao_cidade.dart      # Agrupador da previsão de 4 dias e parser XML
│   ├── services/
│   │   ├── cptec_service.dart        # Cliente HTTP e parser das rotas XML do CPTEC
│   │   └── storage_service.dart      # Persistência local via SharedPreferences
│   ├── utils/
│   │   └── weather_condition_helper.dart # Dicionário de siglas, descrições e ícones
│   ├── widgets/
│   │   ├── weather_card.dart         # Cartão diário com temperaturas, ícones e IUV
│   │   ├── temperature_chart.dart    # Gráfico fl_chart com curvas de temperatura
│   │   ├── uv_badge.dart             # Indicador colorido de risco do índice UV
│   │   ├── error_view.dart           # Componente de erro com botão de retry
│   │   └── empty_state.dart          # Componente para listas vazias e busca sem retorno
│   └── screens/
│       ├── home_screen.dart          # Tela principal (busca, favoritos, histórico)
│       ├── forecast_screen.dart      # Tela de previsão de 4 dias e gráficos
│       └── about_screen.dart         # Tela institucional com informações do projeto
├── test/
│   ├── cptec_service_test.dart       # Testes unitários de parser XML e exceções
│   └── weather_condition_helper_test.dart # Testes do mapeamento de siglas meteorológicas
├── pubspec.yaml                      # Dependências e metadados do projeto
└── README.md                         # Documentação completa do projeto
```

---

## ⚙️ Instruções para Executar o Projeto

### Pré-requisitos
1. **Flutter SDK** (versão 3.0.0 ou superior): verifique com `flutter doctor`.
2. Emulador Android/iOS ou dispositivo físico conectado com depuração USB habilitada (ou suporte a Desktop/Chrome).

### Passo a Passo

1. **Clone o repositório:**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd Atv2-PrevisaoTempo
   ```

2. **Instale as dependências do projeto:**
   ```bash
   flutter pub get
   ```

3. **Execute os testes unitários (opcional):**
   ```bash
   flutter test
   ```

4. **Execute o aplicativo:**
   ```bash
   flutter run
   ```

---

## 📷 Capturas de Tela

> As capturas de tela abaixo ilustram os principais fluxos e requisitos atendidos pelo aplicativo.

| 1. Tela Inicial e Busca | 2. Cidades Favoritas & Histórico |
| :---: | :---: |
| *(Insira aqui o print da pesquisa de cidades)* | *(Insira aqui o print com favoritos e histórico)* |

| 3. Previsão de 4 Dias e Gráfico | 4. Modo Offline & Tratamento de Erros |
| :---: | :---: |
| *(Insira aqui o print com o gráfico e os cards)* | *(Insira aqui o print com o banner offline ou erro)* |

---

## 🌐 Endpoints Oficiais Utilizados (CPTEC/INPE)

- **Consulta de Localidades:**
  ```text
  https://servicos.cptec.inpe.br/XML/listaCidades?city={nome_da_cidade}
  ```
- **Previsão do Tempo para 4 Dias:**
  ```text
  https://servicos.cptec.inpe.br/XML/cidade/{id_da_cidade}/previsao.xml
  ```
- **Documentação Oficial:** [Serviços Web CPTEC/INPE](https://servicos.cptec.inpe.br/XML/)
