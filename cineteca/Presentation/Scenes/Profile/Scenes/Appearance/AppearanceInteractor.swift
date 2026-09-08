import Foundation

protocol AppearanceBusinessLogic {
    func fetchAppearance(request: AppearanceModels.FetchAppearance.Request)
    func previewTheme(request: AppearanceModels.PreviewTheme.Request)
    func applyAppearance(request: AppearanceModels.ApplyAppearance.Request)
}

final class AppearanceInteractor {
    private let presenter: AppearancePresentationLogic
    private let appearanceRepository: AppearanceRepositoryProtocol
    private var savedTheme: AppTheme = .dark
    private var pendingTheme: AppTheme = .dark

    init(presenter: AppearancePresentationLogic, appearanceRepository: AppearanceRepositoryProtocol) {
        self.presenter = presenter
        self.appearanceRepository = appearanceRepository
    }
}

extension AppearanceInteractor: AppearanceBusinessLogic {
    func fetchAppearance(request: AppearanceModels.FetchAppearance.Request) {
        savedTheme = appearanceRepository.fetchSelectedTheme()
        pendingTheme = savedTheme
        presenter.presentFetchAppearance(response: .content(savedTheme: savedTheme, pendingTheme: pendingTheme))
    }

    func previewTheme(request: AppearanceModels.PreviewTheme.Request) {
        pendingTheme = request.theme
        presenter.presentPreviewTheme(response: .content(savedTheme: savedTheme, pendingTheme: pendingTheme))
    }

    func applyAppearance(request: AppearanceModels.ApplyAppearance.Request) {
        appearanceRepository.saveSelectedTheme(pendingTheme)
        savedTheme = pendingTheme
        presenter.presentApplyAppearance(response: .success(pendingTheme))
    }
}
