background "教室_日.jpg"
bgm "bgm/bgm01.mp3"

-- heroine 3, 桃濑 舞
舞 = Character {
    image = "live2d/Hiyori.model3.json", -- live2d模型需要.model3.json结尾, 以和spine模型区分
    name = "舞",
    x = 920,
    y = 174,
    scale = 3.3,
    好感度 = 50
}

-- 利用 cocos2d-x Actions 演出
novel._uiLayer:hide()
novel._background:position(video.center.x, 0):anchor(0.5, 0)
wait(2.0)
novel._background:runAction(moveBy { 2.5, 0, video.height - novel._background:getBoundingBox().height }) -- 计算以适应各种比例屏幕
wait(2.5)
novel._uiLayer:show()
wait(0.5)

local dayType = random(3) -- 对于可能影响游戏进程的随机数, 必须使用本引擎提供的random函数
todaystr = ({ "二十五", "二十六", "二十七" })[dayType] -- 由于模板字符串'${expression}'其表达式不支持局部变量, 使用临时的全局变量
_ "二零一六年的七月${todaystr}日。"
todaystr = nil

require "storyScript/ui/nameInputUI.lua" -- 自定义的姓名输入UI
local results = NameInput { firstName = "国崎", lastName = "勇太" }
我.firstName = results.firstName
我.lastName = results.lastName

_ "现在正值高中二年级的暑假，我<#ff0000>${我.firstName .. \" \" .. 我.lastName}<font>却坐在教室内，并且刚刚从一个讨厌的<#ff0000>噩梦<font>中醒来。"
_ "将桌上的笔记本摊开，手撑着脸颊，表情呆滞地看着窗外景色。"
_ "自这座位于山丘上的学校可将下方的城镇景色尽收眼底：位于盆地内的乡下小镇，视野当中绿意的比例更胜水泥建筑的灰色，到了夏天，那翠绿便越发盎然。"
_ "在这炎热的正午时分，阳光烧灼着地面，学校回荡着自操场或体育馆传来的运动社团的吆喝声，仿佛在向所有人宣告自己正挥洒着青春。"
我 "（青春根本没有价值可言，为青春挥洒汗水到最后只是徒然。）"
我 "（说穿了，青春不过是逃避现实。）"
_ "因为啊，我就是一度逃避现实才会落得现在的窘境。"
sound("sound/chalkboard.ogg", 1, 0.5, true)
_ "就在这时，我听见粉笔敲在黑板上的声音。"
_ "转头一看，教师正在讲台上授课，在黑板上接连写下文字。\n粉笔随着固定节奏敲打黑板，不知为何那声音比运动社团的吆喝声响亮。"
_ "教室内坐在座位上的学生不多，而且绝大多数的学生并非忙着做笔记，而是直盯着时钟。再过三分钟、再过两分钟、还剩一分钟。当规定的时间越来越靠近，心跳也跟着转为急促。\n我不由得咽下口中唾液。"
_ "最后————"
sound("sound/class_chime.ogg", 2)
_ "盖过一切杂音的下课铃声在校内响起。"
sound("", 1, 1.0) -- 黑板音(channel 1) fade out
_ "同时教师也已经写完板书，转身面对学生。"
local 教师 = Character { name = "教师" }
教师 "那么就到这里结束。起立！"
_ "学生们迫不及待自座位上站起，在对老师行礼后气氛瞬间沸腾，仿佛在说我们的暑假从这一刻真正开始啦。"
sound("", 2, 2.0)
_ "<#ff0000>暑修<font>到此结束。"
novel._background:runAction(fadeTo { 1.0, 255 * 0.4 })
wait(1.0)
_ "根据学校规定，接受补考也未达一定分数的学生，就必须在暑假期间到学校暑修。"
_ "照理来说，学生只要认真向学就不会和这规则扯上关系，但我之前在棒球队时把读书抛在脑后，因此落得现在必须暑修的下场。"
_ "过去可能不当一回事，但正因为退出了棒球队，让我更加切身体会到早知如此，与其把青春献给积弱不振的棒球校队，更该把精力用在读书以避免暑修。"
_ "不过这样的后悔就到今天为止。"
_ "暑修结束了。"
novel._background:runAction(fadeTo { 1.0, 255 })
wait(1.0)
background("校园_日.jpg", 2.0)

