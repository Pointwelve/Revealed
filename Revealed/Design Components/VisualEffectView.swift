//
//  VisualEffectView.swift
//  Revealed
//
//  Created by KokHong on 30/3/20.
//  Copyright © 2020 Pointwelve. All rights reserved.
//

import SwiftUI
#if canImport(UIKit)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

/// https://github.com/AlanQuatermain/AQUI/blob/421e807d92d1ee2ff85058dc518e0bcaf8379dff/Sources/AQUI/VisualEffectView.swift
/// The key used to access into the `EnvironmentValues` data set.
struct VisualEffectKey: EnvironmentKey {
  typealias Value = VisualEffect?
  static var defaultValue: Value = nil
}

extension EnvironmentValues {
  /// The visual effect applied to views tagged with the `.visualEffect(_:)`
  /// modifier, if any.
  public var visualEffect: VisualEffect? {
    get { self[VisualEffectKey.self] }
    set { self[VisualEffectKey.self] = newValue }
  }
}

struct VisualEffectPreferenceKey: PreferenceKey {
  typealias Value = VisualEffect?
  static var defaultValue: VisualEffect?

  static func reduce(value: inout VisualEffect?, nextValue: () -> VisualEffect?) {
    // use the lowest value only
    // would be nice to have these things be combinable, though.
    guard value == nil else { return }
    value = nextValue()
  }
}

/// Describes a visual effect to be applied to the background of a view, typically to provide
/// a blurred rendition of the content below the view in z-order.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, *)
@available(watchOS, unavailable)
public enum VisualEffect: Equatable, Hashable {
  /// The material types available for the effect.
  ///
  /// On iOS and tvOS, this uses material types to specify the desired effect, while on
  /// macOS the materials are specified semantically based on their expected use case.
  public enum Material: Equatable, Hashable {
    /// A default appearance, suitable for most cases.
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, *)
    case `default`

    /// A blur simulating a very thin material.
    @available(iOS 13.0, tvOS 13.0, *)
    @available(OSX, unavailable)
    case ultraThin

    /// A blur simulating a thin material.
    @available(iOS 13.0, tvOS 13.0, *)
    @available(OSX, unavailable)
    case thin

    /// A blur simulating a thicker than normal material.
    @available(iOS 13.0, tvOS 13.0, *)
    @available(OSX, unavailable)
    case thick

    /// A blur matching the system chrome.
    @available(iOS 13.0, tvOS 13.0, *)
    @available(OSX, unavailable)
    case chrome

