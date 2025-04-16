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

import { HeaderComponent } from './HeaderComponent';
import lottie, { AnimationItem } from '@ohos/lottie';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct CoordinatorExample {
  private data: MyListDataSource = new MyListDataSource(Array.from<number>(Array<number>(10).keys()));
  @State animationsInfo:string = '';
  private pollingTimerId?:number = undefined;
  @Provide testReusableNode: boolean = true;
  @Provide testNormalNode: boolean = false;

  aboutToDisappear(): void {
    if(this.pollingTimerId) {
      clearInterval(this.pollingTimerId);
      this.pollingTimerId = undefined;
    }
  }

  pollingAnimationsInfo() {
    let animations: AnimationItem[] = lottie.getRegisteredAnimations();
    let text = `CURRENT ABILITY NAME: ${(getContext() as common.UIAbilityContext)?.abilityInfo.name}`;
    let n = 1;
    animations.forEach((value) => {
      text += `\n${n++}:${value.animationID}: ${value.context.abilityInfo.name} ${value.isPaused ? 'paused' : 'playing'} ${value.currentFrame.toFixed(2)}`;
    })
    this.animationsInfo = text;
  }

  build() {
    Stack() {
      Column() {
        HeaderComponent({ text: $r("app.string.coordinatorExample_title") })
        Scroll() {
          Text(this.animationsInfo)
            .fontSize(14)
            .height(500)
            .align(Alignment.TopStart)
            .textAlign(TextAlign.Start)
            .onAppear(() => {
              this.pollingTimerId = setInterval(() => {
                this.pollingAnimationsInfo();
              }, 50);
            })
        }.height(200).width('100%').borderWidth(1).borderColor(Color.Red);
        Row() {
          Button(this.testReusableNode? '有复用节点':'无复用节点')
            .onClick(() => {
              this.testReusableNode = !this.testReusableNode;
            })
          Button(this.testNormalNode? '有常规节点' : '无常规节点')
            .onClick(() => {
              this.testNormalNode = !this.testNormalNode;
            })
        }

        Swiper() {
          LazyForEach(this.data, (item: number) => {
            Column() {
              SwiperItem()
              Text(`Swiper Item ${item}`)
              Text('划动此区域切换Swiper')
            }.backgroundColor('#F0F0F0')
          }, (item: number) => String(item))
        }
        .width('100%')
        .height('100%')
        .borderWidth(2)
        .borderColor(Color.Yellow)
        .id("recommendSwiper")
        .cachedCount(1)
        .loop(false)
        .vertical(true)
        .indicator(false)
        .interval(3000)
        .align(Alignment.Top)
      }
    }
    .width("100%")
  }
}

class MyListDataSource implements IDataSource {
  private dataArray: number[] = [];

  constructor(data:number[]) {
    this.dataArray = data;
  }

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): number {
    return this.dataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}

@Component
export struct SwiperItem {
  @State attachToTree: boolean = true;
  @Consume testReusableNode: boolean;
  @Consume testNormalNode: boolean;
  private myReusedId1: string = 'reused_1';
  private data: MyListDataSource = new MyListDataSource(Array.from<number>(Array<number>(20).keys()));
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  @State context2DContainer1: Context2DContainer = {
    dynamicContext2D: new CanvasRenderingContext2D(this.renderingSettings)
  };
  @State context2DContainer2: Context2DContainer = {
    dynamicContext2D: new CanvasRenderingContext2D(this.renderingSettings),
  }

  aboutToAppear(): void {
    if(lottie.bindContext2dToCoordinator) {
      lottie.bindContext2dToCoordinator(this.context2DContainer1.dynamicContext2D);
    }
  }

  aboutToDisappear(): void {
    if(lottie.unbindContext2dFromCoordinator) {
      lottie.unbindContext2dFromCoordinator(this.context2DContainer1.dynamicContext2D);
    }
  }

