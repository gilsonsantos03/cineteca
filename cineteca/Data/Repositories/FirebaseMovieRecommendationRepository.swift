import FirebaseFunctions
import Foundation

final class FirebaseMovieRecommendationRepository: MovieRecommendationRepositoryProtocol, @unchecked Sendable {
    private let functions: Functions
    private let localeProvider: LocaleProviderProtocol

    init(
        functions: Functions = .functions(),
        localeProvider: LocaleProviderProtocol
    ) {
        self.functions = functions
        self.localeProvider = localeProvider
    }

    func recommend(mode: MovieRecommendationMode) async throws -> MovieRecommendation {
        var payload: [String: Any]

        switch mode {
        case let .moment(text):
            let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !prompt.isEmpty, prompt.count <= 500 else {
                throw MovieRecommendationError.invalidInput
            }
            payload = ["mode": "moment", "prompt": prompt]
        case let .blend(firstMovieID, secondMovieID):
            guard
                firstMovieID > 0,
                secondMovieID > 0,
                firstMovieID != secondMovieID
            else {
                throw MovieRecommendationError.invalidInput
            }
            payload = ["mode": "blend", "movieIds": [firstMovieID, secondMovieID]]
        }

        payload["locale"] = localeProvider.apiLanguage

        do {
            let result = try await functions.httpsCallable("recommendMovie").call(payload)
            guard
                let response = result.data as? [String: Any],
                let movieID = response["movieId"] as? Int,
                movieID > 0,
                let explanation = response["explanation"] as? String,
                !explanation.isEmpty,
                explanation.count <= 500
            else {
                throw MovieRecommendationError.unavailable
            }

            return MovieRecommendation(movieID: movieID, explanation: explanation)
        } catch let error as NSError where error.domain == FunctionsErrorDomain {
            switch FunctionsErrorCode(rawValue: error.code) {
            case .aborted:
                throw MovieRecommendationError.rateLimited
            default:
                throw MovieRecommendationError.unavailable
            }
        }
    }
}
