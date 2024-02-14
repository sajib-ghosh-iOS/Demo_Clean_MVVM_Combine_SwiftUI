import Foundation
@testable import ProductsCleanMVVM

extension Product {
    static func stub(id: Product.Identifier = 1,
                title: String? = "title1" ,
                description: String? = "1",
                price: Int? = 100) -> Self {
        Product(id: id, title: title, description: description, price: price, discountPercentage: nil, rating: nil, stock: nil, brand: nil, category: nil, thumbnail: nil, images: nil)
    }
}
