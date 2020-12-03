//
//  OptItem.swift
//  Utility
//
//  Created by Tian on 2020/10/30.
//

import Foundation

var globalTimer: DispatchSource?

let DemoOptItems = [
    OptItem(name: "GCDTimer - Start", tap: { (item) in
        guard globalTimer == nil else {
            return
        }
        print("timer will start! \(Thread.current)")
        globalTimer = UtilityTools.startGCDTimer(withInterval: 3) {
            print("gcd timer invoked! \(Thread.current)")
        }
    }),
    OptItem(name: "GCDTimer - Stop", tap: { (item) in
        if let timer = globalTimer {
            print("timer will stop! \(Thread.current)")
            UtilityTools.stopGCDTimer(timer)
        }
    }),
    OptItem(name: "DeviceInfo - Print", tap: { (item) in
        print("\(NWDeviceInfo.getRemainingDiskSpace()) - \(NWDeviceInfo.getTotalDiskSpace())")
    }),
    OptItem(name: "Swizzler - Add", tap: { (item) in
        NWSwizzlerTest.addSwizzler()
    }),
    OptItem(name: "Swizzler - Test", tap: { (item) in
        NWSwizzlerClass().method3("param1", param2: "param2")
        NWSwizzlerClass.method4()
    }),
    OptItem(name: "UserDataStore-Get", tap: { (item) in
        let urls = [
            "https://down.sandai.net/mac/thunder_3.4.1.4368.dmg",
            "https://image.baidu.com/search/down?tn=download&word=download&ie=utf8&fr=detail&url=https%3A%2F%2Ftimgsa.baidu.com%2Ftimg%3Fimage%26quality%3D80%26size%3Db9999_10000%26sec%3D1604070329622%26di%3D6c6d553d325e5c6b62aab69552bc0171%26imgtype%3D0%26src%3Dhttp%253A%252F%252Fimg.hx2cars.com%252Fupload%252Fnewimg1%252FM04%252FAF%252FF9%252FClo8w1x8wieAdCMXAAMfmTNg58M709_small_800_600.jpg&thumburl=https%3A%2F%2Fss0.bdstatic.com%2F70cFuHSh_Q1YnxGkpoWK1HF6hhy%2Fit%2Fu%3D2667762009%2C1302650551%26fm%3D26%26gp%3D0.jpg",
            "https://cc-download.wondershare.cc/mac-pdfelement_full5546.zip",
            "http://dldir1.qq.com/dlomg/qqcom/mini/QQNewsMini5.exe",
        ]
        NWSmallFileDownloader.download(withURLs: urls, filePaths: nil) {
            print("download finished!")
        }
    }),
    OptItem(name: "URL Encode / Decode", tap: { (item) in
        let encode = UtilityTools.urlEncode("你好")
        let decode = UtilityTools.urlDecode(encode)
        print("\(encode) - \(decode)")
    }),
    OptItem(name: "UserDataStore-Get", tap: { (item) in
        print(UserDataStore.getHashedData() ?? "none")
    }),
    OptItem(name: "UserDataStore-Store", tap: { (item) in
        // 同步读，异步写
        // 一些时候可能需要同步写、异步读
        UserDataStore.setAndHashData("helloworld", forType: UserDataType.fieldName)
        UserDataStore.setAndHashData("test@gmail.com", forType: UserDataType.fieldEmail)
    }),
    OptItem(name: "UserDataStore-Clear", tap: { (item) in
        UserDataStore.clearData(forType: .fieldName)
        UserDataStore.clearData(forType: .fieldEmail)
    }),
    
]
