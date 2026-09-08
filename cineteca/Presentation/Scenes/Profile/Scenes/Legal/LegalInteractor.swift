import Foundation

protocol LegalBusinessLogic {
    func fetchLegal(request: LegalModels.FetchLegal.Request)
}

final class LegalInteractor {
    private let presenter: LegalPresentationLogic

    init(presenter: LegalPresentationLogic) {
        self.presenter = presenter
    }
}

extension LegalInteractor: LegalBusinessLogic {
    func fetchLegal(request: LegalModels.FetchLegal.Request) {
        presenter.presentFetchLegal(response: .content)
    }
}
