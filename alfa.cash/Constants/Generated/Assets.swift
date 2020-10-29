// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let ada = ImageAsset(name: "ada")
  internal static let adx = ImageAsset(name: "adx")
  internal static let ae = ImageAsset(name: "ae")
  internal static let ardr = ImageAsset(name: "ardr")
  internal static let ark = ImageAsset(name: "ark")
  internal static let bat = ImageAsset(name: "bat")
  internal static let bcc = ImageAsset(name: "bcc")
  internal static let bch = ImageAsset(name: "bch")
  internal static let bcn = ImageAsset(name: "bcn")
  internal static let block = ImageAsset(name: "block")
  internal static let bnb = ImageAsset(name: "bnb")
  internal static let bnt = ImageAsset(name: "bnt")
  internal static let btc = ImageAsset(name: "btc")
  internal static let btcd = ImageAsset(name: "btcd")
  internal static let btg = ImageAsset(name: "btg")
  internal static let btm = ImageAsset(name: "btm")
  internal static let bts = ImageAsset(name: "bts")
  internal static let cnx = ImageAsset(name: "cnx")
  internal static let cvc = ImageAsset(name: "cvc")
  internal static let dash = ImageAsset(name: "dash")
  internal static let dcr = ImageAsset(name: "dcr")
  internal static let dgb = ImageAsset(name: "dgb")
  internal static let dgd = ImageAsset(name: "dgd")
  internal static let doge = ImageAsset(name: "doge")
  internal static let edg = ImageAsset(name: "edg")
  internal static let emc2 = ImageAsset(name: "emc2")
  internal static let eos = ImageAsset(name: "eos")
  internal static let etc = ImageAsset(name: "etc")
  internal static let eth = ImageAsset(name: "eth")
  internal static let ethos = ImageAsset(name: "ethos")
  internal static let etp = ImageAsset(name: "etp")
  internal static let fct = ImageAsset(name: "fct")
  internal static let fun = ImageAsset(name: "fun")
  internal static let game = ImageAsset(name: "game")
  internal static let gas = ImageAsset(name: "gas")
  internal static let gbyte = ImageAsset(name: "gbyte")
  internal static let gno = ImageAsset(name: "gno")
  internal static let gnt = ImageAsset(name: "gnt")
  internal static let grs = ImageAsset(name: "grs")
  internal static let gxs = ImageAsset(name: "gxs")
  internal static let hsr = ImageAsset(name: "hsr")
  internal static let icn = ImageAsset(name: "icn")
  internal static let iot = ImageAsset(name: "iot")
  internal static let kmd = ImageAsset(name: "kmd")
  internal static let knc = ImageAsset(name: "knc")
  internal static let lsk = ImageAsset(name: "lsk")
  internal static let ltc = ImageAsset(name: "ltc")
  internal static let maid = ImageAsset(name: "maid")
  internal static let mco = ImageAsset(name: "mco")
  internal static let mnx = ImageAsset(name: "mnx")
  internal static let mona = ImageAsset(name: "mona")
  internal static let mtl = ImageAsset(name: "mtl")
  internal static let nav = ImageAsset(name: "nav")
  internal static let neo = ImageAsset(name: "neo")
  internal static let nxs = ImageAsset(name: "nxs")
  internal static let nxt = ImageAsset(name: "nxt")
  internal static let omg = ImageAsset(name: "omg")
  internal static let pay = ImageAsset(name: "pay")
  internal static let pivx = ImageAsset(name: "pivx")
  internal static let pot = ImageAsset(name: "pot")
  internal static let power = ImageAsset(name: "power")
  internal static let ppc = ImageAsset(name: "ppc")
  internal static let ppt = ImageAsset(name: "ppt")
  internal static let pura = ImageAsset(name: "pura")
  internal static let qash = ImageAsset(name: "qash")
  internal static let qtum = ImageAsset(name: "qtum")
  internal static let rdn = ImageAsset(name: "rdn")
  internal static let rep = ImageAsset(name: "rep")
  internal static let salt = ImageAsset(name: "salt")
  internal static let san = ImageAsset(name: "san")
  internal static let sc = ImageAsset(name: "sc")
  internal static let sky = ImageAsset(name: "sky")
  internal static let sngls = ImageAsset(name: "sngls")
  internal static let snt = ImageAsset(name: "snt")
  internal static let start = ImageAsset(name: "start")
  internal static let steem = ImageAsset(name: "steem")
  internal static let storj = ImageAsset(name: "storj")
  internal static let sys = ImageAsset(name: "sys")
  internal static let trx = ImageAsset(name: "trx")
  internal static let ubq = ImageAsset(name: "ubq")
  internal static let usdt = ImageAsset(name: "usdt")
  internal static let ven = ImageAsset(name: "ven")
  internal static let vtc = ImageAsset(name: "vtc")
  internal static let waves = ImageAsset(name: "waves")
  internal static let wtc = ImageAsset(name: "wtc")
  internal static let xem = ImageAsset(name: "xem")
  internal static let xlm = ImageAsset(name: "xlm")
  internal static let xmr = ImageAsset(name: "xmr")
  internal static let xrp = ImageAsset(name: "xrp")
  internal static let xuc = ImageAsset(name: "xuc")
  internal static let xvg = ImageAsset(name: "xvg")
  internal static let xzc = ImageAsset(name: "xzc")
  internal static let zec = ImageAsset(name: "zec")
  internal static let zen = ImageAsset(name: "zen")
  internal static let zrx = ImageAsset(name: "zrx")
  internal static let kBackgroundColor = ColorAsset(name: "kBackgroundColor")
  internal static let kCellBackgroundBlueColor = ColorAsset(name: "kCellBackgroundBlueColor")
  internal static let kErrorColor = ColorAsset(name: "kErrorColor")
  internal static let kSubtitleColor = ColorAsset(name: "kSubtitleColor")
  internal static let kTextColor35 = ColorAsset(name: "kTextColor35")
  internal static let kTintColor = ColorAsset(name: "kTintColor")
  internal static let legal = ImageAsset(name: "legal")
  internal static let security = ImageAsset(name: "security")
  internal static let username = ImageAsset(name: "username")
  internal static let arrowWhite = ImageAsset(name: "arrow-white")
  internal static let arrowWhite2 = ImageAsset(name: "arrowWhite2")
  internal static let backArrow = ImageAsset(name: "backArrow")
  internal static let backArrowBlack = ImageAsset(name: "backArrowBlack")
  internal static let bellNotification = ImageAsset(name: "bellNotification")
  internal static let checkmarkBlue = ImageAsset(name: "checkmark_blue")
  internal static let checkmarkWhite = ImageAsset(name: "checkmark_white")
  internal static let copy = ImageAsset(name: "copy")
  internal static let digital = ImageAsset(name: "digital")
  internal static let emptyWallet = ImageAsset(name: "emptyWallet")
  internal static let faceId = ImageAsset(name: "faceId")
  internal static let filter = ImageAsset(name: "filter")
  internal static let icKeyboardBack = ImageAsset(name: "icKeyboardBack")
  internal static let icnExchanged = ImageAsset(name: "icnExchanged")
  internal static let icnReceived = ImageAsset(name: "icnReceived")
  internal static let icnSent = ImageAsset(name: "icnSent")
  internal static let keypad = ImageAsset(name: "keypad")
  internal static let logo = ImageAsset(name: "logo")
  internal static let menu = ImageAsset(name: "menu")
  internal static let searchIcn = ImageAsset(name: "searchIcn")
  internal static let touchIdIcn = ImageAsset(name: "touchIdIcn")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
