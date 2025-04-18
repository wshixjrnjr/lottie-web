import {
  extendPrototype,
} from '../utils/functionExtensions';
import {
  createSizedArray,
} from '../utils/helpers/arrays';
import createTag from '../utils/helpers/html_elements';
import SVGRenderer from './SVGRenderer';
import Matrix from '../3rd_party/transformation-matrix';
import BaseRenderer from './BaseRenderer';
import CVContextData from '../elements/canvasElements/CVContextData';
import CVShapeElement from '../elements/canvasElements/CVShapeElement';
import CVTextElement from '../elements/canvasElements/CVTextElement';
import CVImageElement from '../elements/canvasElements/CVImageElement';
import CVSolidElement from '../elements/canvasElements/CVSolidElement';
import {LogUtil} from '../utils/LogUtil'

function CanvasRendererBase(animationItem, config) {
  this.animationItem = animationItem;
  this.renderConfig = {
    clearCanvas: (config && config.clearCanvas !== undefined) ? config.clearCanvas : true,
    context: (config && config.context) || null,
    progressiveLoad: (config && config.progressiveLoad) || false,
    preserveAspectRatio: (config && config.preserveAspectRatio) || 'xMidYMid meet',
    imagePreserveAspectRatio: (config && config.imagePreserveAspectRatio) || 'xMidYMid slice',
    contentVisibility: (config && config.contentVisibility) || 'visible',
    className: (config && config.className) || '',
    id: (config && config.id) || '',
  };
  this.renderConfig.dpr = (config && config.dpr) || 1;
  if (this.animationItem.wrapper) {
    this.renderConfig.dpr = (config && config.dpr) || 1;
  }
  this.renderedFrame = -1;
  this.globalData = {
    frameNum: -1,
    _mdf: false,
    renderConfig: this.renderConfig,
    currentGlobalAlpha: -1,
  };
  this.contextData = new CVContextData();
  this.elements = [];
  this.pendingElements = [];
  this.transformMat = new Matrix();
  this.completeLayers = false;
  this.rendererType = 'canvas';
}
extendPrototype([BaseRenderer], CanvasRendererBase);

CanvasRendererBase.prototype.createShape = function (data) {
  return new CVShapeElement(data, this.globalData, this);
};

CanvasRendererBase.prototype.createText = function (data) {
  return new CVTextElement(data, this.globalData, this);
};

CanvasRendererBase.prototype.createImage = function (data) {
  return new CVImageElement(data, this.globalData, this);
};

CanvasRendererBase.prototype.createSolid = function (data) {
  return new CVSolidElement(data, this.globalData, this);
};

CanvasRendererBase.prototype.createNull = SVGRenderer.prototype.createNull;

CanvasRendererBase.prototype.ctxTransform = function (props) {
  if (props[0] === 1 && props[1] === 0 && props[4] === 0 && props[5] === 1 && props[12] === 0 && props[13] === 0) {
    return;
  }
  if (!this.renderConfig.clearCanvas) {
    this.canvasContext.transform(props[0], props[1], props[4], props[5], props[12], props[13]);
    return;
  }
  // Resetting the canvas transform matrix to the new transform
  this.transformMat.cloneFromProps(props);
  // Taking the last transform value from the stored stack of transforms
  var currentTransform = this.contextData.getTransform();
  var cProps = currentTransform.props;
  // Applying the last transform value after the new transform to respect the order of transformations
  this.transformMat.transform(cProps[0], cProps[1], cProps[2], cProps[3], cProps[4], cProps[5], cProps[6], cProps[7], cProps[8], cProps[9], cProps[10], cProps[11], cProps[12], cProps[13], cProps[14], cProps[15]);
  // Storing the new transformed value in the stored transform
  currentTransform.cloneFromProps(this.transformMat.props);
  var trProps = currentTransform.props;
  // Applying the new transform to the canvas
  this.canvasContext.setTransform(trProps[0], trProps[1], trProps[4], trProps[5], trProps[12], trProps[13]);
};

CanvasRendererBase.prototype.ctxOpacity = function (op) {
  /* if(op === 1){
        return;
    } */
  var currentOpacity = this.contextData.getOpacity();
  if (!this.renderConfig.clearCanvas) {
    this.canvasContext.globalAlpha *= op < 0 ? 0 : op;
    this.globalData.currentGlobalAlpha = currentOpacity;
    return;
  }
  currentOpacity *= op < 0 ? 0 : op;
  this.contextData.setOpacity(currentOpacity);
  //设置当前画布的透明度，防止this.globalData.currentGlobalAlpha不为1时画布被隐藏
  this.canvasContext.globalAlpha = currentOpacity;
  if (this.globalData.currentGlobalAlpha !== currentOpacity) {
    this.globalData.currentGlobalAlpha = currentOpacity;
  }
};