_ "我冲出教室打算先回家。一路上不时与来学校参加社团活动的同学和老师们擦身而过，来到教学楼旁脚踏车停车场。"
_ "在我牵出脚踏车时，突然听见有人喊自己的名字。耳熟的女学生的声音。"
舞.name = "女生"
舞 "${我.lastName}君~~~~"
舞:show()
舞:setIsAutoIdle(false)
舞:startMotion("Smile", 0, 3)
舞:opacity(0):rotation(-12)
舞:setPositionX(video.width + 120)
舞:runAction(sequence {
    delay { 2.0 }, -- skip the motion's first 2 seconds
    fadeIn { 0.4 },
    moveBy { 1.0, -200, 0 },
    delay { 8.0 - 1.0 - 0.4 - 2.0 } -- match the duration of the motion
})
_ "我立刻就明白那是谁，却没见到那人的身影。\n左顾右盼之下，终于还是让我找到了。"
_ "位于脚踏车停车场旁的教学楼，那个人正从教学楼的侧面探出头来望着我。"
wait(function() return 舞:getNumberOfRunningActions() == 0 end) -- wait until prev action/motion done
舞:runAction(spawn {
    rotateTo { 0.5, 0 }, -- from -12 to 0
    moveBy { 1.5, -(video.width / 2 - 80), 0 },
    sequence {
        delay { 0.4 },
        orbitCamera { 0.5, 1, 0, 0, 180, 0, 0 },
        delay { 0.6 },
        call { function() 舞:startMotion("Debut", 0, 3) end },
        delay { 5.0 } -- match the duration of the motion
    }
})
_ "她在看到被我发现后，如同小兔子般欢快地跑了过来。"
_ "<#ff0000>桃濑 舞<font>。对我而言，她是小一岁的青梅竹马，有如自己的妹妹。不过自从升上高中，开始流露莫名的女人味，绑成马尾的头发下时隐时现的后颈不时提醒着她确实是异性，这甚至让我有几分不自在。"
wait(function() return 舞:getNumberOfRunningActions() == 0 end)
舞.name = "舞"
舞:setLipSyncValue(0)
wait(0.2)
舞:startMotion("Idle", 0, 3)
舞 "${我.lastName}，你要回去了喔？棒球队呢？"
舞:startMotion("TurnSmile", 0, 3)
舞:runAction(delay { 4.0 }) -- for measuring the live2d motion
我 "我之前不是说过我退队了吗？"
舞 "啊~~好像是有这么一回事喔。\n啊哈哈，我忘了耶。"
wait(function() return 舞:getNumberOfRunningActions() == 0 end)
_ "少女愉快地笑着。"
wait(1.0)
我 "（她好可爱。）"
我 "话说，你还在学校做什么啊？"
舞 "这还用问，当然是同好会——<#ff0000>传说研究会<font>的活动啊。"
我 "噢，那个莫名其妙的社团喔。"
舞:startMotion("Surprise", 1, 3)
舞 "什么莫名其妙，真是失礼。<img icon_angry.png>\n历史可是比棒球队还悠久喔。"
我 "那具体来说都在做什么啊？"
舞:startMotion("Idle", 0, 3)
舞 "比方说调查从地方到全国规模的各种民俗啊，看，像是读这类的书。"
_ "小舞手中拿着本老旧的书籍。看来似乎是文集。从纸张的状况来看，大概是过去传说研究会的成员制作的刊物吧。"
舞 "${我.lastName}也有兴趣吧？"
if Choice { "确实……不能说没有。", "鬼才会有。" } == 1 then
    舞.好感度 = 舞.好感度 + 20
    我 "确实……不能说没有。"
    _ "我回想起今天在教室里做的那个<#ff0000>怪梦<font>。"
    我 "如果有机会的话，我也想多了解看看。"
    舞:startMotion("Happy", 0, 3)
    舞 "果然很好奇对吧~~……比如，这一段你来看一下。"
    _ "小舞兴致勃勃把她手上的文集翻开递过来，我大致浏览过去，上头写着某地的怪谈故事。"
else
    舞.好感度 = 舞.好感度 - 10
    我 "鬼才会有。"
    舞:startMotion("Surprise", 1, 3)
    舞 "咦咦咦~~~明明就很有意思耶~~\n……来，这一段你看一下嘛。"
    _ "青梅竹马将摊开的书塞过来强迫给我看。我不大情愿地大致浏览，上头写着某地的怪谈故事。"
end
舞:startMotion("Idle", 1, 3)
_ "「丑时三刻，深山里的某个古老隧道会变成通往异世界的入口，经过的人一旦被吞噬便有去无回。」"
_ "内容看上去相当无厘头，这种事在现实中根本不可能。"
我 "这哪是什么民间传说，根本是超自然现象吧。"
舞 "包含这种在内，广义来说也是种传说喔。\n不过这算是我个人的见解啦。"

bgm("", 4.0)
background("black.png", 4.0)
_ "<font 40 italic>未 完 待 续<font>"

-- 返回主菜单
loadScene("sceneMainMenu", nil, "fade", const.LOGO_TRANSITION_TIME, cc.WHITE)