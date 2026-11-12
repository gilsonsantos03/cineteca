# Recomendações de filmes com IA — estado da implementação

## Estado atual

A feature tem cliente iOS e Cloud Function callable implementados localmente. O cliente inclui um botão flutuante na Home, os modos “Meu momento” e “Combinar filmes”, seleção via Search, chamada a `recommendMovie`, busca dos detalhes canônicos no TMDB, estados de loading/erro/retry, localização pt-BR/en e configuração de App Check.

O backend em `functions/` valida entradas e exige uma conta Firebase Auth não
anônima, consulta candidatos TMDB, solicita ao Gemini que escolha entre eles e
verifica a resposta antes de devolver `movieId` e `explanation`. Há rate limit
de cinco chamadas por UID por minuto. O App Check está temporariamente sem
enforcement no ambiente de desenvolvimento porque o registro de App Attest
depende de uma equipe Apple Developer paga; ele deve ser reativado antes da
publicação.

O app exige login ou cadastro antes de permitir o uso da recomendação. Não são
criadas sessões anônimas e não há quota gratuita para visitantes. No cadastro
por e-mail, o username escolhido é encaminhado junto da criação da conta e
usado na criação do perfil; se essa etapa falhar, a conta recém-criada é
revertida.

## Contrato cliente/backend

Callable Function: `recommendMovie`.

- `moment`: `{ mode: "moment", prompt: string, locale: string }`, prompt entre 1 e 500 caracteres; locale aceito: `en-US` ou `pt-BR`.
- `blend`: `{ mode: "blend", movieIds: [int, int], locale: string }`, dois IDs positivos e distintos.
- Resposta: `{ movieId: int, explanation: string }`. O ID é validado contra candidatos encontrados no TMDB; o app busca o restante dos detalhes pelo repositório TMDB.

## Verificações

- `npm --prefix functions test` passou: TypeScript compilado e 5 testes aprovados.
- `xcodebuild -project cineteca.xcodeproj -scheme cineteca -destination 'generic/platform=iOS Simulator' build` concluiu com `BUILD SUCCEEDED`. As falhas anteriores (argumento extra no `MainTabBarController`, import de `FirebaseCore` na factory App Check e assinatura de cadastro) foram corrigidas.
- A revisão do código encontrou e corrigiu a exclusão de perfis com mais de 500 atividades, a corrida entre conteúdo sugerido e buscas na cena Search e a exibição de um destaque fora do gênero selecionado quando não há correspondência. A factory da App Check e o build do simulador foram revalidados depois dessas correções.
- Login social não está habilitado: a lista de provedores injetados está vazia e não há implementações de provedores neste código; o fluxo disponível é e-mail/senha.
- Exercitar seleção, substituição/remoção de filmes, retry, nova recomendação e fluxo de autenticação na interface.
- Validar funcionalmente o ranking de candidatos populares e similares com
  credenciais reais de TMDB/Gemini.
- Ampliar cobertura de rate limit, rollback de cadastro e falhas externas.

## Segurança e operações

As chaves TMDB/Gemini são definidas como Firebase secrets e não devem ser incluídas no app/repositório. `firebase.json` registra Functions e emuladores. O deploy do ambiente de desenvolvimento e a configuração dos secrets são feitos manualmente no projeto Firebase selecionado; essas configurações não são reproduzidas pelo código-fonte.

Nenhum commit ou push foi feito.

O enforcement de App Check permanece desativado apenas no ambiente de
desenvolvimento até que o App Attest possa ser registrado para a publicação.
