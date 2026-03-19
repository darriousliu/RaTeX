# ratex-react-native

Native LaTeX math rendering for React Native — no WebView, no JavaScript math engine. Formulas are parsed and laid out in Rust (compiled to a native library) and drawn directly onto a native Canvas using KaTeX fonts.

> Chinese documentation: [README.zh.md](./README.zh.md)

## Features

- Renders LaTeX math natively on iOS and Android
- Supports both the **New Architecture** (Fabric / JSI) and the **Old Architecture** (Bridge)
- Measures rendered content size for scroll and dynamic layout
- Error callback for parse failures
- Bundles all required KaTeX fonts — no extra setup

## Requirements

| Dependency | Version |
|-----------|---------|
| React Native | ≥ 0.73 |
| React | ≥ 18 |
| iOS | ≥ 14.0 |
| Android | minSdk 21 (Android 5.0+) |

## Installation

```sh
npm install ratex-react-native
```

### iOS — pod install

```sh
cd ios && pod install
```

### Android

No additional steps required. The native `.so` libraries are bundled automatically.

## Usage

```tsx
import { RaTeXView } from 'ratex-react-native';

function MathFormula() {
  return (
    <RaTeXView
      latex="\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}"
      fontSize={24}
      onError={(e) => console.warn('LaTeX error:', e.nativeEvent.error)}
    />
  );
}
```

## API

### `<RaTeXView />`

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `latex` | `string` | — | LaTeX math-mode string to render (required) |
| `fontSize` | `number` | `24` | Font size in **dp** (density-independent pixels). The rendered formula scales proportionally. |
| `style` | `StyleProp<ViewStyle>` | — | Standard React Native style. Width and height are automatically set from measured content unless overridden. |
| `onError` | `(e: { nativeEvent: { error: string } }) => void` | — | Called when the LaTeX string fails to parse. |
| `onContentSizeChange` | `(e: { nativeEvent: { width: number; height: number } }) => void` | — | Called after layout with the formula's rendered dimensions in dp. Useful for scroll views or dynamic containers. |

### Content size auto-sizing

`RaTeXView` automatically applies the measured `width` and `height` from `onContentSizeChange` to its own style. This means you can use `wrap_content`-style layout without specifying explicit dimensions:

```tsx
<ScrollView horizontal>
  <RaTeXView latex="\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}" fontSize={28} />
</ScrollView>
```

## Architecture Support

### New Architecture (Fabric)

The component is defined via **Codegen** (`RaTeXViewNativeComponent.ts`) and uses Fabric's synchronous rendering pipeline. No additional configuration is needed — React Native ≥ 0.73 with `newArchEnabled=true` picks it up automatically.

### Old Architecture (Bridge)

A `RaTeXViewManager` (iOS: `RaTeXViewManager.mm`, Android: `RaTeXViewManager.kt`) is provided for projects still on the classic bridge. The same JS component works for both architectures.

## Font size note

`fontSize` is interpreted as **dp (density-independent pixels)**, not CSS `pt` or raw pixels. On a 3× density screen, a `fontSize={24}` formula renders at 72 physical pixels tall. This matches React Native's standard layout unit.

## License

MIT
