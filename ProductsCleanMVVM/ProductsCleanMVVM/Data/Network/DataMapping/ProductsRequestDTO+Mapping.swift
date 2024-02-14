import Foundation

struct ProductsRequestDTO: Encodable {
    let skip: Int
    let limit: Int
}
