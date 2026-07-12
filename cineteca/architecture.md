---
ai_read_when: Read this when reviewing iOS architecture decisions across presentation patterns, domain/data boundaries, and interface vs implementation module design.
---

# Architecture

iFood iOS architecture baseline: Google app-architecture principles adapted to iOS, with default VIP (UIKit) / MVVM (SwiftUI) presentation, repository-first data design, and taxonomy-safe modularization.

- **Goal:** maintainable features with clear responsibilities, low coupling, and predictable module dependencies.
- **Use when:** creating new features, splitting modules, migrating legacy code, or reviewing architectural decisions.

## Principles & Guardrails

- Follow separation of concerns, SSOT, and unidirectional data flow from Google app architecture.
- VIP (UIKit) and MVVM (SwiftUI) are defaults, not hard mandates. Alternative patterns are fine when responsibilities are clear, boundaries are explicit, and the feature is easy to test.
- UI renders state and forwards user events — no business rules in UI.
- **Repository-first:** the repository is the default and only required data boundary. Start every feature with a repository. `UseCase` and `DataSource` are optional layers — only add them when they earn their place:
  - **UseCase is optional.** Only introduce one when there is real orchestration to perform: validation, policy checks, multi-repo composition, or flow decisions. If a use case only forwards a single repository call, it adds no value — delete it.
  - **DataSource is optional.** Only introduce one when the repository must manage more than one data origin (e.g., remote + local cache) or when source-specific integration logic is complex enough to warrant its own type. If there is a single source, keep the storage logic inside the repository itself.
  - Remove premature layers aggressively. When in doubt, start without the extra layer and extract it later if a clear need emerges.
- Use cases are stateless and expose one primary `execute(...)` API. If one type needs many unrelated public methods, use a service abstraction instead.
- Communication chain: `Presentation -> (UseCase or Repository contract) -> Repository -> (optional) DataSource`. DataSources must not call UseCases or UI.
- No reactive architecture requirement.
- Use interface-first module imports (`*Interface`) whenever available. Never import implementation modules across features.
- Assign one owner for UI state; expose immutable/read-only state. Keep infra feature-agnostic. Keep utils generic and dependency-light.

### When to add layers

The default choice is **repository only** — no use case, no data source. Add layers only when the situation demands it.

| Situation | Action |
|---|---|
| Single backend call, simple mapping | Repository only — skip use case and data source. **This is the default.** |
| Single data source (API, or cache) | Keep storage logic inside the repository — skip data source. |
| Same business rule reused across multiple presenters/viewmodels | Introduce a use case. |
| Validation, policy checks, or multi-repo composition needed | Introduce a use case. |
| Remote + local cache needed | Orchestrate in repository; add data sources only if the source-specific logic is complex enough to justify separate types. |
| API model shape diverges from domain entity | Add DTO and map at data boundary (inside the repository). |
| Use case only forwards one repository call | Remove it — it adds no value. |
| Data source wraps a single source with no extra logic | Remove it — inline the logic in the repository. |
| Boilerplate with no clear behavior split | Remove premature layers. |

## Layer Contract

| Layer | Owns | Depends on | Must not own |
|---|---|---|---|
| Presentation | UI state, rendering, user events, navigation triggers | Domain + Data contracts via interfaces | Business rules, persistence/network details |
| Domain (optional) | Entities, business rules, repository interfaces, optional use cases | Domain entities/contracts and repository interfaces | UIKit/SwiftUI, API/DB frameworks |
| Data | Repository implementations, optional data sources, DTO mapping, persistence/network | Infra + utils + interface contracts | UI concerns, direct view logic |

## Presentation Patterns

### UIKit: VIP

Flow: `ViewController -> Interactor -> Presenter -> ViewController`.

- `Interactor` is the main orchestrator (business decisions, logging, analytics, routing decisions).
- `Presenter` is optional for trivial mappings; use when formatting logic is non-trivial.
- `Router` is optional; simple scenes can navigate directly with RouterService contracts.
- Keep detached `View` objects — avoid bloated `UIViewController` classes.

### SwiftUI: MVVM

- `ViewModel` holds state and orchestrates presentation behavior; `View` stays display-focused and binds via `@ObservedObject` / `@StateObject`.
- Use `HostingViewController` to bridge UIKit navigation and SwiftUI screens.
- Keep RouterService-based navigation; avoid SwiftUI-native navigation as architectural default.

## Naming Conventions

### Domain & Data

| Type | Protocol | Implementation | File |
|---|---|---|---|
| Repository | `<Name>RepositoryProtocol` | `<Name>Repository` | `<Name>Repository.swift` |
| DataSource (optional) | `<Name><Source>DataSourceProtocol` | `<Name><Source>DataSource` | `<Name><Source>DataSource.swift` |
| UseCase (optional) | `<DoSomething>UseCase` | `<DoSomething>` | `<DoSomething>UseCase.swift` |
| Service | `<Name>ServiceProtocol` (optional) | `<Name>Service` | `<Name>Service.swift` |
| DTO/Response | n/a | `<Name>DTO` / `<Name>Model` | `<Name>DTO.swift` / `<Name>Model.swift` |

### VIP (UIKit)

