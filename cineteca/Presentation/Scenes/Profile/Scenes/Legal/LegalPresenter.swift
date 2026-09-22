import Foundation

protocol LegalPresentationLogic {
    func presentFetchLegal(response: LegalModels.FetchLegal.Response)
}

final class LegalPresenter {
    weak var view: LegalDisplayLogic?
}

extension LegalPresenter: LegalPresentationLogic {
    func presentFetchLegal(response: LegalModels.FetchLegal.Response) {
        switch response {
        case .content:
            view?.displayFetchLegal(
                viewModel: .content(
                    LegalModels.FetchLegal.ViewModel.Content(
                        linksSection: LegalLinksSectionViewModel(
                            title: Strings.LegalScene.Section.legal,
                            rows: [
                                LegalLinkRowViewModel(
                                    title: Strings.LegalScene.Row.privacyPolicy,
                                    action: .privacyPolicy
                                ),
                                LegalLinkRowViewModel(
                                    title: Strings.LegalScene.Row.termsOfService,
                                    action: .termsOfService
                                )
                            ]
                        )
                    )
                )
            )
        }
    }
}
