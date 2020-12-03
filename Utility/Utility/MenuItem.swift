//
//  MenuItem.swift
//  Utility
//
//  Created by Tian on 2020/10/30.
//

import SwiftUI

typealias MenuItemTapAction = (MenuItem?) -> ()

struct OptItem: Identifiable {
    var id = UUID()
    var name: String = ""
    var tap: MenuItemTapAction?
}

struct MenuItem: View {
    var item: OptItem?
    var body: some View {
        Text(item?.name ?? "")
    }
}

struct MenuItem_Previews: PreviewProvider {
    static var previews: some View {
        MenuItem(item: DemoOptItems[0])
    }
}
