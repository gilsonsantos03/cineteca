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
            return try Self.fetchUserEntity(in: context).toDomain()
        }
    }

    func updateProfile(_ update: UserProfileUpdate) async throws -> User {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let entity = try Self.fetchUserEntity(in: context)
            entity.displayName = update.displayName
            entity.bio = update.bio
            try context.save()
            return entity.toDomain()
        }
    }

    func updatePassword(_ update: UserPasswordUpdate) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let entity = try Self.fetchUserEntity(in: context)
            guard entity.password == update.currentPassword else {
                throw UserRepositoryError.invalidCurrentPassword
            }
            entity.password = update.newPassword
            try context.save()
        }
    }

    private static func fetchUserEntity(in context: NSManagedObjectContext) throws -> UserEntity {
        let request = UserEntity.fetchRequest()
        request.fetchLimit = 1
        guard let entity = try context.fetch(request).first else {
            throw UserRepositoryError.userNotFound
        }
        return entity
    }
}

enum UserRepositoryError: Error {
    case userNotFound
    case invalidCurrentPassword
}
