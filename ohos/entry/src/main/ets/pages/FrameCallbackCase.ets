import { HeaderComponent } from './HeaderComponent';
import { FrameCallback } from '@kit.ArkUI';

class MySharedData {
  public status: string = '';
}

class MyFrameCallback extends FrameCallback {
  public sharedData: MySharedData;
  public requestNextFrame?: () => void;
  private lastFrameTime?: number = undefined;

  constructor(sharedData: MySharedData) {
    super()
    this.sharedData = sharedData;
  }

  onFrame(frameTimeNanos: number) {
    if (this.requestNextFrame) {
      this.requestNextFrame();
    }

    let period = 0;
    if (this.lastFrameTime !== undefined) {
      period = frameTimeNanos - this.lastFrameTime;
    }
    this.lastFrameTime = frameTimeNanos;

    this.sharedData.status = `timestamp: ${frameTimeNanos}\nperiod:${period}ns`;
    console.info(this.sharedData.status);
  }
}

@Entry
@Component
struct FrameCallbackCase {
  @State sharedData: MySharedData = new MySharedData();
  @State delayTime: number = 20;
  private myFrameCallback?: MyFrameCallback;

  build() {
    Stack() {
      Column() {
        HeaderComponent({ text: $r("app.string.coordinatorExample_title") })
        Text(`${this.sharedData.status}`).height(100)
        Row() {
          Text('延迟时间:')
          TextInput({ text: `${this.delayTime}` })
            .height(40)
            .width(100)
            .type(InputType.Number)
            .padding(5)
            .borderRadius(3)
            .onChange((value) => {
              this.delayTime = Number(value);
            })
          Text(`${this.delayTime}`)
        }

        Button('点击触发postDelayedFrameCallback')
          .onClick(() => {
            let uiContext = this.getUIContext();
            if (!this.myFrameCallback) {
              // 确保单例
              this.myFrameCallback = new MyFrameCallback(this.sharedData);
              uiContext.postDelayedFrameCallback(this.myFrameCallback, this.delayTime);
            }

            this.myFrameCallback.requestNextFrame = () => {
              uiContext.postDelayedFrameCallback(this.myFrameCallback, this.delayTime);
            }
          })
        Button('停止')
          .onClick(() => {
            if (this.myFrameCallback) {
              this.myFrameCallback.requestNextFrame = undefined;
              this.myFrameCallback = undefined;
            }
          })
      }.height('100%').width('100%')
    }
    .width("100%")
  }
}