import Foundation

struct APIEndpoints {
    
    static func getProducts(with productsRequestDTO: ProductsRequestDTO) -> Endpoint<ProductsResponseDTO> {

        return Endpoint(
            path: "products",
            method: .get,
            queryParametersEncodable: productsRequestDTO
        )
    }
}
