//
//  ProductListCell.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 14/02/24.
//

import SwiftUI

struct ProductListCell: View {
    var item: ProductItemViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title).font(.title)
            Text("\(item.price, format: .currency(code:"USD"))")
                .foregroundStyle(.red)
                .font(.title2)
            Text(item.description)
                .font(.title3)
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ProductListCell(item: ProductItemViewModel(id: 1, title: "Title", description: "Description", price: 100, image: ""))
}
