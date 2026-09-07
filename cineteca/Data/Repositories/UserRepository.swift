import CoreData
import Foundation

final class UserRepository: UserRepositoryProtocol {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetchCurrentUser() async throws -> User {
        let context = coreDataStack.viewContext
        return try await context.perform {
            try ProfileSeedData.seedIfNeeded(in: context)
            let request = UserEntity.fetchRequest()
            request.fetchLimit = 1
            guard let entity = try context.fetch(request).first else {
                throw UserRepositoryError.userNotFound
            }
            return entity.toDomain()
        }
    }
}

enum UserRepositoryError: Error {
    case userNotFound
}