CanvasRendererBase.prototype.reset = function () {
  if (!this.renderConfig.clearCanvas) {
    this.canvasContext.restore();
    return;
  }
  this.contextData.reset();
};

CanvasRendererBase.prototype.save = function (actionFlag) {
  if (!this.renderConfig.clearCanvas) {
    this.canvasContext.save();
    return;
  }
  if (actionFlag) {
    this.canvasContext.save();
  }
  this.contextData.push();
};

CanvasRendererBase.prototype.restore = function (actionFlag) {
  if (!this.renderConfig.clearCanvas) {
    this.canvasContext.restore();
    return;
  }
  if (actionFlag) {
    this.canvasContext.restore();
    this.globalData.blendMode = 'source-over';
  }
  var popped = this.contextData.pop();
  var transform = popped.transform;
  var opacity = popped.opacity;
  this.canvasContext.setTransform(transform[0], transform[1], transform[4], transform[5], transform[12], transform[13]);
  if (this.globalData.currentGlobalAlpha !== opacity) {
    this.canvasContext.globalAlpha = opacity;
    this.globalData.currentGlobalAlpha = opacity;
  }
};

CanvasRendererBase.prototype.configAnimation = function (animData) {
  if (this.animationItem.wrapper) {
    this.canvasContext = this.animationItem.wrapper;
  } else {
    this.canvasContext = this.renderConfig.context;
  }

  if (this.animationItem.contentMode) {
    if (this.animationItem.contentMode == 'Fill') {
      this.renderConfig.preserveAspectRatio = 'none';
    } else if (this.animationItem.contentMode == 'Top') {
      this.renderConfig.preserveAspectRatio = 'xMinYMin meet';
    } else if (this.animationItem.contentMode == 'Cover') {
      this.renderConfig.preserveAspectRatio = 'xMidYMid slice';
    } else if (this.animationItem.contentMode == 'Bottom') {
      this.renderConfig.preserveAspectRatio = 'xMaxYMax meet';
    } else if (this.animationItem.contentMode == 'Contain') {
      this.renderConfig.preserveAspectRatio = 'xMidYMid meet';
    }
  }

  this.data = animData;
  this.layers = animData.layers;
  this.transformCanvas = {
    w: animData.w,
    h: animData.h,
    sx: 0,
    sy: 0,
    tx: 0,
    ty: 0,
  };
  this.setupGlobalData(animData, {});
  this.globalData.canvasContext = this.canvasContext;
  this.globalData.renderer = this;
  this.globalData.isDashed = false;
  this.globalData.progressiveLoad = this.renderConfig.progressiveLoad;
  this.globalData.transformCanvas = this.transformCanvas;
  this.elements = createSizedArray(animData.layers.length);
  this.updateContainerSize();
};

CanvasRendererBase.prototype.updateContentMode = function (contentMode) {
  if (contentMode && this.renderConfig) {
    if (contentMode == 'Fill') {
      this.renderConfig.preserveAspectRatio = 'none';
    } else if (contentMode == 'Top') {
      this.renderConfig.preserveAspectRatio = 'xMinYMin meet';
    } else if (contentMode == 'Cover') {
      this.renderConfig.preserveAspectRatio = 'xMidYMid slice';
    } else if (contentMode == 'Bottom') {
      this.renderConfig.preserveAspectRatio = 'xMaxYMax meet';
    } else if (contentMode == 'Contain') {
      this.renderConfig.preserveAspectRatio = 'xMidYMid meet';
    }
    this.updateContainerSize();
  }
}

