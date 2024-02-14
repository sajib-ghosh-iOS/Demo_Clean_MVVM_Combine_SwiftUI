//
//  HeaderImageView.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 14/02/24.
//

import SwiftUI

struct HeaderImageView: View {
    let urlString: String
    var body: some View {
        AsyncImage(url: URL(string: urlString),scale: 3) { image in
            image
                .resizable()
                .scaledToFit()
        }placeholder: {
            ProgressView()
        }
        .frame(maxWidth: .infinity)
        .frame(height:300)
        .preferredColorScheme(.light)
    }
}

#Preview {
    HeaderImageView(urlString: "https://cdn.dummyjson.com/product-images/100/thumbnail.jpg")
}
