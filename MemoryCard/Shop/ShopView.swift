//
//  ShopView.swift
//  MemoryCard
//
//  Created by yc on 2023/12/05.
//

import SwiftUI

struct ShopView: View {
    
    @Binding var isShow: Bool
    let iap = IAPManager(productID: ["YC.MemoryCard.inapp.1"])
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    HStack {
                        Image(systemName: "sdcard")
                            .resizable()
                            .scaledToFit()
                            .padding(32)
                            .foregroundStyle(.cyan)
                            .frame(height: 300)
                            .rotationEffect(.radians(-.pi / 6.0))
                        Spacer()
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Spacer()
                            .frame(width: 100)
                        Image(systemName: "sdcard")
                            .resizable()
                            .scaledToFit()
                            .padding(32)
                            .foregroundStyle(.orange)
                            .frame(height: 300)
                            .rotationEffect(.radians(.pi / 6.0))
                    }
                }
                
                Button {
                    
                    iap.buy()
                } label: {
                    
                    HStack {
                        Spacer()
                        Text("Card+5")
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12.0)
                            .stroke(.gray.opacity(0.3), lineWidth: 1.0)
                    }
                    .padding(.horizontal, 16)
                }
                
                Spacer()
            }
            .navigationTitle("이용권 구매")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShow = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Text("구매 복원")
                    }
                }
            }
        }
    }
}

import StoreKit

final class IAPManager: NSObject {
    let productID: Set<String>
    
    var productRequest: SKProductsRequest?
    
    init(productID: Set<String>) {
        self.productID = productID
        super.init()
        
    }
    
    func buy() {
        productRequest = SKProductsRequest(productIdentifiers: productID)
        productRequest?.delegate = self
        productRequest?.start()
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse
    ) {
        let products = response.products
        
        let payment = SKPayment(product: products.first!)
        
        SKPaymentQueue.default().add(payment)
    }
}
