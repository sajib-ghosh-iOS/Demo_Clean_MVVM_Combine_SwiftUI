//
//  ListLayout.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 11/02/24.
//

import SwiftUI

struct ProductListLayout: View {
    let items: [ProductItemViewModel]
    var body: some View {
        List{
            ForEach(items, id:\.id) { item in
                NavigationLink(value: item) {
                    ProductListCell(item: item)
                }
            }
        }.navigationDestination(for: ProductItemViewModel.self, destination: { item in
            //move to details view
            ProductDetailsView.create(with: item)
        })
        .preferredColorScheme(.light)
    }
}

#Preview {
    ProductListLayout(items: [ProductItemViewModel]())
}
