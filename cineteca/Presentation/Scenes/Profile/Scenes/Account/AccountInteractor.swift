import Foundation

protocol AccountBusinessLogic {
    func fetchAccount(request: AccountModels.FetchAccount.Request)
}

final class AccountInteractor {
    private let presenter: AccountPresentationLogic
    private let userRepository: UserRepositoryProtocol

    init(presenter: AccountPresentationLogic, userRepository: UserRepositoryProtocol) {
        self.presenter = presenter
        self.userRepository = userRepository
    }
}

extension AccountInteractor: AccountBusinessLogic {
    func fetchAccount(request: AccountModels.FetchAccount.Request) {
        presenter.presentLoading()
        Task {
            let response: AccountModels.FetchAccount.Response
            do {
                let user = try await userRepository.fetchCurrentUser()
                response = .content(user)
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentFetchAccount(response: response)
            }
        }
    }
}
