import Foundation

enum LegalDocumentType {
    case privacyPolicy
    case termsOfService
}

struct LegalDocumentSection {
    let title: String
    let body: String
}

struct LegalDocumentContent {
    let title: String
    let lastUpdated: String
    let sections: [LegalDocumentSection]
}

enum LegalDocumentContentBuilder {
    static func makeContent(for type: LegalDocumentType) -> LegalDocumentContent {
        switch type {
        case .privacyPolicy:
            return LegalDocumentContent(
                title: Strings.LegalDocumentScene.PrivacyPolicy.title,
                lastUpdated: Strings.LegalDocumentScene.lastUpdated,
                sections: privacySections
            )
        case .termsOfService:
            return LegalDocumentContent(
                title: Strings.LegalDocumentScene.TermsOfService.title,
                lastUpdated: Strings.LegalDocumentScene.lastUpdated,
                sections: termsSections
            )
        }
    }

    private static let privacySections: [LegalDocumentSection] = [
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section1.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section1.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section2.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section2.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section3.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section3.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section4.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section4.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section5.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section5.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section6.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section6.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section7.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section7.body),
        .init(title: Strings.LegalDocumentScene.PrivacyPolicy.Section8.title, body: Strings.LegalDocumentScene.PrivacyPolicy.Section8.body)
    ]

    private static let termsSections: [LegalDocumentSection] = [
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section1.title, body: Strings.LegalDocumentScene.TermsOfService.Section1.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section2.title, body: Strings.LegalDocumentScene.TermsOfService.Section2.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section3.title, body: Strings.LegalDocumentScene.TermsOfService.Section3.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section4.title, body: Strings.LegalDocumentScene.TermsOfService.Section4.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section5.title, body: Strings.LegalDocumentScene.TermsOfService.Section5.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section6.title, body: Strings.LegalDocumentScene.TermsOfService.Section6.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section7.title, body: Strings.LegalDocumentScene.TermsOfService.Section7.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section8.title, body: Strings.LegalDocumentScene.TermsOfService.Section8.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section9.title, body: Strings.LegalDocumentScene.TermsOfService.Section9.body),
        .init(title: Strings.LegalDocumentScene.TermsOfService.Section10.title, body: Strings.LegalDocumentScene.TermsOfService.Section10.body)
    ]
}
