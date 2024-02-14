import Foundation

// MARK: - Data Transfer Object

struct ProductsResponseDTO: Decodable {
    let skip: Int
    let limit: Int
    let total: Int
    let products: [ProductDTO]
}

extension ProductsResponseDTO {
    struct ProductDTO: Decodable {
        let id: Int
        let title: String?
        let description: String?
        let price: Int?
        let discountPercentage: Double?
        let rating: Double?
        let stock: Int?
        let brand: String?
        let category: String?
        let thumbnail: String?
        let images: [String]?
    }
}

// MARK: - Mappings to Domain

extension ProductsResponseDTO {
    func toDomain() -> ProductsPage {
        return .init(skip: skip, limit: limit, total: total, products: products.map { $0.toDomain() })
    }
}

extension ProductsResponseDTO.ProductDTO {
    func toDomain() -> Product {
        return .init(id: Product.Identifier(id), title: title, description: description, price: price, discountPercentage: discountPercentage, rating: rating, stock: stock, brand: brand, category: category, thumbnail: thumbnail, images: images)
    }
}
