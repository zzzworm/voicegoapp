import Foundation
import Dependencies
import DependenciesMacros

final class UserInfoRepository {
    var currentUser: UserProfile?
    func saveCurrentUser(_ user: UserProfile?) {
        currentUser = user
        // Here you would typically save the user to a database or persistent storage
    }
}

enum UserInfoRepositoryKey: DependencyKey {
 static var liveValue: UserInfoRepository = UserInfoRepository()
}


extension DependencyValues {
    var userInfoRepository: UserInfoRepository {
        get { self[UserInfoRepositoryKey.self] }
        set { self[UserInfoRepositoryKey.self] = newValue }
    }
}


    
