/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import lottie from '@ohos/lottie';
import { AnimationItem } from '@ohos/lottie';
import { HeaderComponent } from './HeaderComponent';

@Entry
@Component
struct DownloadImg {
  @State isNet: string = this.getResourceString($r("app.string.download_is_network"));
  // 渲染构建上下文
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  // 动画名称
  private animateName: string = "Red envelope";

  aboutToDisappear() {
    lottie.destroy(this.animateName);
  }

  build() {
    Column() {
      HeaderComponent({ text: $r("app.string.load_img") })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Row({ space: 10 }) {
          // 关联画布
          Canvas(this.canvasRenderingContext)
            .width(200)
            .height(200)
            .backgroundColor(Color.Gray)
            .onReady(() => {
              // 可在此生命回调周期中加载动画，可以保证动画尺寸正确
              this.animateItem?.resize();
            })
            .onDisAppear(() => {
              lottie.destroy(this.animateName);
            })

        }

        // 加载网络Img
        Row() {
          Button($r("app.string.load_img"))
            .onClick(() => {
              lottie.destroy(this.animateName)
              this.animateItem = lottie.loadAnimation({
                // uri: "http://10.50.80.58:4000/tpc/download/RedEnvelope.json",
                path: "common/lottie/data_url.json",
                isNetwork: false,
                container: this.canvasRenderingContext,
                renderer: 'canvas', // canvas 渲染模式
                loop: true,
                autoplay: true,
                name: this.animateName,
              })
              this.animateItem.addEventListener('error', (args: Object): void => {
                console.info("error:" + JSON.stringify(args));
              });
            })
          Button(this.isNet)
            .onClick(() => {
              if (this.animateItem != null) {
                console.info("isNetLoad:" + this.animateItem.isNetLoad);
                this.isNet = this.getResourceString($r("app.string.download_is_network")) + this.animateItem.isNetLoad
              }
            })
        }.margin({ top: 5 })

        Row() {
          Button($r("app.string.download_clear_cache"))
            .onClick(() => {
              lottie.clearFileCache("common/lottie/data_url.json", this.canvasRenderingContext);
            })
          Button($r("app.string.play"))
            .onClick(() => {
              lottie.play();
            })

          Button($r("app.string.pause"))
            .onClick(() => {
              lottie.pause();
            })

          Button($r("app.string.destroy"))
            .onClick(() => {
              if (this.animateItem != null) {
                this.animateItem = null;
              }
              lottie.destroy();
            })
        }.margin({ top: 5 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  onBackPress(): boolean | void {
    if (this.animateItem != null) {
      this.animateItem = null;
    }
    lottie.destroy(this.animateName);
    return false;
  }
  getResourceString(res: Resource){
    return getContext().resourceManager.getStringSync(res.id)
  }
}