CanvasRendererBase.prototype.updateContainerSize = function (width, height) {
  if (!this.canvasContext) {
    return;
  }
  this.canvasContext.restore();
  this.canvasContext.setTransform(1, 0, 0, 1, 0, 0);//resetting the transform
  this.canvasContext.clearRect(0, 0, this.transformCanvas.w, this.transformCanvas.h); //清空之前画布
  this.canvasContext.clearRect(0, 0, this.canvasContext.width, this.canvasContext.height); //清空之前画布
  this.canvasContext.save();
  this.reset();
  var elementWidth;
  var elementHeight;
  if (width) {
    elementWidth = width;
    elementHeight = height;
  } else {
    if (this.canvasContext) {
      elementHeight = this.canvasContext.height;
      elementWidth = this.canvasContext.width;
      LogUtil.info("Lottie canvas size:" + elementHeight + "," + elementWidth + " with fr:" + this.animationItem?.animationData?.fr);

      if (!elementHeight) {
        elementHeight = 360;
      }
      if (!elementWidth) {
        elementWidth = 540;
      }
    }
  }

  var elementRel;
  var animationRel;
  if (this.renderConfig.preserveAspectRatio.indexOf('meet') !== -1 || this.renderConfig.preserveAspectRatio.indexOf('slice') !== -1) {
    var par = this.renderConfig.preserveAspectRatio.split(' ');
    var fillType = par[1] || 'meet';
    var pos = par[0] || 'xMidYMid';
    var xPos = pos.substr(0, 4);
    var yPos = pos.substr(4);
    elementRel = elementWidth / elementHeight;
    animationRel = this.transformCanvas.w / this.transformCanvas.h;
    if ((animationRel > elementRel && fillType === 'meet') || (animationRel < elementRel && fillType === 'slice')) {
      this.transformCanvas.sx = elementWidth / (this.transformCanvas.w / this.renderConfig.dpr);
      this.transformCanvas.sy = elementWidth / (this.transformCanvas.w / this.renderConfig.dpr);
    } else {
      this.transformCanvas.sx = elementHeight / (this.transformCanvas.h / this.renderConfig.dpr);
      this.transformCanvas.sy = elementHeight / (this.transformCanvas.h / this.renderConfig.dpr);
    }

    if (xPos === 'xMid' && ((animationRel < elementRel && fillType === 'meet') || (animationRel > elementRel && fillType === 'slice'))) {
      this.transformCanvas.tx = ((elementWidth - this.transformCanvas.w * (elementHeight / this.transformCanvas.h)) / 2) * this.renderConfig.dpr;
    } else if (xPos === 'xMax' && ((animationRel < elementRel && fillType === 'meet') || (animationRel > elementRel && fillType === 'slice'))) {
      this.transformCanvas.tx = (elementWidth - this.transformCanvas.w * (elementHeight / this.transformCanvas.h)) * this.renderConfig.dpr;
    } else {
      this.transformCanvas.tx = 0;
    }
    if (yPos === 'YMid' && ((animationRel > elementRel && fillType === 'meet') || (animationRel < elementRel && fillType === 'slice'))) {
      this.transformCanvas.ty = ((elementHeight - this.transformCanvas.h * (elementWidth / this.transformCanvas.w)) / 2) * this.renderConfig.dpr;
    } else if (yPos === 'YMax' && ((animationRel > elementRel && fillType === 'meet') || (animationRel < elementRel && fillType === 'slice'))) {
      this.transformCanvas.ty = ((elementHeight - this.transformCanvas.h * (elementWidth / this.transformCanvas.w))) * this.renderConfig.dpr;
    } else {
      this.transformCanvas.ty = 0;
    }
  } else if (this.renderConfig.preserveAspectRatio === 'none') {
    this.transformCanvas.sx = elementWidth / (this.transformCanvas.w / this.renderConfig.dpr);
    this.transformCanvas.sy = elementHeight / (this.transformCanvas.h / this.renderConfig.dpr);
    this.transformCanvas.tx = 0;
    this.transformCanvas.ty = 0;
  } else {
    this.transformCanvas.sx = this.renderConfig.dpr;
    this.transformCanvas.sy = this.renderConfig.dpr;
    this.transformCanvas.tx = 0;
    this.transformCanvas.ty = 0;
  }
  this.transformCanvas.props = [this.transformCanvas.sx, 0, 0, 0, 0, this.transformCanvas.sy, 0, 0, 0, 0, 1, 0, this.transformCanvas.tx, this.transformCanvas.ty, 0, 1];
  /* var i, len = this.elements.length;
    for(i=0;i<len;i+=1){
        if(this.elements[i] && this.elements[i].data.ty === 0){
            this.elements[i].resize(this.globalData.transformCanvas);
        }
    } */
  this.ctxTransform(this.transformCanvas.props);
  this.canvasContext.beginPath();
  this.canvasContext.rect(0, 0, this.transformCanvas.w, this.transformCanvas.h);
  this.canvasContext.closePath();
  this.canvasContext.clip();

  this.renderFrame(this.renderedFrame, true);
};