| Component | Protocol | Implementation | File |
|---|---|---|---|
| View controller | `<Scene>DisplayLogic` | `<Scene>ViewController` | `<Scene>ViewController.swift` |
| Interactor | `<Scene>BusinessLogic` | `<Scene>Interactor` | `<Scene>Interactor.swift` |
| Presenter | `<Scene>PresentationLogic` | `<Scene>Presenter` | `<Scene>Presenter.swift` |
| Router | `<Scene>RoutingLogic` | `<Scene>Router` | `<Scene>Router.swift` |
| Scene models | n/a | enum `<Scene>Models` (nested Request/Response/ViewModel) | `<Scene>Models.swift` |

### MVVM (SwiftUI)

| Component | Naming |
|---|---|
| ViewModel protocol | `<Scene>ViewModelProtocol: ObservableObject` |
| ViewModel class | `<Scene>ViewModel` |
| View | `<Scene>View` |
| Feature builder | `<Scene>Feature` |
| UIKit bridge | `<Scene>HostingViewController` or shared `HostingViewController` |

## Examples

### Repository only (default) — single source, no extra layers:

```swift
protocol AccountRepositoryProtocol {
    func fetchAccount() async throws -> Account
}

final class AccountRepository: AccountRepositoryProtocol {
    private let httpClient: HTTPClientProtocol

    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }

    func fetchAccount() async throws -> Account {
        let dto: AccountDTO = try await httpClient.request(.get, path: "/account")
        return Account(id: dto.id, name: dto.name)
    }
}

struct AccountDTO: Decodable {
    let id: String
    let name: String
}
```

> This is the starting point for every feature. No use case, no data source — just a repository behind a protocol. Add layers later only if a concrete need appears.

### UseCase (optional) — orchestrates multiple repositories with a business rule:

```swift
protocol AddCartItemUseCase {
    func execute(params: AddCartItemParams) async throws -> Cart
}

struct AddCartItemParams {
    let item: CartItem
}

enum AddCartItemError: Error {
    case unavailableItem
}

final class AddCartItem: AddCartItemUseCase {
    private let cartRepository: CartRepositoryProtocol
    private let inventoryRepository: InventoryRepositoryProtocol

    init(
        cartRepository: CartRepositoryProtocol,
        inventoryRepository: InventoryRepositoryProtocol
    ) {
        self.cartRepository = cartRepository
        self.inventoryRepository = inventoryRepository
    }

    func execute(params: AddCartItemParams) async throws -> Cart {
        let isAvailable = try await inventoryRepository.isAvailable(itemID: params.item.id)
        guard isAvailable else {
            throw AddCartItemError.unavailableItem
        }

        let currentCart = try await cartRepository.currentCart()
        let updatedCart = currentCart.adding(params.item)
        return try await cartRepository.save(cart: updatedCart)
    }
}
```

> A use case earns its place here because it composes two repositories and contains a business rule (availability check). If it only forwarded a single repository call, it should be removed.

### Repository + DataSource (optional) — multiple sources justify the split:

```swift
protocol AccountRepositoryProtocol {
    func fetchAccount() async throws -> Account
}

final class AccountRepository: AccountRepositoryProtocol {
    private let apiDataSource: AccountAPIDataSourceProtocol
    private let cacheDataSource: AccountCacheDataSourceProtocol

    init(
        apiDataSource: AccountAPIDataSourceProtocol,
        cacheDataSource: AccountCacheDataSourceProtocol
    ) {
        self.apiDataSource = apiDataSource
        self.cacheDataSource = cacheDataSource
    }

    func fetchAccount() async throws -> Account {
        if let cached = try? await cacheDataSource.get() {
            return cached
        }
        let dto = try await apiDataSource.fetchAccountDTO()
        let account = Account(id: dto.id)
        try? await cacheDataSource.save(account)
        return account
    }
}

protocol AccountAPIDataSourceProtocol {
    func fetchAccountDTO() async throws -> AccountDTO
}

final class AccountAPIDataSource: AccountAPIDataSourceProtocol {
    func fetchAccountDTO() async throws -> AccountDTO {
        AccountDTO(id: "123")
    }
}

protocol AccountCacheDataSourceProtocol {
    func get() async throws -> Account?
    func save(_ account: Account) async throws
}

struct AccountDTO: Decodable {
    let id: String
}
```

> Data sources earn their place here because the repository orchestrates two distinct origins (API + cache). With a single source, this split would be unnecessary — keep the logic inside the repository.

## Modularization

- Prefer `Interface + Implementation` split for feature and infra modules.
- Keep `Presentation/Domain/Data` as directories inside modules first; split into separate modules only when complexity or build impact justifies it.
- Split large features by functionality before splitting by technical layer.
- `iFood` (app module) and Example App targets can import implementation modules; other libraries depend on interfaces.

### Interface vs Implementation

| Module type | Contains | Avoids | Visibility |
|---|---|---|---|
| Interface | Public protocols, shared entities/models, public routes, lightweight contracts, simple reusable views | Scene wiring, feature-specific orchestration, large concrete flows | `public` |
| Implementation | VIP/MVVM concrete classes, repo/usecase/datasource implementations, route handlers, composition code | API surface shared broadly across modules | `internal` / `private` |

- If another library needs to import it → move the contract to `Interface`.
- Multiple interface modules per implementation is valid when consumers need different public surfaces.
- Keep interface modules small and dependency-light; implementation modules behavior-rich and mostly non-public.
