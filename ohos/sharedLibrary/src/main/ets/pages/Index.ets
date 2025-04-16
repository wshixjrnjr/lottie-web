/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import lottie from '@ohos/lottie';
import { AnimationItem } from '@ohos/lottie';
import util from '@ohos.util';
import common from '@ohos.app.ability.common';

@Entry({routeName : 'myPage'})
@Component
struct Index {
  @State message: string = 'Hello World'
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null;
  private mLottieData: object | null = null;
  private animateName: string = "grunt";

  async aboutToAppear(){
    let resStr = new util.TextDecoder('utf-8',{ignoreBOM: true});
    let context = getContext(this).createModuleContext('sharedLibrary') as common.UIAbilityContext
    context.resourceManager.getRawFile('grunt.json',(err: Error,data: Uint8Array) =>{
      if(data === null || data === undefined || data.buffer=== undefined){
        return;
      }
      let lottieStr = resStr.decode(new Uint8Array(data.buffer));
      this.mLottieData = JSON.parse(lottieStr);
    })
  }
  aboutToDisappear(){
    lottie.destroy()
  }
  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Row({ space: 10 }) {

        Canvas(this.canvasRenderingContext)
          .width(200)
          .height(200)
          .backgroundColor(Color.Gray)
          .onReady(() => {
            // 可在此生命回调周期中加载动画，可以保证动画尺寸正确
          })
          .onDisAppear(() => {
            lottie.destroy(this.animateName);
          })
      }

      Row() {
        Button($r("app.string.load_grunt"))
          .onClick(() => {
            lottie.destroy(this.animateName)
            let contexts = getContext(this).createModuleContext('sharedLibrary') as common.UIAbilityContext
            this.animateItem = lottie.loadAnimation({
              container: this.canvasRenderingContext,
              renderer: 'canvas', // canvas 渲染模式
              loop: true,
              autoplay: true,
              context: contexts,
              name: this.animateName,
              animationData: this.mLottieData,
            })
          })
      }.margin({ top: 5 })

      Row() {
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
}