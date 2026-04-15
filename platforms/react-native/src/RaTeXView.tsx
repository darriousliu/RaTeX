import React, {useState, useCallback, useEffect} from 'react';
import {StyleSheet} from 'react-native';
import type {StyleProp, ViewStyle} from 'react-native';
import RaTeXViewNativeComponent from './RaTeXViewNativeComponent';

export interface RaTeXViewProps {
  latex: string;
  fontSize?: number;
  /** true (default) = display/block style ($$...$$); false = inline/text style ($...$). */
  displayMode?: boolean;
  style?: StyleProp<ViewStyle>;
  onError?: (e: {nativeEvent: {error: string}}) => void;
  /** Called when content size is measured (e.g. for scroll layout). */
  onContentSizeChange?: (e: {
    nativeEvent: {width: number; height: number};
  }) => void;
}

export function RaTeXView({
  latex,
  fontSize = 24,
  displayMode = true,
  style,
  onError,
  onContentSizeChange,
}: RaTeXViewProps): React.JSX.Element {
  const [contentSize, setContentSize] = useState<{
    width: number;
    height: number;
  } | null>(null);

  // When inputs change, drop the cached measurement so the view can shrink/grow
  // immediately instead of keeping a stale width/height until the next event arrives.
  useEffect(() => {
    setContentSize(null);
  }, [latex, fontSize, displayMode]);

  const handleContentSizeChange = useCallback(
    (e: {nativeEvent: {width: number; height: number}}) => {
      setContentSize({
        width: e.nativeEvent.width,
        height: e.nativeEvent.height,
      });
      onContentSizeChange?.(e);
    },
    [onContentSizeChange],
  );

  // Respect explicit width/height from user styles.
  // Auto-apply measured size only when width/height are not provided.
  const flatStyle = StyleSheet.flatten(style) as ViewStyle | undefined;
  const hasWidth = typeof flatStyle?.width === 'number';
  const hasHeight = typeof flatStyle?.height === 'number';

  const resolvedStyle = contentSize
    ? [
        style,
        {
          ...(hasWidth ? {} : {width: contentSize.width}),
          ...(hasHeight ? {} : {height: contentSize.height}),
        },
      ]
    : style;

  return (
    <RaTeXViewNativeComponent
      latex={latex}
      fontSize={fontSize}
      displayMode={displayMode}
      style={resolvedStyle}
      onError={onError}
      onContentSizeChange={handleContentSizeChange}
    />
  );
}
