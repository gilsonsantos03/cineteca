import Foundation

protocol ProfileBusinessLogic {
    func fetchProfile(request: ProfileModels.FetchProfile.Request)
}

final class ProfileInteractor {
    private let presenter: ProfilePresentationLogic
    private let userRepository: UserRepositoryProtocol

    init(presenter: ProfilePresentationLogic, userRepository: UserRepositoryProtocol) {
        self.presenter = presenter
        self.userRepository = userRepository
    }
}

extension ProfileInteractor: ProfileBusinessLogic {
    func fetchProfile(request: ProfileModels.FetchProfile.Request) {
        presenter.presentLoading()
        Task {
            let response: ProfileModels.FetchProfile.Response
            do {
                let user = try await userRepository.fetchCurrentUser()
                response = .content(user)
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentFetchProfile(response: response)
            }
        }
    }
}