CanvasRendererBase.prototype.destroy = function () {
  if (this.renderConfig.clearCanvas && this.animationItem.wrapper && this.transformCanvas) {
    this.animationItem.wrapper.clearRect(0, 0, this.transformCanvas.w, this.transformCanvas.h);
    this.canvasContext?.setTransform(1, 0, 0, 1, 0, 0);
    this.canvasContext?.clearRect(0, 0, this.canvasContext.width, this.canvasContext.height); //清空之前画布
  }
  var i;
  var len = this.layers ? this.layers.length : 0;
  for (i = len - 1; i >= 0; i -= 1) {
    if (this.elements[i] && this.elements[i].destroy) {
      this.elements[i].destroy();
    }
  }
  this.elements.length = 0;
  this.globalData.canvasContext = null;
  this.animationItem.container = null;
  this.destroyed = true;
};

CanvasRendererBase.prototype.changeColor = function (color, endColor, layer, index) {
  if (typeof endColor == 'object') {
    if (Array.isArray(endColor)) {
      if (!layer) {
        var len = this.layers.length;
        var i;
        for (i = 0; i < len; i += 1) {
          let tag = true;
          if (this.layers[i] && this.layers[i].td) {
            tag = false;
          }
          if (tag && (this.completeLayers || this.elements[i])) {
            this.elements[i].changeColor(color, endColor);
          }
        }
      } else {
        if (this.completeLayers || this.elements[layer-1]) {
          this.elements[layer-1].changeColor(color, endColor, index);
        }
      }
    }
  } else if (typeof endColor == 'number') {
    if (endColor == 0) {
      var len = this.layers.length;
      var i;
      for (i = 0; i < len; i += 1) {
        let tag = true;
        if (this.layers[i] && this.layers[i].td) {
          tag = false;
        }
        if (tag && (this.completeLayers || this.elements[i])) {
          this.elements[i].changeColor(color, undefined);
        }
      }
    } else {
      if (this.completeLayers || this.elements[endColor-1]) {
        this.elements[endColor-1].changeColor(color, layer, index);
      }
    }
  } else {
    var len = this.layers.length;
    var i;
    for (i = 0; i < len; i += 1) {
      let tag = true;
      if (this.layers[i] && this.layers[i].td) {
        tag = false;
      }
      if (tag && (this.completeLayers || this.elements[i])) {
        this.elements[i].changeColor(color, undefined);
      }
    }
  }
}

CanvasRendererBase.prototype.renderFrame = function (num, forceRender) {
  if ((this.renderedFrame === num && this.renderConfig.clearCanvas === true && !forceRender) || this.destroyed || num === -1) {
    return;
  }
  this.renderedFrame = num;
  this.globalData.frameNum = num - this.animationItem._isFirstFrame;
  this.globalData.frameId += 1;
  this.globalData._mdf = !this.renderConfig.clearCanvas || forceRender;
  this.globalData.projectInterface.currentFrame = num;

  // LogUtil.log('--------');
  // LogUtil.log('NEW: ',num);
  var i;
  var len = this.layers.length;
  if (!this.completeLayers) {
    this.checkLayers(num);
  }

  for (i = 0; i < len; i += 1) {
    if (this.completeLayers || this.elements[i]) {
      this.elements[i].prepareFrame(num - this.layers[i].st);
    }
  }

  if (this.renderConfig.clearCanvas === true) {
    let currentTranform = this.canvasContext.getTransform();
    this.canvasContext.clearRect(0, 0, this.transformCanvas.w, this.transformCanvas.h); //清空之前画布
    this.canvasContext.setTransform(1, 0, 0, 1, 0, 0);
    this.canvasContext.clearRect(0, 0, this.canvasContext.width, this.canvasContext.height); //清空之前画布
    this.canvasContext.reset();
    this.canvasContext.setTransform(currentTranform);
  } else {
    this.save();
  }
  for (i = len - 1; i >= 0; i -= 1) {
    if (this.completeLayers || this.elements[i]) {
      this.elements[i].renderFrame();
    }
  }
  if (this.renderConfig.clearCanvas !== true) {
    this.restore();
  }
};

CanvasRendererBase.prototype.buildItem = function (pos) {
  var elements = this.elements;
  if (elements[pos] || this.layers[pos].ty === 99) {
    return;
  }
  var element = this.createItem(this.layers[pos], this, this.globalData);
  elements[pos] = element;
  element.initExpressions();
  /* if(this.layers[pos].ty === 0){
        element.resize(this.globalData.transformCanvas);
    } */
};

CanvasRendererBase.prototype.checkPendingElements = function () {
  while (this.pendingElements.length) {
    var element = this.pendingElements.pop();
    element.checkParenting();
  }
};

CanvasRendererBase.prototype.hide = function () {
  this.animationItem.container.style.display = 'none';
};

CanvasRendererBase.prototype.show = function () {
  this.animationItem.container.style.display = 'block';
};

export default CanvasRendererBase;
