//
//  ProductDetailsView.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 10/02/24.
//

import SwiftUI

struct ProductDetailsView: View {
    
    private var viewModel: ProductDetailsViewModel!
    
    static func create(with product: ProductItemViewModel) -> ProductDetailsView {
        let view = ProductDetailsView(viewModel: DefaultProductDetailsViewModel(product: product))
        return view
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                HeaderImageView(urlString: viewModel.image)
                Text("Title : \(viewModel.title)").font(.title)
                Text("Price : \(viewModel.price, format: .currency(code:"USD"))").font(.title2)
                Text("Description : \(viewModel.description)").font(.title3)
            }
            .padding(10)
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
        }.preferredColorScheme(.light)
    }
}

#Preview {
    ProductDetailsView()
}
