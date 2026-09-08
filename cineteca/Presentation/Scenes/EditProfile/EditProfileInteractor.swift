import Foundation

protocol EditProfileBusinessLogic {
    func fetchProfile(request: EditProfileModels.FetchProfile.Request)
    func saveProfile(request: EditProfileModels.SaveProfile.Request)
}

final class EditProfileInteractor {
    private let presenter: EditProfilePresentationLogic
    private let userRepository: UserRepositoryProtocol

    init(presenter: EditProfilePresentationLogic, userRepository: UserRepositoryProtocol) {
        self.presenter = presenter
        self.userRepository = userRepository
    }
}

extension EditProfileInteractor: EditProfileBusinessLogic {
    func fetchProfile(request: EditProfileModels.FetchProfile.Request) {
        presenter.presentLoading()
        Task {
            let response: EditProfileModels.FetchProfile.Response
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

    func saveProfile(request: EditProfileModels.SaveProfile.Request) {
        Task {
            let response: EditProfileModels.SaveProfile.Response
            do {
                _ = try await userRepository.updateProfile(
                    UserProfileUpdate(
                        displayName: request.displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                        bio: request.bio.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                )
                response = .success
            } catch {
                response = .error
            }
            await MainActor.run {
                presenter.presentSaveProfile(response: response)
            }
        }
    }
}
