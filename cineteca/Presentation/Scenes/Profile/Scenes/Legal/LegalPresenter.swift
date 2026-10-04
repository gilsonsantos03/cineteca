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
                        linksSection: LegalModels.LinksSectionViewModel(
                            title: Strings.LegalScene.Section.legal,
                            rows: [
                                LegalModels.LinkRowViewModel(
                                    title: Strings.LegalScene.Row.privacyPolicy,
                                    action: .privacyPolicy
                                ),
                                LegalModels.LinkRowViewModel(
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
