# DreamAVG

A full-featured cross-platform visual novel/galgame engine base on cocos2d-x and luajit

## 快速开始
```lua
background "校园_日.jpg"
舞 = Character { name = "舞", image = "舞_制服1.png", x = 720, y = 96 }

舞:show()
舞 "勇太也有兴趣吧？"
if Choice { "确实……不能说没有。", "鬼才会有。" } == 1 then
    舞.好感度 = 舞.好感度 + 20
    我 "确实……不能说没有。"
    _ "我回想起今天在教室里做的那个<#ff0000>怪梦<font>。"
else
    我 "鬼才会有。"
    舞.image = "舞_制服_生气1.png"
    舞 "voice/mai_01.ogg" "咦咦咦~~~明明就很有意思耶~~\n……来，这一段你看一下嘛。"    
end
```

虽然dream-avg的剧本格式和renpy等传统galgame引擎相似, 但它并非一种DSL, 而是跑在cocos2d-x环境下的标准lua代码

因此, 你可以不受限制的在剧本中使用lua和cocos2d-x已有内容, 例如: dream-avg并不需要其他引擎那样的label和jump, 直接使用lua语句if/while/for等就可以了

## TechDemo

桜花恋舞 ([Windows版](https://github.com/re-esper/dream-avg/releases/download/0.1/techdemo-sakumai-windows.zip)   Android版)

<img src="https://github.com/re-esper/dream-avg/blob/master/screenshot/demo_1.jpg" width="40%" height="40%">        <img src="https://github.com/re-esper/dream-avg/blob/master/screenshot/demo_2.jpg" width="40%" height="40%">
<img src="https://github.com/re-esper/dream-avg/blob/master/screenshot/demo_3.jpg" width="40%" height="40%">        <img src="https://github.com/re-esper/dream-avg/blob/master/screenshot/demo_5.jpg" width="40%" height="40%">
<img src="https://github.com/re-esper/dream-avg/blob/master/screenshot/demo_6.jpg" width="40%" height="40%">        <img src="https://github.com/re-esper/dream-avg/blob/master/screenshot/demo_7.jpg" width="40%" height="40%">

[Credits](https://github.com/re-esper/dream-avg/tree/master/demo)

## 特性

- 提供AVG/galgame所需的完整功能
- 易于使用的语法, 剧本命令和lua脚本语言无缝衔接
- 跨平台, 支持windows/android/iOS/mac/linux, 对移动设备支持良好, 自动适配不同分辨率
- 引擎提供的Character对象原生支持live2d和spine模型
- Small codebase, 引擎lua代码只有不足800行, 也适合作为其他类型游戏的剧情模块使用

## 简介

暂无文档, 可能永远不会有, 细节请自行阅读源码了解, 也欢迎在issue提问  
但这里还是做些简单的提示性介绍, 另外也请参考TechDemo里面的[剧本文件](https://github.com/re-esper/dream-avg/tree/master/demo/src/storyScript)

#### 角色

角色Character支持单图片, 多层图片(使用parts字段定义部件), live2d模型(需要添加库[cocos-live2d-sprite](https://github.com/re-esper/cocos-live2d-sprite)), spine模型  
每个Character对象自身就是1个cc.Sprite (或cc.Live2DSprite/sp.SkeletonAnimation), 可以对其调用任何cocos2d-x相关功能接口, 例如action动画, shader等  
也可以直接在Character对象上绑定任意数据, 例如上面的好感度, 支持复杂lua table数据

#### 文本

文本支持就地嵌入标签控制, 包括fontname/size/color/style等, 也支持标签插入图片甚至自定义控件, 请参考[framework/extends/richtextex.lua](https://github.com/re-esper/cocos2d-lua-framework/blob/master/framework/extends/richtextex.lua)中的注释  
文本也支持javascript风格的模板字符串

#### 转场

在不同的剧本文件切换可以加入转场特效, 请参考[framework/extends/scene.lua](https://github.com/re-esper/cocos2d-lua-framework/blob/master/framework/extends/scene.lua)中的定义

#### 等待

`wait` 命令可以等待时间也可以等待一个条件成立

#### 注意事项

在实现含用户输入的自定义UI时, 又或在剧本中插入一个子游戏时, 需要参考 `Choice` 的实现方式, 在整个过程的前后分别调用novel._preUserInput/ novel._postUserInput







