import Foundation

protocol AppearancePresentationLogic {
    func presentFetchAppearance(response: AppearanceModels.FetchAppearance.Response)
    func presentPreviewTheme(response: AppearanceModels.PreviewTheme.Response)
    func presentApplyAppearance(response: AppearanceModels.ApplyAppearance.Response)
}

protocol AppearanceDisplayLogic: AnyObject {
    func displayFetchAppearance(viewModel: AppearanceModels.FetchAppearance.ViewModel)
    func displayPreviewTheme(viewModel: AppearanceModels.PreviewTheme.ViewModel)
    func displayApplyAppearance(viewModel: AppearanceModels.ApplyAppearance.ViewModel)
}

final class AppearancePresenter {
    weak var view: AppearanceDisplayLogic?
}

extension AppearancePresenter: AppearancePresentationLogic {
    func presentFetchAppearance(response: AppearanceModels.FetchAppearance.Response) {
        switch response {
        case let .content(savedTheme, pendingTheme):
            view?.displayFetchAppearance(
                viewModel: .content(makeContent(savedTheme: savedTheme, pendingTheme: pendingTheme))
            )
        }
    }

    func presentPreviewTheme(response: AppearanceModels.PreviewTheme.Response) {
        switch response {
        case let .content(savedTheme, pendingTheme):
            view?.displayPreviewTheme(
                viewModel: .content(makeContent(savedTheme: savedTheme, pendingTheme: pendingTheme))
            )
        }
    }

    func presentApplyAppearance(response: AppearanceModels.ApplyAppearance.Response) {
        switch response {
        case .success(let theme):
            view?.displayApplyAppearance(viewModel: .success(theme))
        }
    }

    private func makeContent(
        savedTheme: AppTheme,
        pendingTheme: AppTheme
    ) -> AppearanceModels.FetchAppearance.ViewModel.Content {
        AppearanceModels.FetchAppearance.ViewModel.Content(
            savedTheme: savedTheme,
            pendingTheme: pendingTheme,
            themeSection: AppearanceThemeSectionViewModel(
                title: Strings.AppearanceScene.Section.theme,
                options: AppTheme.allCases.map { theme in
                    AppearanceThemeOptionViewModel(
                        theme: theme,
                        title: title(for: theme),
                        isSelected: theme == pendingTheme
                    )
                }
            ),
            isApplyEnabled: pendingTheme != savedTheme
        )
    }

    private func title(for theme: AppTheme) -> String {
        switch theme {
        case .dark:
            Strings.AppearanceScene.Theme.dark
        case .light:
            Strings.AppearanceScene.Theme.light
        case .system:
            Strings.AppearanceScene.Theme.system
        }
    }
}
