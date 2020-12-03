//
//  MenuList.swift
//  Utility
//
//  Created by Tian on 2020/10/30.
//

import SwiftUI

struct MenuList: View {
    var body: some View {
        NavigationView {
            List (DemoOptItems) { item in
                let mItem = MenuItem(item: item)
                Button(action: {
                    if let tap = item.tap {
                        tap(mItem)
                    }
                }, label: {
                    mItem
                })
            }
        }.navigationTitle("Menu")
    }
}

struct MenuList_Previews: PreviewProvider {
    static var previews: some View {
        MenuList()
    }
}
