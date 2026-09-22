import Foundation

protocol AccountPresentationLogic {
    func presentFetchAccount(response: AccountModels.FetchAccount.Response)
    func presentLoading()
}

final class AccountPresenter {
    weak var view: AccountDisplayLogic?
}

extension AccountPresenter: AccountPresentationLogic {
    func presentFetchAccount(response: AccountModels.FetchAccount.Response) {
        switch response {
        case .content(let user):
            view?.displayFetchAccount(viewModel: .content(makeContent(from: user)))
        case .error:
            view?.displayFetchAccount(viewModel: .error)
        }
    }

    func presentLoading() {
        view?.displayLoading()
    }

    private func makeContent(from user: User) -> AccountModels.FetchAccount.ViewModel.Content {
        AccountModels.FetchAccount.ViewModel.Content(
            profileCard: AccountProfileCardViewModel(
                username: user.username,
                email: user.email,
                avatarImageName: user.avatarImageName
            ),
            profileSection: AccountSectionViewModel(
                title: Strings.AccountScene.Section.profile,
                rows: [
                    .value(title: Strings.AccountScene.Row.username, value: user.username),
                    .value(title: Strings.AccountScene.Row.displayName, value: user.displayName),
                    .value(title: Strings.AccountScene.Row.bio, value: user.bio)
                ]
            ),
            securitySection: AccountSectionViewModel(
                title: Strings.AccountScene.Section.security,
                rows: [
                    .value(title: Strings.AccountScene.Row.email, value: user.email),
                    .navigation(title: Strings.AccountScene.Row.changePassword, action: .changePassword)
                ]
            ),
            dangerSection: AccountSectionViewModel(
                title: Strings.AccountScene.Section.dangerZone,
                rows: [
                    .danger(title: Strings.AccountScene.Row.deleteAccount, action: .deleteAccount)
                ]
            )
        )
    }
}
