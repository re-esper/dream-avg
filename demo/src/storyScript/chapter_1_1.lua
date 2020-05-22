-- main character, without figure
我 = Character {
    name = "我"
}
-- heroine 2, 常陆 花恋
花恋 = Character {
    image = "花恋_制服1.png",
    name = "花恋",
    x = 720,
    y = 96,
    scale = 1.0,
    parts = {
        表情 = { file = "花恋_表情_普通.png", x = 140, y = 1504, anchor = { 0, 1 } } -- 自定义部件, 支持任意多个部件
    },
    好感度 = 50
}

background "夜空_雨.jpg"
sound("sound/se_rain_01.ogg", 1, 2.0, true)
wait(1.0)
_ "黯淡无光的雨夜。" -- 预定义的旁白者角色

-- 利用 cocos2d-x 粒子系统演出
cc.ParticleSystemQuad:create("particle/particle_rain.plist")
    :position(video.center.x, video.height + 20):addTo()
    :setPosVar(cc.p(video.width / 2, 0))

background("山_山道.jpg", 2.0) -- 带有过渡时间的背景切换

_ "湿冷的雨打在我身上，打在眼前的山间密林中，雨声淅沥而柔和。\n开始漂浮的雾霭，在真夜中到处冒着白烟。"
_ "眼前的一切让我陷入有如梦境的非现实感。"
我 "（等等，或许，这就是一个<#ff0000>梦<font>吧。）"
_ "我在雨夜的山林中漫无目的地徘徊 ……"

花恋.表情 = "花恋_表情_悲.png"
花恋.name = "少女"
花恋:show()
花恋:opacity(0)
花恋:runAction(fadeTo { 1.0, 0.25 * 255 })
_ "不知何时，眼前出现了一位看似制服打扮的人影。\n朦朦胧胧的我不太敢肯定，不过从对方的身形来看大概是高中生吧，她身上穿着裙子。"
花恋:runAction(fadeTo { 1.0, 0.5 * 255 })
_ "制服也是熟悉的。没有看错的话，就是我所在高中的女生制服。"
花恋:runAction(fadeTo { 1.0, 0.75 * 255 })
_ "逐渐的，少女的面容清晰起来 ……"
花恋:runAction(fadeTo { 1.0, 1.0 * 255 })
_ "待至看清少女的刹那，胸口像是被勒紧似的发疼。眼眶也湿润起来。\n我认识她，我怎么可能不知晓她？！她对我来说是那样重要的人！！！"
util.shakeScreen(0.5, 10, 10)
我 "（啊…呼啊…呼啊……）"
_ "然而，我却想不起她的名字，以及任何关于她的事。我的记忆像是被<#ff0000>生生<font>的挖掉了一块。"
花恋.表情 = "花恋_表情_寂.png"
_ "………………"
_ "……………"
_ "少女哀怨的望着我，想说什么，却欲言又止。\n最终，她轻声呢喃般的话语传入我耳中。"

花恋 "我的事就请你不要自责，这一切都是我自己的选择。"
花恋 "呐，在名为「未来」的时光里，一定要幸福哦。"
花恋.image = "花恋_制服1_抬手.png"
花恋.表情 = "花恋_表情_悲.png"
花恋 "sound/voice_karen_01.ogg" "可是，真的真的好想见你啊。" -- 语音+文字的方式
花恋.image = "" -- 恢复默认立绘

sound("sound/se_heart.ogg", 2, 0.3, true)
花恋:runAction(fadeTo { 1.0, 0.75 * 255 })
_ "我竭尽全力地搜索着记忆，这．个．少．女．到底是谁，可无论如何都想不出分毫。"
_ "我越是尽力思索，头就越发疼痛，就连意识也模糊起来。"
sound("sound/se_heart.ogg", 3, 0.3, true)
_ "喉咙深处开始有想吐的感觉。\n随着心脏每次跳动，就像被刺到一样地头痛。\n头痛欲裂。"
花恋:fadeOut(5.0)
_ "少女也似乎渐渐消失了。"
我 "（啊…呼啊…呼啊……）"
我 "（为什么？！为什么啊？！……）"
sound("sound/se_heart.ogg", 4, 0.3, true)
util.shakeScreen(2.0, 50, 50)
我 "（<40>啊啊啊啊啊啊啊！！！！！！！<font>）"
_ "………………"
_ "……………"

storyJumpTo("chapter_1_2", "fade", 4.0, cc.WHITE)