  build() {
    Column() {
      Button(this.attachToTree ? 'List下树' : 'List上树')
        .onClick(() => {
          this.attachToTree = !this.attachToTree
        })
      if (this.attachToTree) {
        List() {
          LazyForEach(this.data, (item: number, index: number) => {
            if (index == 0) {
              ListItem() {
                Row() {
                  if (this.testReusableNode) {
                    ReusableChildComponent({
                      myReusedId: `${this.myReusedId1}`,
                      outerContext2DContainer: this.context2DContainer1,
                    })
                      .reuseId(`${this.myReusedId1}`)
                      .width(this.testReusableNode && this.testNormalNode ? '50%' : '100%')
                  }

                  if (this.testNormalNode) {
                    LottieBuilder({
                      outerContext2DContainer: this.context2DContainer2,
                    })
                      .width(this.testReusableNode && this.testNormalNode ? '50%' : '100%')
                  }
                }.width('100%')
              }
            } else if (index == this.data.totalCount() - 1) {
              ListItem() {
                Row() {
                  if (this.testReusableNode) {
                    ReusableChildComponent({
                      myReusedId: `${this.myReusedId1}`,
                      outerContext2DContainer: this.context2DContainer1,
                    })
                      .reuseId(`${this.myReusedId1}`)
                      .width(this.testReusableNode && this.testNormalNode ? '50%' : '100%')
                  }

                  if (this.testNormalNode) {
                    LottieBuilder({
                      outerContext2DContainer: this.context2DContainer2,
                    })
                      .width(this.testReusableNode && this.testNormalNode ? '50%' : '100%')
                  }
                }
              }
            } else {
              ListItem() {
                Column() {
                  Text(`List Item ${index}`)
                  Text('划动此区域触发列表滚动')
                }
              }.width('100%').height(80)
            }
          })
        }
        .cachedCount(1)
        .width('100%').height(300)
        .borderWidth(1)
        .borderColor(Color.Gray)
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
  }
}

@Reusable
@Component
struct ReusableChildComponent {
  @State myReusedId: string = ''
  private myId:number = 0;
  @Link outerContext2DContainer:Context2DContainer;

  aboutToAppear() {
    this.myId = this.getUniqueId();
    console.log(`lottie_ohos: ReusableChildComponent(${this.myId}) aboutToAppear by reusedId:${this.myReusedId}`);
  }

  aboutToReuse(params: ESObject) {
    this.myId = this.getUniqueId();
    console.log(`lottie_ohos: ReusableChildComponent(${this.myId}) aboutToReuse by reusedId:${this.myReusedId}`)

    let constructorParams: ReusableChildComponent = params as ReusableChildComponent;
    if(constructorParams.myReusedId) {
      this.myReusedId = constructorParams.myReusedId;
    }

    // 务必先清除, 再复原, 以便触发变更. 为避免两者本就是同一个对象而出现误清空的情况，先对构造参数的数据做备份
    let context2d = constructorParams.outerContext2DContainer?.dynamicContext2D;
    if(context2d) {
      this.outerContext2DContainer.dynamicContext2D = undefined;
      this.outerContext2DContainer.dynamicContext2D = context2d;
    }
  }

  aboutToDisappear(): void {
    console.log(`lottie_ohos: ReusableChildComponent(${this.myId}) aboutToDisappear by reusedId:${this.myReusedId}`)
  }

  aboutToRecycle(): void {
    console.log(`lottie_ohos: ReusableChildComponent(${this.myId}) aboutToRecycle by reusedId:${this.myReusedId}`)
  }

  build() {
    Column() {
      Text(`Id: ${this.myId}`)
      Text(`ReusedId: ${this.myReusedId}`).height(30)
      LottieBuilder({
        outerContext2DContainer: this.outerContext2DContainer,
      });
    }
    .borderWidth(1)
    .borderColor(Color.Blue)
    .padding({ left: 10, right: 10 })
  }
}

class Context2DContainer {
  dynamicContext2D?:CanvasRenderingContext2D;
}

@Component
export struct LottieBuilder {
  public lottiePath: string = "common/lottie/robotYoga.json";
  @Link outerContext2DContainer: Context2DContainer;
  private myId: number = 0;
  private animateItem?: AnimationItem;
  private playing: boolean = true;
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private innerContext2D: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  @State private context2DContainer: Context2DContainer = new Context2DContainer();
  @State private hasArea: boolean = true;

  aboutToAppear(): void {
    this.myId = this.getUniqueId();
    console.log(`lottie_ohos: LottieBuilder(${this.myId}) aboutToAppear`);
    this.context2DContainer.dynamicContext2D = this.innerContext2D;
  }

  aboutToDisappear(): void {
    console.log(`lottie_ohos: LottieBuilder(${this.myId}) aboutToDisappear`);
    if (this.animateItem) {
      this.animateItem.destroy();
      this.animateItem = undefined;
    }
  }

  aboutToReuse(params: ESObject) {
    this.myId = this.getUniqueId();
    console.log(`lottie_ohos: LottieBuilder(${this.myId}) aboutToReuse`);

    let constructorParams: LottieBuilder = params as LottieBuilder;
    if (constructorParams.lottiePath) {
      this.lottiePath = constructorParams.lottiePath;
    }
    if (constructorParams.outerContext2DContainer) {
      this.outerContext2DContainer = constructorParams.outerContext2DContainer;
    }
  }

  aboutToRecycle(): void {
    console.log(`lottie_ohos: LottieBuilder(${this.myId}) aboutToRecycle`);
  }

  build() {
    Stack() {
      Row() {
        Column() {
          Button(this.hasArea ? 'forceNoArea' : 'forceHasArea')
            .onClick(() => {
              this.hasArea = !this.hasArea;
              if(lottie.setAttachedCanvasHasVisibleArea) {
                lottie.setAttachedCanvasHasVisibleArea(this.outerContext2DContainer.dynamicContext2D, this.hasArea);
              }
            }).height(20)
          Canvas(this.outerContext2DContainer.dynamicContext2D)
            .width(100)
            .height(100)
            .borderWidth(1)
            .borderStyle(BorderStyle.Dashed)
            .borderColor(Color.Gray)
            .onReady(() => {
              // setTimeout(() => {
              if (this.animateItem) {
                this.animateItem.destroy();
              }
              this.animateItem = lottie.loadAnimation({
                container: this.outerContext2DContainer.dynamicContext2D,
                renderer: 'canvas', // canvas 渲染模式
                loop: true,
                autoplay: this.playing,
                name: this.lottiePath,
                contentMode: 'Contain',
                path: this.lottiePath,
              })
              // }, 100);
            })
            .onClick(() => {
              this.playing = !this.playing;
              this.playing ? this.animateItem?.play() : this.animateItem?.stop();
            })
        }.width('50%')

        Column() {
          Column() {
            Button(this.context2DContainer.dynamicContext2D ? 'clearContext2d' : 'restore')
              .onClick(() => {
                if (this.context2DContainer.dynamicContext2D) {
                  this.context2DContainer.dynamicContext2D = undefined;
                } else {
                  this.context2DContainer.dynamicContext2D = this.innerContext2D;
                }
              }).height(20).margin(5)
            Button(this.context2DContainer.dynamicContext2D === this.outerContext2DContainer.dynamicContext2D ?
              'switchInner' : 'switchOuter')
              .onClick(() => {
                if (this.context2DContainer.dynamicContext2D === this.outerContext2DContainer.dynamicContext2D) {
                  this.context2DContainer.dynamicContext2D = this.innerContext2D;
                } else {
                  this.context2DContainer.dynamicContext2D = this.outerContext2DContainer.dynamicContext2D;
                }
              }).height(20)
          }

          Canvas(this.context2DContainer.dynamicContext2D)
            .width(100).height(100)
            .borderWidth(1).borderStyle(BorderStyle.Dashed).borderColor(Color.Gray)
        }.width('50%')
      }.width('100%')
    }.width('100%')
  }
}
