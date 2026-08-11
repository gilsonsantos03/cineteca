# Cineteca

App iOS de catálogo de filmes integrado ao [TMDB](https://www.themoviedb.org/). UIKit, VIP na camada de apresentação, repositórios para dados remotos.

## Documentação

| Arquivo | Conteúdo |
|---|---|
| [architecture.md](architecture.md) | Camadas, VIP/MVVM, repositórios, quando extrair use cases |
| [view-conventions.md](view-conventions.md) | Estrutura de views, naming, Cartography, delegates |

## Setup

1. Clone o repositório.
2. Crie `cineteca/Keys.plist` com a chave `API_KEY` (token de leitura v4 do TMDB).
3. Abra `cineteca.xcodeproj` e rode no simulador ou dispositivo.

`Keys.plist` está no `.gitignore` — não commite o token.

## Localização

Padrão igual ao habit-stack: `en.lproj/Localizable.strings`, `pt-BR.lproj/Localizable.strings` e chaves type-safe em `Presentation/Helpers/Strings.swift` (`NSLocalizedString`).

- **UI** (labels, botões, chip "All"): idioma do dispositivo via `Strings`.
- **API TMDB** (nomes de gênero nos filmes): `LocaleProvider.apiLanguage` nos repositórios.

## Modelos de domínio vs Responses da API

| Pasta | Conteúdo |
|---|---|
| `Domain/Models/` | Entidades: `Genre`, `Movie`, `MovieDetails` (+ cast, crew, providers) |
| `Data/Models/` | Responses da API: `GenreResponse`, `MovieResponse`, `MovieDetailsResponse` |

O mapping Response → domínio acontece na camada Data (extensions `toDomain()`). A Presentation recebe apenas entidades ou view models derivados delas.

## Home

A Home carrega quatro listas do TMDB (popular, now playing, trending, top rated) e os gêneros (`/genre/movie/list`). O filtro por gênero é **client-side**: os filmes completos ficam em cache no `HomeInteractor` e são refiltrados ao trocar o chip, sem nova chamada à API.

```
API (5x no load/refresh)  →  CachedHomeContent  →  filtro por gênero (0x)  →  FetchContent.Response  →  UI
                                    ↑
                          selectGenre() reutiliza o cache
```

**5 requests por load:** 1× gêneros + 4× listas de filmes. Trocar o chip de gênero não dispara nova request.

Código em `cineteca/Presentation/Scenes/Home/`.

### CachedHomeContent

Struct privada do `HomeInteractor` com as listas **antes** do filtro:

| Campo | Origem |
|---|---|
| `featured` | Primeiro filme de `/movie/popular` |
| `nowPlaying` | `/movie/now_playing` |
| `trending` | `/trending/movie/week` |
| `topRated` | `/movie/top_rated` |

O presenter e as views recebem `HomeModels.FetchContent.Response` — listas já filtradas + estado do `GenreFilter`.

### Carregamento

1. `fetchContent()` ou `refresh()` → `loadContent()`.
2. `genreRepository.genres()` — uma request de gêneros (retorna `[Genre]`, com cache no repositório).
3. Quatro requests de filmes em paralelo, recebendo `[Genre]` como parâmetro.
4. `sortedGenres` = gêneros da API ordenados por nome; chip "All/Todos" no índice 0.
5. Salva `CachedHomeContent` em `cachedHomeContent`.
6. `presentFilteredContent(from:)` aplica o gênero atual.

### Filtro por gênero

1. Usuário toca um chip em `GenreFilterView`.
2. Evento sobe via delegates até `HomeViewController`.
3. `selectGenre(index:)` atualiza `selectedGenreIndex`.
4. `presentFilteredContent(from: cachedHomeContent)` — sem loading, sem rede.

**Regras:**

- Índice 0 (`All` / `Todos`): sem filtro.
- Demais: filmes cujo `Movie.genres` contém um `Genre` com o mesmo `id`.

**Filme em destaque ao filtrar:**

1. Sem gênero selecionado → featured original.
2. Featured já tem o gênero → mantém.
3. Senão → primeiro match em now playing, trending ou top rated.
4. Nenhum match → mantém o featured original.

### Por que filtrar no cliente?

- Resposta instantânea ao trocar de gênero.
- Menos chamadas (os endpoints de lista não suportam filtro de gênero hoje).
- Todas as seções partem do mesmo snapshot do último refresh.

### Refresh

`refresh()` substitui o cache. `selectedGenreIndex` é preservado e o filtro ativo é reaplicado nos dados novos.

### Responsabilidades (VIP)

| Responsabilidade | Camada |
|---|---|
| Orquestrar busca de filmes e gêneros | `HomeInteractor` |
| Buscar filmes | `MovieRepository` |
| Buscar e cachear gêneros | `GenreRepository` |
| Cache + filtro | `HomeInteractor` (`CachedHomeContent`) |
| View models | `HomePresenter` |
| Chips e listas | `GenreFilterView`, `HomeContentView` |
| Eventos | Delegates (`GenreFilterViewDelegate` → … → `HomeViewDelegate`) |
