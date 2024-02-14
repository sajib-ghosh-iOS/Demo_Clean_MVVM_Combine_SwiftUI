import Foundation
@testable import ProductsCleanMVVM

final class DispatchQueueTypeMock: DispatchQueueType {
    func async(execute work: @escaping () -> Void) {
        work()
    }
}
