import React from 'react';
import type {StyleProp, ViewStyle} from 'react-native';
import RaTeXViewNativeComponent from './RaTeXViewNativeComponent';

export interface RaTeXViewProps {
  latex: string;
  fontSize?: number;
  style?: StyleProp<ViewStyle>;
  onError?: (e: {nativeEvent: {error: string}}) => void;
}

export function RaTeXView({
  latex,
  fontSize = 24,
  style,
  onError,
}: RaTeXViewProps): React.JSX.Element {
  return (
    <RaTeXViewNativeComponent
      latex={latex}
      fontSize={fontSize}
      style={style}
      onError={onError}
    />
  );
}
