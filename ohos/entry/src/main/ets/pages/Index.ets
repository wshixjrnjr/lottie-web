/**
 * MIT License
 *
 * Copyright (C) 2021 Huawei Device Co., Ltd.
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

import lottie from '@ohos/lottie'
import { AnimationItem, AnimationEventCallback, LogUtil } from '@ohos/lottie'
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { common, UIAbility, Want } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State animationDuration: string = this.getResourceString($r('app.string.get_duration'));
  @State pauseState: string = this.getResourceString($r('app.string.check_state'));
  @State isCanvasVisible: Visibility = Visibility.Visible;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private mainRenderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private mainCanvasRenderingContext: CanvasRenderingContext2D =
    new CanvasRenderingContext2D(this.mainRenderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateItem2: AnimationItem | null = null;
  private animateName: string = "grunt";
  @State subFramed?: boolean = undefined;
  private frameNo: string = '5';
  private frameSeconds: string = '6'
  private maxFrameRate: string = '10';
  private frameRate: string = '30';
  @State currentFrame?: number = undefined;
  @State currentRawFrame?: number = undefined;
  @State totalFrames?: number = undefined;
  @State playCount?: number = undefined;
  @State totalPlayedCount: number = 0;
  @State playDirecton?: number = undefined;
  @State playSpeed?: number = undefined;
  @State buttonBkColor: ResourceColor = $r('sys.color.ohos_id_color_floating_button_bg_normal');
  private specifiedBkColor: ResourceColor = Color.Blue;
  private specifiedAnimation: boolean = false;
  private onlyCurrentAbility: boolean = false;

  updateAllStates() {
    this.subFramed = this.animateItem?.isSubframeEnabled;
    this.currentFrame = this.animateItem?.currentFrame;
    this.currentRawFrame = this.animateItem?.currentRawFrame;
    this.totalFrames = this.animateItem?.totalFrames;
    this.playCount = this.animateItem?.playCount;
    this.playDirecton = this.animateItem?.playDirection;
    this.playSpeed = this.animateItem?.playSpeed;
  }

  pollingAnimationsInfo() {
    let animations: AnimationItem[] = lottie.getRegisteredAnimations();
    let text = `CURRENT ABILITY NAME: ${(getContext() as common.UIAbilityContext)?.abilityInfo.name}`;
    let n = 1;
    animations.forEach((value) => {
      text += `\n${n++}:${value.animationID}: ${value.context.abilityInfo.name} ${value.isPaused ? 'paused' :
        'playing'} ${value.currentFrame.toFixed(2)}`;
    })
    console.info(`lottie_ohos all current animations:\n${text}`);
  }

  aboutToAppear(): void {
    console.info(`lottie_ohos Index Page @${(getContext() as common.UIAbilityContext)?.abilityInfo.name} aboutToAppear`);
    this.pollingAnimationsInfo();
  }

  /**
   * 页面销毁时释放动画资源
   */
  aboutToDisappear(): void {
    console.info(`lottie_ohos Index Page @${(getContext() as common.UIAbilityContext)?.abilityInfo.name} aboutToDisappear`);
    lottie.destroy(undefined, true);
    this.pollingAnimationsInfo();
  }

  onPageShow(): void {
    console.info(`lottie_ohos Index Page @${(getContext() as common.UIAbilityContext)?.abilityInfo.name} onPageShow`);
    this.pollingAnimationsInfo();
  }

  onPageHide(): void {
    console.info(`lottie_ohos Index Page @${(getContext() as common.UIAbilityContext)?.abilityInfo.name} onPageHide`);
    this.pollingAnimationsInfo();
  }

  build() {
    Scroll() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
        Column() {
          Row({ space: 10 }) {
            Canvas(this.canvasRenderingContext)
              .width('45%')
              .height(200)
              .backgroundColor(Color.Gray)
              .onReady(() => {
                this.animateItem2?.resize();
              })
              .onDisAppear(() => {
                // 组件移除时，可销毁动画资源
                lottie.destroy("2016", true);
              })

            Canvas(this.mainCanvasRenderingContext)
              .width('45%')
              .height(200)
              .backgroundColor(Color.Gray)
              .onReady(() => {
                // 可在此生命回调周期中加载动画，可以保证动画尺寸正确
                //抗锯齿的设置
                this.mainCanvasRenderingContext.imageSmoothingEnabled = true;
                this.mainCanvasRenderingContext.imageSmoothingQuality = 'medium'
                this.animateItem?.resize();
              })
              .onDisAppear(() => {
                lottie.destroy(this.animateName, true);

              })
              .visibility(this.isCanvasVisible)
              .onVisibleAreaChange([0], (isVisible: boolean, currentRatio: number) => {
                if (isVisible) {
                  console.log("Canvas Visible")
                  // this.animateItem?.play()
                } else {
                  console.log("Canvas is not visible")
                  // this.animateItem?.pause() //在画布不可见时尝试暂停动画
                }
              })
          }

          Row() {
            Text(this.currentFrame !== undefined ?
              this.currentFrame.toFixed(2) + "/" + this.currentRawFrame?.toFixed(2) + " " +
              this.getResourceString($r("app.string.frame")) : " ").margin({ left: 5 })
            Text(this.totalFrames !== undefined ?
              this.getResourceString($r("app.string.total")) + " " + " " + this.totalFrames +
              this.getResourceString($r("app.string.frame")) + "" : " ").margin({ left: 5 })
            Text(this.playCount !== undefined ? this.playCount + " " + this.getResourceString($r("app.string.time")) :
              " ").margin({ left: 5 })
            Text(this.getResourceString($r("app.string.total")) + " " + this.totalPlayedCount + " " +
            this.getResourceString($r("app.string.time"))).margin({ left: 5 })
            Text(this.playDirecton !== undefined ?
              (this.playDirecton > 0 ? this.getResourceString($r("app.string.forward")) :
              this.getResourceString($r("app.string.backward"))) : " ").margin({ left: 5 })
            Text(this.playSpeed !== undefined ? this.getResourceString($r("app.string.speed")) + " " + this.playSpeed :
              " ").margin({ left: 5 })
          }
          .backgroundColor('#F0F0F0')
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }.height('30%')
        .width('100%')

        Scroll() {
          Column() {
            Row() {
              Button($r("app.string.load_2016"))
                .onClick(() => {
                  lottie.destroy('2016', true)
                  this.animateItem2 = lottie.loadAnimation({
                    container: this.canvasRenderingContext,
                    renderer: 'canvas', // canvas 渲染模式
                    loop: true,
                    autoplay: true,
                    name: '2016',
                    contentMode: 'Contain',
                    path: "common/lottie/robotYoga.json", // 路径加载动画只支持entry/src/main/ets 文件夹下的相对路径
                    // path: "common/lottie/data_rawfile.json"
                    // path: "common/lottie/data_base64.json"
                  })
                })

              Button($r("app.string.clear_cache")).onClick(() => {
                lottie.clearFileCache();
              })

              Button($r("app.string.load_grunt"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  lottie.destroy(this.animateName, true)
                  this.animateItem = lottie.loadAnimation({
                    container: this.mainCanvasRenderingContext,
                    renderer: 'canvas', // canvas 渲染模式
                    loop: 10,
                    autoplay: true,
                    name: this.animateName,
                    contentMode: 'Contain',
                    path: "common/lottie/animation.json", // 路径加载动画只支持entry/src/main/ets 文件夹下的相对路径
                    // path: "common/lottie/grunt.json"   // 可用来测试marker的支持
                  })
                  this.animateItem.addEventListener('enterFrame', (args: Object): void => {
                    console.info("lottie enterFrame");
                    this.updateAllStates();
                  }); //只要播放，会一直触发
                  this.animateItem.addEventListener('loopComplete', (args: Object): void => {
                    console.info("lottie loopComplete");
                    this.playCount = this.animateItem?.playCount;
                    this.totalPlayedCount += 1;
                  }); //动画播放一遍结束触发
                  this.animateItem.addEventListener('complete', (args: Object): void => {
                    console.info("lottie complete");
                    this.updateAllStates();
                  }); //动画播放结束且不再播放动画触发
                  this.animateItem.addEventListener('destroy', (args: Object): void => {
                    console.info("lottie destroy");
                  }); //删除动画触发
                  this.animateItem.addEventListener('DOMLoaded', (args: Object): void => {
                    console.info("lottie DOMLoaded");
                    this.totalPlayedCount = 0;
                    this.updateAllStates();
                  }); //动画加载完成，播放之前触发
                })
            }.margin({ top: 5 })

            Row() {
              Row() {
                Button($r("app.string.setting"))
                  .backgroundColor(this.specifiedBkColor)
                  .onClick(() => {
                    // 设置animator的刷帧率为30
                    this.animateItem?.setFrameRate(Number(this.frameRate));
                    this.updateAllStates();
                  })
                  .type(ButtonType.Normal)

                TextInput({ text: this.frameRate })
                  .height(40)
                  .width(50)
                  .type(InputType.Number)
                  .padding(5)
                  .borderRadius(50)
                  .onChange((value) => {
                    this.frameRate = value;
                  })
                Text("HZ")
                Blank().width(20)
              }

              Row() {
                Button($r("app.string.global_setting"))
                  .onClick(() => {
                    // 设置全局刷帧率
                    lottie.setFrameRate(Number(this.maxFrameRate));
                    this.updateAllStates();
                  })
                  .type(ButtonType.Normal)

                TextInput({ text: this.maxFrameRate })
                  .height(40)
                  .width(50)
                  .type(InputType.Number)
                  .padding(5)
                  .borderRadius(0)
                  .onChange((value) => {
                    this.maxFrameRate = value;
                  })
                Text("HZ")
                Blank().width(20)
              }
            }.margin({ top: 5 })

            Row() {
              Text($r('app.string.specified_animation'));
              Toggle({ type: ToggleType.Switch, isOn: this.specifiedAnimation })
                .onChange((isOn: boolean) => {
                  this.specifiedAnimation = isOn;
                  this.buttonBkColor =
                    isOn ? this.specifiedBkColor : $r('sys.color.ohos_id_color_floating_button_bg_normal');
                })
              Text($r('app.string.only_current_ability'))
              Toggle({ type: ToggleType.Switch, isOn: this.onlyCurrentAbility })
                .onChange((isOn: boolean) => {
                  this.onlyCurrentAbility = isOn;
                })
            }

            Row() {
              Button($r("app.string.play"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.play(); // 仅测试单动画接口
                  lottie.play(this.specifiedAnimation ? this.animateName : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.pause"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.pause(); // 仅测试单动画接口
                  lottie.pause(this.specifiedAnimation ? this.animateName : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.play_pause"))
                .backgroundColor(this.buttonBkColor)
                .fontSize(12)
                .onClick(() => {
                  this.animateItem?.togglePause(); // 仅测试单动画接口,
                  this.animateItem?.togglePause(); // 仅测试单动画接口, 需做两次, 否则状态不对
                  lottie.togglePause(this.specifiedAnimation ? this.animateName : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.stop"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.stop(); // 仅测试单动画接口
                  lottie.stop(this.specifiedAnimation ? this.animateName : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.destroy"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  if (this.specifiedAnimation) {
                    this.animateItem = null;
                    lottie.destroy(this.animateName, this.onlyCurrentAbility ? true : undefined);

                  } else {
                    this.animateItem = null;
                    this.animateItem2 = null;
                    lottie.destroy(undefined, this.onlyCurrentAbility ? true : undefined);
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            /*  接口暂不放开, 只用于临时打开测试
            Row() {
              Button($r("app.string.freeze"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  lottie.freeze(this.specifiedAnimation? this.animateName : undefined, this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.unfreeze"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  lottie.unfreeze(this.specifiedAnimation? this.animateName : undefined, this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.set_volume"))
                .backgroundColor(this.buttonBkColor)
                .fontSize(12)
                .onClick(() => {
                  lottie.setVolume(5, this.specifiedAnimation? this.animateName : undefined, this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.mute"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  lottie.mute(this.specifiedAnimation? this.animateName : undefined, this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.unmute"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  lottie.unmute(this.specifiedAnimation? this.animateName : undefined, this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })
            }.margin({ top: 5 })
            */

            Row() {
              Button('Fill')
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setContentMode('Fill'); // 仅测试单动画接口
                  lottie.setContentMode('Fill', this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button('Cover')
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setContentMode('Cover'); // 仅测试单动画接口
                  lottie.setContentMode('Cover', this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })
              Button('Top')
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setContentMode('Top'); // 仅测试单动画接口
                  lottie.setContentMode('Top', this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })
              Button('Bottom')
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setContentMode('Bottom'); // 仅测试单动画接口
                  lottie.setContentMode('Bottom', this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })
              Button('Contain')
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setContentMode('Contain'); // 仅测试单动画接口
                  lottie.setContentMode('Contain', this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.open_log"))
                .fontSize(14)
                .onClick(() => {
                  LogUtil.mLogLevel = LogUtil.ON;
                })

              Button($r("app.string.close_log"))
                .fontSize(14)
                .onClick(() => {
                  LogUtil.mLogLevel = LogUtil.OFF;
                })

              Button($r("app.string.ability_jump"))
                .fontSize(14)
                .onClick(() => {
                  let w: Want = {
                    bundleName: 'com.openharmony.lottie',
                  };

                  let context = getContext() as common.UIAbilityContext;
                  if (context.abilityInfo.name != 'EntryAbility') {
                    w.abilityName = 'EntryAbility';
                  } else {
                    w.abilityName = 'AnotherAbility';
                  }

                  context.startAbility(w);
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.resize"))
                .backgroundColor(this.buttonBkColor)
                .fontSize(14)
                .onClick(() => {
                  this.animateItem?.resize(200, 200); // 仅测试单动画接口
                  lottie.resize(200, 200, this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button(this.subFramed ? $r("app.string.sub_frame_true") : $r("app.string.sub_frame_false"))
                .backgroundColor(this.specifiedBkColor)
                .fontSize(14)
                .onClick(() => {
                  if (this.animateItem != null) {
                    this.animateItem.setSubframe(!this.subFramed);
                    this.subFramed = this.animateItem.isSubframeEnabled;
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Row() {
                Button($r("app.string.stop_at"))
                  .backgroundColor(this.buttonBkColor)
                  .onClick(() => {
                    this.animateItem?.goToAndStop(Number(this.frameNo), true); // 仅测试单动画接口
                    lottie.goToAndStop(Number(this.frameNo), true,
                      this.specifiedAnimation ? this.animateItem?.name : undefined,
                      this.onlyCurrentAbility ? true : undefined);
                    this.updateAllStates();
                  })
                  .type(ButtonType.Normal)

                TextInput({ text: this.frameNo })
                  .height(40)
                  .width(50)
                  .type(InputType.Normal)
                  .padding(5)
                  .borderRadius(0)
                  .onChange((value) => {
                    this.frameNo = value;
                  })
                Text($r("app.string.frame"))
                Blank().width(20)
              }

              Row() {
                Button($r("app.string.stop_at"))
                  .backgroundColor(this.buttonBkColor)
                  .onClick(() => {
                    this.animateItem?.goToAndStop(Number(this.frameSeconds) * 1000, false); // 仅测试单动画接口
                    lottie.goToAndStop(Number(this.frameSeconds) * 1000, false,
                      this.specifiedAnimation ? this.animateItem?.name : undefined,
                      this.onlyCurrentAbility ? true : undefined);
                    this.updateAllStates();
                  })
                  .type(ButtonType.Normal)

                TextInput({ text: this.frameSeconds })
                  .height(40)
                  .width(50)
                  .type(InputType.Normal)
                  .padding(5)
                  .borderRadius(0)
                  .onChange((value) => {
                    this.frameSeconds = value;
                  })
                Text($r("app.string.second"))
                Blank().width(20)
              }
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.seek_frame_play"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.goToAndPlay(5, true); // 仅测试单动画接口
                  lottie.goToAndPlay(5, true,
                    this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })

              Button($r("app.string.seek_time_play"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.goToAndPlay(1000, false); // 仅测试单动画接口
                  lottie.goToAndPlay(1000, false,
                    this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              // // 使用grunt.json进行验证。且需将goToAndPlay的value参数改为number|string复合类型
              // Button('marker3播放')
              //   .onClick(() => {
              //     if (this.animateItem != null) {
              //       this.animateItem.goToAndPlay("marker3");
              //     }
              //     this.updateAllStates();
              //   })
              // Button('marker4播放')
              //   .onClick(() => {
              //     if (this.animateItem != null) {
              //       this.animateItem.goToAndPlay("marker4");
              //     }
              //     this.updateAllStates();
              //   })
              Button($r("app.string.reset"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    this.animateItem.resetSegments(true);
                    this.totalPlayedCount = 0;
                  }
                  this.updateAllStates();
                })
              Button($r("app.string.index_more"))
                .onClick(() => {
                  router.pushUrl({ url: "pages/MoreExamples" });
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.frame350"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    this.animateItem.setSegment(350, 0);
                  }
                  this.updateAllStates();
                })
              Button($r("app.string.frame50"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    this.animateItem.setSegment(50, 150);
                  }
                  this.updateAllStates();
                })

              Button($r("app.string.frame100"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    this.animateItem.setSegment(100, 200);
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.keep_playing"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    this.animateItem.playSegments([[5, 50], [300, 200], [100, 0], [250, 349]], true);
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Button(this.animationDuration)
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    console.info("getDuration:" + this.animateItem.getDuration() + 's');
                    this.animationDuration = this.getResourceString($r('app.string.get_duration')) +
                    this.animateItem.getDuration().toFixed(2) + 's'
                  }
                  this.updateAllStates();
                })

              Button(this.pauseState)
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    console.info("isPaused:" + this.animateItem.isPaused);
                    this.pauseState = this.getResourceString($r('app.string.is_pause')) + this.animateItem.isPaused
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.hide"))
                .onClick(() => {
                  this.isCanvasVisible = Visibility.Hidden;
                  this.updateAllStates();
                })

              Button($r("app.string.show"))
                .onClick(() => {
                  this.isCanvasVisible = Visibility.Visible;
                  this.updateAllStates();
                })
              Button($r("app.string.change_color"))
                .onClick(() => {
                  // 修改动画颜色。
                  if (this.animateItem != null) {
                    this.animateItem.changeColor([255, 203, 12, 0.5]);
                  }
                  if (this.animateItem2 != null) {
                    this.animateItem2.changeColor([255, 203, 12, 0.5]);
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.add_listener"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  // 添加事件监听，添加和移除的回调方法需要为同一个，否则不能正确移除
                  if (this.animateItem != null) {
                    this.animateItem.addEventListener('loopComplete', (args: Object): void => {
                      console.info("grunt loopComplete");
                      promptAction.showToast({ message: 'grunt loopComplete' })
                    });
                  }
                  this.updateAllStates();
                })

              Button($r("app.string.remove_listener"))
                .backgroundColor(this.specifiedBkColor)
                .onClick(() => {
                  if (this.animateItem != null) {
                    // 监听移除之后callback内容即监听不到
                    this.animateItem.removeEventListener('loopComplete');
                  }
                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.playback_speed6"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setSpeed(6); // 仅测试单动画接口
                  lottie.setSpeed(6, this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);

                  this.playDirecton = this.animateItem?.playDirection;
                  this.playSpeed = this.animateItem?.playSpeed;

                  this.updateAllStates();
                })

              Button($r("app.string.playback_speed1"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setSpeed(1); // 仅测试单动画接口
                  lottie.setSpeed(1, this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);

                  this.playDirecton = this.animateItem?.playDirection;
                  this.playSpeed = this.animateItem?.playSpeed;

                  this.updateAllStates();
                })

              Button($r("app.string.playback_speed"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setSpeed(-1); // 仅测试单动画接口
                  lottie.setSpeed(-1, this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);

                  this.playDirecton = this.animateItem?.playDirection;
                  this.playSpeed = this.animateItem?.playSpeed;

                  this.updateAllStates();
                })
            }.margin({ top: 5 })

            Row() {
              Button($r("app.string.play_forward"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setDirection(1); // 仅测试单动画接口
                  lottie.setDirection(1, this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);

                  this.updateAllStates();
                })

              Button($r("app.string.play_backward"))
                .backgroundColor(this.buttonBkColor)
                .onClick(() => {
                  this.animateItem?.setDirection(-1); // 仅测试单动画接口
                  lottie.setDirection(-1, this.specifiedAnimation ? this.animateItem?.name : undefined,
                    this.onlyCurrentAbility ? true : undefined);

                  this.updateAllStates();
                })
              Button($r("app.string.jump_HSP"))
                .onClick(() => {
                  router.pushUrl({ url: '@bundle:com.openharmony.lottie/sharedLibrary/ets/pages/Index' });
                })
            }.margin({ top: 5 })
          }
        }
        .nestedScroll({ scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.PARENT_FIRST })
        .scrollBar(BarState.Off)
        .height('70%')

        Blank().width('100%').height('100%').backgroundColor('#F0F0F0')
      }
    }
    .scrollBar(BarState.Off)
    .width('100%')
  }

  getResourceString(res: Resource) {
    return getContext().resourceManager.getStringSync(res.id)
  }
}
