//
//  ContentView.swift
//  Utility
//
//  Created by Tian on 2020/10/27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MenuList()
        Image(uiImage: QRCodeHelper.buildQRCode(with: "qrcode", size: 100))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