    /// A material suitable for a window titlebar.
    @available(OSX 10.15, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(macCatalyst, unavailable)
    case titlebar

    /// A material used for the background of a window.
    @available(OSX 10.15, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(macCatalyst, unavailable)
    case windowBackground

    /// A material used for an inline header view.
    /// - Parameter behindWindow: `true` if the effect should use
    ///     the content behind the window, `false` to use content within
    ///     the window at a lower z-order.
    @available(OSX 10.15, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(macCatalyst, unavailable)
    case headerView(behindWindow: Bool)

    /// A material used for the background of a content view, e.g. a scroll
    /// view or a list.
    /// - Parameter behindWindow: `true` if the effect should use
    ///     the content behind the window, `false` to use content within
    ///     the window at a lower z-order.
    @available(OSX 10.15, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(macCatalyst, unavailable)
    case contentBackground(behindWindow: Bool)

    /// A material used for the background of a view that contains a
    /// 'page' interface, as in some document-based applications.
    /// - Parameter behindWindow: `true` if the effect should use
    ///     the content behind the window, `false` to use content within
    ///     the window at a lower z-order.
    @available(OSX 10.15, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(macCatalyst, unavailable)
    case behindPageBackground(behindWindow: Bool)
  }

  /// A standard effect that adapts to the current `ColorScheme`.
  case system
  /// A standard effect that uses the system light appearance.
  case systemLight
  /// A standard effect that uses the system dark appearance.
  case systemDark

  /// An adaptive effect with the given material that changes to match
  /// the current `ColorScheme`.
  case adaptive(Material)
  /// An effect that uses the given material with the system light appearance.
  case light(Material)
  /// An effect that uses the given material with the system dark appearance.
  case dark(Material)
}

#if os(iOS) || targetEnvironment(macCatalyst)
  extension VisualEffect {
    /// Vends an appropriate `UIVisualEffect`.
    var parameters: UIVisualEffect { UIBlurEffect(style: blurStyle) }

    private var blurStyle: UIBlurEffect.Style {
      switch self {
      case .system: return .systemMaterial
      case .systemLight: return .systemMaterialLight
      case .systemDark: return .systemMaterialDark
      case let .adaptive(material):
        switch material {
        case .ultraThin: return .systemUltraThinMaterial
        case .thin: return .systemThinMaterial
        case .default: return .systemMaterial
        case .thick: return .systemThickMaterial
        case .chrome: return .systemChromeMaterial
        }
      case let .light(material):
        switch material {
        case .ultraThin: return .systemUltraThinMaterialLight
        case .thin: return .systemThinMaterialLight
        case .default: return .systemMaterialLight
        case .thick: return .systemThickMaterialLight
        case .chrome: return .systemChromeMaterialLight
        }
      case let .dark(material):
        switch material {
        case .ultraThin: return .systemUltraThinMaterialDark
        case .thin: return .systemThinMaterialDark
        case .default: return .systemMaterialDark
        case .thick: return .systemThickMaterialDark
        case .chrome: return .systemChromeMaterialDark
        }
      }
    }
  }

#elseif os(tvOS)
  extension VisualEffect {
    /// Vends an appropriate `UIVisualEffect`.
    var parameters: UIVisualEffect {
      switch self {
      case .adaptive, .system: return UIBlurEffect(style: .regular)
      case .light, .systemLight: return UIBlurEffect(style: .light)
      case .dark, .systemDark: return UIBlurEffect(style: .dark)
      }
    }
  }

#elseif os(macOS)
  extension VisualEffect {
    /// A type describing the values passed to an `NSVisualEffectView`.
    struct NSEffectParameters {
      var material: NSVisualEffectView.Material = .contentBackground
      var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
      var appearance: NSAppearance?
    }

    /// Vends an appropriate `NSEffectParameters`.
    var parameters: NSEffectParameters {
      switch self {
      case .system: return NSEffectParameters()
      case .systemLight: return NSEffectParameters(appearance: NSAppearance(named: .aqua))
      case .systemDark: return NSEffectParameters(appearance: NSAppearance(named: .darkAqua))
      case .adaptive:
        return NSEffectParameters(material: material,
                                  blendingMode: blendingMode)
      case .light:
        return NSEffectParameters(material: material,
                                  blendingMode: blendingMode,
                                  appearance: NSAppearance(named: .aqua))
      case .dark:
        return NSEffectParameters(material: material,
                                  blendingMode: blendingMode,
                                  appearance: NSAppearance(named: .darkAqua))
      }
    }

    private var material: NSVisualEffectView.Material {
      switch self {
      case .system, .systemLight, .systemDark:
        return .contentBackground
      case let .adaptive(material), let .light(material), let .dark(material):
        switch material {
        case .default, .contentBackground: return .contentBackground
        case .titlebar: return .titlebar
        case .headerView: return .headerView
        case .behindPageBackground: return .underPageBackground
        case .windowBackground: return .windowBackground
        }
      }
    }

    private var blendingMode: NSVisualEffectView.BlendingMode {
      switch self {
      case .system, .systemLight, .systemDark:
        return .behindWindow
      case let .adaptive(material),
           let .light(material),
           let .dark(material):
        switch material {
        case .default, .windowBackground:
          return .behindWindow
        case .titlebar:
          return .withinWindow
        case let .contentBackground(b),
             let .headerView(b),
             let .behindPageBackground(b):
          return b ? .behindWindow : .withinWindow
        }
      }
    }
  }
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, *)
@available(watchOS, unavailable)
struct VisualEffectView: View {
  @State private var effect: VisualEffect?
  private let content: _PlatformVisualEffectView

  var body: some View {
    content
      .environment(\.visualEffect, effect)
      .onPreferenceChange(VisualEffectPreferenceKey.self) {
        self.effect = $0
      }
  }

  fileprivate init(effect: VisualEffect) {
    _effect = State(wrappedValue: effect)
    content = _PlatformVisualEffectView()
  }

  #if os(macOS)
    private struct _PlatformVisualEffectView: NSViewRepresentable {
      func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.autoresizingMask = [.width, .height]
        return view
      }

      func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        guard let params = context.environment.visualEffect?.parameters else {
          // disable the effect
          nsView.isHidden = true
          return
        }
        nsView.isHidden = false
        nsView.material = params.material
        nsView.blendingMode = params.blendingMode
        nsView.appearance = params.appearance

        // mark emphasized if it contains the first responder
        if let resp = nsView.window?.firstResponder as? NSView {
          nsView.isEmphasized = resp === nsView || resp.isDescendant(of: nsView)
        } else {
          nsView.isEmphasized = false
        }
      }
    }

  #elseif canImport(UIKit)
    private struct _PlatformVisualEffectView: UIViewRepresentable {
      func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = context.environment.visualEffect ?? .system

        let view = UIVisualEffectView(effect: effect.parameters)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
      }

      func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        guard let effect = context.environment.visualEffect else {
          // disable the effect
          uiView.isHidden = true
          return
        }

        uiView.isHidden = false
        uiView.effect = effect.parameters
      }
    }
  #endif
}

extension View {
  /// Applies a `VisualEffect` to the background of this view.
  /// - Parameter effect: The effect to use. If unspecified, uses `VisualEffect.system`.
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, *)
  @available(watchOS, unavailable)
  public func visualEffect(_ effect: VisualEffect = .system) -> some View {
    background(VisualEffectView(effect: effect))
  }

  /// Advertises a view's preference for the `VisualEffect` to be applied to its nearest
  /// ancestor that has the `.visualEffect(_:)` modifier.
  /// - Parameter effect: The requested effect.
  @available(OSX 10.15, iOS 13.0, tvOS 13.0, macCatalyst 13.0, *)
  @available(watchOS, unavailable)
  public func visualEffectPreference(_ effect: VisualEffect) -> some View {
    preference(key: VisualEffectPreferenceKey.self, value: effect)
  }
}
