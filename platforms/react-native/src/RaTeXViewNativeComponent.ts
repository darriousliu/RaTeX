import type {Float, BubblingEventHandler} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type {HostComponent, ViewProps} from 'react-native';

type OnErrorEvent = {error: string};

export interface NativeProps extends ViewProps {
  latex: string;
  fontSize?: Float;
  onError?: BubblingEventHandler<OnErrorEvent>;
}

export default codegenNativeComponent<NativeProps>(
  'RaTeXView',
) as HostComponent<NativeProps>;
